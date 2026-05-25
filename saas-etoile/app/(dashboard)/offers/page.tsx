"use client";

import { Suspense, useCallback, useEffect, useState } from "react";
import { useSearchParams } from "next/navigation";
import Link from "next/link";
import { createClient } from "@/lib/supabase/client";
import { ROUTES } from "@/lib/constants/routes";
import type { Video } from "@/lib/types/database";
import { buttonVariants } from "@/components/ui/button";
import { OfferCard } from "@/components/offers/offer-card";
import { OfferCandidatesView } from "@/components/offers/OfferCandidatesView";
import { EditOfferDialog } from "@/components/offers/edit-offer-dialog";
import { DeleteOfferDialog } from "@/components/offers/delete-offer-dialog";
import { Package } from "lucide-react";

export default function OffersPage() {
  return (
    <Suspense>
      <OffersPageInner />
    </Suspense>
  );
}

function OffersPageInner() {
  const [videos, setVideos] = useState<Video[]>([]);
  const [appCounts, setAppCounts] = useState<Record<string, number>>({});
  const [loading, setLoading] = useState(true);
  const [selectedOffer, setSelectedOffer] = useState<Video | null>(null);
  const [editVideo, setEditVideo] = useState<Video | null>(null);
  const [deleteVideo, setDeleteVideo] = useState<Video | null>(null);
  const searchParams = useSearchParams();

  const loadOffers = useCallback(async () => {
    const supabase = createClient();
    const { data: { user } } = await supabase.auth.getUser();
    if (!user) return;

    const { data: videosData } = await supabase
      .from("videos")
      .select("*")
      .eq("user_id", user.id)
      .in("type", ["offer", "poster"])
      .neq("status", "deleted")
      .order("created_at", { ascending: false });

    const offersList = (videosData ?? []) as Video[];
    setVideos(offersList);

    if (offersList.length > 0) {
      const videoIds = offersList.map((v) => v.id);
      const { data: apps } = await supabase
        .from("applications")
        .select("video_id")
        .in("video_id", videoIds);

      const counts: Record<string, number> = {};
      for (const app of apps ?? []) {
        counts[app.video_id] = (counts[app.video_id] ?? 0) + 1;
      }
      setAppCounts(counts);
    }

    setLoading(false);
  }, []);

  useEffect(() => { loadOffers(); }, [loadOffers]);

  // Ouvre directement l'offre si ?offer=<id> est dans l'URL (lien depuis le dashboard)
  useEffect(() => {
    const offerId = searchParams.get("offer");
    if (offerId && videos.length > 0) {
      const target = videos.find((v) => v.id === offerId);
      if (target) setSelectedOffer(target);
    }
  }, [searchParams, videos]);

  // État B — Vue candidatures d'une offre
  if (selectedOffer) {
    return (
      <OfferCandidatesView
        offer={selectedOffer}
        onBack={() => setSelectedOffer(null)}
      />
    );
  }

  // État A — Liste des offres
  if (loading) {
    return (
      <div className="flex items-center justify-center py-20">
        <p className="text-muted-foreground">Chargement...</p>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <h1 className="text-2xl font-bold">Mes offres</h1>
        <Link href={ROUTES.OFFERS_NEW} className={buttonVariants({ variant: "default" })}>
          Publier une offre
        </Link>
      </div>

      {videos.length === 0 ? (
        <div className="flex flex-col items-center justify-center rounded-lg border border-dashed py-20">
          <Package className="h-12 w-12 text-muted-foreground mb-4" />
          <p className="text-lg font-medium">Prêt à démarrer ?</p>
          <p className="mt-1 text-sm text-muted-foreground">
            Publiez votre première offre pour commencer à recevoir des candidatures.
          </p>
          <Link href={ROUTES.OFFERS_NEW} className={buttonVariants({ variant: "default", className: "mt-4" })}>
            Publier une offre
          </Link>
        </div>
      ) : (
        <div className="grid gap-6 sm:grid-cols-2 lg:grid-cols-3">
          {videos.map((video) => (
            <OfferCard
              key={video.id}
              video={video}
              applicationCount={appCounts[video.id] ?? 0}
              onEdit={setEditVideo}
              onDelete={setDeleteVideo}
              onViewCandidates={() => setSelectedOffer(video)}
            />
          ))}
        </div>
      )}

      <EditOfferDialog
        video={editVideo}
        open={editVideo !== null}
        onOpenChange={(open) => { if (!open) setEditVideo(null); }}
        onSaved={loadOffers}
      />

      <DeleteOfferDialog
        video={deleteVideo}
        open={deleteVideo !== null}
        onOpenChange={(open) => { if (!open) setDeleteVideo(null); }}
        onDeleted={loadOffers}
      />
    </div>
  );
}
