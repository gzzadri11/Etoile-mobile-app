library;

/// Calcul du score de matching chercheur ↔ offre (FeedItem).
///
/// Critères (total 100%) :
/// - Secteur/domaine  : 25%
/// - Spécialité       : 20%
/// - Ville/zone       : 20%
/// - Niveau d'études  : 15%
/// - Compétences      : 20% (neutre si aucun keyword défini sur l'offre)

import '../../features/feed/data/models/feed_item_model.dart';
import '../../features/profile/data/models/seeker_profile_model.dart';

/// Calcul du score de matching entre un chercheur et une offre du feed.
class MatchingScore {
  MatchingScore._();

  /// Retourne un score entre 0 et 100.
  ///
  /// [seeker] : profil du chercheur (domain, specialty, city, studyLevel, skills)
  /// [offer]  : item du feed représentant l'offre (sector, specialty, city, studyLevel)
  static int calculate({
    required SeekerProfile seeker,
    required FeedItem offer,
  }) {
    double score = 0;

    // ── SECTEUR (25%) ── seeker.domain ↔ offer.sector
    if (seeker.domain != null && offer.sector != null) {
      if (seeker.domain == offer.sector) {
        score += 0.25;
      }
    }

    // ── SPÉCIALITÉ (20%) ── correspondance exacte ou partielle
    if (seeker.specialty != null && offer.specialty != null) {
      final ss = seeker.specialty!.toLowerCase().trim();
      final os = offer.specialty!.toLowerCase().trim();
      if (ss == os) {
        score += 0.20;
      } else if (ss.contains(os) || os.contains(ss)) {
        score += 0.10; // correspondance partielle
      }
    }

    // ── VILLE / ZONE (20%) ── exacte = 20%, même zone IdF = 10%
    if (seeker.city != null && offer.city != null) {
      final sc = seeker.city!.toLowerCase().trim();
      final oc = offer.city!.toLowerCase().trim();
      if (sc == oc) {
        score += 0.20;
      } else if (_sameZoneIdf(sc, oc)) {
        score += 0.10;
      }
    }

    // ── NIVEAU D'ÉTUDES (15%) ── exact = 15%, adjacent = 8%
    if (seeker.studyLevel != null && offer.studyLevel != null) {
      score += 0.15 * _levelScore(seeker.studyLevel!, offer.studyLevel!);
    }

    // ── COMPÉTENCES (20%) ── skills chercheur vs keywords offre
    // Note : FeedItem n'expose pas encore les keywords — score neutre (10%)
    // À activer quand Video.keywords sera mappé dans FeedItem.
    score += 0.10;

    return (score * 100).round().clamp(0, 100);
  }

  // ── Helpers ──

  static double _levelScore(String seekerLevel, String offerLevel) {
    const levels = ['Bac', 'Bac+2', 'Bac+3', 'Bac+4', 'Bac+5'];
    final si = levels.indexOf(seekerLevel);
    final ri = levels.indexOf(offerLevel);
    if (si == -1 || ri == -1) return 0.5; // niveau inconnu → neutre
    final diff = (si - ri).abs();
    if (diff == 0) return 1.0;
    if (diff == 1) return 0.5;
    return 0.0;
  }

  static bool _sameZoneIdf(String city1, String city2) {
    const zones = [
      ['paris'],
      ['vincennes', 'montreuil', 'saint-maur', 'nogent', 'joinville', 'charenton'],
      ['boulogne', 'neuilly', 'levallois', 'issy', 'vanves', 'malakoff', 'clamart'],
      ['saint-denis', 'aubervilliers', 'pantin', 'le blanc-mesnil', 'bobigny'],
      ['créteil', 'ivry', 'vitry', 'choisy', 'villejuif', 'alfortville'],
      ['versailles', 'saint-germain', 'poissy', 'mantes'],
    ];
    for (final zone in zones) {
      final c1 = zone.any((z) => city1.contains(z));
      final c2 = zone.any((z) => city2.contains(z));
      if (c1 && c2) return true;
    }
    return false;
  }

  /// Formate le score pour affichage (ex : "78%").
  static String format(int score) => '$score%';

  /// Couleur sémantique selon le score.
  static ({int r, int g, int b}) scoreColor(int score) {
    if (score >= 75) return (r: 16, g: 185, b: 129); // success #10B981
    if (score >= 50) return (r: 99, g: 91, b: 255);  // accent #635BFF
    if (score >= 25) return (r: 245, g: 158, b: 11); // warning #F59E0B
    return (r: 239, g: 68, b: 68);                   // danger #EF4444
  }
}
