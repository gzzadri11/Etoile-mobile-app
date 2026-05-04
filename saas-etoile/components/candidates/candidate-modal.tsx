"use client";

import { useState, useRef, useEffect } from "react";
import { useRouter } from "next/navigation";
import Image from "next/image";
import type { CandidateWithProfile } from "@/lib/types/database";
import { createClient } from "@/lib/supabase/client";
import { getSectorLabel, getStudyLevelLabel } from "@/lib/constants/sectors";
import { getScoreBadgeVariant, getScoreRangeLabel } from "@/lib/scoring";
import { useKeyboardShortcuts } from "@/hooks/use-keyboard-shortcuts";
import { saveEvaluation, getEvaluation } from "@/app/(dashboard)/candidates/actions";
import {
  Dialog,
  DialogContent,
} from "@/components/ui/dialog";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { Separator } from "@/components/ui/separator";
import { Textarea } from "@/components/ui/textarea";
import {
  Tabs,
  TabsContent,
  TabsList,
  TabsTrigger,
} from "@/components/ui/tabs";
import { X, ThumbsUp, Minus, ThumbsDown } from "lucide-react";
import { MessageTab } from "@/components/messages/message-tab";

interface CandidateModalProps {
  candidate: (CandidateWithProfile & { matchScore?: number }) | null;
  open: boolean;
  onOpenChange: (open: boolean) => void;
  onStatusChanged: () => void;
}

