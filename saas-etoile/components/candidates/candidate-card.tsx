"use client";

import { useState, useRef, useEffect } from "react";
import Image from "next/image";
import type { CandidateWithProfile } from "@/lib/types/database";
import { getSectorLabel } from "@/lib/constants/sectors";
import { getScoreBadgeVariant } from "@/lib/scoring";
import { Badge } from "@/components/ui/badge";
import {
  Card,
  CardContent,
  CardHeader,
} from "@/components/ui/card";

interface CandidateCardProps {
  candidate: CandidateWithProfile;
  onClick: () => void;
  matchScore?: number;
}

const STATUS_LABELS: Record<string, { label: string; variant: "default" | "secondary" | "outline" }> = {
  pending: { label: "En attente", variant: "secondary" },
  contacted: { label: "Contacte", variant: "default" },
  withdrawn: { label: "Retire", variant: "outline" },
};

export function CandidateCard({ candidate, onClick, matchScore }: CandidateCardProps) {
  const { seeker, offer, application, presentation_video } = candidate;
  const statusInfo = STATUS_LABELS[application.status] ?? { label: application.status, variant: "outline" as const };
  const [isHovering, setIsHovering] = useState(false);
  const videoRef = useRef<HTMLVideoElement | null>(null);

  const fullName = [seeker.first_name, seeker.last_name]
    .filter(Boolean)
    .join(" ") || "Anonyme";

  const workerUrl = process.env.NEXT_PUBLIC_CLOUDFLARE_WORKER_URL;
  const videoSrc = presentation_video?.video_url
    ? presentation_video.video_url
    : presentation_video?.video_key
    ? `${workerUrl}/video/${presentation_video.video_key}`
    : null;

  const thumbnailSrc = presentation_video?.thumbnail_url
    ? presentation_video.thumbnail_url
    : presentation_video?.thumbnail_key
    ? `${workerUrl}/thumbnail/${presentation_video.thumbnail_key}`
    : null;

  // Play video on hover
  useEffect(() => {
    if (isHovering && videoRef.current && videoSrc) {
      videoRef.current.play().catch(() => {
        // Ignore autoplay errors
      });
    } else if (!isHovering && videoRef.current) {
      videoRef.current.pause();
      videoRef.current.currentTime = 0;
    }
  }, [isHovering, videoSrc]);

  return (
    <Card
      className="group relative cursor-pointer overflow-hidden transition-all duration-200 hover:border-primary hover:shadow-lg hover:-translate-y-0.5"
      onClick={onClick}
      onMouseEnter={() => setIsHovering(true)}
      onMouseLeave={() => setIsHovering(false)}
    >
      {/* Match score badge - always visible */}
      {matchScore !== undefined && (
        <div className="absolute right-2 top-2 z-10">
          <Badge variant={getScoreBadgeVariant(matchScore)} className="text-xs font-bold shadow-md">
            {matchScore}%
          </Badge>
        </div>
      )}

      <CardHeader className="pb-3">
        <div className="flex items-start gap-3">
          {/* Photo with video preview overlay */}
          <div className="relative h-16 w-16 shrink-0 overflow-hidden rounded-full bg-muted">
            {isHovering && videoSrc ? (
              <video
                ref={videoRef}
                src={videoSrc}
                muted
                loop
                playsInline
                className="h-full w-full object-cover"
              />
            ) : thumbnailSrc ? (
              <Image
                src={thumbnailSrc}
                alt={fullName}
                fill
                className="object-cover"
                sizes="64px"
              />
            ) : seeker.photo_url ? (
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
          <div className="min-w-0 flex-1">
            <h3 className="truncate font-semibold">{fullName}</h3>
            {seeker.age && (
              <p className="text-sm text-muted-foreground">{seeker.age} ans</p>
            )}
            {seeker.school && (
              <p className="truncate text-sm text-muted-foreground">{seeker.school}</p>
            )}
          </div>
        </div>
      </CardHeader>

      <CardContent className="space-y-2 pt-0">
        {/* Offer applied to */}
        <div className="rounded-md bg-muted px-2 py-1 text-xs">
          <span className="font-medium">Offre :</span>{" "}
          {offer.title || "Sans titre"}
        </div>

        {/* Badges */}
        <div className="flex flex-wrap gap-1">
          <Badge variant={statusInfo.variant} className="text-xs">
            {statusInfo.label}
          </Badge>
          {seeker.domain && (
            <Badge variant="secondary" className="text-xs">
              {getSectorLabel(seeker.domain)}
            </Badge>
          )}
          {seeker.city && (
            <Badge variant="secondary" className="text-xs">
              {seeker.city}
            </Badge>
          )}
        </div>

        {/* Applied date */}
        <p className="text-xs text-muted-foreground">
          Postule le{" "}
          {new Date(application.applied_at).toLocaleDateString("fr-FR", {
            day: "numeric",
            month: "short",
            year: "numeric",
          })}
        </p>
      </CardContent>
    </Card>
  );
}
