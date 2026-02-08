/// Application string constants
///
/// Contains all user-facing strings for localization.
/// Organized by feature/screen for easy maintenance.
abstract class AppStrings {
  // ============================================
  // APP GENERAL
  // ============================================
  static const String appName = 'Etoile';
  static const String appTagline = '40 secondes pour briller';

  // ============================================
  // ONBOARDING
  // ============================================
  static const String welcomeTitle = 'Bienvenue sur Etoile';
  static const String welcomeSubtitle = '40 secondes pour montrer qui vous etes vraiment';
  static const String iAmSeeker = 'Je cherche un emploi';
  static const String iAmRecruiter = 'Je recrute';

  // ============================================
  // AUTHENTICATION
  // ============================================
  static const String login = 'Connexion';
  static const String register = 'Inscription';
  static const String logout = 'Deconnexion';
  static const String email = 'Email';
  static const String password = 'Mot de passe';
  static const String confirmPassword = 'Confirmer le mot de passe';
  static const String forgotPassword = 'Mot de passe oublie ?';
  static const String createAccount = 'Creons votre compte';
  static const String createAccountSubtitle = "C'est rapide, promis !";
  static const String alreadyHaveAccount = 'Deja un compte ?';
  static const String noAccount = 'Pas encore de compte ?';

  // ============================================
  // PROFILE SETUP
  // ============================================
  static const String tellUsAboutYou = 'Parlez-nous de vous';
  static const String tellUsAboutYouSubtitle = 'Ces infos aident les recruteurs a vous trouver';
  static const String firstName = 'Prenom';
  static const String lastName = 'Nom';
  static const String phone = 'Telephone';
  static const String sector = 'Secteur recherche';
  static const String contractType = 'Type de contrat';
  static const String location = 'Localisation';
  static const String availability = 'Disponibilite';
  static const String companyName = 'Nom de l\'entreprise';
  static const String siret = 'SIRET';
  static const String companyDescription = 'Description de l\'entreprise';

  // ============================================
  // VIDEO RECORDING
  // ============================================
  static const String readyToShine = 'Pret a briller ?';
  static const String noEditNoStress = 'Pas de montage, pas de stress. Juste vous.';
  static const String recordNow = 'Enregistrer maintenant';
  static const String later = 'Plus tard';
  static const String startRecording = 'Demarrer l\'enregistrement';
  static const String reRecord = 'Re-enregistrer';
  static const String publishVideo = 'Publier ma video';
  static const String videoTip = 'Trouvez un endroit calme et bien eclaire';

  // Video phases
  static const String phase1Prompt = 'Presentez-vous en quelques mots';
  static const String phase2Prompt = 'Parlez de vos competences cles';
  static const String phase3Prompt = 'Pourquoi vous choisir ?';

  // ============================================
  // FEED
  // ============================================
  static const String feed = 'Feed';
  static const String filters = 'Filtres';
  static const String search = 'Recherche';
  static const String apply = 'Appliquer';
  static const String reset = 'Reinitialiser';
  static const String noResults = 'Aucun profil ne correspond a vos criteres. Modifiez vos filtres.';
  static const String endOfFeed = 'Vous avez tout vu ! Revenez bientot.';

  // ============================================
  // MESSAGES
  // ============================================
  static const String messages = 'Messages';
  static const String typeMessage = 'Votre message...';
  static const String send = 'Envoyer';
  static const String noMessages = 'Votre video est decouverte par les recruteurs';
  static const String noMessagesSubtitle = 'Les opportunites arrivent bientot !';
  static const String today = 'Aujourd\'hui';
  static const String thisWeek = 'Cette semaine';

  // Message templates
  static const String templateInterested = 'Votre profil m\'interesse, discutons !';
  static const String templateOpportunity = 'J\'ai une opportunite qui pourrait vous convenir';

  // ============================================
  // PROFILE
  // ============================================
  static const String profile = 'Profil';
  static const String editProfile = 'Modifier mon profil';
  static const String editVideo = 'Modifier ma video';
  static const String viewMyVideo = 'Voir ma video';
  static const String statistics = 'Statistiques';
  static const String profileViewed = 'Votre profil a ete vu';
  static const String goPremiumForDetails = 'Passez Premium pour les details';
  static const String verifiedBadge = 'Verifie';
  static const String pendingVerification = 'En cours de verification';

  // ============================================
  // PREMIUM
  // ============================================
  static const String premium = 'Premium';
  static const String goPremium = 'Passer Premium';
  static const String premiumBenefits = 'Avantages Premium';
  static const String subscribe = 'S\'abonner';
  static const String perMonth = '/mois';

  // ============================================
  // SETTINGS
  // ============================================
  static const String settings = 'Parametres';
  static const String help = 'Aide';
  static const String faq = 'FAQ';
  static const String contactSupport = 'Contacter le support';
  static const String privacyPolicy = 'Politique de confidentialite';
  static const String termsOfService = 'Conditions d\'utilisation';
  static const String deleteAccount = 'Supprimer mon compte';
  static const String about = 'A propos';

  // ============================================
  // ACTIONS
  // ============================================
  static const String continueAction = 'Continuer';
  static const String cancel = 'Annuler';
  static const String confirm = 'Confirmer';
  static const String save = 'Enregistrer';
  static const String delete = 'Supprimer';
  static const String block = 'Bloquer';
  static const String report = 'Signaler';
  static const String retry = 'Reessayer';
  static const String close = 'Fermer';
  static const String back = 'Retour';

  // ============================================
  // SUCCESS MESSAGES (Warm tone)
  // ============================================
  static const String successVideoPublished = 'Bravo ! Votre etoile brille maintenant dans le ciel Etoile.';
  static const String successFirstMessage = 'Bonne nouvelle ! Un recruteur s\'interesse a votre profil.';
  static const String successMessageSent = 'Message envoye ! Croisons les doigts.';
  static const String successVerified = 'Felicitations ! Votre compte est maintenant verifie.';

  // ============================================
  // ERROR MESSAGES (Human tone)
  // ============================================
  static const String errorNetwork = 'Oups, petit souci de connexion. Reessayez dans un instant.';
  static const String errorUpload = 'Aie, la video n\'a pas pu etre envoyee. On reessaie ?';
  static const String errorSession = 'Votre session a expire. Reconnectez-vous pour continuer.';
  static const String errorGeneric = 'Quelque chose s\'est mal passe. Notre equipe est sur le coup !';
  static const String errorInvalidEmail = 'Veuillez entrer un email valide';
  static const String errorInvalidPassword = 'Le mot de passe doit contenir au moins 8 caracteres';
  static const String errorPasswordMismatch = 'Les mots de passe ne correspondent pas';
  static const String errorFieldRequired = 'Ce champ est requis';

  // ============================================
  // INFO MESSAGES
  // ============================================
  static const String infoVerificationPending = 'Votre compte est en cours de verification. Patience !';
  static const String infoStatsNonPremium = 'Votre profil a ete vu. Passez Premium pour les details.';

  // ============================================
  // AVAILABILITY OPTIONS
  // ============================================
  static const String availabilityImmediate = 'Immediate';
  static const String availability1Month = 'Sous 1 mois';
  static const String availability3Months = 'Sous 3 mois';
  static const String availabilityFlexible = 'Flexible';

  // ============================================
  // CONTRACT TYPES
  // ============================================
  static const String contractCDI = 'CDI';
  static const String contractCDD = 'CDD';
  static const String contractAlternance = 'Alternance';
  static const String contractStage = 'Stage';
  static const String contractInterim = 'Interim';
}
