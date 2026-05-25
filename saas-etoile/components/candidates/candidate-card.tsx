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
  onHide?: () => void;
  matchScore?: number;
}

export function CandidateCard({ candidate, onClick, onHide, matchScore }: CandidateCardProps) {
  const { seeker, offer, application, presentation_video } = candidate;
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

  // Play video on hover
  useEffect(() => {
    if (isHovering && videoRef.current && videoSrc) {
      videoRef.current.play().catch(() => {});
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
      {/* Bouton masquer — croix discrète, visible au hover */}
      {onHide && (
        <button
          onClick={(e) => { e.stopPropagation(); onHide(); }}
          title="Masquer ce candidat"
          className="absolute left-2 top-2 z-20 flex h-6 w-6 items-center justify-center rounded-full bg-black/10 text-xs text-text-tertiary opacity-0 transition-opacity hover:bg-black/20 hover:text-text-primary group-hover:opacity-100"
        >
          ×
        </button>
      )}

      {/* Score badge */}
      {matchScore !== undefined && (
        <div className="absolute right-2 top-2 z-10">
          <Badge variant={getScoreBadgeVariant(matchScore)} className="text-xs font-bold shadow-md">
            {matchScore}%
          </Badge>
        </div>
      )}

      <CardHeader className="pb-3">
        <div className="flex items-start gap-3">
          {/* Photo (default) with video preview on hover */}
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
          {application.status === "contacted" && (
            <Badge variant="default" className="text-xs">Contacté</Badge>
          )}
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
          Postulé le{" "}
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
