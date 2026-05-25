"use client";

import { useCallback, useEffect, useState } from "react";
import { createClient } from "@/lib/supabase/client";
import type { Video, CandidateWithProfile } from "@/lib/types/database";
import { calculateMatchScore } from "@/lib/scoring";
import { calculateAndStoreMatchScore } from "@/app/(dashboard)/candidates/actions";
import { CandidateCard } from "@/components/candidates/candidate-card";
import { CandidateModal } from "@/components/candidates/candidate-modal";
import { PageHeader } from "@/components/layout/PageHeader";
import { UserX, ArrowLeft } from "lucide-react";

type CandidateWithScore = CandidateWithProfile & { matchScore: number };

type ScoreFilter = "all" | "high" | "medium" | "low";

interface OfferCandidatesViewProps {
  offer: Video;
  onBack: () => void;
}

export function OfferCandidatesView({ offer, onBack }: OfferCandidatesViewProps) {
  const [candidates, setCandidates] = useState<CandidateWithScore[]>([]);
  const [filtered, setFiltered] = useState<CandidateWithScore[]>([]);
  const [loading, setLoading] = useState(true);
  const [selected, setSelected] = useState<CandidateWithScore | null>(null);
  const [scoreFilter, setScoreFilter] = useState<ScoreFilter>("all");

  const loadCandidates = useCallback(async () => {
    const supabase = createClient();
    const { data: { user } } = await supabase.auth.getUser();
    if (!user) return;

    const { data: recruiterProfile } = await supabase
      .from("recruiter_profiles")
      .select("locations")
      .eq("user_id", user.id)
      .single();
    const locations = recruiterProfile?.locations ?? [];

    const { data: apps } = await supabase
      .from("applications")
      .select("*")
      .eq("video_id", offer.id)
      .eq("recruiter_id", user.id)
      .in("status", ["pending", "contacted"])
      .order("applied_at", { ascending: false });

    if (!apps || apps.length === 0) {
      setLoading(false);
      return;
    }

    const { data: existingScores } = await supabase
      .from("match_scores")
      .select("seeker_id, video_id, score")
      .eq("video_id", offer.id);

    const scoresMap = new Map<string, number>();
    existingScores?.forEach((s) => scoresMap.set(s.seeker_id, s.score));

    const enriched: CandidateWithScore[] = await Promise.all(
      apps.map(async (app) => {
        const { data: seekerProfile } = await supabase
          .from("seeker_profiles")
          .select("*")
          .eq("user_id", app.seeker_id)
          .single();

        const { data: presentationVideo } = await supabase
          .from("videos")
          .select("id, video_key, video_url, thumbnail_key, thumbnail_url, duration_seconds")
          .eq("user_id", app.seeker_id)
          .eq("type", "presentation")
          .eq("status", "active")
          .order("created_at", { ascending: false })
          .limit(1)
          .maybeSingle();

        let matchScore = scoresMap.get(app.seeker_id);
        if (matchScore === undefined) {
          const calculated = await calculateAndStoreMatchScore(app.seeker_id, offer.id);
          matchScore = calculated ?? calculateMatchScore(seekerProfile!, offer.sector ?? null, locations);
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
          offer: { id: offer.id, title: offer.title, type: offer.type as "offer" | "poster", sector: offer.sector, contract_type: offer.contract_type },
          presentation_video: presentationVideo,
          matchScore: matchScore ?? 0,
        };
      })
    );

    // Déduplication par seeker_id (garde le meilleur score)
    const seen = new Set<string>();
    const unique = enriched
      .sort((a, b) => b.matchScore - a.matchScore)
      .filter(c => {
        if (seen.has(c.seeker.user_id)) return false;
        seen.add(c.seeker.user_id);
        return true;
      });

    setCandidates(unique);
    setFiltered(unique);
    setLoading(false);
  }, [offer]);

  useEffect(() => { loadCandidates(); }, [loadCandidates]);

  // Filtre rapide par score
  useEffect(() => {
    if (scoreFilter === "all") { setFiltered(candidates); return; }
    setFiltered(candidates.filter(c => {
      if (scoreFilter === "high") return c.matchScore >= 80;
      if (scoreFilter === "medium") return c.matchScore >= 60 && c.matchScore < 80;
      return c.matchScore < 60;
    }));
  }, [scoreFilter, candidates]);

  function handlePass(candidate: CandidateWithScore) {
    setCandidates(prev => prev.filter(c => c.application.id !== candidate.application.id));
    const supabase = createClient();
    supabase
      .from("applications")
      .update({ status: "withdrawn" })
      .eq("id", candidate.application.id)
      .then(({ error }) => {
        if (error) {
          setCandidates(prev => [...prev, candidate].sort((a, b) => b.matchScore - a.matchScore));
        }
      });
  }

  const filterLabels: { key: ScoreFilter; label: string }[] = [
    { key: "all", label: "Tous" },
    { key: "high", label: "Excellent (>80%)" },
    { key: "medium", label: "Bon (60-80%)" },
    { key: "low", label: "Faible (<60%)" },
  ];

  return (
    <div>
      <PageHeader
        title={
          <div className="flex items-center gap-2">
            <button
              onClick={onBack}
              className="flex items-center justify-center rounded-lg p-1 text-text-secondary transition-colors hover:bg-bg-muted hover:text-text-primary"
            >
              <ArrowLeft className="h-5 w-5" />
            </button>
            <span className="text-sm text-text-tertiary">Mes offres</span>
            <span className="text-text-tertiary">›</span>
            <span className="text-base font-semibold text-text-primary">{offer.title || "Sans titre"}</span>
          </div>
        }
      >
        <span className="text-sm text-text-secondary">
          {candidates.length} candidat{candidates.length !== 1 ? "s" : ""}
        </span>
      </PageHeader>

      <div className="space-y-6 p-8">
        {/* Filtres rapides */}
        <div className="flex flex-wrap gap-2">
          {filterLabels.map(({ key, label }) => (
            <button
              key={key}
              onClick={() => setScoreFilter(key)}
              className={`rounded-full px-3 py-1.5 text-xs font-medium transition-colors ${
                scoreFilter === key
                  ? "bg-accent text-white"
                  : "border border-border text-text-secondary hover:border-accent hover:text-accent"
              }`}
            >
              {label}
            </button>
          ))}
        </div>

        {/* Grille */}
        {loading ? (
          <div className="py-20 text-center text-sm text-text-tertiary">Chargement…</div>
        ) : filtered.length === 0 ? (
          <div className="flex flex-col items-center justify-center rounded-xl border border-dashed border-border py-20">
            <UserX className="mb-4 h-12 w-12 text-text-tertiary" strokeWidth={1.5} />
            <p className="font-medium text-text-primary">
              {candidates.length === 0 ? "Aucune candidature pour cette offre" : "Aucun candidat pour ce filtre"}
            </p>
            {candidates.length > 0 && (
              <button onClick={() => setScoreFilter("all")} className="mt-2 text-sm text-accent hover:underline">
                Voir tous les candidats
              </button>
            )}
          </div>
        ) : (
          <div className="grid gap-6 sm:grid-cols-2 lg:grid-cols-3 2xl:grid-cols-4">
            {filtered.map((candidate) => (
              <CandidateCard
                key={candidate.application.id}
                candidate={candidate}
                matchScore={candidate.matchScore}
                onClick={() => setSelected(candidate)}
                onPass={() => handlePass(candidate)}
              />
            ))}
          </div>
        )}
      </div>

      <CandidateModal
        candidate={selected}
        open={selected !== null}
        onOpenChange={(open) => { if (!open) setSelected(null); }}
        onStatusChanged={loadCandidates}
      />
    </div>
  );
}
