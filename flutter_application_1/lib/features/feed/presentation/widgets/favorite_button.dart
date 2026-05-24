library;

/// Bouton favori animé pour une vidéo/offre dans le feed (chercheur uniquement).

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/constants/app_colors.dart';

/// Bouton cœur qui permet au chercheur de sauvegarder une offre.
class FavoriteButton extends StatefulWidget {
  final String videoId;
  final String seekerId;
  final Color iconColor;
  final double size;

  const FavoriteButton({
    required this.videoId,
    required this.seekerId,
    this.iconColor = Colors.white,
    this.size = 24,
    super.key,
  });

  @override
  State<FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<FavoriteButton>
    with SingleTickerProviderStateMixin {
  bool _isFav = false;
  late AnimationController _ctrl;
  late Animation<double> _scale;

  SupabaseClient get _supabase => GetIt.I<SupabaseClient>();

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _scale = Tween(begin: 1.0, end: 1.3)
        .chain(CurveTween(curve: Curves.elasticOut))
        .animate(_ctrl);
    _check();
  }

  Future<void> _check() async {
    try {
      final res = await _supabase
          .from('seeker_favorites')
          .select('id')
          .eq('seeker_id', widget.seekerId)
          .eq('video_id', widget.videoId)
          .maybeSingle();
      if (!mounted) return;
      setState(() => _isFav = res != null);
    } catch (_) {}
  }

  Future<void> _toggle() async {
    final next = !_isFav;
    setState(() => _isFav = next);
    _ctrl.forward().then((_) => _ctrl.reverse());

    try {
      if (next) {
        await _supabase.from('seeker_favorites').insert({
          'seeker_id': widget.seekerId,
          'video_id': widget.videoId,
        });
      } else {
        await _supabase
            .from('seeker_favorites')
            .delete()
            .eq('seeker_id', widget.seekerId)
            .eq('video_id', widget.videoId);
      }
    } catch (e) {
      // Rollback optimiste en cas d'erreur
      if (mounted) setState(() => _isFav = !next);
      debugPrint('[FavoriteButton] Erreur toggle favori: $e');
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggle,
      child: ScaleTransition(
        scale: _scale,
        child: Icon(
          _isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
          color: _isFav ? AppColors.danger : widget.iconColor,
          size: widget.size,
        ),
      ),
    );
  }
}
