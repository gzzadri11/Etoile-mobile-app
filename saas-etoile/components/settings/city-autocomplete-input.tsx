"use client";

import { useState, useEffect, useRef } from "react";
import { Input } from "@/components/ui/input";
import { MapPin, Loader2 } from "lucide-react";

interface CitySuggestion {
  label: string; // "Paris (75001)"
  city: string;
  postcode: string | null;
  context: string | null;
}

interface CityAutocompleteInputProps {
  onCitySelected: (cityLabel: string) => void;
  placeholder?: string;
}

export function CityAutocompleteInput({
  onCitySelected,
  placeholder = "Tapez pour rechercher une ville...",
}: CityAutocompleteInputProps) {
  const [query, setQuery] = useState("");
  const [suggestions, setSuggestions] = useState<CitySuggestion[]>([]);
  const [searching, setSearching] = useState(false);
  const [showSuggestions, setShowSuggestions] = useState(false);
  const debounceRef = useRef<NodeJS.Timeout | null>(null);
  const wrapperRef = useRef<HTMLDivElement>(null);

  // Close suggestions when clicking outside
  useEffect(() => {
    function handleClickOutside(event: MouseEvent) {
      if (wrapperRef.current && !wrapperRef.current.contains(event.target as Node)) {
        setShowSuggestions(false);
      }
    }

    document.addEventListener("mousedown", handleClickOutside);
    return () => document.removeEventListener("mousedown", handleClickOutside);
  }, []);

  async function searchCity(searchQuery: string) {
    setSearching(true);

    try {
      const response = await fetch(
        `https://api-adresse.data.gouv.fr/search/?q=${encodeURIComponent(
          searchQuery
        )}&type=municipality&limit=5`
      );

      if (!response.ok) {
        throw new Error("API error");
      }

      const data = await response.json();
      const features = data.features || [];
      const results: CitySuggestion[] = [];

      for (const feature of features) {
        const props = feature.properties || {};
        const city = props.city || props.name;
        if (!city) continue;

        const postcode = props.postcode || null;
        const context = props.context || null;

        // Build label: "Paris (75001)"
        const label = postcode ? `${city} (${postcode})` : city;

        // Avoid duplicates
        if (results.some((r) => r.label === label)) continue;

        results.push({ label, city, postcode, context });
      }

      setSuggestions(results);
      setShowSuggestions(results.length > 0);
    } catch (error) {
      console.error("City search error:", error);
      setSuggestions([]);
    } finally {
      setSearching(false);
    }
  }

  function handleInputChange(value: string) {
    setQuery(value);

    // Clear debounce timer
    if (debounceRef.current) {
      clearTimeout(debounceRef.current);
    }

    // Hide suggestions if query is too short
    if (value.trim().length < 2) {
      setSuggestions([]);
      setShowSuggestions(false);
      return;
    }

    // Debounce search (400ms)
    debounceRef.current = setTimeout(() => {
      searchCity(value.trim());
    }, 400);
  }

  function handleSelectSuggestion(suggestion: CitySuggestion) {
    onCitySelected(suggestion.label);
    setQuery("");
    setSuggestions([]);
    setShowSuggestions(false);
  }

  return (
    <div ref={wrapperRef} className="relative">
      <div className="relative">
        <MapPin className="absolute left-2.5 top-1/2 -translate-y-1/2 h-4 w-4 text-muted-foreground" />
        <Input
          value={query}
          onChange={(e) => handleInputChange(e.target.value)}
          placeholder={placeholder}
          className="pl-9"
          onFocus={() => {
            if (suggestions.length > 0) {
              setShowSuggestions(true);
            }
          }}
        />
        {searching && (
          <Loader2 className="absolute right-2.5 top-1/2 -translate-y-1/2 h-4 w-4 text-muted-foreground animate-spin" />
        )}
      </div>

      {/* Suggestions dropdown */}
      {showSuggestions && suggestions.length > 0 && (
        <div className="absolute z-50 mt-1 w-full rounded-lg border border-border bg-popover shadow-lg">
          {suggestions.map((suggestion, index) => (
            <button
              key={index}
              type="button"
              onClick={() => handleSelectSuggestion(suggestion)}
              className="flex w-full items-start gap-2 px-3 py-2 text-left text-sm hover:bg-accent transition-fast first:rounded-t-lg last:rounded-b-lg"
            >
              <MapPin className="h-4 w-4 text-muted-foreground mt-0.5 shrink-0" />
              <div className="flex-1 min-w-0">
                <div className="font-medium">{suggestion.label}</div>
                {suggestion.context && (
                  <div className="text-xs text-muted-foreground truncate">
                    {suggestion.context}
                  </div>
                )}
              </div>
            </button>
          ))}
        </div>
      )}
    </div>
  );
}
