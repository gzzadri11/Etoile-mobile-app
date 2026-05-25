"use client";

import { useCallback, useEffect, useRef, useState } from "react";
import { createClient } from "@/lib/supabase/client";
import { PageHeader } from "@/components/layout/PageHeader";
import { SECTORS, STUDY_LEVELS } from "@/lib/constants/sectors";
import { CandidateModal } from "@/components/candidates/candidate-modal";
import type { CandidateWithProfile } from "@/lib/types/database";
import { Search as SearchIcon, UserX } from "lucide-react";

const RHYTHMS = [
  { value: "3j/2j", label: "3j / 2j" },
  { value: "1sem/1sem", label: "1 sem / 1 sem" },
  { value: "2sem/2sem", label: "2 sem / 2 sem" },
  { value: "1mois/1mois", label: "1 mois / 1 mois" },
];

type SearchResult = CandidateWithProfile & { matchScore: number };

export default function SearchPage() {
  const supabase = useRef(createClient()).current;
  const [query, setQuery] = useState("");
  const [sector, setSector] = useState("");
  const [level, setLevel] = useState("");
  const [rhythm, setRhythm] = useState("");
  const [results, setResults] = useState<SearchResult[]>([]);
  const [loading, setLoading] = useState(false);
  const [searched, setSearched] = useState(false);
  const [selected, setSelected] = useState<SearchResult | null>(null);
  const debounceRef = useRef<ReturnType<typeof setTimeout> | null>(null);

  const search = useCallback(async (q: string, s: string, lv: string, r: string) => {
    setLoading(true);
    setSearched(true);

    let queryBuilder = supabase
      .from("seeker_profiles")
      .select("*")
      .eq("profile_complete", true);

    if (q.trim()) {
      queryBuilder = queryBuilder.or(
        `first_name.ilike.%${q.trim()}%,last_name.ilike.%${q.trim()}%,username.ilike.%${q.trim()}%`
      );
    }
    if (s) queryBuilder = queryBuilder.eq("domain", s);
    if (lv) queryBuilder = queryBuilder.eq("study_level", lv);
    if (r) queryBuilder = queryBuilder.eq("rhythm", r);

    const { data: seekers } = await queryBuilder
      .order("created_at", { ascending: false })
      .limit(50);

    if (!seekers || seekers.length === 0) {
      setResults([]);
      setLoading(false);
      return;
    }

    // Fetch presentation videos for each seeker
    const seekerIds = seekers.map((s: any) => s.user_id);
    const { data: videos } = await supabase
      .from("videos")
      .select("id, user_id, video_key, video_url, thumbnail_key, thumbnail_url, duration_seconds")
      .in("user_id", seekerIds)
      .eq("type", "presentation")
      .eq("status", "active");

    const videoMap = Object.fromEntries(
      (videos ?? []).map((v: any) => [v.user_id, v])
    );

    const enriched: SearchResult[] = seekers.map((seeker: any) => ({
      application: { id: "", video_id: "", seeker_id: seeker.user_id, recruiter_id: "", status: "pending", applied_at: "" },
      seeker,
      offer: { id: "", title: null, type: "offer", sector: null, contract_type: null },
      presentation_video: videoMap[seeker.user_id] ?? null,
      matchScore: 0,
    }));

    setResults(enriched);
    setLoading(false);
  }, [supabase]);

  // Debounce sur le champ texte
  useEffect(() => {
    if (!query.trim() && !sector && !level && !rhythm) return;
    if (debounceRef.current) clearTimeout(debounceRef.current);
    debounceRef.current = setTimeout(() => {
      search(query, sector, level, rhythm);
    }, 400);
    return () => { if (debounceRef.current) clearTimeout(debounceRef.current); };
  }, [query, sector, level, rhythm, search]);

  function reset() {
    setQuery(""); setSector(""); setLevel(""); setRhythm("");
    setResults([]); setSearched(false);
  }

  const hasFilters = !!query || !!sector || !!level || !!rhythm;

  return (
    <div className="space-y-6">
      <PageHeader title="Rechercher un candidat" />

      <div className="space-y-3">
        {/* Champ texte */}
        <div className="relative">
          <SearchIcon className="absolute left-3 top-1/2 h-5 w-5 -translate-y-1/2 text-text-tertiary" />
          <input
            value={query}
            onChange={(e) => setQuery(e.target.value)}
            placeholder="Nom, prénom, @username…"
            className="w-full rounded-lg border-2 border-border bg-white py-3 pl-10 pr-4 text-sm font-[Sora,sans-serif] outline-none transition-colors focus:border-accent"
          />
        </div>

        {/* Filtres */}
        <div className="flex flex-wrap gap-2">
          <select
            value={sector}
            onChange={(e) => setSector(e.target.value)}
            className={`rounded-lg border-[1.5px] px-3 py-2 text-sm font-[Sora,sans-serif] outline-none transition-colors cursor-pointer ${sector ? "border-accent bg-accent/5 text-accent" : "border-border bg-white text-text-secondary"}`}
          >
            <option value="">Secteur</option>
            {SECTORS.map((s) => <option key={s.value} value={s.value}>{s.label}</option>)}
          </select>

          <select
            value={level}
            onChange={(e) => setLevel(e.target.value)}
            className={`rounded-lg border-[1.5px] px-3 py-2 text-sm font-[Sora,sans-serif] outline-none transition-colors cursor-pointer ${level ? "border-accent bg-accent/5 text-accent" : "border-border bg-white text-text-secondary"}`}
          >
            <option value="">Niveau</option>
            {STUDY_LEVELS.map((l) => <option key={l.value} value={l.value}>{l.label}</option>)}
          </select>

          <select
            value={rhythm}
            onChange={(e) => setRhythm(e.target.value)}
            className={`rounded-lg border-[1.5px] px-3 py-2 text-sm font-[Sora,sans-serif] outline-none transition-colors cursor-pointer ${rhythm ? "border-accent bg-accent/5 text-accent" : "border-border bg-white text-text-secondary"}`}
          >
            <option value="">Rythme</option>
            {RHYTHMS.map((r) => <option key={r.value} value={r.value}>{r.label}</option>)}
          </select>

          {hasFilters && (
            <button
              onClick={reset}
              className="rounded-lg border border-border bg-white px-3 py-2 text-sm text-text-secondary transition-colors hover:border-text-secondary hover:text-text-primary"
            >
              Réinitialiser
            </button>
          )}

          <button
            onClick={() => search(query, sector, level, rhythm)}
            className="rounded-lg bg-accent px-4 py-2 text-sm font-semibold text-white transition-opacity hover:opacity-90"
          >
            Rechercher →
          </button>
        </div>
      </div>

      {/* Résultats */}
      {loading && (
        <div className="py-12 text-center text-sm text-text-tertiary">Recherche…</div>
      )}

      {!loading && searched && results.length === 0 && (
        <div className="flex flex-col items-center justify-center rounded-xl border border-dashed border-border py-20">
          <UserX className="mb-4 h-12 w-12 text-text-tertiary" strokeWidth={1.5} />
          <p className="font-medium text-text-primary">Aucun candidat trouvé</p>
          <p className="mt-1 text-sm text-text-secondary">Essayez d'élargir vos critères de recherche.</p>
        </div>
      )}

      {!loading && !searched && (
        <div className="flex flex-col items-center justify-center rounded-xl border border-dashed border-border py-20">
          <SearchIcon className="mb-3 h-12 w-12 text-text-tertiary opacity-20" />
          <p className="text-sm text-text-tertiary">Tapez un nom ou sélectionnez des filtres pour rechercher</p>
        </div>
      )}

      {!loading && results.length > 0 && (
        <div>
          <p className="mb-4 text-xs text-text-tertiary">{results.length} résultat{results.length > 1 ? "s" : ""}</p>
          <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4">
            {results.map((r) => (
              <div
                key={r.seeker.user_id}
                onClick={() => setSelected(r)}
                className="cursor-pointer rounded-xl border border-border bg-white p-4 transition-all hover:-translate-y-0.5 hover:border-accent hover:shadow-md"
              >
                {/* Avatar */}
                <div className="mb-3 flex items-center gap-3">
                  {r.seeker.photo_url ? (
                    // eslint-disable-next-line @next/next/no-img-element
                    <img src={r.seeker.photo_url} alt="" className="h-12 w-12 rounded-full object-cover" />
                  ) : (
                    <div className="flex h-12 w-12 items-center justify-center rounded-full bg-accent/10 text-lg font-bold text-accent">
                      {(r.seeker.first_name?.[0] ?? "?").toUpperCase()}
                    </div>
                  )}
                  <div className="min-w-0">
                    <p className="truncate text-sm font-semibold text-text-primary">
                      {[r.seeker.first_name, r.seeker.last_name].filter(Boolean).join(" ") || "Anonyme"}
                    </p>
                    {r.seeker.username && (
                      <p className="truncate text-xs text-text-tertiary">@{r.seeker.username}</p>
                    )}
                  </div>
                </div>

                {/* Infos */}
                <div className="space-y-1">
                  {r.seeker.city && (
                    <p className="text-xs text-text-secondary">📍 {r.seeker.city}</p>
                  )}
                  {r.seeker.study_level && (
                    <p className="text-xs text-text-secondary">🎓 {r.seeker.study_level}</p>
                  )}
                  {r.seeker.rhythm && (
                    <p className="text-xs text-text-secondary">🔄 {r.seeker.rhythm}</p>
                  )}
                </div>

                {r.presentation_video && (
                  <div className="mt-3 rounded-md bg-accent/5 py-1.5 text-center text-xs font-medium text-accent">
                    ▶ Voir la vidéo
                  </div>
                )}
              </div>
            ))}
          </div>
        </div>
      )}

      {selected && (
        <CandidateModal
          candidate={selected}
          open={true}
          onOpenChange={(open) => { if (!open) setSelected(null); }}
          onStatusChanged={() => {}}
        />
      )}
    </div>
  );
}
