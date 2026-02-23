import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_theme.dart';

/// Generic legal page displaying static text content in a ScrollView.
///
/// Reused for: Mentions legales, CGU, Politique de confidentialite.
class LegalPage extends StatelessWidget {
  final String title;
  final List<LegalSection> sections;

  const LegalPage._({
    required this.title,
    required this.sections,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spaceMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Derniere mise a jour : 1er janvier 2026',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.greyWarm,
                  ),
            ),
            const SizedBox(height: AppTheme.spaceLg),
            for (final section in sections) ...[
              Text(
                section.heading,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: AppTheme.spaceSm),
              Text(
                section.body,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.greyWarm,
                      height: 1.6,
                    ),
              ),
              const SizedBox(height: AppTheme.spaceLg),
            ],
          ],
        ),
      ),
    );
  }

  // =========================================================================
  // FACTORY CONSTRUCTORS
  // =========================================================================

  /// Conditions Generales d'Utilisation
  factory LegalPage.termsOfService() => const LegalPage._(
        title: 'Conditions d\'utilisation',
        sections: _termsOfServiceSections,
      );

  /// Politique de Confidentialite
  factory LegalPage.privacyPolicy() => const LegalPage._(
        title: 'Politique de confidentialite',
        sections: _privacyPolicySections,
      );

  /// Mentions Legales
  factory LegalPage.legalNotice() => const LegalPage._(
        title: 'Mentions legales',
        sections: _legalNoticeSections,
      );
}

// =============================================================================
// DATA
// =============================================================================

class LegalSection {
  final String heading;
  final String body;
  const LegalSection({required this.heading, required this.body});
}

// ---------------------------------------------------------------------------
// CGU
// ---------------------------------------------------------------------------
const _termsOfServiceSections = [
  LegalSection(
    heading: '1. Objet',
    body:
        'Les presentes Conditions Generales d\'Utilisation (CGU) regissent l\'utilisation '
        'de l\'application mobile Etoile, editee par Etoile SAS. En utilisant l\'application, '
        'vous acceptez sans reserve les presentes conditions.',
  ),
  LegalSection(
    heading: '2. Description du service',
    body:
        'Etoile est une plateforme de mise en relation entre chercheurs d\'emploi et recruteurs '
        'via des videos courtes de 40 secondes. Le service permet aux chercheurs de se presenter '
        'de maniere authentique et aux recruteurs de decouvrir des talents.',
  ),
  LegalSection(
    heading: '3. Inscription et compte',
    body:
        'L\'inscription est gratuite et ouverte a toute personne majeure. Vous etes responsable '
        'de la confidentialite de vos identifiants. Tout usage frauduleux doit etre signale '
        'immediatement. Les recruteurs doivent fournir un numero SIRET valide.',
  ),
  LegalSection(
    heading: '4. Contenu utilisateur',
    body:
        'Vous conservez la propriete de vos contenus (videos, textes, images). En les publiant, '
        'vous accordez a Etoile une licence non-exclusive pour les afficher dans l\'application. '
        'Tout contenu illegal, discriminant ou inapproprie est interdit et sera supprime.',
  ),
  LegalSection(
    heading: '5. Abonnements et paiements',
    body:
        'Etoile propose des abonnements Premium avec facturation mensuelle. Les paiements sont '
        'securises via Stripe. Vous pouvez annuler a tout moment ; l\'acces reste actif jusqu\'a '
        'la fin de la periode payee. Les credits achetes a l\'unite ne sont pas remboursables.',
  ),
  LegalSection(
    heading: '6. Responsabilite',
    body:
        'Etoile s\'efforce d\'assurer la disponibilite du service mais ne garantit pas un acces '
        'ininterrompu. Etoile n\'est pas responsable des echanges entre utilisateurs ni du contenu '
        'publie par les utilisateurs. Nous nous reservons le droit de suspendre tout compte '
        'ne respectant pas les presentes CGU.',
  ),
  LegalSection(
    heading: '7. Modification des CGU',
    body:
        'Etoile se reserve le droit de modifier les presentes CGU. Les utilisateurs seront '
        'informes par notification. La poursuite de l\'utilisation vaut acceptation des nouvelles conditions.',
  ),
  LegalSection(
    heading: '8. Droit applicable',
    body:
        'Les presentes CGU sont regies par le droit francais. Tout litige sera soumis '
        'aux tribunaux competents de Paris.',
  ),
];

