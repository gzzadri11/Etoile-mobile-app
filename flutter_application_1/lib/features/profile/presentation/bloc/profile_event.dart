/// Evenements du BLoC profil (chargement, mise a jour, stats).

part of 'profile_bloc.dart';

/// Classe de base des evenements profil.
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