export function CandidateModal({
  candidate,
  open,
  onOpenChange,
  onStatusChanged,
}: CandidateModalProps) {
  const router = useRouter();
  const [contacting, setContacting] = useState(false);
  const videoRef = useRef<HTMLVideoElement>(null);

  // Task #2: Evaluation state (3-state rating + notes)
  const [rating, setRating] = useState<"interested" | "neutral" | "not_interested" | null>(null);
  const [notes, setNotes] = useState<string>("");
  const [loadingEvaluation, setLoadingEvaluation] = useState(false);
  const [savingEvaluation, setSavingEvaluation] = useState(false);

  // DEBUG: Log candidate data when modal opens
  useEffect(() => {
    if (candidate) {
      console.log('🔍 DEBUG Candidate Modal - Full data:', {
        userId: candidate.seeker.user_id,
        firstName: candidate.seeker.first_name,
        skills: candidate.seeker.skills,
        skillsType: typeof candidate.seeker.skills,
        skillsIsArray: Array.isArray(candidate.seeker.skills),
        skillsLength: candidate.seeker.skills?.length,
        fullSeeker: candidate.seeker,
      });
    }
  }, [candidate]);

  // Load existing evaluation when modal opens
  useEffect(() => {
    if (!candidate || !open) return;

    async function loadExistingEvaluation() {
      if (!candidate) return; // TypeScript guard
      setLoadingEvaluation(true);
      const evaluation = await getEvaluation(candidate.application.id);
      if (evaluation) {
        setRating(evaluation.rating);
        setNotes(evaluation.notes || "");
      } else {
        setRating(null);
        setNotes("");
      }
      setLoadingEvaluation(false);
    }

    loadExistingEvaluation();
  }, [candidate, open]);

  // Toggle video play/pause
  const toggleVideoPlay = () => {
    if (!videoRef.current) return;
    if (videoRef.current.paused) {
      videoRef.current.play();
    } else {
      videoRef.current.pause();
    }
  };

  // Keyboard shortcuts - MUST be called before any conditional return
  useKeyboardShortcuts(
    {
      " ": toggleVideoPlay,
      Escape: () => onOpenChange(false),
      c: () => {
        if (candidate?.application.status === "pending" && !contacting) {
          handleContact();
        }
      },
    },
    open
  );

  // Early return AFTER all hooks
  if (!candidate) return null;

  const { seeker, offer, application, presentation_video } = candidate;
  const fullName = [seeker.first_name, seeker.last_name]
    .filter(Boolean)
    .join(" ") || "Anonyme";

  const workerUrl = process.env.NEXT_PUBLIC_CLOUDFLARE_WORKER_URL;
  const videoSrc = presentation_video?.video_url
    ? presentation_video.video_url
    : presentation_video?.video_key
    ? `${workerUrl}/video/${presentation_video.video_key}`
    : null;

  async function handleContact() {
    setContacting(true);

    const supabase = createClient();
    const {
      data: { user },
    } = await supabase.auth.getUser();
    if (!user) {
      setContacting(false);
      return;
    }

    // Find or create conversation (fixed logic: both participants in same conversation)
    const { data: existingConv } = await supabase
      .from("conversations")
      .select("id")
      .or(
        `and(participant_1.eq.${user.id},participant_2.eq.${seeker.user_id}),` +
        `and(participant_1.eq.${seeker.user_id},participant_2.eq.${user.id})`
      )
      .limit(1)
      .maybeSingle();

    let conversationId = existingConv?.id;

    if (!conversationId) {
      const { data: newConv, error } = await supabase
        .from("conversations")
        .insert({
          participant_1: user.id,
          participant_2: seeker.user_id,
          video_id: offer.id,
        })
        .select("id")
        .single();

      if (error) {
        console.error('Failed to create conversation:', error);
        setContacting(false);
        return;
      }

      conversationId = newConv?.id;
    }

    // Mark application as contacted
    await supabase
      .from("applications")
      .update({ status: "contacted" })
      .eq("id", application.id);

    setContacting(false);
    onStatusChanged();

    // Navigate to Messages page with this conversation
    if (conversationId) {
      router.push(`/messages?conversation=${conversationId}`);
    }

    onOpenChange(false);
  }

  // Task #2: Save rating when button clicked
  async function handleRatingChange(newRating: "interested" | "neutral" | "not_interested") {
    if (!candidate) return; // TypeScript guard
    setSavingEvaluation(true);
    const result = await saveEvaluation(candidate.application.id, newRating, notes);
    if (result) {
      setRating(newRating);
    }
    setSavingEvaluation(false);
  }

  // Task #2: Save notes on blur
  async function handleNotesBlur() {
    if (!candidate) return; // TypeScript guard
    if (notes.trim() === "" && rating === null) return; // Don't save empty evaluation
    setSavingEvaluation(true);
    await saveEvaluation(candidate.application.id, rating, notes.trim() || null);
    setSavingEvaluation(false);
  }

  const matchScore = candidate.matchScore ?? 0;

  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent
        className="!max-w-[96vw] !h-[92vh] !w-[96vw] p-0 gap-0"
        showCloseButton={false}
      >

        <div className="flex h-full overflow-hidden">
          {/* Left: Video 50% - Always visible, no scroll */}
          <div className="w-1/2 bg-black flex items-center justify-center p-6 shrink-0">
            {videoSrc ? (
              <video
                ref={videoRef}
                src={videoSrc}
                controls
                autoPlay
                className="max-w-full max-h-full object-contain rounded-lg"
              />
            ) : (
              <div className="text-center text-white/70">
                <p className="text-lg">Aucune vidéo de présentation</p>
              </div>
            )}
          </div>

          {/* Right: Panel 50% - Scrollable content */}
          <div className="w-1/2 flex flex-col bg-background relative overflow-hidden shrink-0">
            {/* Close button */}
            <button
              onClick={() => onOpenChange(false)}
              className="absolute right-2 top-2 z-10 rounded-sm opacity-70 ring-offset-background transition-opacity hover:opacity-100 focus:outline-none focus:ring-2 focus:ring-ring focus:ring-offset-2"
            >
              <X className="h-5 w-5" />
              <span className="sr-only">Close</span>
            </button>

            {/* Header */}
            <div className="p-6 pr-12 border-b shrink-0">
              <div className="flex items-start gap-4">
                {/* Photo */}
                <div className="relative h-16 w-16 shrink-0 overflow-hidden rounded-full bg-muted">
                  {seeker.photo_url ? (
                    <Image
                      src={seeker.photo_url}
                      alt={fullName}
                      fill
                      className="object-cover"
                      sizes="64px"
                    />
                  ) : (
                    <div className="flex h-full items-center justify-center text-2xl font-bold text-muted-foreground">
                      {fullName[0]?.toUpperCase()}
                    </div>
                  )}
                </div>

                {/* Info */}
                <div className="flex-1 min-w-0">
                  <h2 className="text-xl font-bold truncate">{fullName}</h2>
                  {seeker.username && (
                    <p className="text-sm text-muted-foreground">@{seeker.username}</p>
                  )}
                </div>
              </div>

              {/* Badges */}
              <div className="flex flex-wrap gap-2 mt-4">
                <Badge variant={getScoreBadgeVariant(matchScore)} className="text-sm font-bold px-3 py-1">
                  {matchScore}% match
                </Badge>
                {seeker.age && <Badge variant="outline" className="text-sm px-3 py-1">{seeker.age} ans</Badge>}
                {seeker.city && <Badge variant="outline" className="text-sm px-3 py-1">{seeker.city}</Badge>}
              </div>
            </div>

            {/* Tabs */}
            <Tabs defaultValue="profil" className="flex-1 overflow-hidden flex flex-col">
              <TabsList className="w-full grid grid-cols-3 shrink-0 h-12 sticky top-0 z-10 bg-background border-b">
                <TabsTrigger value="profil" className="text-base">Profil</TabsTrigger>
                <TabsTrigger value="evaluer" className="text-base">Évaluer</TabsTrigger>
                <TabsTrigger value="messages" className="text-base">Messages</TabsTrigger>
              </TabsList>

              <div className="flex-1 overflow-y-auto bg-background">
                {/* Tab: Profil */}
                <TabsContent value="profil" className="p-6 space-y-5 mt-0">
                  <div>
                    <h3 className="text-base font-semibold mb-3">Formation</h3>
                    {seeker.school && (
                      <div className="mb-3">
                        <p className="text-sm text-muted-foreground">École</p>
                        <p className="text-base font-medium">{seeker.school}</p>
                      </div>
                    )}
                    {seeker.study_level && (
                      <div>
                        <p className="text-sm text-muted-foreground">Niveau d&apos;études</p>
                        <p className="text-base font-medium">{getStudyLevelLabel(seeker.study_level)}</p>
                      </div>
                    )}
                  </div>

                  <Separator />

                  <div>
                    <h3 className="text-base font-semibold mb-3">Domaine</h3>
                    {seeker.domain && (
                      <div className="mb-3">
                        <p className="text-sm text-muted-foreground">Secteur</p>
                        <p className="text-base font-medium">{getSectorLabel(seeker.domain)}</p>
                      </div>
                    )}
                    {seeker.specialty && (
                      <div>
                        <p className="text-sm text-muted-foreground">Spécialité</p>
                        <p className="text-base font-medium">{seeker.specialty}</p>
                      </div>
                    )}
                  </div>

                  <Separator />

                  {/* Compétences */}
                  {seeker.skills && seeker.skills.length > 0 && (
                    <>
                      <div>
                        <h3 className="text-base font-semibold mb-3">Compétences</h3>
                        <div className="flex flex-wrap gap-2">
                          {seeker.skills.map((skill, idx) => (
                            <span
                              key={idx}
                              className="inline-flex items-center px-3 py-1.5 rounded-full text-sm font-medium bg-primary/10 text-primary border border-primary/20"
                            >
                              {skill}
                            </span>
                          ))}
                        </div>
                      </div>
                      <Separator />
                    </>
                  )}

                  <div>
                    <h3 className="text-base font-semibold mb-3">Candidature</h3>
                    <div className="space-y-3">
                      <div>
                        <p className="text-sm text-muted-foreground">Offre</p>
                        <p className="text-base font-medium">{offer.title || "Sans titre"}</p>
                      </div>
                      <div>
                        <p className="text-sm text-muted-foreground">Date de candidature</p>
                        <p className="text-base font-medium">
                          {new Date(application.applied_at).toLocaleDateString("fr-FR", {
                            day: "numeric",
                            month: "long",
                            year: "numeric",
                            hour: "2-digit",
                            minute: "2-digit",
                          })}
                        </p>
                      </div>
                      <div>
                        <p className="text-sm text-muted-foreground">Statut</p>
                        <Badge variant={application.status === "pending" ? "secondary" : "default"} className="text-sm px-3 py-1">
                          {application.status === "pending" ? "En attente" :
                           application.status === "contacted" ? "Contacté" : "Retiré"}
                        </Badge>
                      </div>
                    </div>
                  </div>

                  <Separator />

                  <div>
                    <h3 className="text-base font-semibold mb-3">Score de compatibilité</h3>
                    <div className="rounded-lg bg-muted p-4">
                      <div className="flex items-center justify-between mb-3">
                        <span className="text-3xl font-bold">{matchScore}%</span>
                        <Badge variant={getScoreBadgeVariant(matchScore)} className="text-sm px-3 py-1">
                          {getScoreRangeLabel(matchScore)}
                        </Badge>
                      </div>
                      <p className="text-sm text-muted-foreground">
                        Basé sur le secteur, le niveau d&apos;études, la localisation et la spécialité
                      </p>
                    </div>
                  </div>
                </TabsContent>

                {/* Tab: Évaluer - Task #2 */}
                <TabsContent value="evaluer" className="p-6 space-y-5 mt-0">
                  {loadingEvaluation ? (
                    <div className="text-center text-muted-foreground py-8">Chargement...</div>
                  ) : (
                    <>
                      {/* Rating: 3-state system */}
                      <div>
                        <h3 className="text-base font-semibold mb-3">Votre évaluation</h3>
                        <div className="grid grid-cols-3 gap-3">
                          <Button
                            variant={rating === "interested" ? "default" : "outline"}
                            className="h-20 flex flex-col gap-2"
                            onClick={() => handleRatingChange("interested")}
                            disabled={savingEvaluation}
                          >
                            <ThumbsUp className="h-5 w-5" />
                            <span className="text-sm font-medium">Intéressé</span>
                          </Button>
                          <Button
                            variant={rating === "neutral" ? "default" : "outline"}
                            className="h-20 flex flex-col gap-2"
                            onClick={() => handleRatingChange("neutral")}
                            disabled={savingEvaluation}
                          >
                            <Minus className="h-5 w-5" />
                            <span className="text-sm font-medium">Peut-être</span>
                          </Button>
                          <Button
                            variant={rating === "not_interested" ? "default" : "outline"}
                            className="h-20 flex flex-col gap-2"
                            onClick={() => handleRatingChange("not_interested")}
                            disabled={savingEvaluation}
                          >
                            <ThumbsDown className="h-5 w-5" />
                            <span className="text-sm font-medium">Pas intéressé</span>
                          </Button>
                        </div>
                        {rating && (
                          <p className="text-sm text-muted-foreground mt-3 text-center">
                            {rating === "interested" && "✓ Candidat marqué comme intéressant"}
                            {rating === "neutral" && "~ Candidat à revoir plus tard"}
                            {rating === "not_interested" && "✗ Candidat écarté"}
                          </p>
                        )}
                      </div>

                      <Separator />

                      {/* Notes privées */}
                      <div>
                        <h3 className="text-base font-semibold mb-3">Notes privées</h3>
                        <Textarea
                          placeholder="Vos impressions, questions, points à aborder en entretien..."
                          className="min-h-[140px] resize-none text-base"
                          value={notes}
                          onChange={(e) => setNotes(e.target.value)}
                          onBlur={handleNotesBlur}
                          disabled={savingEvaluation}
                        />
                        <p className="text-sm text-muted-foreground mt-2">
                          Ces notes sont privées et visibles uniquement par vous.
                          {savingEvaluation && " Enregistrement..."}
                        </p>
                      </div>

                      <Separator />

                      {/* Actions */}
                      <div>
                        <h3 className="text-base font-semibold mb-3">Actions</h3>
                        <div className="space-y-3">
                          {application.status === "pending" && (
                            <Button
                              variant="default"
                              className="w-full text-base h-11"
                              onClick={handleContact}
                              disabled={contacting}
                            >
                              {contacting ? "Ouverture..." : "Contacter ce candidat"}
                            </Button>
                          )}
                          {application.status === "contacted" && (
                            <div className="rounded-lg bg-muted p-4 text-center">
                              <p className="text-base text-muted-foreground mb-3">
                                Candidat déjà contacté
                              </p>
                              <Button variant="outline" className="w-full text-base h-11">
                                Voir la conversation
                              </Button>
                            </div>
                          )}
                        </div>
                      </div>
                    </>
                  )}
                </TabsContent>

                {/* Tab: Messages - Epic 15 */}
                <TabsContent value="messages" className="p-6 mt-0">
                  <MessageTab
                    seekerId={seeker.user_id}
                    videoId={offer.id}
                    applicationStatus={application.status}
                    onConversationCreated={onStatusChanged}
                  />
                </TabsContent>
              </div>
            </Tabs>
          </div>
        </div>
      </DialogContent>
    </Dialog>
  );
}
