"use client";

import { useCallback, useEffect, useRef, useState } from "react";
import { useRouter } from "next/navigation";
import { createClient } from "@/lib/supabase/client";
import { uploadFile } from "@/lib/upload";
import { ROUTES } from "@/lib/constants/routes";
import { SECTORS } from "@/lib/constants/sectors";
import { CONTRACT_TYPES } from "@/lib/constants/contracts";
import type { RecruiterProfile } from "@/lib/types/database";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Textarea } from "@/components/ui/textarea";
import { Progress } from "@/components/ui/progress";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import { FileDropZone } from "@/components/offers/file-drop-zone";
import { MobilePreview } from "@/components/offers/MobilePreview";

type OfferType = "offer" | "poster";
type Step = "type" | "upload" | "details" | "publishing";

const MAX_VIDEO_DURATION = 40;
const MAX_VIDEO_SIZE_MB = 50;
const MAX_POSTER_SIZE_MB = 10;

export default function NewOfferPage() {
  const router = useRouter();

  // Verification gate
  const [verified, setVerified] = useState<boolean | null>(null);
  const [userId, setUserId] = useState<string | null>(null);
  const [videoCredits, setVideoCredits] = useState<number>(0);
  const [posterCredits, setPosterCredits] = useState<number>(0);
  const [companyName, setCompanyName] = useState<string>("");

  // Wizard state
  const [step, setStep] = useState<Step>("type");
  const [offerType, setOfferType] = useState<OfferType | null>(null);
  const [file, setFile] = useState<File | null>(null);
  const [preview, setPreview] = useState<string | null>(null);
  const [videoDuration, setVideoDuration] = useState<number>(0);

  // Details form
  const [title, setTitle] = useState("");
  const [sector, setSector] = useState("");
  const [contractType, setContractType] = useState("");
  const [description, setDescription] = useState("");

  // Publishing
  const [progress, setProgress] = useState(0);
  const [error, setError] = useState<string | null>(null);

  const videoRef = useRef<HTMLVideoElement>(null);

  // Check verification status on mount
  useEffect(() => {
    async function checkAccess() {
      const supabase = createClient();
      const {
        data: { user },
      } = await supabase.auth.getUser();
      if (!user) {
        router.push(ROUTES.LOGIN);
        return;
      }
      setUserId(user.id);

      const { data } = await supabase
        .from("recruiter_profiles")
        .select("verification_status, video_credits, poster_credits, company_name")
        .eq("user_id", user.id)
        .single<Pick<RecruiterProfile, "verification_status" | "video_credits" | "poster_credits" | "company_name">>();

      setVerified(data?.verification_status === "verified");
      setVideoCredits(data?.video_credits ?? 0);
      setPosterCredits(data?.poster_credits ?? 0);
      setCompanyName(data?.company_name ?? "");
    }
    checkAccess();
  }, [router]);

  // Validate video duration after file selection
  const handleVideoFile = useCallback((selectedFile: File) => {
    setFile(selectedFile);
    setError(null);

    const url = URL.createObjectURL(selectedFile);
    setPreview(url);

    // Validate duration via <video> element
    const videoEl = document.createElement("video");
    videoEl.preload = "metadata";
    videoEl.onloadedmetadata = () => {
      URL.revokeObjectURL(videoEl.src);
      if (videoEl.duration > MAX_VIDEO_DURATION) {
        setError(`Oups ! Votre vidéo dure ${Math.round(videoEl.duration)}s, la limite est de ${MAX_VIDEO_DURATION}s. Essayez de la raccourcir un peu.`);
        setFile(null);
        setPreview(null);
      } else {
        setVideoDuration(Math.round(videoEl.duration));
      }
    };
    videoEl.src = url;
  }, []);

  const handlePosterFile = useCallback(async (selectedFile: File) => {
    setFile(selectedFile);
    setError(null);

    const url = URL.createObjectURL(selectedFile);
    setPreview(url);
  }, []);

  async function handlePublish() {
    if (!file || !userId) return;

    setStep("publishing");
    setProgress(0);
    setError(null);

    try {
      const isVideo = offerType === "offer";
      const uploadType = isVideo ? "video" : "thumbnail";

      const result = await uploadFile(file, uploadType, (pct) => setProgress(pct));

      // INSERT into videos
      const supabase = createClient();
      const { error: insertError } = await supabase.from("videos").insert({
        user_id: userId,
        type: offerType,
        title: title || null,
        description: description || null,
        video_key: result.key,
        video_url: isVideo ? result.url : null,
        thumbnail_key: isVideo ? null : result.key,
        thumbnail_url: isVideo ? null : result.url,
        duration_seconds: isVideo ? videoDuration : 0,
        file_size_bytes: result.size,
        status: "active",
        contract_type: contractType || null,
        sector: sector || null,
        published_at: new Date().toISOString(),
      });

      if (insertError) {
        throw new Error(insertError.message);
      }

      // Decrement credits
      const creditField = isVideo ? "video_credits" : "poster_credits";
      const { error: creditError } = await supabase
        .from("recruiter_profiles")
        .update({ [creditField]: isVideo ? videoCredits - 1 : posterCredits - 1 })
        .eq("user_id", userId);

      if (creditError) {
        console.error("Failed to decrement credits:", creditError);
        // Don't fail the whole operation, just log it
      }

      router.push(ROUTES.OFFERS);
    } catch (err) {
      setError(err instanceof Error ? err.message : "Oups, un petit souci est survenu lors de la publication. Réessayez dans quelques instants.");
      setStep("details");
    }
  }

  // Gate: not yet loaded
  if (verified === null) {
    return (
      <div className="flex items-center justify-center py-20">
        <p className="text-muted-foreground">Chargement...</p>
      </div>
    );
  }

  // Gate: not verified
  if (!verified) {
    return (
      <div className="flex flex-col items-center justify-center py-20">
        <p className="text-lg font-medium">Compte non verifie</p>
        <p className="mt-2 text-sm text-muted-foreground">
          Votre entreprise doit etre verifiee avant de publier des offres.
          Rendez-vous dans les parametres pour soumettre vos documents.
        </p>
        <Button
          variant="outline"
          className="mt-4"
          onClick={() => router.push(ROUTES.SETTINGS)}
        >
          Aller aux parametres
        </Button>
      </div>
    );
  }

  return (
    <div className={`mx-auto space-y-6 ${step === "details" ? "max-w-6xl" : "max-w-2xl"}`}>
      {/* Step indicators */}
      <div className="flex gap-2">
        {(["type", "upload", "details", "publishing"] as Step[]).map((s, i) => (
          <div
            key={s}
            className={`h-1 flex-1 rounded-full ${
              (["type", "upload", "details", "publishing"] as Step[]).indexOf(step) >= i
                ? "bg-primary"
                : "bg-muted"
            }`}
          />
        ))}
      </div>

      {/* Step 1: Type selection */}
      {step === "type" && (
        <div className="space-y-4">
          <h2 className="text-xl font-semibold">Quel type d&apos;offre ?</h2>
          <div className="grid gap-4 sm:grid-cols-2">
            <Card
              className={`transition-fast ${
                videoCredits > 0
                  ? `cursor-pointer hover:border-primary ${
                      offerType === "offer" ? "border-primary bg-primary/5" : ""
                    }`
                  : "opacity-50 cursor-not-allowed"
              }`}
              onClick={() => videoCredits > 0 && setOfferType("offer")}
            >
              <CardHeader>
                <CardTitle className="flex items-center justify-between">
                  Video
                  <span className="text-sm font-normal text-muted-foreground">
                    {videoCredits} crédit{videoCredits > 1 ? "s" : ""}
                  </span>
                </CardTitle>
                <CardDescription>
                  {videoCredits > 0
                    ? "Enregistrez une video de 40 secondes max pour presenter votre offre."
                    : "Plus de crédits vidéo disponibles. Rechargez votre compte."}
                </CardDescription>
              </CardHeader>
            </Card>

            <Card
              className={`transition-fast ${
                posterCredits > 0
                  ? `cursor-pointer hover:border-primary ${
                      offerType === "poster" ? "border-primary bg-primary/5" : ""
                    }`
                  : "opacity-50 cursor-not-allowed"
              }`}
              onClick={() => posterCredits > 0 && setOfferType("poster")}
            >
              <CardHeader>
                <CardTitle className="flex items-center justify-between">
                  Affiche
                  <span className="text-sm font-normal text-muted-foreground">
                    {posterCredits} crédit{posterCredits > 1 ? "s" : ""}
                  </span>
                </CardTitle>
                <CardDescription>
                  {posterCredits > 0
                    ? "Importez une image (JPEG, PNG, WebP) pour votre offre."
                    : "Plus de crédits affiche disponibles. Rechargez votre compte."}
                </CardDescription>
              </CardHeader>
            </Card>
          </div>

          <div className="flex justify-between">
            <Button variant="outline" onClick={() => router.push(ROUTES.OFFERS)}>
              Annuler
            </Button>
            <Button disabled={!offerType} onClick={() => setStep("upload")}>
              Suivant
            </Button>
          </div>
        </div>
      )}

      {/* Step 2: Upload */}
      {step === "upload" && (
        <div className="space-y-4">
          <h2 className="text-xl font-semibold">
            {offerType === "offer" ? "Selectionnez votre video" : "Selectionnez votre image"}
          </h2>

          {!preview ? (
            <FileDropZone
              accept={
                offerType === "offer"
                  ? "video/mp4,video/quicktime,video/webm"
                  : "image/jpeg,image/png,image/webp"
              }
              maxSizeMB={offerType === "offer" ? MAX_VIDEO_SIZE_MB : MAX_POSTER_SIZE_MB}
              onFileSelected={offerType === "offer" ? handleVideoFile : handlePosterFile}
              label={
                offerType === "offer"
                  ? "Glissez votre video ici"
                  : "Glissez votre image ici"
              }
              hint={
                offerType === "offer"
                  ? "MP4, MOV ou WebM — 40 secondes max"
                  : "JPEG, PNG ou WebP"
              }
            />
          ) : (
            <div className="space-y-4">
              {offerType === "offer" ? (
                <video
                  ref={videoRef}
                  src={preview}
                  controls
                  className="mx-auto max-h-80 rounded-lg"
                />
              ) : (
                // eslint-disable-next-line @next/next/no-img-element
                <img
                  src={preview}
                  alt="Preview"
                  className="mx-auto max-h-80 rounded-lg object-contain"
                />
              )}
              <Button
                variant="outline"
                onClick={() => {
                  setFile(null);
                  setPreview(null);
                  setError(null);
                }}
              >
                Changer de fichier
              </Button>
            </div>
          )}

          {error && <p className="text-sm text-destructive">{error}</p>}

          <div className="flex justify-between">
            <div className="flex gap-2">
              <Button variant="ghost" onClick={() => router.push(ROUTES.OFFERS)}>
                Annuler
              </Button>
              <Button variant="outline" onClick={() => setStep("type")}>
                Retour
              </Button>
            </div>
            <Button disabled={!file || !!error} onClick={() => setStep("details")}>
              Suivant
            </Button>
          </div>
        </div>
      )}

      {/* Step 3: Details */}
      {step === "details" && (
        <div className="space-y-6">
          <h2 className="text-xl font-semibold">Details de l&apos;offre</h2>

          {/* 2-column layout: Form + Preview */}
          <div className="grid gap-8 lg:grid-cols-2">
            {/* Left column: Form */}
            <div className="space-y-4">
              <div className="space-y-2">
                <Label htmlFor="title">Titre</Label>
                <Input
                  id="title"
                  value={title}
                  onChange={(e) => setTitle(e.target.value)}
                  placeholder="Ex: Alternant developpeur web"
                />
              </div>

              <div className="space-y-2">
                <Label htmlFor="sector">Secteur</Label>
                <Select value={sector} onValueChange={(v) => setSector(v ?? "")}>
                  <SelectTrigger id="sector">
                    <SelectValue placeholder="Choisir un secteur" />
                  </SelectTrigger>
                  <SelectContent>
                    {SECTORS.map((s) => (
                      <SelectItem key={s.value} value={s.value}>
                        {s.label}
                      </SelectItem>
                    ))}
                  </SelectContent>
                </Select>
              </div>

              <div className="space-y-2">
                <Label htmlFor="contract">Type de contrat</Label>
                <Select value={contractType} onValueChange={(v) => setContractType(v ?? "")}>
                  <SelectTrigger id="contract">
                    <SelectValue placeholder="Choisir un type" />
                  </SelectTrigger>
                  <SelectContent>
                    {CONTRACT_TYPES.map((c) => (
                      <SelectItem key={c.value} value={c.value}>
                        {c.label}
                      </SelectItem>
                    ))}
                  </SelectContent>
                </Select>
              </div>

              <div className="space-y-2">
                <Label htmlFor="description">Description</Label>
                <Textarea
                  id="description"
                  value={description}
                  onChange={(e) => setDescription(e.target.value)}
                  placeholder="Decrivez le poste, les missions, le profil recherche..."
                  rows={5}
                />
              </div>
            </div>

            {/* Right column: Mobile Preview */}
            <div className="flex items-start justify-center lg:sticky lg:top-6">
              <MobilePreview
                videoUrl={offerType === "offer" ? preview : null}
                posterUrl={offerType === "poster" ? preview : null}
                title={title || "Titre du poste"}
                companyName={companyName}
                sector={sector ? SECTORS.find((s) => s.value === sector)?.label || sector : "Secteur"}
              />
            </div>
          </div>

          {error && <p className="text-sm text-destructive">{error}</p>}

          <div className="flex justify-between">
            <div className="flex gap-2">
              <Button variant="ghost" onClick={() => router.push(ROUTES.OFFERS)}>
                Annuler
              </Button>
              <Button variant="outline" onClick={() => setStep("upload")}>
                Retour
              </Button>
            </div>
            <Button onClick={handlePublish}>Publier</Button>
          </div>
        </div>
      )}

      {/* Step 4: Publishing */}
      {step === "publishing" && (
        <div className="flex flex-col items-center justify-center space-y-4 py-20">
          <h2 className="text-xl font-semibold">Publication en cours...</h2>
          <Progress value={progress} className="w-64" />
          <p className="text-sm text-muted-foreground">{progress}%</p>
        </div>
      )}
    </div>
  );
}
