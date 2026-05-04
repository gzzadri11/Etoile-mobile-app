"use client";

import { useState } from "react";
import type { Video } from "@/lib/types/database";
import { createClient } from "@/lib/supabase/client";
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogDescription,
  DialogFooter,
} from "@/components/ui/dialog";
import { Button } from "@/components/ui/button";

interface DeleteOfferDialogProps {
  video: Video | null;
  open: boolean;
  onOpenChange: (open: boolean) => void;
  onDeleted: () => void;
}

export function DeleteOfferDialog({
  video,
  open,
  onOpenChange,
  onDeleted,
}: DeleteOfferDialogProps) {
  const [deleting, setDeleting] = useState(false);

  async function handleDelete() {
    if (!video) return;
    setDeleting(true);

    const supabase = createClient();

    // Get current user ID
    const {
      data: { user },
    } = await supabase.auth.getUser();

    if (!user) {
      setDeleting(false);
      return;
    }

    // Soft delete video
    await supabase
      .from("videos")
      .update({
        status: "deleted",
        updated_at: new Date().toISOString(),
      })
      .eq("id", video.id);

    // Re-increment credits (undo decrement from publish)
    const creditField = video.type === "offer" ? "video_credits" : "poster_credits";
    const { data: profile } = await supabase
      .from("recruiter_profiles")
      .select(creditField)
      .eq("user_id", user.id)
      .single();

    if (profile) {
      await supabase
        .from("recruiter_profiles")
        .update({ [creditField]: (profile[creditField as keyof typeof profile] as number) + 1 })
        .eq("user_id", user.id);
    }

    setDeleting(false);
    onOpenChange(false);
    onDeleted();
  }

  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent className="sm:max-w-md">
        <DialogHeader>
          <DialogTitle>Supprimer l&apos;offre</DialogTitle>
          <DialogDescription>
            Voulez-vous vraiment supprimer &quot;{video?.title || "Sans titre"}&quot; ?
            Cette action est irreversible.
          </DialogDescription>
        </DialogHeader>

        <DialogFooter>
          <Button variant="outline" onClick={() => onOpenChange(false)}>
            Annuler
          </Button>
          <Button variant="destructive" onClick={handleDelete} disabled={deleting}>
            {deleting ? "Suppression..." : "Supprimer"}
          </Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  );
}
