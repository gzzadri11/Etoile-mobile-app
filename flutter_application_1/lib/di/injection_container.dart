import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/services/push_notification_service.dart';
import '../core/services/stripe_service.dart';
import '../core/services/supabase_service.dart';
import '../core/services/video_upload_service.dart';
import '../features/admin/data/repositories/admin_repository.dart';
import '../features/messages/data/repositories/block_repository.dart';
import '../features/report/data/repositories/report_repository.dart';
import '../features/auth/presentation/bloc/auth_bloc.dart';
import '../features/feed/data/repositories/feed_repository.dart';
import '../features/feed/presentation/bloc/feed_bloc.dart';
import '../features/messages/data/repositories/conversation_repository.dart';
import '../features/messages/data/repositories/message_repository.dart';
import '../features/messages/presentation/bloc/message_bloc.dart';
import '../features/payment/data/repositories/payment_repository.dart';
import '../features/profile/data/repositories/profile_repository.dart';
import '../features/profile/data/repositories/stats_repository.dart';
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
  // SERVICES
  // ============================================

  // Supabase Service - centralized access to Supabase features
  sl.registerLazySingleton<SupabaseService>(
    () => SupabaseService(client: sl()),
  );

  // Stripe Service - payment processing
  sl.registerLazySingleton<StripeService>(
    () => StripeService(supabaseService: sl()),
  );

  // Push Notification Service - SINGLETON
  sl.registerLazySingleton<PushNotificationService>(
    () => PushNotificationService(supabaseClient: sl()),
  );

  // Video Upload Service - SINGLETON
  sl.registerLazySingleton<VideoUploadService>(
    () => VideoUploadService(supabaseClient: sl()),
  );

  // ============================================
  // REPOSITORIES
  // ============================================

  // Profile repository
  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepository(supabaseClient: sl()),
  );

  // Stats repository
  sl.registerLazySingleton<StatsRepository>(
    () => StatsRepository(supabaseClient: sl()),
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

  // Payment repository
  sl.registerLazySingleton<PaymentRepository>(
    () => PaymentRepository(supabaseClient: sl(), stripeService: sl()),
  );

  // Admin repository
  sl.registerLazySingleton<AdminRepository>(
    () => AdminRepository(supabaseClient: sl()),
  );

  // Report repository
  sl.registerLazySingleton<ReportRepository>(
    () => ReportRepository(supabaseClient: sl()),
  );

  // Block repository
  sl.registerLazySingleton<BlockRepository>(
    () => BlockRepository(supabaseClient: sl()),
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
    () => AuthBloc(supabaseClient: sl(), profileRepository: sl()),
  );

  // ============================================
  // FEATURES - PROFILE
  // ============================================

  // ProfileBloc
  sl.registerFactory<ProfileBloc>(
    () => ProfileBloc(
      profileRepository: sl(),
      videoRepository: sl(),
      statsRepository: sl(),
      supabaseClient: sl(),
    ),
  );

  // ============================================
  // FEATURES - VIDEO
  // ============================================

  // VideoBloc
  sl.registerFactory<VideoBloc>(
    () => VideoBloc(videoRepository: sl(), uploadService: sl()),
  );

  // ============================================
  // FEATURES - FEED
  // ============================================

  // FeedBloc
  sl.registerFactory<FeedBloc>(
    () => FeedBloc(feedRepository: sl(), blockRepository: sl()),
  );
}
