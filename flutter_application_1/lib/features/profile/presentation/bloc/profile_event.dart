part of 'profile_bloc.dart';

/// Base class for profile events
sealed class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

/// Load user profile
class ProfileLoadRequested extends ProfileEvent {
  const ProfileLoadRequested();
}

/// Update user profile
class ProfileUpdateRequested extends ProfileEvent {
  final SeekerProfile? seekerProfile;
  final RecruiterProfile? recruiterProfile;

  const ProfileUpdateRequested({
    this.seekerProfile,
    this.recruiterProfile,
  });

  @override
  List<Object?> get props => [seekerProfile, recruiterProfile];
}

/// Refresh profile data
class ProfileRefreshRequested extends ProfileEvent {
  const ProfileRefreshRequested();
}
