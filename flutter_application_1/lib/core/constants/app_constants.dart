library;

/// Constantes globales de l'application Etoile.

/// Liste complete officielle des rythmes d'alternance en France.
///
/// Sources : pratiques reelles des ecoles et entreprises francaises.
/// Ordre : du plus frequent au moins frequent.
const List<String> alternanceRhythms = [
  // Rythmes hebdomadaires (les plus courants)
  '2 jours école / 3 jours entreprise',
  '3 jours école / 2 jours entreprise',
  '1 jour école / 4 jours entreprise',

  // Rythmes bi-hebdomadaires
  '1 semaine école / 1 semaine entreprise',
  '1 semaine école / 2 semaines entreprise',
  '1 semaine école / 3 semaines entreprise',

  // Rythmes mensuels / trimestriels
  '2 semaines école / 2 semaines entreprise',
  '1 mois école / 1 mois entreprise',
  '6 semaines école / 6 semaines entreprise',

  // Rythmes blocs (Bachelor, Master)
  '1 trimestre école / 1 trimestre entreprise',

  // Autre
  'Rythme personnalisé',
];

/// Mapping court vers affichage complet (pour compatibilite base de donnees).
const Map<String, String> rhythmShortToFull = {
  '3j/2j': '3 jours école / 2 jours entreprise',
  '2j/3j': '2 jours école / 3 jours entreprise',
  '1j/4j': '1 jour école / 4 jours entreprise',
  '1sem/1sem': '1 semaine école / 1 semaine entreprise',
  '1sem/2sem': '1 semaine école / 2 semaines entreprise',
  '1sem/3sem': '1 semaine école / 3 semaines entreprise',
  '2sem/2sem': '2 semaines école / 2 semaines entreprise',
  '1mois/1mois': '1 mois école / 1 mois entreprise',
  '6sem/6sem': '6 semaines école / 6 semaines entreprise',
  '1tri/1tri': '1 trimestre école / 1 trimestre entreprise',
  'mensuel': '1 mois école / 1 mois entreprise',
  'personnalise': 'Rythme personnalisé',
};

/// Mapping affichage complet vers code court (pour sauvegarde DB).
const Map<String, String> rhythmFullToShort = {
  '3 jours école / 2 jours entreprise': '3j/2j',
  '2 jours école / 3 jours entreprise': '2j/3j',
  '1 jour école / 4 jours entreprise': '1j/4j',
  '1 semaine école / 1 semaine entreprise': '1sem/1sem',
  '1 semaine école / 2 semaines entreprise': '1sem/2sem',
  '1 semaine école / 3 semaines entreprise': '1sem/3sem',
  '2 semaines école / 2 semaines entreprise': '2sem/2sem',
  '1 mois école / 1 mois entreprise': '1mois/1mois',
  '6 semaines école / 6 semaines entreprise': '6sem/6sem',
  '1 trimestre école / 1 trimestre entreprise': '1tri/1tri',
  'Rythme personnalisé': 'personnalise',
};
