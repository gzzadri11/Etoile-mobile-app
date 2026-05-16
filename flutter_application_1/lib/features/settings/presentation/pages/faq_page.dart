library;

/// Page de la Foire Aux Questions (FAQ).
///
/// Affiche les questions/reponses organisees par theme
/// dans des sections extensibles (ExpansionTile).

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/empty_state_widget.dart';

/// Page FAQ avec sections extensibles organisees par theme.
///
/// Features:
/// - Search bar to filter questions by keyword
/// - Accordion-style ExpansionTile for each question
/// - "Contact support" button at the bottom
class FaqPage extends StatefulWidget {
  const FaqPage({super.key});

  @override
  State<FaqPage> createState() => _FaqPageState();
}

class _FaqPageState extends State<FaqPage> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredSections = _getFilteredSections();

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.faq),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(AppTheme.spaceMd),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher une question...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                setState(() => _searchQuery = value.toLowerCase());
              },
            ),
          ),

          // FAQ content
          Expanded(
            child: filteredSections.isEmpty
                ? EmptyStateWidget(
                    icon: Icons.search_off,
                    title: 'Aucun resultat pour "$_searchQuery"',
                  )
                : ListView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.spaceMd),
                    children: [
                      for (final section in filteredSections) ...[
                        _SectionHeader(title: section.title, icon: section.icon),
                        ...section.items.map(
                          (item) => _FaqTile(
                            question: item.question,
                            answer: item.answer,
                          ),
                        ),
                        const SizedBox(height: AppTheme.spaceMd),
                      ],

                      // Contact support button
                      const SizedBox(height: AppTheme.spaceMd),
                      Center(
                        child: Text(
                          'Vous n\'avez pas trouve votre reponse ?',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                        ),
                      ),
                      const SizedBox(height: AppTheme.spaceSm),
                      Center(
                        child: OutlinedButton.icon(
                          onPressed: () =>
                              context.push(AppRoutes.contactSupport),
                          icon: const Icon(Icons.mail_outline),
                          label: const Text(AppStrings.contactSupport),
                        ),
                      ),
                      const SizedBox(height: AppTheme.space2Xl),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  List<_FaqSection> _getFilteredSections() {
    if (_searchQuery.isEmpty) return _allSections;

    final filtered = <_FaqSection>[];
    for (final section in _allSections) {
      final matchingItems = section.items.where((item) {
        return item.question.toLowerCase().contains(_searchQuery) ||
            item.answer.toLowerCase().contains(_searchQuery);
      }).toList();

      if (matchingItems.isNotEmpty) {
        filtered.add(_FaqSection(
          title: section.title,
          icon: section.icon,
          items: matchingItems,
        ));
      }
    }
    return filtered;
  }
}

// =============================================================================
// WIDGETS
// =============================================================================

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: AppTheme.spaceSm,
        bottom: AppTheme.spaceXs,
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.accent, size: 20),
          const SizedBox(width: AppTheme.spaceSm),
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: AppColors.accent,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

class _FaqTile extends StatelessWidget {
  final String question;
  final String answer;

