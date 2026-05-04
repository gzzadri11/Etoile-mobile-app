"use client";

import { useCallback, useEffect, useState } from "react";
import { createClient } from "@/lib/supabase/client";
import type { CandidateWithProfile } from "@/lib/types/database";
import { CandidateCard } from "@/components/candidates/candidate-card";
import { CandidateModal } from "@/components/candidates/candidate-modal";
import {
  CandidateFiltersComponent,
  type CandidateFilters,
} from "@/components/candidates/candidate-filters";
import { calculateMatchScore } from "@/lib/scoring";
import { calculateAndStoreMatchScore } from "./actions";
import { UserX } from "lucide-react";

type CandidateWithScore = CandidateWithProfile & { matchScore: number };

export default function CandidatesPage() {
  const [candidates, setCandidates] = useState<CandidateWithScore[]>([]);
  const [filteredCandidates, setFilteredCandidates] = useState<CandidateWithScore[]>([]);
  const [loading, setLoading] = useState(true);
  const [selectedCandidate, setSelectedCandidate] = useState<CandidateWithScore | null>(null);
  const [recruiterLocations, setRecruiterLocations] = useState<string[]>([]);

  // Filters
  const [filters, setFilters] = useState<CandidateFilters>({
    status: "all",
    offerId: "all",
    sector: "all",
    scoreRange: "all",
    rhythm: "all",
  });

  const loadCandidates = useCallback(async () => {
    const supabase = createClient();
    const {
      data: { user },
    } = await supabase.auth.getUser();
    if (!user) return;

    // Load recruiter profile for locations
    const { data: recruiterProfile } = await supabase
      .from("recruiter_profiles")
      .select("locations")
      .eq("user_id", user.id)
      .single();

    const locations = recruiterProfile?.locations ?? [];
    setRecruiterLocations(locations);

    // Load applications for this recruiter (exclude withdrawn)
    const { data: apps } = await supabase
      .from("applications")
      .select("*")
      .eq("recruiter_id", user.id)
      .in("status", ["pending", "contacted"])
      .order("applied_at", { ascending: false });

    if (!apps || apps.length === 0) {
      setLoading(false);
      return;
    }

    // Epic 14: Load all match scores for this recruiter's offers
    const offerIds = [...new Set(apps.map((a) => a.video_id))];
    const { data: existingScores } = await supabase
      .from("match_scores")
      .select("seeker_id, video_id, score")
      .in("video_id", offerIds);

    // Create a Map for fast score lookup
    const scoresMap = new Map<string, number>();
    existingScores?.forEach((s) => {
      scoresMap.set(`${s.seeker_id}_${s.video_id}`, s.score);
    });

    // For each application, fetch related data
    const enriched: CandidateWithScore[] = await Promise.all(
      apps.map(async (app) => {
        // Fetch seeker profile
        const { data: seekerProfile } = await supabase
          .from("seeker_profiles")
          .select("*")
          .eq("user_id", app.seeker_id)
          .single();

        // Fetch offer details
        const { data: offerVideo } = await supabase
          .from("videos")
          .select("id, title, type, sector, contract_type")
          .eq("id", app.video_id)
          .single();

        // Find seeker's presentation video
        const { data: presentationVideo } = await supabase
          .from("videos")
          .select("id, video_key, video_url, thumbnail_key, thumbnail_url, duration_seconds")
          .eq("user_id", app.seeker_id)
          .eq("type", "presentation")
          .eq("status", "active")
          .order("created_at", { ascending: false })
          .limit(1)
          .maybeSingle();

        // Epic 14: Get match score from PostgreSQL or calculate if missing
        const scoreKey = `${app.seeker_id}_${app.video_id}`;
        let matchScore = scoresMap.get(scoreKey);

        if (matchScore === undefined) {
          // Score doesn't exist - calculate and store via PostgreSQL function
          const calculatedScore = await calculateAndStoreMatchScore(
            app.seeker_id,
            app.video_id
          );
          matchScore = calculatedScore ?? calculateMatchScore(
            seekerProfile!,
            offerVideo?.sector ?? null,
            locations
          );
        }

        return {
          application: {
            id: app.id,
            video_id: app.video_id,
            seeker_id: app.seeker_id,
            recruiter_id: app.recruiter_id,
            status: app.status,
            applied_at: app.applied_at,
          },
          seeker: seekerProfile!,
          offer: offerVideo!,
          presentation_video: presentationVideo,
          matchScore,
        };
      })
    );

    // Sort by match score descending
    enriched.sort((a, b) => b.matchScore - a.matchScore);

    setCandidates(enriched);
    setFilteredCandidates(enriched);
    setLoading(false);
  }, []);

  useEffect(() => {
    loadCandidates();
  }, [loadCandidates]);

  // Apply filters
  useEffect(() => {
    let filtered = [...candidates];

    // Status filter
    if (filters.status !== "all") {
      filtered = filtered.filter((c) => c.application.status === filters.status);
    }

    // Offer filter
    if (filters.offerId !== "all") {
      filtered = filtered.filter((c) => c.offer.id === filters.offerId);
    }

    // Sector filter
    if (filters.sector !== "all") {
      filtered = filtered.filter((c) => c.seeker.domain === filters.sector);
    }

    // Rhythm filter
    if (filters.rhythm !== "all") {
      filtered = filtered.filter((c) => c.seeker.rhythm === filters.rhythm);
    }

    // Score range filter
    if (filters.scoreRange === "high") {
      filtered = filtered.filter((c) => c.matchScore >= 80);
    } else if (filters.scoreRange === "medium") {
      filtered = filtered.filter((c) => c.matchScore >= 60 && c.matchScore < 80);
    } else if (filters.scoreRange === "low") {
      filtered = filtered.filter((c) => c.matchScore < 60);
    }

    setFilteredCandidates(filtered);
  }, [candidates, filters]);

  // Get unique offers for filter dropdown
  const uniqueOffers = Array.from(
    new Map(candidates.map((c) => [c.offer.id, c.offer])).values()
  );

  if (loading) {
    return (
      <div className="flex items-center justify-center py-20">
        <p className="text-muted-foreground">Chargement...</p>
      </div>
    );
  }

  return (
    <div className="flex gap-6 -m-8 h-[calc(100vh-5rem)]">
      {/* Sidebar filters - Fixed height, scrollable */}
      <div className="w-64 shrink-0 overflow-y-auto border-r bg-muted/30">
        <CandidateFiltersComponent
          offers={uniqueOffers}
          filters={filters}
          onFiltersChange={setFilters}
        />
      </div>

      {/* Main content - Scrollable */}
      <div className="flex-1 overflow-y-auto pr-8 pt-0">
        {/* Header with count */}
        <div className="mb-6 flex items-center justify-between sticky top-0 bg-background py-4 z-10 border-b border-border">
          <h1 className="font-display text-3xl font-semibold tracking-tight">Candidats</h1>
          <div className="font-mono text-sm text-text-secondary">
            {filteredCandidates.length} candidat{filteredCandidates.length !== 1 ? "s" : ""}
          </div>
        </div>

        {/* Grid */}
        {filteredCandidates.length === 0 ? (
          <div className="flex flex-col items-center justify-center rounded-lg border border-dashed border-border bg-bg-subtle py-20">
            <UserX className="h-12 w-12 text-text-tertiary mb-4" strokeWidth={1.5} />
            <p className="font-display text-lg font-medium italic text-text-primary">Aucun candidat trouvé</p>
            <p className="mt-2 max-w-md text-center text-sm text-text-secondary">
              {candidates.length === 0
                ? "Les candidatures apparaîtront ici dès que des chercheurs postuleront à vos offres."
                : "Essayez de modifier vos filtres pour voir plus de candidats."}
            </p>
          </div>
        ) : (
          <div className="grid gap-6 sm:grid-cols-2 lg:grid-cols-3 2xl:grid-cols-4">
            {filteredCandidates.map((candidate) => (
              <CandidateCard
                key={candidate.application.id}
                candidate={candidate}
                matchScore={candidate.matchScore}
                onClick={() => setSelectedCandidate(candidate)}
              />
            ))}
          </div>
        )}
      </div>

      {/* Modal */}
      <CandidateModal
        candidate={selectedCandidate}
        open={selectedCandidate !== null}
        onOpenChange={(open) => {
          if (!open) setSelectedCandidate(null);
        }}
        onStatusChanged={loadCandidates}
      />
    </div>
  );
}
