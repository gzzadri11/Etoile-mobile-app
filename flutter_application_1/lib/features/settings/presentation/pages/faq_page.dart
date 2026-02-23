import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';

/// FAQ page with expandable sections organized by theme.
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
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.search_off,
                            size: 48, color: AppColors.greyMedium),
                        const SizedBox(height: AppTheme.spaceMd),
                        Text(
                          'Aucun resultat pour "$_searchQuery"',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppColors.greyWarm,
                                  ),
                        ),
                      ],
                    ),
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
                                    color: AppColors.greyWarm,
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
          Icon(icon, color: AppColors.primaryOrange, size: 20),
          const SizedBox(width: AppTheme.spaceSm),
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: AppColors.primaryOrange,
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
                  color: AppColors.greyWarm,
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
            'Bien sur ! Vous pouvez modifier votre profil a tout moment depuis '
            'l\'onglet Profil > Modifier mon profil. Vos modifications sont enregistrees instantanement.',
      ),
      _FaqItem(
        question: 'Comment supprimer mon compte ?',
        answer:
            'Rendez-vous dans Parametres > Contacter le support et faites une demande de suppression. '
            'Conformement au RGPD, vos donnees seront supprimees sous 30 jours.',
      ),
    ],
  ),
  const _FaqSection(
    title: 'Video',
    icon: Icons.videocam_outlined,
    items: [
      _FaqItem(
        question: 'Comment enregistrer ma video de presentation ?',
        answer:
            'Depuis l\'onglet Profil, appuyez sur "Modifier ma video". '
            'Vous disposez de 40 secondes pour vous presenter en 3 etapes guidees. '
            'Trouvez un endroit calme et bien eclaire pour un meilleur resultat !',
      ),
      _FaqItem(
        question: 'Puis-je re-enregistrer ma video ?',
        answer:
            'Oui, vous pouvez re-enregistrer autant de fois que vous le souhaitez '
            'avant de publier. Une fois publiee, vous pouvez toujours en enregistrer une nouvelle '
            'qui remplacera l\'ancienne.',
      ),
      _FaqItem(
        question: 'Quelle est la duree maximale d\'une video ?',
        answer:
            'Chaque video dure 40 secondes maximum, divisee en 3 phases de coaching : '
            'presentation, competences et motivation. Ce format court permet aux recruteurs '
            'de decouvrir rapidement votre personnalite.',
      ),
      _FaqItem(
        question: 'Ma video ne s\'uploade pas, que faire ?',
        answer:
            'Verifiez votre connexion internet et reessayez. Si le probleme persiste, '
            'redemarrez l\'application. La taille maximale est de 50 Mo. '
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
            'Seuls les recruteurs verifies peuvent contacter les chercheurs. '
            'Cela garantit des echanges serieux et de qualite. '
            'Vous recevrez une notification push a chaque nouveau message.',
      ),
      _FaqItem(
        question: 'Comment savoir si j\'ai de nouveaux messages ?',
        answer:
            'Un badge rouge apparait sur l\'onglet Messages quand vous avez des messages non lus. '
            'Vous recevez egalement des notifications push sur votre telephone.',
      ),
      _FaqItem(
        question: 'Puis-je bloquer ou signaler un utilisateur ?',
        answer:
            'Oui, dans une conversation, appuyez sur le menu (trois points) pour bloquer '
            'ou signaler un utilisateur. Notre equipe traite chaque signalement sous 48h.',
      ),
    ],
  ),
  const _FaqSection(
    title: 'Paiements & Premium',
    icon: Icons.star_outline,
    items: [
      _FaqItem(
        question: 'Quels sont les avantages Premium ?',
        answer:
            'En tant que chercheur Premium (4,99 EUR/mois), vous voyez qui a consulte votre video, '
            'acces aux statistiques detaillees et un badge Premium visible. '
            'Les recruteurs Premium (499 EUR/mois) ont des publications incluses et un acces prioritaire.',
      ),
      _FaqItem(
        question: 'Comment m\'abonner a Premium ?',
        answer:
            'Rendez-vous dans Parametres > Premium, puis appuyez sur "S\'abonner". '
            'Le paiement est securise via Stripe. Vous pouvez annuler a tout moment.',
      ),
      _FaqItem(
        question: 'Comment annuler mon abonnement ?',
        answer:
            'Dans Parametres > Premium, appuyez sur "Gerer mon abonnement". '
            'Votre acces Premium reste actif jusqu\'a la fin de la periode en cours.',
      ),
      _FaqItem(
        question: 'Les credits sont-ils remboursables ?',
        answer:
            'Les credits achetes a l\'unite (video ou affiche) ne sont pas remboursables '
            'une fois utilises. Les credits non utilises restent sur votre compte sans expiration.',
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
            'Une connexion internet est necessaire pour utiliser l\'application.',
      ),
      _FaqItem(
        question: 'Je ne recois pas les notifications, que faire ?',
        answer:
            'Verifiez que les notifications sont autorisees dans les parametres de votre telephone '
            '(Parametres > Applications > Etoile > Notifications). '
            'Assurez-vous aussi que le mode "Ne pas deranger" est desactive.',
      ),
      _FaqItem(
        question: 'Mes donnees sont-elles en securite ?',
        answer:
            'Absolument ! Vos donnees sont hebergees en Europe (Paris) et protegees par chiffrement. '
            'Nous respectons le RGPD et vous pouvez exporter ou supprimer vos donnees a tout moment.',
      ),
    ],
  ),
];
