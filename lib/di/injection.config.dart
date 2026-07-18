// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:bet_out_app/api/mappers/spin_result_mapper.dart' as _i36;
import 'package:bet_out_app/api/mappers/welcome_mapper.dart' as _i1041;
import 'package:bet_out_app/api/providers/simulator_provider.dart' as _i188;
import 'package:bet_out_app/api/providers/welcome_provider.dart' as _i225;
import 'package:bet_out_app/core/services/authenticated_http_client.dart'
    as _i391;
import 'package:bet_out_app/core/services/navigation_service.dart' as _i998;
import 'package:bet_out_app/core/services/token_storage_service.dart' as _i886;
import 'package:bet_out_app/di/http_module.dart' as _i813;
import 'package:bet_out_app/features/home/domain/get_welcome_message_usecase.dart'
    as _i4;
import 'package:bet_out_app/features/home/presentation/bloc/home_bloc.dart'
    as _i1044;
import 'package:bet_out_app/features/simulator/domain/get_simulator_stats_usecase.dart'
    as _i630;
import 'package:bet_out_app/features/simulator/domain/reset_simulator_usecase.dart'
    as _i400;
import 'package:bet_out_app/features/simulator/domain/spin_simulator_usecase.dart'
    as _i107;
import 'package:bet_out_app/features/simulator/presentation/bloc/simulator_bloc.dart'
    as _i783;
import 'package:get_it/get_it.dart' as _i174;
import 'package:http/http.dart' as _i519;
import 'package:injectable/injectable.dart' as _i526;
import 'package:shared_preferences/shared_preferences.dart' as _i460;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final httpModule = _$HttpModule();
    gh.factory<_i36.SpinResultMapper>(() => _i36.SpinResultMapper());
    gh.factory<_i1041.WelcomeMapper>(() => _i1041.WelcomeMapper());
    gh.lazySingleton<_i998.NavigationService>(() => _i998.NavigationService());
    gh.lazySingleton<_i519.Client>(() => httpModule.httpClient);
    await gh.lazySingletonAsync<_i460.SharedPreferences>(
      () => httpModule.sharedPreferences,
      preResolve: true,
    );
    gh.factory<_i188.SimulatorProvider>(
      () => _i188.SimulatorProvider(gh<_i460.SharedPreferences>()),
    );
    gh.factory<_i225.WelcomeProvider>(
      () => _i225.WelcomeProvider(gh<_i460.SharedPreferences>()),
    );
    gh.lazySingleton<_i886.TokenStorageService>(
      () => _i886.TokenStorageService(gh<_i460.SharedPreferences>()),
    );
    gh.factory<_i4.GetWelcomeMessageUsecase>(
      () => _i4.GetWelcomeMessageUsecaseImpl(
        gh<_i225.WelcomeProvider>(),
        gh<_i1041.WelcomeMapper>(),
      ),
    );
    gh.factory<_i400.ResetSimulatorUsecase>(
      () => _i400.ResetSimulatorUsecaseImpl(
        gh<_i188.SimulatorProvider>(),
        gh<_i36.SpinResultMapper>(),
      ),
    );
    gh.factory<_i630.GetSimulatorStatsUsecase>(
      () => _i630.GetSimulatorStatsUsecaseImpl(
        gh<_i188.SimulatorProvider>(),
        gh<_i36.SpinResultMapper>(),
      ),
    );
    gh.factory<_i1044.HomeBloc>(
      () => _i1044.HomeBloc(gh<_i4.GetWelcomeMessageUsecase>()),
    );
    gh.lazySingleton<_i391.AuthenticatedHttpClient>(
      () => _i391.AuthenticatedHttpClient(
        gh<_i519.Client>(),
        gh<_i886.TokenStorageService>(),
        gh<_i998.NavigationService>(),
      ),
    );
    gh.factory<_i107.SpinSimulatorUsecase>(
      () => _i107.SpinSimulatorUsecaseImpl(
        gh<_i188.SimulatorProvider>(),
        gh<_i36.SpinResultMapper>(),
      ),
    );
    gh.factory<_i783.SimulatorBloc>(
      () => _i783.SimulatorBloc(
        gh<_i107.SpinSimulatorUsecase>(),
        gh<_i630.GetSimulatorStatsUsecase>(),
        gh<_i400.ResetSimulatorUsecase>(),
      ),
    );
    return this;
  }
}

class _$HttpModule extends _i813.HttpModule {}
