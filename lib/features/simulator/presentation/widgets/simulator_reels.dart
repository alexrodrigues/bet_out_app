import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/utils/asset_paths.dart';

typedef ReelSymbols = List<int>;

/// Casino-style staggered reel animation over [AssetPaths.gameBoard].
class SimulatorReels extends StatefulWidget {
  const SimulatorReels({
    super.key,
    required this.targetSymbols,
    required this.isSpinning,
    this.onSpinComplete,
  });

  /// Three stop indexes into [AssetPaths.reelSymbols], or null for idle.
  final ReelSymbols? targetSymbols;
  final bool isSpinning;
  final VoidCallback? onSpinComplete;

  @override
  State<SimulatorReels> createState() => _SimulatorReelsState();
}

class _SimulatorReelsState extends State<SimulatorReels>
    with TickerProviderStateMixin {
  static const _stripLength = 20;
  static const _visibleRows = 3;
  static const _durations = [
    Duration(milliseconds: 1200),
    Duration(milliseconds: 1600),
    Duration(milliseconds: 2000),
  ];

  /// Gold 3×3 playfield inside [AssetPaths.gameBoard] (1024×1024), measured
  /// from the black cell regions as fractions of the painted image.
  static const _gridLeft = 0.1064;
  static const _gridTop = 0.1045;
  static const _gridWidth = 0.7852;
  static const _gridHeight = 0.7197;

  late final List<AnimationController> _controllers;
  late final List<Animation<double>> _animations;
  late List<List<int>> _strips;
  int _completedReels = 0;
  bool _listening = false;
  int _spinGeneration = 0;

  ui.Image? _boardImage;
  double? _boardAspect;

  @override
  void initState() {
    super.initState();
    _strips = List.generate(3, (_) => _buildIdleStrip());
    _controllers = List.generate(3, (i) {
      return AnimationController(vsync: this, duration: _durations[i]);
    });
    _animations = _controllers.map((c) {
      return CurvedAnimation(parent: c, curve: Curves.easeOutCubic);
    }).toList();
    _loadBoardSize();
  }

  Future<void> _loadBoardSize() async {
    final data = await rootBundle.load(AssetPaths.gameBoard);
    final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    final frame = await codec.getNextFrame();
    if (!mounted) return;
    setState(() {
      _boardImage = frame.image;
      _boardAspect = frame.image.width / frame.image.height;
    });
  }

  @override
  void didUpdateWidget(covariant SimulatorReels oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSpinning &&
        !oldWidget.isSpinning &&
        widget.targetSymbols != null) {
      _startSpin(widget.targetSymbols!);
    }
  }

  List<int> _buildIdleStrip() {
    final symbols = AssetPaths.reelSymbols.length;
    return List<int>.generate(_stripLength, (i) => i % symbols);
  }

  List<int> _buildSpinStrip(int targetIndex) {
    final symbols = AssetPaths.reelSymbols.length;
    final strip = List<int>.generate(
      _stripLength,
      (i) => (targetIndex + i) % symbols,
    );
    // Place target in the middle row of the final visible window.
    final mid = _stripLength - 2;
    strip[mid - 1] = (targetIndex + 1) % symbols;
    strip[mid] = targetIndex;
    strip[mid + 1] = (targetIndex + 2) % symbols;
    return strip;
  }

  Future<void> _startSpin(List<int> targets) async {
    final generation = ++_spinGeneration;
    _completedReels = 0;
    _listening = true;
    for (var i = 0; i < 3; i++) {
      _strips[i] = _buildSpinStrip(targets[i]);
      _controllers[i].reset();
    }
    setState(() {});

    for (var i = 0; i < 3; i++) {
      _controllers[i].forward().whenComplete(() {
        if (!_listening || generation != _spinGeneration) return;
        _completedReels++;
        if (_completedReels >= 3) {
          _listening = false;
          widget.onSpinComplete?.call();
        }
      });
    }
  }

  /// Painted bounds of an image with [BoxFit.contain] inside [boxSize].
  Rect _containRect(Size boxSize, double aspect) {
    final boxAspect = boxSize.width / boxSize.height;
    late final double width;
    late final double height;
    if (boxAspect > aspect) {
      height = boxSize.height;
      width = height * aspect;
    } else {
      width = boxSize.width;
      height = width / aspect;
    }
    return Rect.fromLTWH(
      (boxSize.width - width) / 2,
      (boxSize.height - height) / 2,
      width,
      height,
    );
  }

  @override
  void dispose() {
    _listening = false;
    for (final c in _controllers) {
      c.dispose();
    }
    _boardImage?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final boardSize = width.clamp(0.0, 420.0);
        final boxSize = Size(boardSize, boardSize);
        final aspect = _boardAspect ?? 1.0;
        final painted = _containRect(boxSize, aspect);

        final gridRect = Rect.fromLTWH(
          painted.left + painted.width * _gridLeft,
          painted.top + painted.height * _gridTop,
          painted.width * _gridWidth,
          painted.height * _gridHeight,
        );

        return SizedBox(
          width: boardSize,
          height: boardSize,
          child: Stack(
            children: [
              Positioned.fromRect(
                rect: painted,
                child: Image.asset(
                  AssetPaths.gameBoard,
                  fit: BoxFit.fill,
                  width: painted.width,
                  height: painted.height,
                ),
              ),
              Positioned.fromRect(
                rect: gridRect,
                child: Row(
                  children: List.generate(3, (col) {
                    return Expanded(
                      child: _ReelColumn(
                        animation: _animations[col],
                        strip: _strips[col],
                        visibleRows: _visibleRows,
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ReelColumn extends StatelessWidget {
  const _ReelColumn({
    required this.animation,
    required this.strip,
    required this.visibleRows,
  });

  final Animation<double> animation;
  final List<int> strip;
  final int visibleRows;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final cellHeight = constraints.maxHeight / visibleRows;
            final maxOffset = (strip.length - visibleRows) * cellHeight;
            final offset = animation.value * maxOffset;

            return ClipRect(
              child: OverflowBox(
                alignment: Alignment.topCenter,
                maxHeight: double.infinity,
                child: Transform.translate(
                  offset: Offset(0, -offset),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (final symbolIndex in strip)
                        SizedBox(
                          height: cellHeight,
                          width: constraints.maxWidth,
                          child: Padding(
                            padding: const EdgeInsets.all(1),
                            child: Image.asset(
                              AssetPaths.reelSymbols[symbolIndex],
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
