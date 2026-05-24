library;

/// Bouton favori pour le recruteur sur les profils chercheurs.

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/constants/app_colors.dart';

/// Bouton signet permettant au recruteur de sauvegarder un chercheur.
class RecruiterFavoriteButton extends StatefulWidget {
  final String seekerId;
  final String recruiterId;

  const RecruiterFavoriteButton({
    required this.seekerId,
    required this.recruiterId,
    super.key,
  });

  @override
  State<RecruiterFavoriteButton> createState() => _RecruiterFavoriteButtonState();
}

class _RecruiterFavoriteButtonState extends State<RecruiterFavoriteButton> {
  bool _isFav = false;

  SupabaseClient get _supabase => GetIt.I<SupabaseClient>();

  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    try {
      final res = await _supabase
          .from('recruiter_favorites')
          .select('id')
          .eq('recruiter_id', widget.recruiterId)
          .eq('seeker_id', widget.seekerId)
          .maybeSingle();
      if (!mounted) return;
      setState(() => _isFav = res != null);
    } catch (_) {}
  }

  Future<void> _toggle() async {
    final next = !_isFav;
    setState(() => _isFav = next);
    try {
      if (next) {
        await _supabase.from('recruiter_favorites').insert({
          'recruiter_id': widget.recruiterId,
          'seeker_id': widget.seekerId,
        });
      } else {
        await _supabase
            .from('recruiter_favorites')
            .delete()
            .eq('recruiter_id', widget.recruiterId)
            .eq('seeker_id', widget.seekerId);
      }
    } catch (e) {
      if (mounted) setState(() => _isFav = !next);
      debugPrint('[RecruiterFavoriteButton] Erreur toggle: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: _toggle,
      icon: Icon(
        _isFav ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
        color: _isFav ? AppColors.accent : AppColors.textTertiary,
      ),
      tooltip: _isFav ? 'Retirer des favoris' : 'Sauvegarder ce profil',
    );
  }
}
