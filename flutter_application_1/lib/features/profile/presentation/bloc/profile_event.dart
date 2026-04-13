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

/// Update seeker profile
class ProfileUpdateRequested extends ProfileEvent {
  final SeekerProfile? seekerProfile;

  const ProfileUpdateRequested({
    this.seekerProfile,
  });

  @override
  List<Object?> get props => [seekerProfile];
}

/// Refresh profile data
class ProfileRefreshRequested extends ProfileEvent {
  const ProfileRefreshRequested();
}
