"use client";

import { useState } from "react";
import type { Video } from "@/lib/types/database";
import { SECTORS } from "@/lib/constants/sectors";
import { CONTRACT_TYPES } from "@/lib/constants/contracts";
import { createClient } from "@/lib/supabase/client";
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogFooter,
} from "@/components/ui/dialog";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Textarea } from "@/components/ui/textarea";
import { Button } from "@/components/ui/button";

interface EditOfferDialogProps {
  video: Video | null;
  open: boolean;
  onOpenChange: (open: boolean) => void;
  onSaved: () => void;
}

export function EditOfferDialog({
  video,
  open,
  onOpenChange,
  onSaved,
}: EditOfferDialogProps) {
  const [title, setTitle] = useState(video?.title ?? "");
  const [description, setDescription] = useState(video?.description ?? "");
  const [sector, setSector] = useState(video?.sector ?? "");
  const [contractType, setContractType] = useState(video?.contract_type ?? "");
  const [saving, setSaving] = useState(false);

  // Sync state when video changes
  const [prevVideoId, setPrevVideoId] = useState<string | null>(null);
  if (video && video.id !== prevVideoId) {
    setPrevVideoId(video.id);
    setTitle(video.title ?? "");
    setDescription(video.description ?? "");
    setSector(video.sector ?? "");
    setContractType(video.contract_type ?? "");
  }

  async function handleSave() {
    if (!video) return;
    setSaving(true);

    const supabase = createClient();
    await supabase
      .from("videos")
      .update({
        title: title || null,
        description: description || null,
        sector: sector || null,
        contract_type: contractType || null,
        updated_at: new Date().toISOString(),
      })
      .eq("id", video.id);

    setSaving(false);
    onOpenChange(false);
    onSaved();
  }

  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent className="sm:max-w-md">
        <DialogHeader>
          <DialogTitle>Modifier l&apos;offre</DialogTitle>
        </DialogHeader>

        <div className="space-y-4">
          <div className="space-y-2">
            <Label htmlFor="edit-title">Titre</Label>
            <Input
              id="edit-title"
              value={title}
              onChange={(e) => setTitle(e.target.value)}
              placeholder="Ex: Alternant développeur web"
            />
          </div>

          <div className="space-y-2">
            <Label htmlFor="edit-sector">Secteur</Label>
            <Select value={sector} onValueChange={(v) => setSector(v ?? "")}>
              <SelectTrigger id="edit-sector">
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
            <Label htmlFor="edit-contract">Type de contrat</Label>
            <Select value={contractType} onValueChange={(v) => setContractType(v ?? "")}>
              <SelectTrigger id="edit-contract">
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
            <Label htmlFor="edit-description">Description</Label>
            <Textarea
              id="edit-description"
              value={description}
              onChange={(e) => setDescription(e.target.value)}
              placeholder="Décrivez le poste..."
              rows={4}
            />
          </div>
        </div>

        <DialogFooter>
          <Button variant="outline" onClick={() => onOpenChange(false)}>
            Annuler
          </Button>
          <Button onClick={handleSave} disabled={saving}>
            {saving ? "Enregistrement..." : "Enregistrer"}
          </Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  );
}
