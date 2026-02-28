import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/services/video_upload_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../feed/data/repositories/feed_repository.dart';
import '../../data/models/video_model.dart';
import '../../data/repositories/video_repository.dart';

/// Page listing all publications (videos + posters) for the current recruiter.
class MyPublicationsPage extends StatefulWidget {
  final String initialTab;

  const MyPublicationsPage({super.key, this.initialTab = 'recruitment'});

  @override
  State<MyPublicationsPage> createState() => _MyPublicationsPageState();
}

class _MyPublicationsPageState extends State<MyPublicationsPage>
    with SingleTickerProviderStateMixin {
  List<Video> _publications = [];
  bool _isLoading = true;
  String? _error;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTab == 'presentations' ? 0 : 1,
    );
    _loadPublications();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Video> get _presentations =>
      _publications.where((v) => v.type == 'presentation').toList();

  List<Video> get _recruitment =>
      _publications.where((v) => v.type == 'offer' || v.type == 'poster').toList();

  Future<void> _loadPublications() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final videoRepo = GetIt.I<VideoRepository>();
      final userId = videoRepo.currentUserId;
      if (userId == null) throw Exception('Non authentifie');

      final videos = await videoRepo.getVideosForUser(userId);
      if (mounted) {
        setState(() {
          _publications = videos;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _editPublication(Video video) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radiusLg)),
      ),
      builder: (context) => _EditPublicationSheet(video: video),
    );

    if (result == true) {
      _loadPublications();
    }
  }

  Future<void> _deletePublication(Video video) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer la publication'),
        content: Text(
          'Voulez-vous vraiment supprimer "${video.title ?? 'cette publication'}" ? Cette action est irreversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final videoRepo = GetIt.I<VideoRepository>();
      await videoRepo.deleteVideo(video.id);

      // Best-effort R2 cleanup
      try {
        final uploadService = GetIt.I<VideoUploadService>();
        final type = video.type == 'poster' ? 'thumbnail' : 'video';
        await uploadService.deleteFile(key: video.videoKey, type: type);
      } catch (_) {}

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Publication supprimee')),
        );
        _loadPublications();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }

  Widget _buildPublicationList(List<Video> items) {
    if (items.isEmpty) {
      return EmptyStateWidget(
        showMascotte: true,
        title: 'Aucune publication',
        subtitle:
            'Publiez votre premiere offre video ou affiche pour attirer des candidats',
        actionLabel: 'Publier une offre',
        onAction: () => context.go(AppRoutes.publish),
      );
    }
    return RefreshIndicator(
      onRefresh: _loadPublications,
      child: ListView.separated(
        padding: const EdgeInsets.all(AppTheme.spaceMd),
        itemCount: items.length,
        separatorBuilder: (context, index) =>
            const SizedBox(height: AppTheme.spaceMd),
        itemBuilder: (context, index) {
          return _PublicationCard(
            video: items[index],
            onEdit: () => _editPublication(items[index]),
            onDelete: () => _deletePublication(items[index]),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes publications'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primaryYellow,
          labelColor: AppColors.primaryOrange,
          unselectedLabelColor: AppColors.greyWarm,
          tabs: const [
            Tab(text: 'Presentations'),
            Tab(text: 'Recrutement'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _ErrorView(error: _error!, onRetry: _loadPublications)
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildPublicationList(_presentations),
                    _buildPublicationList(_recruitment),
                  ],
                ),
      floatingActionButton: _publications.isNotEmpty
          ? FloatingActionButton(
              onPressed: () => context.go(AppRoutes.publish),
              backgroundColor: AppColors.primaryYellow,
              child: const Icon(Icons.add, color: AppColors.black),
            )
          : null,
    );
  }
}

/// Single publication card
class _PublicationCard extends StatelessWidget {
  final Video video;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _PublicationCard({
    required this.video,
    required this.onEdit,
    required this.onDelete,
  });

  bool get _isPoster => video.type == 'poster';

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppColors.greyLight),
      ),
      child: Row(
        children: [
          // Thumbnail / image
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(AppTheme.radiusLg),
              bottomLeft: Radius.circular(AppTheme.radiusLg),
            ),
            child: SizedBox(
              width: 100,
              height: 100,
              child: _buildThumbnail(),
            ),
          ),

          // Info
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spaceMd),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Type badge + status + menu
                  Row(
                    children: [
                      _TypeBadge(type: video.type),
                      const Spacer(),
                      _StatusBadge(status: video.status),
                      const SizedBox(width: 4),
                      PopupMenuButton<String>(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        iconSize: 20,
                        icon: const Icon(Icons.more_vert, size: 20),
                        onSelected: (value) {
                          if (value == 'edit') onEdit();
                          if (value == 'delete') onDelete();
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit_outlined, size: 18),
                                SizedBox(width: 8),
                                Text('Modifier'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                                SizedBox(width: 8),
                                Text('Supprimer', style: TextStyle(color: AppColors.error)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.spaceSm),

                  // Title
                  Text(
                    video.title ?? 'Sans titre',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppTheme.spaceXs),

                  // Date + views
                  Row(
                    children: [
                      Icon(Icons.calendar_today,
                          size: 12, color: AppColors.greyWarm),
                      const SizedBox(width: 4),
                      Text(
                        _formatDate(video.publishedAt ?? video.createdAt),
                        style:
                            Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: AppColors.greyWarm,
                                ),
                      ),
                      const SizedBox(width: AppTheme.spaceMd),
                      Icon(Icons.visibility_outlined,
                          size: 12, color: AppColors.greyWarm),
                      const SizedBox(width: 4),
                      Text(
                        '${video.viewsCount}',
                        style:
                            Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: AppColors.greyWarm,
                                ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThumbnail() {
    final url = video.thumbnailUrl ?? video.videoUrl;
    if (url != null && url.isNotEmpty) {
      if (_isPoster) {
        return Image.network(url, fit: BoxFit.cover);
      }
      return Stack(
        fit: StackFit.expand,
        children: [
          if (video.thumbnailUrl != null)
            Image.network(video.thumbnailUrl!, fit: BoxFit.cover),
          Container(color: AppColors.black.withAlpha(60)),
          const Center(
            child:
                Icon(Icons.play_circle_filled, color: AppColors.white, size: 36),
          ),
        ],
      );
    }
    return Container(
      color: AppColors.greyLight,
      child: Icon(
        _isPoster ? Icons.image : Icons.videocam,
        color: AppColors.greyMedium,
        size: 36,
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}

/// Type badge (presentation / video / poster)
class _TypeBadge extends StatelessWidget {
  final String type;

  const _TypeBadge({required this.type});

  @override
  Widget build(BuildContext context) {
    final (IconData icon, String label, Color color) = switch (type) {
      'presentation' => (Icons.business, 'Presentation', AppColors.success),
      'poster' => (Icons.image, 'Affiche', AppColors.primaryOrange),
      _ => (Icons.videocam, 'Video', AppColors.info),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

/// Status badge
class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;
    switch (status) {
      case 'active':
        color = AppColors.success;
        label = 'Active';
        break;
      case 'processing':
        color = AppColors.warning;
        label = 'En cours';
        break;
      case 'suspended':
        color = AppColors.error;
        label = 'Suspendue';
        break;
      default:
        color = AppColors.greyWarm;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}


/// Error state
class _ErrorView extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const _ErrorView({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.space2Xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const SizedBox(height: AppTheme.spaceMd),
            Text(
              'Impossible de charger les publications',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppTheme.spaceSm),
            Text(
              error,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.greyWarm,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.spaceLg),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Reessayer'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Bottom sheet for editing a publication (title + category)
class _EditPublicationSheet extends StatefulWidget {
  final Video video;

  const _EditPublicationSheet({required this.video});

  @override
  State<_EditPublicationSheet> createState() => _EditPublicationSheetState();
}

class _EditPublicationSheetState extends State<_EditPublicationSheet> {
  late final TextEditingController _titleController;
  String? _selectedCategory;
  final _formKey = GlobalKey<FormState>();
  bool _saving = false;
  List<Map<String, dynamic>> _categories = [];
  bool _categoriesLoading = true;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.video.title ?? '');
    _selectedCategory = widget.video.categoryId;
    _loadCategories();
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    try {
      final feedRepo = GetIt.I<FeedRepository>();
      final cats = await feedRepo.getCategories();
      if (mounted) {
        setState(() {
          _categories = cats;
          _categoriesLoading = false;
          // Guard: reset category if not in the list
          if (_selectedCategory != null &&
              !cats.any((c) => c['id'] == _selectedCategory)) {
            _selectedCategory = null;
          }
        });
      }
    } catch (e) {
      if (mounted) setState(() => _categoriesLoading = false);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    try {
      final videoRepo = GetIt.I<VideoRepository>();
      await videoRepo.updateVideo(
        videoId: widget.video.id,
        title: _titleController.text.trim(),
        categoryId: _selectedCategory,
      );

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: AppTheme.spaceLg,
        right: AppTheme.spaceLg,
        top: AppTheme.spaceLg,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppTheme.spaceLg,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.greyMedium,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppTheme.spaceLg),

            Text(
              'Modifier la publication',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppTheme.spaceLg),

            // Title
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Titre du poste',
                prefixIcon: Icon(Icons.work_outline),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return AppStrings.errorFieldRequired;
                }
                if (value.trim().length < 3) {
                  return 'Le titre doit faire au moins 3 caracteres';
                }
                return null;
              },
            ),
            const SizedBox(height: AppTheme.spaceMd),

            // Category
            if (_categoriesLoading)
              const Center(child: CircularProgressIndicator())
            else
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Categorie',
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                items: _categories.map((cat) {
                  return DropdownMenuItem<String>(
                    value: cat['id'] as String,
                    child: Text(cat['name'] as String? ?? cat['id'] as String),
                  );
                }).toList(),
                onChanged: (v) => setState(() => _selectedCategory = v),
              ),

            const SizedBox(height: AppTheme.spaceLg),

            // Save button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Enregistrer'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
