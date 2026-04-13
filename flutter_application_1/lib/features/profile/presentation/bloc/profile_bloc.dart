library;

/// BLoC de gestion du profil utilisateur (chercheur ou recruteur).
///
/// Charge le profil depuis Supabase, gere les mises a jour,
/// la completude et le chargement des statistiques video.

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/models/seeker_profile_model.dart';
import '../../data/models/video_stats.dart';
import '../../../../core/router/app_router.dart';
import '../../data/repositories/profile_repository.dart';
import '../../data/repositories/stats_repository.dart';
import '../../../video/data/models/video_model.dart';
import '../../../video/data/repositories/video_repository.dart';

part 'profile_event.dart';
part 'profile_state.dart';

/// BLoC for managing user profile state
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileRepository _profileRepository;
  final VideoRepository _videoRepository;
  final StatsRepository _statsRepository;
  final SupabaseClient _supabaseClient;

  ProfileBloc({
    required ProfileRepository profileRepository,
    required VideoRepository videoRepository,
    required StatsRepository statsRepository,
    required SupabaseClient supabaseClient,
  })  : _profileRepository = profileRepository,
        _videoRepository = videoRepository,
        _statsRepository = statsRepository,
        _supabaseClient = supabaseClient,
        super(const ProfileInitial()) {
    on<ProfileLoadRequested>(_onLoadRequested);
    on<ProfileUpdateRequested>(_onUpdateRequested);
    on<ProfileRefreshRequested>(_onRefreshRequested);
  }

  /// Load profile based on user role
  Future<void> _onLoadRequested(
    ProfileLoadRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileLoading());

    try {
      final role = await _profileRepository.getUserRole();

      if (role == 'seeker') {
        final profile = await _profileRepository.getSeekerProfile();
        final categories = await _profileRepository.getCategories();
        final stats = await _statsRepository.getStats();
        Video? presentationVideo;
        try {
          presentationVideo = await _videoRepository.getMyPresentationVideo();
        } catch (_) {}

        if (profile != null) {
          AppRouter.updateProfileComplete(profile.completionPercentage >= 100);
          emit(SeekerProfileLoaded(
            profile: profile,
            categories: categories,
            isPremium: false,
            stats: stats,
            presentationVideo: presentationVideo,
          ));
        } else {
          emit(const ProfileError(message: 'Profil non trouve'));
        }
      } else if (role == 'admin') {
        final userId = _profileRepository.currentUserId ?? '';
        final email = _supabaseClient.auth.currentUser?.email ?? '';
        emit(AdminProfileLoaded(userId: userId, email: email));
      } else {
        emit(const ProfileError(message: 'Role utilisateur inconnu'));
      }
    } catch (e) {
      emit(ProfileError(message: 'Erreur: ${e.toString()}'));
    }
  }

  /// Update seeker profile
  Future<void> _onUpdateRequested(
    ProfileUpdateRequested event,
    Emitter<ProfileState> emit,
  ) async {
    final currentState = state;

    emit(const ProfileSaving());

    try {
      if (event.seekerProfile != null) {
        final updated =
            await _profileRepository.updateSeekerProfile(event.seekerProfile!);
        final prevSeeker = currentState is SeekerProfileLoaded ? currentState : null;
        final categories = prevSeeker?.categories ?? await _profileRepository.getCategories();

        AppRouter.updateProfileComplete(updated.completionPercentage >= 100);
        emit(ProfileSaveSuccess());
        emit(SeekerProfileLoaded(
          profile: updated,
          categories: categories,
          isPremium: prevSeeker?.isPremium ?? false,
          stats: prevSeeker?.stats ?? VideoStats.empty(),
          presentationVideo: prevSeeker?.presentationVideo,
        ));
      }
    } catch (e) {
      emit(ProfileError(message: 'Erreur de sauvegarde: ${e.toString()}'));

      if (currentState is SeekerProfileLoaded) {
        emit(currentState);
      }
    }
  }

  /// Refresh profile
  Future<void> _onRefreshRequested(
    ProfileRefreshRequested event,
    Emitter<ProfileState> emit,
  ) async {
    add(const ProfileLoadRequested());
  }
}
