import 'package:equatable/equatable.dart';

/// Statistics for a user's videos
class VideoStats extends Equatable {
  final int totalViews;
  final int uniqueViewers;
  final int thisWeekViews;
  final int lastWeekViews;
  final double trendPercent;

  const VideoStats({
    required this.totalViews,
    required this.uniqueViewers,
    required this.thisWeekViews,
    required this.lastWeekViews,
    required this.trendPercent,
  });

  factory VideoStats.empty() => const VideoStats(
        totalViews: 0,
        uniqueViewers: 0,
        thisWeekViews: 0,
        lastWeekViews: 0,
        trendPercent: 0,
      );

  bool get isPositiveTrend => trendPercent > 0;
  bool get isNegativeTrend => trendPercent < 0;
  bool get hasData => totalViews > 0;

  @override
  List<Object?> get props => [
        totalViews,
        uniqueViewers,
        thisWeekViews,
        lastWeekViews,
        trendPercent,
      ];
}
