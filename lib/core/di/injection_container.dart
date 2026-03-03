import 'package:get_it/get_it.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../network/network_info.dart';
import '../network/api_client.dart';
import '../../features/detection/data/datasources/detection_local_datasource.dart';
import '../../features/detection/data/datasources/model_datasource.dart';
import '../../features/detection/data/repositories/detection_repository_impl.dart';
import '../../features/detection/domain/repositories/detection_repository.dart';
import '../../features/detection/domain/usecases/detect_species_usecase.dart';
import '../../features/history/data/datasources/history_local_datasource.dart';
import '../../features/history/data/repositories/history_repository_impl.dart';
import '../../features/history/domain/repositories/history_repository.dart';
import '../../features/history/domain/usecases/get_history_usecase.dart';
import '../../features/history/domain/usecases/save_detection_usecase.dart';
import '../../features/history/domain/usecases/delete_detection_usecase.dart';
import '../../features/history/domain/usecases/clear_history_usecase.dart';
import '../../features/audio_detection/data/datasources/audio_local_datasource.dart';
import '../../features/audio_detection/data/repositories/audio_detection_repository_impl.dart';
import '../../features/audio_detection/domain/repositories/audio_detection_repository.dart';
import '../../features/audio_detection/domain/usecases/detect_bird_sound_usecase.dart';
import '../../features/share/domain/share_service.dart';

final GetIt sl = GetIt.instance;

/// Initialize all dependencies
Future<void> initDependencies() async {
  // Initialize Hive
  await Hive.initFlutter();
  
  // Core
  await _initCore();
  
  // Features
  await _initDetectionFeature();
  await _initHistoryFeature();
  await _initAudioDetectionFeature();
  await _initShareFeature();
}

Future<void> _initCore() async {
  // Network
  sl.registerLazySingleton<Connectivity>(() => Connectivity());
  sl.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(connectivity: sl()),
  );
  sl.registerLazySingleton<ApiClient>(() => ApiClient());
}

Future<void> _initDetectionFeature() async {
  // Datasources
  sl.registerLazySingleton<ModelDatasource>(
    () => ModelDatasourceImpl(),
  );
  sl.registerLazySingleton<DetectionLocalDatasource>(
    () => DetectionLocalDatasourceImpl(),
  );
  
  // Repository
  sl.registerLazySingleton<DetectionRepository>(
    () => DetectionRepositoryImpl(
      modelDatasource: sl(),
      localDatasource: sl(),
    ),
  );
  
  // Usecases
  sl.registerLazySingleton(() => DetectSpeciesUsecase(sl()));
}

Future<void> _initHistoryFeature() async {
  // Datasources
  sl.registerLazySingleton<HistoryLocalDatasource>(
    () => HistoryLocalDatasourceImpl(),
  );
  
  // Repository
  sl.registerLazySingleton<HistoryRepository>(
    () => HistoryRepositoryImpl(localDatasource: sl()),
  );
  
  // Usecases
  sl.registerLazySingleton(() => GetHistoryUsecase(sl()));
  sl.registerLazySingleton(() => SaveDetectionUsecase(sl()));
  sl.registerLazySingleton(() => DeleteDetectionUsecase(sl()));
  sl.registerLazySingleton(() => ClearHistoryUsecase(sl()));
}

Future<void> _initAudioDetectionFeature() async {
  // Datasources
  sl.registerLazySingleton<AudioLocalDatasource>(
    () => AudioLocalDatasourceImpl(),
  );
  
  // Repository
  sl.registerLazySingleton<AudioDetectionRepository>(
    () => AudioDetectionRepositoryImpl(
      audioDatasource: sl(),
      modelDatasource: sl(),
    ),
  );
  
  // Usecases
  sl.registerLazySingleton(() => DetectBirdSoundUsecase(sl()));
}

Future<void> _initShareFeature() async {
  sl.registerLazySingleton<ShareService>(() => ShareServiceImpl());
}
