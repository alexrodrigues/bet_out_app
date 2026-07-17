import 'package:equatable/equatable.dart';

class WelcomeViewObject extends Equatable {
  const WelcomeViewObject({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
