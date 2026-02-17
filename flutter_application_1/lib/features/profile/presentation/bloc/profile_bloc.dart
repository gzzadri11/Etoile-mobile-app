import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/seeker_profile_model.dart';
import '../../data/models/recruiter_profile_model.dart';
import '../../data/repositories/profile_repository.dart';
import '../../../video/data/repositories/video_repository.dart';

part 'profile_event.dart';
part 'profile_state.dart';

/// BLoC for managing user profile state
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileRepository _profileRepository;
  final VideoRepository _videoRepository;

  ProfileBloc({
    required ProfileRepository profileRepository,
    required VideoRepository videoRepository,
  })  : _profileRepository = profileRepository,
        _videoRepository = videoRepository,
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

        if (profile != null) {
          emit(SeekerProfileLoaded(
            profile: profile,
            categories: categories,
          ));
        } else {
          emit(const ProfileError(message: 'Profil non trouve'));
        }
      } else if (role == 'recruiter') {
        final profile = await _profileRepository.getRecruiterProfile();

        if (profile != null) {
          // Count publications by type
          int presentationCount = 0;
          int offerCount = 0;
          int posterCount = 0;
          try {
            final userId = _videoRepository.currentUserId;
            if (userId != null) {
              final videos = await _videoRepository.getVideosForUser(userId);
              for (final video in videos) {
                switch (video.type) {
                  case 'presentation':
                    presentationCount++;
                  case 'offer':
                    offerCount++;
                  case 'poster':
                    posterCount++;
                }
              }
            }
          } catch (_) {}

          emit(RecruiterProfileLoaded(
            profile: profile,
            presentationCount: presentationCount,
            offerCount: offerCount,
            posterCount: posterCount,
          ));
        } else {
          emit(const ProfileError(message: 'Profil non trouve'));
        }
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
        final categories = currentState is SeekerProfileLoaded
            ? currentState.categories
            : await _profileRepository.getCategories();

        emit(ProfileSaveSuccess());
        emit(SeekerProfileLoaded(profile: updated, categories: categories));
      } else if (event.recruiterProfile != null) {
        final updated = await _profileRepository
            .updateRecruiterProfile(event.recruiterProfile!);

        emit(ProfileSaveSuccess());
        // Preserve counters from previous state
        final prevState = currentState;
        if (prevState is RecruiterProfileLoaded) {
          emit(RecruiterProfileLoaded(
            profile: updated,
            presentationCount: prevState.presentationCount,
            offerCount: prevState.offerCount,
            posterCount: prevState.posterCount,
          ));
        } else {
          emit(RecruiterProfileLoaded(profile: updated));
        }
      }
    } catch (e) {
      emit(ProfileError(message: 'Erreur de sauvegarde: ${e.toString()}'));

      // Restore previous state
      if (currentState is SeekerProfileLoaded) {
        emit(currentState);
      } else if (currentState is RecruiterProfileLoaded) {
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
