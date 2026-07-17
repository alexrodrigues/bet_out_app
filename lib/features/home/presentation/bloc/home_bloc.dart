import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../domain/get_welcome_message_usecase.dart';

part 'home_event.dart';
part 'home_state.dart';

@injectable
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc(this._getWelcomeMessage) : super(const HomeInitial()) {
    on<HomeStarted>(_onStarted);
  }

  final GetWelcomeMessageUsecase _getWelcomeMessage;

  Future<void> _onStarted(
    HomeStarted event,
    Emitter<HomeState> emit,
  ) async {
    emit(const HomeLoading());
    try {
      final welcome = await _getWelcomeMessage.invoke();
      emit(HomeLoaded(message: welcome.message));
    } catch (_) {
      emit(const HomeFailure(message: 'Unable to load welcome message'));
    }
  }
}