  const _FaqTile({required this.question, required this.answer});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppTheme.spaceSm),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: AppTheme.spaceMd),
        childrenPadding: const EdgeInsets.fromLTRB(
          AppTheme.spaceMd,
          0,
          AppTheme.spaceMd,
          AppTheme.spaceMd,
        ),
        shape: const Border(),
        collapsedShape: const Border(),
        title: Text(
          question,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
        ),
        children: [
          Text(
            answer,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.6,
                ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// DATA
// =============================================================================

class _FaqItem {
  final String question;
  final String answer;
  const _FaqItem({required this.question, required this.answer});
}

class _FaqSection {
  final String title;
  final IconData icon;
  final List<_FaqItem> items;
  const _FaqSection({
    required this.title,
    required this.icon,
    required this.items,
  });
}

final _allSections = [
  const _FaqSection(
    title: 'Compte & Profil',
    icon: Icons.person_outline,
    items: [
      _FaqItem(
        question: 'Comment creer mon compte ?',
        answer:
            'Telechargez l\'application, appuyez sur "Je cherche un emploi" ou "Je recrute", '
            'puis renseignez votre email et un mot de passe. C\'est rapide et gratuit !',
      ),
      _FaqItem(
        question: 'Comment completer mon profil ?',
        answer:
            'Rendez-vous sur l\'onglet Profil, puis appuyez sur "Modifier mon profil". '
            'Remplissez toutes les sections pour atteindre 100% de completude. '
            'Un profil complet est necessaire pour etre visible et postuler.',
      ),
      _FaqItem(
        question: 'Puis-je modifier mes informations apres inscription ?',
        answer:
            'Bien sûr ! Vous pouvez modifier votre profil à tout moment depuis '
            'l\'onglet Profil > Modifier mon profil. Vos modifications sont enregistrées instantanément.',
      ),
      _FaqItem(
        question: 'Comment supprimer mon compte ?',
        answer:
            'Rendez-vous dans Paramètres > Contacter le support et faites une demande de suppression. '
            'Conformément au RGPD, vos données seront supprimées sous 30 jours.',
      ),
    ],
  ),
  const _FaqSection(
    title: 'Vidéo',
    icon: Icons.videocam_outlined,
    items: [
      _FaqItem(
        question: 'Comment enregistrer ma vidéo de présentation ?',
        answer:
            'Depuis l\'onglet Profil, appuyez sur "Modifier ma vidéo". '
            'Vous disposez de 40 secondes pour vous présenter en 3 étapes guidées. '
            'Trouvez un endroit calme et bien éclairé pour un meilleur résultat !',
      ),
      _FaqItem(
        question: 'Puis-je re-enregistrer ma vidéo ?',
        answer:
            'Oui, vous pouvez re-enregistrer autant de fois que vous le souhaitez '
            'avant de publier. Une fois publiée, vous pouvez toujours en enregistrer une nouvelle '
            'qui remplacera l\'ancienne.',
      ),
      _FaqItem(
        question: 'Quelle est la durée maximale d\'une vidéo ?',
        answer:
            'Chaque vidéo dure 40 secondes maximum, divisée en 3 phases de coaching : '
            'présentation, compétences et motivation. Ce format court permet aux recruteurs '
            'de découvrir rapidement votre personnalité.',
      ),
      _FaqItem(
        question: 'Ma vidéo ne s\'uploade pas, que faire ?',
        answer:
            'Vérifiez votre connexion internet et réessayez. Si le problème persiste, '
            'redémarrez l\'application. La taille maximale est de 50 Mo. '
            'En cas de souci persistant, contactez notre support.',
      ),
    ],
  ),
  const _FaqSection(
    title: 'Messages',
    icon: Icons.chat_outlined,
    items: [
      _FaqItem(
        question: 'Qui peut m\'envoyer un message ?',
        answer:
            'Seuls les recruteurs vérifiés peuvent contacter les chercheurs. '
            'Cela garantit des échanges sérieux et de qualité. '
            'Vous recevrez une notification push à chaque nouveau message.',
      ),
      _FaqItem(
        question: 'Comment savoir si j\'ai de nouveaux messages ?',
        answer:
            'Un badge rouge apparaît sur l\'onglet Messages quand vous avez des messages non lus. '
            'Vous recevez également des notifications push sur votre téléphone.',
      ),
      _FaqItem(
        question: 'Puis-je bloquer ou signaler un utilisateur ?',
        answer:
            'Oui, dans une conversation, appuyez sur le menu (trois points) pour bloquer '
            'ou signaler un utilisateur. Notre équipe traite chaque signalement sous 48h.',
      ),
    ],
  ),
  const _FaqSection(
    title: 'Technique',
    icon: Icons.build_outlined,
    items: [
      _FaqItem(
        question: 'L\'application est disponible sur quel appareil ?',
        answer:
            'Etoile est disponible sur iPhone (iOS 15+) et Android (version 10+). '
            'Une connexion internet est nécessaire pour utiliser l\'application.',
      ),
      _FaqItem(
        question: 'Je ne reçois pas les notifications, que faire ?',
        answer:
            'Vérifiez que les notifications sont autorisées dans les paramètres de votre téléphone '
            '(Paramètres > Applications > Etoile > Notifications). '
            'Assurez-vous aussi que le mode "Ne pas déranger" est désactivé.',
      ),
      _FaqItem(
        question: 'Mes données sont-elles en sécurité ?',
        answer:
            'Absolument ! Vos données sont hébergées en Europe (Paris) et protégées par chiffrement. '
            'Nous respectons le RGPD et vous pouvez exporter ou supprimer vos données à tout moment.',
      ),
    ],
  ),
];
