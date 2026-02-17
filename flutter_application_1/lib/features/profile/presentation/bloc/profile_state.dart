part of 'profile_bloc.dart';

/// Base class for profile states
sealed class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

/// Loading profile
class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

/// Saving profile changes
class ProfileSaving extends ProfileState {
  const ProfileSaving();
}

/// Seeker profile loaded successfully
class SeekerProfileLoaded extends ProfileState {
  final SeekerProfile profile;
  final List<Map<String, dynamic>> categories;

  const SeekerProfileLoaded({
    required this.profile,
    required this.categories,
  });

  @override
  List<Object?> get props => [profile, categories];
}

/// Recruiter profile loaded successfully
class RecruiterProfileLoaded extends ProfileState {
  final RecruiterProfile profile;
  final int presentationCount;
  final int offerCount;
  final int posterCount;

  const RecruiterProfileLoaded({
    required this.profile,
    this.presentationCount = 0,
    this.offerCount = 0,
    this.posterCount = 0,
  });

  @override
  List<Object?> get props => [profile, presentationCount, offerCount, posterCount];
}

/// Profile saved successfully
class ProfileSaveSuccess extends ProfileState {}

/// Error state
class ProfileError extends ProfileState {
  final String message;

  const ProfileError({required this.message});

  @override
  List<Object?> get props => [message];
}
