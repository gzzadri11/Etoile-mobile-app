library;

/// Page de contact du support utilisateur.
///
/// Contient un formulaire (sujet + message) qui ouvre le client
/// mail avec un email pre-rempli vers le support Etoile.

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_theme.dart';

/// Page de contact support avec formulaire ouvrant le client mail.
///
/// Champs :
/// - Subject (dropdown): Probleme technique, Question Premium, Signaler un bug, Autre
/// - Description (textarea): min 20 characters
/// - Send button: opens mailto: with pre-filled subject & body
class ContactSupportPage extends StatefulWidget {
  const ContactSupportPage({super.key});

  @override
  State<ContactSupportPage> createState() => _ContactSupportPageState();
}

class _ContactSupportPageState extends State<ContactSupportPage> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  String? _selectedSubject;
  bool _sent = false;

  static const _supportEmail = 'support@etoile-app.fr';

  static const _subjects = [
    'Probleme technique',
    'Question sur Premium',
    'Signaler un bug',
    'Autre',
  ];

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.contactSupport),
      ),
      body: _sent ? _buildConfirmation(context) : _buildForm(context),
    );
  }

  Widget _buildForm(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spaceMd),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'Comment pouvons-nous vous aider ?',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppTheme.spaceXs),
            Text(
              'Decrivez votre demande et nous reviendrons vers vous rapidement.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.greyWarm,
                  ),
            ),

            const SizedBox(height: AppTheme.spaceLg),

            // Subject dropdown
            Text(
              'Sujet',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: AppTheme.spaceSm),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                hintText: 'Choisir un sujet',
              ),
              initialValue: _selectedSubject,
              items: _subjects
                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                  .toList(),
              onChanged: (value) => setState(() => _selectedSubject = value),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez choisir un sujet';
                }
                return null;
              },
            ),

            const SizedBox(height: AppTheme.spaceLg),

            // Description
            Text(
              'Description',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: AppTheme.spaceSm),
            TextFormField(
              controller: _descriptionController,
              maxLines: 6,
              decoration: const InputDecoration(
                hintText:
                    'Decrivez votre probleme ou votre question en detail...',
                alignLabelWithHint: true,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return AppStrings.errorFieldRequired;
                }
                if (value.trim().length < 20) {
                  return 'Veuillez decrire votre demande (20 caracteres minimum)';
                }
                return null;
              },
            ),

            const SizedBox(height: AppTheme.spaceXl),

            // Send button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _onSend,
                icon: const Icon(Icons.send),
                label: const Text(AppStrings.send),
              ),
            ),

            const SizedBox(height: AppTheme.spaceLg),
          ],
        ),
      ),
    );
  }

  Widget _buildConfirmation(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spaceXl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.success.withAlpha(25),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_outline,
                size: 48,
                color: AppColors.success,
              ),
            ),
            const SizedBox(height: AppTheme.spaceLg),
            Text(
              'Message envoye !',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: AppTheme.spaceSm),
            Text(
              'Merci de nous avoir contactes. '
              'Notre equipe vous repondra sous 48h.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.greyWarm,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.spaceXl),
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(AppStrings.back),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onSend() async {
    if (!_formKey.currentState!.validate()) return;

    final subject = Uri.encodeComponent(
      '[Etoile] $_selectedSubject',
    );
    final body = Uri.encodeComponent(
      _descriptionController.text.trim(),
    );

    final uri = Uri.parse('mailto:$_supportEmail?subject=$subject&body=$body');

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
      if (mounted) {
        setState(() => _sent = true);
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Impossible d\'ouvrir le client mail. '
              'Envoyez un email a $_supportEmail',
            ),
          ),
        );
      }
    }
  }
}
