"use client";

import { useState } from "react";
import { PageHeader } from "@/components/layout/PageHeader";
import { Input } from "@/components/ui/input";
import { Search as SearchIcon } from "lucide-react";

export default function SearchPage() {
  const [query, setQuery] = useState("");

  return (
    <div className="space-y-6">
      <PageHeader title="Rechercher" />

      <div className="space-y-4">
        <p className="text-sm text-text-secondary">
          Recherchez des candidats par nom, secteur, ville ou compétences
        </p>

        {/* Barre de recherche */}
        <div className="relative">
          <SearchIcon className="absolute left-3 top-1/2 h-5 w-5 -translate-y-1/2 text-text-tertiary" />
          <Input
            type="text"
            placeholder="Rechercher un candidat..."
            value={query}
            onChange={(e) => setQuery(e.target.value)}
            className="pl-10"
          />
        </div>

        {/* Zone de résultats */}
        <div className="rounded-xl border border-border bg-white p-6">
          {query ? (
            <div className="text-center text-text-secondary">
              <p className="text-sm">
                Recherche pour <span className="font-medium text-text-primary">&quot;{query}&quot;</span>
              </p>
              <p className="mt-2 text-xs text-text-tertiary">
                Fonctionnalité en cours de développement
              </p>
            </div>
          ) : (
            <div className="text-center text-text-tertiary">
              <SearchIcon className="mx-auto mb-3 h-12 w-12 opacity-20" />
              <p className="text-sm">Commencez à taper pour rechercher</p>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
