import type { SeekerProfile } from "./types/database";

/**
 * Calculate match score between a seeker and an offer
 *
 * Algorithm weights:
 * - Sector match: 30%
 * - Study level: 25%
 * - Location: 25%
 * - Specialty: 20%
 *
 * @param seeker The seeker profile
 * @param offerSector The sector of the offer
 * @param recruiterLocations List of recruiter location cities
 * @returns Match score from 0 to 100
 */
export function calculateMatchScore(
  seeker: SeekerProfile,
  offerSector: string | null,
  recruiterLocations: string[]
): number {
  let score = 0;

  // Sector match (30%)
  if (seeker.domain && offerSector && seeker.domain === offerSector) {
    score += 30;
  }

  // Study level (25%)
  const studyLevelScore = getStudyLevelScore(seeker.study_level);
  score += studyLevelScore;

  // Location match (25%)
  if (seeker.city && recruiterLocations.length > 0) {
    const cityLower = seeker.city.toLowerCase();
    const hasMatch = recruiterLocations.some((loc) => {
      const locLower = loc.toLowerCase();
      return (
        cityLower.includes(locLower) ||
        locLower.includes(cityLower) ||
        cityLower === locLower
      );
    });
    if (hasMatch) {
      score += 25;
    }
  }

  // Specialty (20%) - for MVP, give points if specialty is filled
  // In V2, we can add fuzzy matching or related specialties
  if (seeker.specialty) {
    score += 20;
  }

  return Math.min(100, Math.max(0, score));
}

/**
 * Get study level score based on education level
 * Higher education = higher score
 *
 * @param level Study level code
 * @returns Score from 0 to 25
 */
function getStudyLevelScore(level: string | null): number {
  if (!level) return 0;

  const levels = [
    "sans_diplome",
    "cap_bep",
    "bac",
    "bac+1",
    "bac+2",
    "bac+3",
    "bac+4",
    "bac+5",
    "bac+8",
  ];

  const index = levels.indexOf(level);

  if (index >= 4) return 25; // bac+2 or higher
  if (index >= 2) return 15; // bac or bac+1
  if (index >= 0) return 5; // cap/bep or lower
  return 0;
}

/**
 * Get badge color variant based on score
 *
 * @param score Match score 0-100
 * @returns Badge color variant
 */
export function getScoreBadgeVariant(
  score: number
): "default" | "secondary" | "destructive" {
  if (score >= 80) return "default"; // green
  if (score >= 60) return "secondary"; // orange
  return "destructive"; // red
}

/**
 * Get score range label
 *
 * @param score Match score 0-100
 * @returns Score range label
 */
export function getScoreRangeLabel(score: number): string {
  if (score >= 80) return "Excellent match";
  if (score >= 60) return "Bon match";
  if (score >= 40) return "Match moyen";
  return "Faible match";
}
