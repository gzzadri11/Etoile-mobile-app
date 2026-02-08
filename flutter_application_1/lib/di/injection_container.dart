import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../features/auth/presentation/bloc/auth_bloc.dart';
import '../features/feed/data/repositories/feed_repository.dart';
import '../features/feed/presentation/bloc/feed_bloc.dart';
import '../features/messages/data/repositories/conversation_repository.dart';
import '../features/messages/data/repositories/message_repository.dart';
import '../features/messages/presentation/bloc/message_bloc.dart';
import '../features/profile/data/repositories/profile_repository.dart';
import '../features/profile/presentation/bloc/profile_bloc.dart';
import '../features/video/data/repositories/video_repository.dart';
import '../features/video/presentation/bloc/video_bloc.dart';

/// Service locator instance
final GetIt sl = GetIt.instance;

/// Initialize all dependencies
Future<void> init() async {
  // ============================================
  // EXTERNAL DEPENDENCIES
  // ============================================

  // Supabase client
  sl.registerLazySingleton<SupabaseClient>(
    () => Supabase.instance.client,
  );

  // ============================================
  // REPOSITORIES
  // ============================================

  // Profile repository
  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepository(supabaseClient: sl()),
  );

  // Video repository
  sl.registerLazySingleton<VideoRepository>(
    () => VideoRepository(supabaseClient: sl()),
  );

  // Feed repository
  sl.registerLazySingleton<FeedRepository>(
    () => FeedRepository(supabaseClient: sl()),
  );

  // Conversation repository
  sl.registerLazySingleton<ConversationRepository>(
    () => ConversationRepository(supabaseClient: sl()),
  );

  // Message repository
  sl.registerLazySingleton<MessageRepository>(
    () => MessageRepository(supabaseClient: sl()),
  );

  // ============================================
  // FEATURES - MESSAGES
  // ============================================

  // MessageBloc
  sl.registerFactory<MessageBloc>(
    () => MessageBloc(messageRepository: sl()),
  );

  // ============================================
  // FEATURES - AUTH
  // ============================================

  // AuthBloc - SINGLETON pour maintenir un etat coherent dans toute l'app
  sl.registerLazySingleton<AuthBloc>(
    () => AuthBloc(supabaseClient: sl()),
  );

  // ============================================
  // FEATURES - PROFILE
  // ============================================

  // ProfileBloc
  sl.registerFactory<ProfileBloc>(
    () => ProfileBloc(profileRepository: sl()),
  );

  // ============================================
  // FEATURES - VIDEO
  // ============================================

  // VideoBloc
  sl.registerFactory<VideoBloc>(
    () => VideoBloc(videoRepository: sl()),
  );

  // ============================================
  // FEATURES - FEED
  // ============================================

  // FeedBloc
  sl.registerFactory<FeedBloc>(
    () => FeedBloc(feedRepository: sl()),
  );
}
