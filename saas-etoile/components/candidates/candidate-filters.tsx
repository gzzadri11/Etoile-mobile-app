"use client";

import { SECTORS } from "@/lib/constants/sectors";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Separator } from "@/components/ui/separator";
import { Lightbulb } from "lucide-react";

export interface CandidateFilters {
  status: string;
  offerId: string;
  sector: string;
  scoreRange: "all" | "high" | "medium" | "low";
  rhythm: string;
}

interface CandidateFiltersProps {
  offers: Array<{ id: string; title: string | null }>;
  filters: CandidateFilters;
  onFiltersChange: (filters: CandidateFilters) => void;
}

export function CandidateFiltersComponent({
  offers,
  filters,
  onFiltersChange,
}: CandidateFiltersProps) {
  const updateFilter = (key: keyof CandidateFilters, value: string) => {
    onFiltersChange({ ...filters, [key]: value });
  };

  const resetFilters = () => {
    onFiltersChange({
      status: "all",
      offerId: "all",
      sector: "all",
      scoreRange: "all",
      rhythm: "all",
    });
  };

  const hasActiveFilters =
    filters.status !== "all" ||
    filters.offerId !== "all" ||
    filters.sector !== "all" ||
    filters.scoreRange !== "all" ||
    filters.rhythm !== "all";

  return (
    <div className="space-y-4 p-4 border-r bg-muted/30 min-h-full">
      <div className="flex items-center justify-between">
        <h3 className="font-semibold">Filtres</h3>
        {hasActiveFilters && (
          <Button variant="ghost" size="sm" onClick={resetFilters}>
            Réinitialiser
          </Button>
        )}
      </div>

      <Separator />

      {/* Statut */}
      <div className="space-y-2">
        <label className="text-sm font-medium">Statut</label>
        <Select
          value={filters.status}
          onValueChange={(v) => updateFilter("status", v ?? "all")}
        >
          <SelectTrigger>
            <SelectValue placeholder="Tous les statuts" />
          </SelectTrigger>
          <SelectContent>
            <SelectItem value="all">Tous les statuts</SelectItem>
            <SelectItem value="pending">En attente</SelectItem>
            <SelectItem value="contacted">Contactés</SelectItem>
          </SelectContent>
        </Select>
      </div>

      {/* Offre */}
      <div className="space-y-2">
        <label className="text-sm font-medium">Offre</label>
        <Select
          value={filters.offerId}
          onValueChange={(v) => updateFilter("offerId", v ?? "all")}
        >
          <SelectTrigger>
            <SelectValue placeholder="Toutes les offres" />
          </SelectTrigger>
          <SelectContent>
            <SelectItem value="all">Toutes les offres</SelectItem>
            {offers.map((offer) => (
              <SelectItem key={offer.id} value={offer.id}>
                {offer.title || "Sans titre"}
              </SelectItem>
            ))}
          </SelectContent>
        </Select>
      </div>

      {/* Secteur */}
      <div className="space-y-2">
        <label className="text-sm font-medium">Secteur</label>
        <Select
          value={filters.sector}
          onValueChange={(v) => updateFilter("sector", v ?? "all")}
        >
          <SelectTrigger>
            <SelectValue placeholder="Tous secteurs" />
          </SelectTrigger>
          <SelectContent>
            <SelectItem value="all">Tous secteurs</SelectItem>
            {SECTORS.map((s) => (
              <SelectItem key={s.value} value={s.value}>
                {s.label}
              </SelectItem>
            ))}
          </SelectContent>
        </Select>
      </div>

      {/* Rythme alternance */}
      <div className="space-y-2">
        <label className="text-sm font-medium">Rythme alternance</label>
        <Select
          value={filters.rhythm}
          onValueChange={(v) => updateFilter("rhythm", v ?? "all")}
        >
          <SelectTrigger>
            <SelectValue placeholder="Tous rythmes" />
          </SelectTrigger>
          <SelectContent>
            <SelectItem value="all">Tous rythmes</SelectItem>
            <SelectItem value="3j/2j">3j école / 2j entreprise</SelectItem>
            <SelectItem value="2j/3j">2j école / 3j entreprise</SelectItem>
            <SelectItem value="1j/4j">1j école / 4j entreprise</SelectItem>
            <SelectItem value="1sem/1sem">1 sem école / 1 sem entreprise</SelectItem>
            <SelectItem value="1sem/2sem">1 sem école / 2 sem entreprise</SelectItem>
            <SelectItem value="1sem/3sem">1 sem école / 3 sem entreprise</SelectItem>
            <SelectItem value="2sem/2sem">2 sem école / 2 sem entreprise</SelectItem>
            <SelectItem value="1mois/1mois">1 mois école / 1 mois entreprise</SelectItem>
            <SelectItem value="6sem/6sem">6 sem école / 6 sem entreprise</SelectItem>
            <SelectItem value="1tri/1tri">1 tri école / 1 tri entreprise</SelectItem>
            <SelectItem value="personnalise">Rythme personnalisé</SelectItem>
          </SelectContent>
        </Select>
      </div>

      <Separator />

      {/* Score de matching */}
      <div className="space-y-2">
        <label className="text-sm font-medium">Score de matching</label>
        <div className="flex flex-col gap-2">
          <Badge
            variant={filters.scoreRange === "high" ? "default" : "outline"}
            className="cursor-pointer justify-center py-2 hover:bg-primary/80"
            onClick={() => updateFilter("scoreRange", filters.scoreRange === "high" ? "all" : "high")}
          >
            Excellent (&gt;80%)
          </Badge>
          <Badge
            variant={filters.scoreRange === "medium" ? "default" : "outline"}
            className="cursor-pointer justify-center py-2 hover:bg-primary/80"
            onClick={() => updateFilter("scoreRange", filters.scoreRange === "medium" ? "all" : "medium")}
          >
            Bon (60-80%)
          </Badge>
          <Badge
            variant={filters.scoreRange === "low" ? "default" : "outline"}
            className="cursor-pointer justify-center py-2 hover:bg-primary/80"
            onClick={() => updateFilter("scoreRange", filters.scoreRange === "low" ? "all" : "low")}
          >
            Faible (&lt;60%)
          </Badge>
        </div>
      </div>

      <Separator />

      <div className="flex items-start gap-2 text-xs text-muted-foreground">
        <Lightbulb className="h-3.5 w-3.5 shrink-0 mt-0.5" strokeWidth={2} />
        <span>Astuce : cliquez sur un candidat pour voir son profil détaillé</span>
      </div>
    </div>
  );
}
