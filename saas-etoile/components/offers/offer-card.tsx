"use client";

import Image from "next/image";
import type { Video } from "@/lib/types/database";
import { getSectorLabel } from "@/lib/constants/sectors";
import { getContractTypeLabel } from "@/lib/constants/contracts";
import { Badge } from "@/components/ui/badge";
import {
  Card,
  CardContent,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu";


interface OfferCardProps {
  video: Video;
  applicationCount: number;
  onEdit: (video: Video) => void;
  onDelete: (video: Video) => void;
}

const STATUS_LABELS: Record<string, { label: string; variant: "default" | "secondary" | "destructive" | "outline" }> = {
  active: { label: "Active", variant: "default" },
  processing: { label: "En cours", variant: "secondary" },
  suspended: { label: "Suspendue", variant: "destructive" },
};

export function OfferCard({ video, applicationCount, onEdit, onDelete }: OfferCardProps) {
  const statusInfo = STATUS_LABELS[video.status] ?? { label: video.status, variant: "outline" as const };
  const workerUrl = process.env.NEXT_PUBLIC_CLOUDFLARE_WORKER_URL;
  const thumbnailSrc = video.thumbnail_key
    ? `${workerUrl}/thumbnail/${video.thumbnail_key}`
    : null;
  const isVideo = video.type === "offer";

  return (
    <Card className="overflow-hidden transition-all duration-200 hover:shadow-lg hover:-translate-y-0.5">
      <div className="relative aspect-video bg-muted">
        {thumbnailSrc ? (
          <>
            <Image
              src={thumbnailSrc}
              alt={video.title ?? "Offre"}
              fill
              className="object-cover"
              sizes="(max-width: 768px) 100vw, 33vw"
            />
            {isVideo && (
              <div className="absolute inset-0 flex items-center justify-center bg-black/10">
                <div className="flex h-10 w-10 items-center justify-center rounded-full bg-white/90 shadow-md">
                  <svg className="ml-0.5 h-4 w-4 text-gray-800" fill="currentColor" viewBox="0 0 16 16">
                    <path d="M6.79 5.093L11 8 6.79 10.907V5.093z" />
                    <path fillRule="evenodd" d="M0 8a8 8 0 1116 0A8 8 0 010 8zm8-7a7 7 0 100 14A7 7 0 008 1z" />
                  </svg>
                </div>
              </div>
            )}
          </>
        ) : (
          <div className="flex h-full items-center justify-center text-muted-foreground">
            {isVideo ? "Vidéo" : "Affiche"}
          </div>
        )}
        <div className="absolute right-2 top-2">
          <Badge variant={statusInfo.variant}>{statusInfo.label}</Badge>
        </div>
      </div>

      <CardHeader className="pb-2">
        <div className="flex items-start justify-between gap-2">
          <CardTitle className="line-clamp-1 text-base">
            {video.title || "Sans titre"}
          </CardTitle>
          <DropdownMenu>
            <DropdownMenuTrigger className="inline-flex h-8 w-8 shrink-0 items-center justify-center rounded-lg text-muted-foreground hover:bg-muted hover:text-foreground">
              ...
            </DropdownMenuTrigger>
            <DropdownMenuContent align="end">
              <DropdownMenuItem onClick={() => onEdit(video)}>
                Modifier
              </DropdownMenuItem>
              <DropdownMenuItem
                onClick={() => onDelete(video)}
                className="text-destructive"
              >
                Supprimer
              </DropdownMenuItem>
            </DropdownMenuContent>
          </DropdownMenu>
        </div>
      </CardHeader>

      <CardContent className="space-y-2">
        <div className="flex flex-wrap gap-1">
          <Badge variant="outline">{isVideo ? "Video" : "Affiche"}</Badge>
          {video.sector && (
            <Badge variant="secondary">{getSectorLabel(video.sector)}</Badge>
          )}
          {video.contract_type && (
            <Badge variant="secondary">
              {getContractTypeLabel(video.contract_type)}
            </Badge>
          )}
        </div>
        <p className="text-sm text-muted-foreground">
          {applicationCount} candidature{applicationCount !== 1 ? "s" : ""}
        </p>
      </CardContent>
    </Card>
  );
}
