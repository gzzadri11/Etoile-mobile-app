/// Etats du BLoC profil (initial, charge, erreur).

part of 'profile_bloc.dart';

/// Classe de base des etats profil.
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
  final bool isPremium;
  final VideoStats stats;

  const SeekerProfileLoaded({
    required this.profile,
    required this.categories,
    this.isPremium = false,
    this.stats = const VideoStats(
      totalViews: 0,
      uniqueViewers: 0,
      thisWeekViews: 0,
      lastWeekViews: 0,
      trendPercent: 0,
    ),
  });

  @override
  List<Object?> get props => [profile, categories, isPremium, stats];
}

/// Recruiter profile loaded successfully
class RecruiterProfileLoaded extends ProfileState {
  final RecruiterProfile profile;
  final int presentationCount;
  final int offerCount;
  final int posterCount;
  final bool isPremium;
  final VideoStats stats;

  const RecruiterProfileLoaded({
    required this.profile,
    this.presentationCount = 0,
    this.offerCount = 0,
    this.posterCount = 0,
    this.isPremium = false,
    this.stats = const VideoStats(
      totalViews: 0,
      uniqueViewers: 0,
      thisWeekViews: 0,
      lastWeekViews: 0,
      trendPercent: 0,
    ),
  });

  @override
  List<Object?> get props => [profile, presentationCount, offerCount, posterCount, isPremium, stats];
}

/// Admin profile loaded - minimal state for admin users
class AdminProfileLoaded extends ProfileState {
  final String userId;
  final String email;

  const AdminProfileLoaded({required this.userId, required this.email});

  @override
  List<Object?> get props => [userId, email];
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