// ---------------------------------------------------------------------------
// POLITIQUE DE CONFIDENTIALITE
// ---------------------------------------------------------------------------
const _privacyPolicySections = [
  LegalSection(
    heading: '1. Responsable du traitement',
    body:
        'Etoile SAS, societe immatriculee au RCS de Paris. '
        'Contact : privacy@etoile-app.fr',
  ),
  LegalSection(
    heading: '2. Donnees collectees',
    body:
        'Nous collectons les donnees suivantes :\n'
        '- Identite : nom, prenom, email, telephone\n'
        '- Profil professionnel : secteur, contrat, localisation, disponibilite\n'
        '- Contenus : videos, photos de profil\n'
        '- Donnees techniques : appareil, version OS, adresse IP anonymisee\n'
        '- Donnees de paiement : gerees par Stripe (nous ne stockons pas vos numeros de carte)',
  ),
  LegalSection(
    heading: '3. Finalites du traitement',
    body:
        '- Fourniture du service de mise en relation\n'
        '- Gestion de votre compte et de vos abonnements\n'
        '- Amelioration du service et statistiques anonymes\n'
        '- Communication (notifications, support)\n'
        '- Securite et prevention des fraudes',
  ),
  LegalSection(
    heading: '4. Base legale',
    body:
        'Le traitement de vos donnees repose sur :\n'
        '- L\'execution du contrat (fourniture du service)\n'
        '- Votre consentement (notifications push, cookies)\n'
        '- L\'interet legitime (amelioration du service, securite)',
  ),
  LegalSection(
    heading: '5. Duree de conservation',
    body:
        'Vos donnees sont conservees pendant la duree de votre inscription. '
        'En cas de suppression de compte, vos donnees sont effacees sous 30 jours. '
        'Les donnees de paiement sont conservees selon les obligations legales (10 ans).',
  ),
  LegalSection(
    heading: '6. Partage des donnees',
    body:
        'Vos donnees ne sont jamais vendues. Elles peuvent etre partagees avec :\n'
        '- Les autres utilisateurs (profil public, videos)\n'
        '- Nos sous-traitants techniques (Supabase, Cloudflare, Stripe, Firebase)\n'
        '- Les autorites competentes sur demande legale',
  ),
  LegalSection(
    heading: '7. Hebergement',
    body:
        'Vos donnees sont hebergees en Union Europeenne (region Paris) '
        'chez Supabase (base de donnees) et Cloudflare (videos). '
        'Les transferts hors UE sont encadres par des clauses contractuelles types.',
  ),
  LegalSection(
    heading: '8. Vos droits (RGPD)',
    body:
        'Conformement au RGPD, vous disposez des droits suivants :\n'
        '- Acces : obtenir une copie de vos donnees\n'
        '- Rectification : corriger vos informations\n'
        '- Suppression : demander l\'effacement de vos donnees\n'
        '- Portabilite : recevoir vos donnees au format JSON\n'
        '- Opposition : vous opposer a certains traitements\n\n'
        'Pour exercer vos droits : privacy@etoile-app.fr\n'
        'Vous pouvez egalement saisir la CNIL (cnil.fr).',
  ),
];

// ---------------------------------------------------------------------------
// MENTIONS LEGALES
// ---------------------------------------------------------------------------
const _legalNoticeSections = [
  LegalSection(
    heading: 'Editeur',
    body:
        'Etoile SAS\n'
        'Societe par actions simplifiee\n'
        'Capital social : 1 000 EUR\n'
        'Siege social : Paris, France\n'
        'RCS Paris (en cours d\'immatriculation)\n'
        'Email : contact@etoile-app.fr',
  ),
  LegalSection(
    heading: 'Directeur de la publication',
    body: 'Le representant legal de la societe Etoile SAS.',
  ),
  LegalSection(
    heading: 'Hebergement',
    body:
        'Base de donnees : Supabase Inc., 970 Toa Payoh North #07-04, Singapore 318992\n'
        'Stockage video : Cloudflare Inc., 101 Townsend St, San Francisco, CA 94107, USA\n'
        'Donnees hebergees en Union Europeenne (region Paris).',
  ),
  LegalSection(
    heading: 'Propriete intellectuelle',
    body:
        'L\'ensemble des elements composant l\'application Etoile (design, textes, logo, code) '
        'est protege par le droit de la propriete intellectuelle. Toute reproduction est interdite '
        'sans autorisation prealable.',
  ),
  LegalSection(
    heading: 'Contact',
    body:
        'Pour toute question relative aux mentions legales :\n'
        'Email : legal@etoile-app.fr',
  ),
];
