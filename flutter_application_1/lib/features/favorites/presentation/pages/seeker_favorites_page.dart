library;

/// Page listant les offres sauvegardées par le chercheur.

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../video/data/models/video_model.dart';

/// Page "Mes favoris" du chercheur.
class SeekerFavoritesPage extends StatefulWidget {
  final String seekerId;

  const SeekerFavoritesPage({required this.seekerId, super.key});

  @override
  State<SeekerFavoritesPage> createState() => _SeekerFavoritesPageState();
}

class _SeekerFavoritesPageState extends State<SeekerFavoritesPage> {
  List<_FavoriteEntry> _entries = [];
  bool _loading = true;

  SupabaseClient get _supabase => GetIt.I<SupabaseClient>();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final res = await _supabase
          .from('seeker_favorites')
          .select('video_id, created_at, videos(id, user_id, title, description, video_url, thumbnail_url, video_key, status, type, views_count, unique_viewers, created_at, updated_at)')
          .eq('seeker_id', widget.seekerId)
          .order('created_at', ascending: false);

      if (!mounted) return;
      final entries = (res as List).map((e) {
        final videoJson = e['videos'] as Map<String, dynamic>?;
        return _FavoriteEntry(
          favoriteId: e['video_id'] as String,
          video: videoJson != null ? Video.fromJson(videoJson) : null,
        );
      }).where((e) => e.video != null).toList();

      setState(() {
        _entries = entries;
        _loading = false;
      });
    } catch (e) {
      debugPrint('[SeekerFavoritesPage] Erreur chargement: $e');
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _removeFavorite(String videoId) async {
    setState(() => _entries.removeWhere((e) => e.favoriteId == videoId));
    try {
      await _supabase
          .from('seeker_favorites')
          .delete()
          .eq('seeker_id', widget.seekerId)
          .eq('video_id', videoId);
    } catch (e) {
      debugPrint('[SeekerFavoritesPage] Erreur suppression: $e');
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgSubtle,
      appBar: AppBar(
        backgroundColor: AppColors.bgPrimary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Mes favoris',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.accent))
          : _entries.isEmpty
              ? _buildEmpty()
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(AppTheme.spaceMd),
                    itemCount: _entries.length,
                    itemBuilder: (_, i) => _FavoriteCard(
                      entry: _entries[i],
                      onRemove: () => _removeFavorite(_entries[i].favoriteId),
                      onTap: () => context.push(
                        AppRoutes.companyProfileFor(_entries[i].video!.userId),
                      ),
                    ),
                  ),
                ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.favorite_border_rounded, size: 56, color: AppColors.textTertiary),
          const SizedBox(height: AppTheme.spaceMd),
          Text(
            'Aucun favori',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppTheme.spaceXs),
          Text(
            'Appuyez sur ♡ dans le feed pour sauvegarder une offre.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textTertiary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _FavoriteEntry {
  final String favoriteId;
  final Video? video;

  const _FavoriteEntry({required this.favoriteId, required this.video});
}

class _FavoriteCard extends StatelessWidget {
  final _FavoriteEntry entry;
  final VoidCallback onRemove;
  final VoidCallback onTap;

  const _FavoriteCard({
    required this.entry,
    required this.onRemove,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final video = entry.video!;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppTheme.spaceMd),
        decoration: BoxDecoration(
          color: AppColors.bgPrimary,
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          border: Border.all(color: AppColors.bgSubtle),
        ),
        child: Row(
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(AppTheme.radiusLg)),
              child: SizedBox(
                width: 80,
                height: 80,
                child: video.thumbnailUrl != null
                    ? CachedNetworkImage(
                        imageUrl: video.thumbnailUrl!,
                        fit: BoxFit.cover,
                        placeholder: (_, _) => Container(color: AppColors.bgSubtle),
                        errorWidget: (_, _, _) => Container(
                          color: AppColors.textPrimary,
                          child: const Icon(Icons.play_circle_outline, color: Colors.white54),
                        ),
                      )
                    : Container(
                        color: AppColors.textPrimary,
                        child: const Icon(Icons.play_circle_outline, color: Colors.white54),
                      ),
              ),
            ),
            // Infos
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppTheme.spaceMd, vertical: AppTheme.spaceSm),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      video.title ?? 'Offre sans titre',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (video.description != null && video.description!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        video.description!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            // Supprimer
            IconButton(
              icon: const Icon(Icons.favorite_rounded, color: AppColors.danger, size: 20),
              onPressed: onRemove,
              tooltip: 'Retirer des favoris',
            ),
            const SizedBox(width: 4),
          ],
        ),
      ),
    );
  }
}
