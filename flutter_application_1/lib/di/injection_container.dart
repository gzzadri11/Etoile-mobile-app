/// Injection de dependances — enregistre toutes les instances dans GetIt.
///
/// Convention :
/// - **LazySingleton** : une seule instance partagee (repositories, services,
///   AuthBloc). Utilise quand l'etat doit etre coherent dans toute l'app.
/// - **Factory** : nouvelle instance a chaque appel (ProfileBloc, FeedBloc).
///   Utilise quand chaque ecran a besoin de son propre etat independant.
///
/// Acces : `GetIt.I<ProfileRepository>()` ou via l'alias `sl<ProfileRepository>()`
library;

import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/services/push_notification_service.dart';
import '../core/services/supabase_service.dart';
import '../core/services/video_upload_service.dart';
import '../features/admin/data/repositories/admin_repository.dart';
import '../features/applications/data/repositories/application_repository.dart';
import '../features/auth/presentation/bloc/auth_bloc.dart';
import '../features/feed/data/repositories/feed_repository.dart';
import '../features/feed/presentation/bloc/feed_bloc.dart';
import '../features/messages/data/repositories/block_repository.dart';
import '../features/messages/data/repositories/conversation_repository.dart';
import '../features/messages/data/repositories/message_repository.dart';
import '../features/messages/presentation/bloc/message_bloc.dart';
import '../features/profile/data/repositories/profile_repository.dart';
import '../features/profile/data/repositories/stats_repository.dart';
import '../features/profile/presentation/bloc/profile_bloc.dart';
import '../features/report/data/repositories/report_repository.dart';
import '../features/video/data/repositories/video_repository.dart';
import '../features/video/presentation/bloc/video_bloc.dart';

final GetIt sl = GetIt.instance;

Future<void> init() async {
  // --- Dependances externes ---
  sl.registerLazySingleton<SupabaseClient>(
    () => Supabase.instance.client,
  );

  // --- Services ---
  sl.registerLazySingleton<SupabaseService>(
    () => SupabaseService(client: sl()),
  );
  sl.registerLazySingleton<PushNotificationService>(
    () => PushNotificationService(supabaseClient: sl()),
  );
  sl.registerLazySingleton<VideoUploadService>(
    () => VideoUploadService(supabaseClient: sl()),
  );
  // --- Repositories (singletons : une seule source de verite par domaine) ---
  sl.registerLazySingleton(() => ProfileRepository(supabaseClient: sl()));
  sl.registerLazySingleton(() => StatsRepository(supabaseClient: sl()));
  sl.registerLazySingleton(() => VideoRepository(supabaseClient: sl()));
  sl.registerLazySingleton(() => FeedRepository(supabaseClient: sl()));
  sl.registerLazySingleton(() => ConversationRepository(supabaseClient: sl()));
  sl.registerLazySingleton(() => MessageRepository(supabaseClient: sl()));
  sl.registerLazySingleton(() => BlockRepository(supabaseClient: sl()));
  sl.registerLazySingleton(() => ReportRepository(supabaseClient: sl()));
  sl.registerLazySingleton(() => ApplicationRepository(supabaseClient: sl()));
  sl.registerLazySingleton(() => AdminRepository(supabaseClient: sl()));

  // --- BLoCs ---

  // AuthBloc : singleton car l'etat d'authentification est global.
  // Tous les ecrans observent la meme instance.
  sl.registerLazySingleton(
    () => AuthBloc(supabaseClient: sl(), profileRepository: sl()),
  );

  // Les autres BLoCs sont des factories : chaque ecran cree sa propre
  // instance pour eviter les conflits d'etat entre navigations.
  sl.registerFactory(
    () => ProfileBloc(
      profileRepository: sl(),
      videoRepository: sl(),
      statsRepository: sl(),
      supabaseClient: sl(),
    ),
  );
  sl.registerFactory(
    () => VideoBloc(videoRepository: sl(), uploadService: sl()),
  );
  sl.registerFactory(
    () => MessageBloc(messageRepository: sl()),
  );
  sl.registerFactory(
    () => FeedBloc(
      feedRepository: sl(),
      blockRepository: sl(),
      applicationRepository: sl(),
    ),
  );
}
