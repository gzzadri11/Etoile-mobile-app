library;

/// Page de statistiques chercheur : vues vidéo, candidatures, entreprises vues.

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../features/applications/data/repositories/application_repository.dart';
import '../../../../features/profile/data/repositories/stats_repository.dart';
import '../../../../features/profile/data/models/video_stats.dart';

class SeekerStatsPage extends StatefulWidget {
  const SeekerStatsPage({super.key});

  @override
  State<SeekerStatsPage> createState() => _SeekerStatsPageState();
}

class _SeekerStatsPageState extends State<SeekerStatsPage> {
  bool _loading = true;
  String? _error;
  VideoStats _stats = VideoStats.empty();
  int _applicationsCount = 0;
  List<_ViewerCompany> _viewers = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final statsRepo = GetIt.I<StatsRepository>();
      final appRepo = GetIt.I<ApplicationRepository>();
      final supabase = GetIt.I<SupabaseClient>();

      final stats = await statsRepo.getStats();
      final applications = await appRepo.getSeekerApplications();

      // Fetch recent unique viewers with recruiter profiles
      final viewsData = await supabase
          .from('video_views')
          .select('viewer_id, created_at')
          .order('created_at', ascending: false);

      final seenIds = <String>{};
      final uniqueViewerIds = <String>[];
      for (final row in (viewsData as List)) {
        final viewerId = row['viewer_id'] as String?;
        if (viewerId != null && seenIds.add(viewerId)) {
          uniqueViewerIds.add(viewerId);
        }
      }

      // Batch fetch recruiter profiles for viewer IDs
      final viewers = <_ViewerCompany>[];
      if (uniqueViewerIds.isNotEmpty) {
        final profiles = await supabase
            .from('recruiter_profiles')
            .select('user_id, company_name, sector, photo_url')
            .inFilter('user_id', uniqueViewerIds);

        final profileMap = {
          for (final p in (profiles as List)) p['user_id'] as String: p,
        };

        for (final id in uniqueViewerIds) {
          final p = profileMap[id];
          viewers.add(_ViewerCompany(
            userId: id,
            companyName: p?['company_name'] as String? ?? 'Recruteur',
            sector: p?['sector'] as String? ?? '',
            photoUrl: p?['photo_url'] as String?,
          ));
        }
      }

      if (mounted) {
        setState(() {
          _stats = stats;
          _applicationsCount = applications.length;
          _viewers = viewers;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes statistiques'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadData,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline,
                          size: 48, color: AppColors.danger),
                      const SizedBox(height: AppTheme.spaceMd),
                      Text(_error!),
                      const SizedBox(height: AppTheme.spaceMd),
                      ElevatedButton(
                        onPressed: _loadData,
                        child: const Text('Réessayer'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(AppTheme.spaceMd),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // KPI row
                        Row(
                          children: [
                            Expanded(
                              child: _KpiCard(
                                icon: Icons.play_circle_outline,
                                value: '${_stats.totalViews}',
                                label: 'Vues',
                                color: AppColors.accent,
                              ),
                            ),
                            const SizedBox(width: AppTheme.spaceMd),
                            Expanded(
                              child: _KpiCard(
                                icon: Icons.people_outline,
                                value: '${_stats.uniqueViewers}',
                                label: 'Recruteurs',
                                color: AppColors.success,
                              ),
                            ),
                            const SizedBox(width: AppTheme.spaceMd),
                            Expanded(
                              child: _KpiCard(
                                icon: Icons.send_outlined,
                                value: '$_applicationsCount',
                                label: 'Candidatures',
                                color: AppColors.warning,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: AppTheme.spaceLg),

                        // Weekly trend
                        if (_stats.totalViews > 0) ...[
                          _TrendCard(stats: _stats),
                          const SizedBox(height: AppTheme.spaceLg),
                        ],

                        // Viewer companies
                        Text(
                          'Recruteurs ayant vu votre vidéo',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: AppTheme.spaceSm),

                        if (_viewers.isEmpty)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(AppTheme.spaceLg),
                            decoration: BoxDecoration(
                              color: AppColors.bgPrimary,
                              borderRadius:
                                  BorderRadius.circular(AppTheme.radiusLg),
                              border: Border.all(color: AppColors.bgSubtle),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.visibility_off_outlined,
                                  size: 40,
                                  color: AppColors.textTertiary,
                                ),
                                const SizedBox(height: AppTheme.spaceSm),
                                Text(
                                  'Aucune vue pour l\'instant',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                          color: AppColors.textSecondary),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Partagez votre profil pour gagner en visibilité',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                          color: AppColors.textTertiary),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          )
                        else
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _viewers.length,
                            separatorBuilder: (context2, i) =>
                                const SizedBox(height: AppTheme.spaceSm),
                            itemBuilder: (_, index) =>
                                _ViewerTile(viewer: _viewers[index]),
                          ),

                        const SizedBox(height: AppTheme.spaceLg),
                      ],
                    ),
                  ),
                ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _KpiCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spaceMd),
      decoration: BoxDecoration(
        color: AppColors.bgPrimary,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: AppColors.bgSubtle),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 6),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _TrendCard extends StatelessWidget {
  final VideoStats stats;

  const _TrendCard({required this.stats});

  @override
  Widget build(BuildContext context) {
    final isPositive = stats.trendPercent >= 0;
    final trendText = isPositive
        ? '+${stats.trendPercent.toStringAsFixed(0)}%'
        : '${stats.trendPercent.toStringAsFixed(0)}%';

    return Container(
      padding: const EdgeInsets.all(AppTheme.spaceMd),
      decoration: BoxDecoration(
        color: AppColors.bgPrimary,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: AppColors.bgSubtle),
      ),
      child: Row(
        children: [
          Icon(
            isPositive ? Icons.trending_up : Icons.trending_down,
            color: isPositive ? AppColors.success : AppColors.danger,
          ),
          const SizedBox(width: AppTheme.spaceSm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cette semaine : ${stats.thisWeekViews} vue${stats.thisWeekViews > 1 ? 's' : ''}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(
                  'vs semaine dernière : ${stats.lastWeekViews}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ],
            ),
          ),
          Text(
            trendText,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isPositive ? AppColors.success : AppColors.danger,
                ),
          ),
        ],
      ),
    );
  }
}

class _ViewerTile extends StatelessWidget {
  final _ViewerCompany viewer;

  const _ViewerTile({required this.viewer});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spaceMd),
      decoration: BoxDecoration(
        color: AppColors.bgPrimary,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: AppColors.bgSubtle),
      ),
      child: Row(
        children: [
          // Company avatar
          CircleAvatar(
            radius: 22,
            backgroundColor: AppColors.accentBg,
            backgroundImage: viewer.photoUrl != null
                ? NetworkImage(viewer.photoUrl!)
                : null,
            child: viewer.photoUrl == null
                ? Text(
                    viewer.companyName.isNotEmpty
                        ? viewer.companyName[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      color: AppColors.accent,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: AppTheme.spaceMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  viewer.companyName,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                if (viewer.sector.isNotEmpty)
                  Text(
                    viewer.sector,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.accentBg,
              borderRadius: BorderRadius.circular(AppTheme.radiusFull),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.visibility_outlined,
                    size: 12, color: AppColors.accent),
                const SizedBox(width: 4),
                Text(
                  'A visionné',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.accent,
                        fontSize: 10,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ViewerCompany {
  final String userId;
  final String companyName;
  final String sector;
  final String? photoUrl;

  const _ViewerCompany({
    required this.userId,
    required this.companyName,
    required this.sector,
    this.photoUrl,
  });
}
