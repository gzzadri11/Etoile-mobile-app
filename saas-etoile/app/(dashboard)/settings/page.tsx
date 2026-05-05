"use client";

import { useEffect, useState, useMemo } from "react";
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { createClient } from "@/lib/supabase/client";
import type { RecruiterProfile } from "@/lib/types/database";
import { recruiterSettingsSchema, type RecruiterSettingsFormData } from "@/lib/validations/recruiter-settings";
import { updateRecruiterProfile } from "./actions";
import { calculateRecruiterCompletion } from "@/lib/utils/profile-completion";
import { ProfileProgressBar } from "@/components/settings/ProfileProgressBar";
import { PhotoUploadSection } from "@/components/settings/PhotoUploadSection";
import { DocumentUploadSection } from "@/components/settings/DocumentUploadSection";
import { SECTORS } from "@/lib/constants/sectors";
import { Form, FormControl, FormDescription, FormField, FormItem, FormLabel, FormMessage } from "@/components/ui/form";
import { Input } from "@/components/ui/input";
import { CityAutocompleteInput } from "@/components/settings/city-autocomplete-input";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Textarea } from "@/components/ui/textarea";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { toast } from "sonner";
import { Loader2, CheckCircle2, Clock, XCircle } from "lucide-react";

export default function SettingsPage() {
  const [profile, setProfile] = useState<RecruiterProfile | null>(null);
  const [loading, setLoading] = useState(true);

  const form = useForm<RecruiterSettingsFormData>({
    resolver: zodResolver(recruiterSettingsSchema),
    defaultValues: {
      photo_url: "",
      company_name: "",
      sector: "informatique_tech",
      description: "",
      address: "",
      siret: "",
      document_url: "",
    },
  });

  const { watch, setValue } = form;

  // Load profile data
  async function loadProfile() {
    const supabase = createClient();
    const {
      data: { user },
    } = await supabase.auth.getUser();

    if (!user) {
      setLoading(false);
      return;
    }

    const { data: recruiterProfile } = await supabase
      .from("recruiter_profiles")
      .select("*")
      .eq("user_id", user.id)
      .single();

    if (recruiterProfile) {
      setProfile(recruiterProfile);
      // Set form default values
      form.reset({
        photo_url: recruiterProfile.photo_url || "",
        company_name: recruiterProfile.company_name || "",
        sector: (recruiterProfile.sector as any) || "informatique_tech",
        description: recruiterProfile.description || "",
        address: recruiterProfile.address || "",
        siret: recruiterProfile.siret || "",
        document_url: recruiterProfile.document_url || "",
      });
    }

    setLoading(false);
  }

  useEffect(() => {
    loadProfile();
  }, []);

  // Calculate completion percentage dynamically
  const completionPercentage = useMemo(() => {
    if (!profile) return 0;

    // Create mock profile with current form values
    const currentProfile: RecruiterProfile = {
      ...profile,
      company_name: watch("company_name") || profile.company_name,
      sector: watch("sector") || profile.sector,
      description: watch("description") || profile.description,
      address: watch("address") || profile.address,
      siret: watch("siret") || profile.siret,
      document_url: watch("document_url") || profile.document_url,
    };

    return calculateRecruiterCompletion(currentProfile);
  }, [profile, watch("company_name"), watch("sector"), watch("description"), watch("address"), watch("siret"), watch("document_url")]);

  // Form submission
  const onSubmit = async (data: RecruiterSettingsFormData) => {
    const result = await updateRecruiterProfile(data);

    if (result.success) {
      toast.success("Profil mis à jour", {
        description: "Vos modifications ont été enregistrées avec succès.",
      });
      await loadProfile();
    } else {
      toast.error("Erreur lors de la sauvegarde", {
        description: result.error || "Une erreur est survenue lors de la sauvegarde.",
      });
    }
  };

  const getVerificationBadge = () => {
    if (!profile) return null;

    switch (profile.verification_status) {
      case "verified":
        return (
          <Badge variant="default" className="gap-1">
            <CheckCircle2 className="h-3 w-3" />
            Vérifié
          </Badge>
        );
      case "pending":
        return (
          <Badge variant="secondary" className="gap-1">
            <Clock className="h-3 w-3" />
            En attente
          </Badge>
        );
      case "rejected":
        return (
          <Badge variant="destructive" className="gap-1">
            <XCircle className="h-3 w-3" />
            Rejeté
          </Badge>
        );
    }
  };

  if (loading) {
    return (
      <div className="flex items-center justify-center py-20">
        <Loader2 className="h-6 w-6 animate-spin" />
        <p className="ml-2 text-muted-foreground">Chargement...</p>
      </div>
    );
  }

  if (!profile) {
    return (
      <div className="flex flex-col items-center justify-center py-20">
        <p className="text-lg font-medium">Profil introuvable</p>
        <p className="mt-1 text-sm text-muted-foreground">
          Impossible de charger votre profil recruteur.
        </p>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <div>
        <h1 className="text-2xl font-bold">Paramètres</h1>
        <p className="text-sm text-muted-foreground mt-1">
          Gérez votre profil entreprise et vos informations.
        </p>
      </div>

      {/* Progress Bar Card (Option A) */}
      <Card>
        <CardHeader>
          <CardTitle>Complétude de votre profil</CardTitle>
          <CardDescription>
            Complétez votre profil à 100% pour publier des offres et contacter des candidats.
          </CardDescription>
        </CardHeader>
        <CardContent>
          <ProfileProgressBar completionPercentage={completionPercentage} />
        </CardContent>
      </Card>

      {/* Single Form (7 sections) */}
      <Form {...form}>
        <form onSubmit={form.handleSubmit(onSubmit)} className="space-y-6">
          {/* Section 1: Photo de profil */}
          <Card>
            <CardHeader>
              <CardTitle>Photo de profil</CardTitle>
              <CardDescription>
                Ajoutez une photo pour humaniser votre compte.
              </CardDescription>
            </CardHeader>
            <CardContent>
              <PhotoUploadSection
                currentPhotoUrl={profile.photo_url}
                companyName={profile.company_name}
                userId={profile.user_id}
                onPhotoUpdated={(url) => {
                  setValue("photo_url", url);
                  loadProfile();
                }}
              />
            </CardContent>
          </Card>

          {/* Section 2: Informations entreprise */}
          <Card>
            <CardHeader>
              <CardTitle>Informations entreprise</CardTitle>
              <CardDescription>
                Nom et secteur d'activité de votre entreprise.
              </CardDescription>
            </CardHeader>
            <CardContent className="space-y-4">
              <FormField
                control={form.control}
                name="company_name"
                render={({ field }) => (
                  <FormItem>
                    <FormLabel>Nom de l'entreprise</FormLabel>
                    <FormControl>
                      <Input placeholder="Acme Inc." {...field} />
                    </FormControl>
                    <FormMessage />
                  </FormItem>
                )}
              />

              <FormField
                control={form.control}
                name="sector"
                render={({ field }) => (
                  <FormItem>
                    <FormLabel>Secteur d'activité</FormLabel>
                    <Select onValueChange={field.onChange} value={field.value}>
                      <FormControl>
                        <SelectTrigger>
                          <SelectValue placeholder="Sélectionnez un secteur" />
                        </SelectTrigger>
                      </FormControl>
                      <SelectContent>
                        {SECTORS.map((sector) => (
                          <SelectItem key={sector.value} value={sector.value}>
                            {sector.label}
                          </SelectItem>
                        ))}
                      </SelectContent>
                    </Select>
                    <FormMessage />
                  </FormItem>
                )}
              />
            </CardContent>
          </Card>

          {/* Section 3: Description */}
          <Card>
            <CardHeader>
              <CardTitle>Description</CardTitle>
              <CardDescription>
                Présentez votre entreprise, votre culture et vos valeurs (min. 50 caractères).
              </CardDescription>
            </CardHeader>
            <CardContent>
              <FormField
                control={form.control}
                name="description"
                render={({ field }) => (
                  <FormItem>
                    <FormLabel>Description de l'entreprise</FormLabel>
                    <FormControl>
                      <Textarea
                        placeholder="Décrivez votre entreprise, votre culture, vos valeurs..."
                        className="min-h-[120px]"
                        {...field}
                      />
                    </FormControl>
                    <FormDescription>
                      {field.value?.length || 0} / 50 caractères minimum
                    </FormDescription>
                    <FormMessage />
                  </FormItem>
                )}
              />
            </CardContent>
          </Card>

          {/* Section 4: Ville */}
          <Card>
            <CardHeader>
              <CardTitle>Ville de l'entreprise</CardTitle>
              <CardDescription>
                La ville où se trouve votre entreprise, visible par les candidats.
              </CardDescription>
            </CardHeader>
            <CardContent>
              <FormField
                control={form.control}
                name="address"
                render={({ field }) => (
                  <FormItem>
                    <FormLabel>Ville principale</FormLabel>
                    <FormControl>
                      <CityAutocompleteInput
                        value={field.value || ""}
                        onCitySelected={field.onChange}
                        clearOnSelect={false}
                        placeholder="Ex: Paris, Lyon, Marseille..."
                      />
                    </FormControl>
                    <FormDescription>
                      Tapez au moins 2 caractères pour voir les suggestions de villes.
                    </FormDescription>
                    <FormMessage />
                  </FormItem>
                )}
              />
            </CardContent>
          </Card>

          {/* Section 5: SIRET (read-only) */}
          <Card>
            <CardHeader>
              <CardTitle>SIRET</CardTitle>
              <CardDescription>
                Numéro SIRET de l'entreprise (non modifiable après vérification).
              </CardDescription>
            </CardHeader>
            <CardContent>
              <div className="space-y-2">
                <label className="text-sm font-medium">SIRET</label>
                <div className="flex items-center gap-2">
                  <Input value={profile.siret || "Non renseigné"} disabled />
                  {getVerificationBadge()}
                </div>
                {profile.verification_status === "rejected" && profile.rejection_reason && (
                  <div className="rounded-lg border border-destructive/50 bg-destructive/10 p-4 mt-2">
                    <p className="text-sm font-medium text-destructive">Raison du rejet</p>
                    <p className="text-sm text-destructive/80 mt-1">{profile.rejection_reason}</p>
                  </div>
                )}
              </div>
            </CardContent>
          </Card>

          {/* Section 6: Document justificatif */}
          <Card>
            <CardHeader>
              <CardTitle>Document justificatif</CardTitle>
              <CardDescription>
                Kbis, carte professionnelle ou autre document prouvant votre identité professionnelle.
              </CardDescription>
            </CardHeader>
            <CardContent>
              <DocumentUploadSection
                currentDocumentUrl={profile.document_url}
                documentType={profile.document_type}
                verificationStatus={profile.verification_status}
                rejectionReason={profile.rejection_reason}
                userId={profile.user_id}
                onDocumentUpdated={(url) => {
                  setValue("document_url", url);
                  loadProfile();
                }}
              />
            </CardContent>
          </Card>

          {/* Submit Button */}
          <div className="flex justify-end">
            <Button type="submit" size="lg" disabled={form.formState.isSubmitting}>
              {form.formState.isSubmitting ? (
                <>
                  <Loader2 className="mr-2 h-4 w-4 animate-spin" />
                  Enregistrement...
                </>
              ) : (
                "Enregistrer les modifications"
              )}
            </Button>
          </div>
        </form>
      </Form>
    </div>
  );
}
