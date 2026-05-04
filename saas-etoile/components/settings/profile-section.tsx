"use client";

import { useState } from "react";
import { createClient } from "@/lib/supabase/client";
import type { RecruiterProfile } from "@/lib/types/database";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Textarea } from "@/components/ui/textarea";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { SECTORS } from "@/lib/constants/sectors";
import { X } from "lucide-react";
import { CityAutocompleteInput } from "./city-autocomplete-input";
import { PhotoUploadSection } from "./PhotoUploadSection";

interface ProfileSectionProps {
  profile: RecruiterProfile;
  onUpdate: () => void;
}

export function ProfileSection({ profile, onUpdate }: ProfileSectionProps) {
  const [photoUrl, setPhotoUrl] = useState(profile.photo_url || null);
  const [companyName, setCompanyName] = useState(profile.company_name);
  const [description, setDescription] = useState(profile.description || "");
  const [sector, setSector] = useState(profile.sector || "");
  const [locations, setLocations] = useState<string[]>(profile.locations || []);
  const [saving, setSaving] = useState(false);

  function handlePhotoUpdated(newPhotoUrl: string) {
    setPhotoUrl(newPhotoUrl);
    // Refresh parent to update profile data
    onUpdate();
  }

  function handleAddLocation(cityLabel: string) {
    const trimmed = cityLabel.trim();
    if (!trimmed) return;

    if (locations.includes(trimmed)) {
      alert("Cette ville est déjà dans la liste.");
      return;
    }

    setLocations([...locations, trimmed]);
  }

  function handleRemoveLocation(index: number) {
    setLocations(locations.filter((_, i) => i !== index));
  }

  async function handleSave() {
    setSaving(true);
    const supabase = createClient();

    const { error } = await supabase
      .from("recruiter_profiles")
      .update({
        company_name: companyName,
        description: description || null,
        sector: sector || null,
        locations: locations,
      })
      .eq("user_id", profile.user_id);

    if (!error) {
      alert("✅ Profil mis à jour !");
      onUpdate();
    } else {
      alert("❌ Erreur : " + error.message);
    }

    setSaving(false);
  }

  const hasChanges =
    companyName !== profile.company_name ||
    (description || "") !== (profile.description || "") ||
    (sector || "") !== (profile.sector || "") ||
    JSON.stringify(locations) !== JSON.stringify(profile.locations || []);

  return (
    <Card>
      <CardHeader>
        <CardTitle>Informations du profil</CardTitle>
        <CardDescription>
          Gérez les informations de votre entreprise visibles par les candidats.
        </CardDescription>
      </CardHeader>
      <CardContent className="space-y-6">
        {/* Photo Profile */}
        <PhotoUploadSection
          currentPhotoUrl={photoUrl}
          companyName={companyName}
          userId={profile.user_id}
          onPhotoUpdated={handlePhotoUpdated}
        />

        {/* Company Name */}
        <div className="space-y-2">
          <Label htmlFor="company-name">Nom de l'entreprise</Label>
          <Input
            id="company-name"
            value={companyName}
            onChange={(e) => setCompanyName(e.target.value)}
            placeholder="Ex: Boulangerie Martin"
          />
        </div>

        {/* SIRET (read-only) */}
        <div className="space-y-2">
          <Label>SIRET</Label>
          <div className="flex items-center gap-2">
            <Input value={profile.siret || "Non renseigné"} disabled />
            {profile.verification_status === "verified" && (
              <Badge variant="default">Vérifié</Badge>
            )}
          </div>
          <p className="text-xs text-muted-foreground">
            Le SIRET ne peut pas être modifié après vérification.
          </p>
        </div>

        {/* Sector */}
        <div className="space-y-2">
          <Label htmlFor="sector">Secteur d'activité</Label>
          <Select value={sector} onValueChange={(v) => setSector(v ?? "")}>
            <SelectTrigger id="sector">
              <SelectValue placeholder="Sélectionnez un secteur" />
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

        {/* Description */}
        <div className="space-y-2">
          <Label htmlFor="description">
            Description de l'entreprise
            <span className="ml-2 text-xs text-muted-foreground">
              ({description.length}/500 caractères)
            </span>
          </Label>
          <Textarea
            id="description"
            value={description}
            onChange={(e) => setDescription(e.target.value.slice(0, 500))}
            placeholder="Présentez votre entreprise en quelques lignes..."
            rows={4}
          />
        </div>

        {/* Locations */}
        <div className="space-y-2">
          <Label>Localisations de l'entreprise</Label>
          <p className="text-xs text-muted-foreground">
            Ajoutez les villes où se trouvent vos bureaux, sites ou établissements
          </p>
          <CityAutocompleteInput
            onCitySelected={handleAddLocation}
            placeholder="Recherchez une ville (ex: Paris, Lyon...)"
          />
          <div className="flex flex-wrap gap-2 mt-2">
            {locations.length > 0 ? (
              locations.map((loc, i) => (
                <Badge
                  key={i}
                  variant="secondary"
                  className="gap-1 pr-1 cursor-pointer hover:bg-destructive/20"
                  onClick={() => handleRemoveLocation(i)}
                >
                  {loc}
                  <X className="h-3 w-3" />
                </Badge>
              ))
            ) : (
              <p className="text-sm text-muted-foreground">Aucune localisation</p>
            )}
          </div>
        </div>

        {/* Save button */}
        <div className="flex justify-end pt-4">
          <Button
            variant="default"
            onClick={handleSave}
            disabled={!hasChanges || saving}
          >
            {saving ? "Enregistrement..." : "Enregistrer les modifications"}
          </Button>
        </div>
      </CardContent>
    </Card>
  );
}
