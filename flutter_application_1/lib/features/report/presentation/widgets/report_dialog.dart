library;

/// Boite de dialogue de signalement reutilisable (bottom sheet).

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/repositories/report_repository.dart';

/// Bottom sheet de signalement reutilisable.
///
/// Affiche une liste de motifs et un champ de description optionnel.
/// Appeler [showReportDialog] pour l'afficher.
Future<void> showReportDialog(
  BuildContext context, {
  required String reportedUserId,
  String? reportedVideoId,
  String? reportedMessageId,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (_) => _ReportSheet(
      reportedUserId: reportedUserId,
      reportedVideoId: reportedVideoId,
      reportedMessageId: reportedMessageId,
    ),
  );
}

class _ReportSheet extends StatefulWidget {
  final String reportedUserId;
  final String? reportedVideoId;
  final String? reportedMessageId;

  const _ReportSheet({
    required this.reportedUserId,
    this.reportedVideoId,
    this.reportedMessageId,
  });

  @override
  State<_ReportSheet> createState() => _ReportSheetState();
}

class _ReportSheetState extends State<_ReportSheet> {
  static const _reasons = [
    'Contenu inapproprie',
    'Spam ou publicite',
    'Fausse identite',
    'Harcelement',
    'Autre',
  ];

  String? _selectedReason;
  final _descriptionController = TextEditingController();
  bool _isSending = false;

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_selectedReason == null) return;

    setState(() => _isSending = true);

    try {
      await GetIt.I<ReportRepository>().createReport(
        reason: _selectedReason!,
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        reportedUserId: widget.reportedUserId,
        reportedVideoId: widget.reportedVideoId,
        reportedMessageId: widget.reportedMessageId,
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Merci pour votre signalement. Nous allons examiner ce contenu.',
            ),
          ),
        );
      }
    } catch (e) {
      setState(() => _isSending = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur : ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.bgPrimary,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppTheme.radiusXl),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: AppTheme.spaceMd),
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Title
            Padding(
              padding: const EdgeInsets.all(AppTheme.spaceMd),
              child: Text(
                'Signaler',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),

            const Divider(height: 1),

            // Reasons
            RadioGroup<String>(
              groupValue: _selectedReason ?? '',
              onChanged: (v) => setState(() => _selectedReason = v),
              child: Column(
                children: _reasons
                    .map((reason) => ListTile(
                          leading: Radio<String>(value: reason),
                          title: Text(reason),
                          onTap: () =>
                              setState(() => _selectedReason = reason),
                        ))
                    .toList(),
              ),
            ),

            // Description
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spaceMd,
              ),
              child: TextField(
                controller: _descriptionController,
                maxLines: 3,
                maxLength: 500,
                decoration: const InputDecoration(
                  hintText: 'Details supplementaires (optionnel)',
                  border: OutlineInputBorder(),
                ),
              ),
            ),

            // Submit button
            Padding(
              padding: EdgeInsets.fromLTRB(
                AppTheme.spaceMd,
                AppTheme.spaceMd,
                AppTheme.spaceMd,
                AppTheme.spaceMd + MediaQuery.of(context).padding.bottom,
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed:
                      _selectedReason != null && !_isSending ? _submit : null,
                  child: _isSending
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Envoyer le signalement'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
