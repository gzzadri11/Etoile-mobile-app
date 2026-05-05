"use client";

import { useState } from "react";
import { motion } from "framer-motion";
import { X, Check, FileText, Users, MessageCircle } from "lucide-react";
import { useOnboardingStatus } from "@/hooks/useOnboardingStatus";

export function OnboardingBanner() {
  const [dismissed, setDismissed] = useState(false);
  const { steps, allDone, loading } = useOnboardingStatus();

  if (dismissed || allDone) return null;

  const stepConfig = [
    { key: "accountCreated" as const, label: "Compte créé", icon: Check },
    { key: "siretVerified" as const, label: "SIRET vérifié", icon: Check },
    { key: "offerPublished" as const, label: "Publier une offre", icon: FileText },
    { key: "candidateViewed" as const, label: "Voir vos candidats", icon: Users },
    { key: "firstContact" as const, label: "Premier contact", icon: MessageCircle },
  ];

  // Active step = first incomplete one
  const activeKey = stepConfig.find((s) => !steps[s.key])?.key;

  return (
    <div className="relative overflow-hidden rounded-xl border border-border bg-white p-6 shadow-sm">
      <button
        onClick={() => setDismissed(true)}
        className="absolute right-4 top-4 rounded-lg p-1 text-text-tertiary transition-colors hover:bg-bg-muted hover:text-text-primary"
      >
        <X className="h-4 w-4" />
      </button>

      <div className="mb-4 flex items-start gap-3">
        <div className="flex h-10 w-10 shrink-0 items-center justify-center rounded-lg bg-accent-bg text-xl">
          ⭐
        </div>
        <div>
          <h3 className="text-lg font-semibold text-text-primary">Complétez votre profil</h3>
          <p className="text-sm text-text-secondary">
            {loading ? "Chargement…" : "Quelques étapes pour démarrer votre recrutement"}
          </p>
        </div>
      </div>

      <div className="flex items-center gap-3 overflow-x-auto pb-2">
        {stepConfig.map((step, i) => {
          const Icon = step.icon;
          const isDone = steps[step.key];
          const isActive = step.key === activeKey;

          return (
            <div key={step.key} className="flex items-center">
              <motion.div
                animate={isActive ? { scale: [1, 1.02, 1] } : {}}
                transition={{ repeat: Infinity, duration: 2 }}
                className="flex shrink-0 items-center gap-2"
              >
                <div
                  className={`flex h-8 w-8 items-center justify-center rounded-full border-2 ${
                    isDone
                      ? "border-success bg-success text-white"
                      : isActive
                      ? "border-accent bg-accent text-white"
                      : "border-border bg-white text-text-tertiary"
                  }`}
                >
                  <Icon className="h-4 w-4" strokeWidth={2.5} />
                </div>
                <span
                  className={`whitespace-nowrap text-sm font-medium ${
                    isDone ? "text-success" : isActive ? "text-accent" : "text-text-tertiary"
                  }`}
                >
                  {step.label}
                </span>
              </motion.div>

              {i < stepConfig.length - 1 && (
                <div className={`mx-3 h-px w-8 ${isDone ? "bg-success" : "bg-border"}`} />
              )}
            </div>
          );
        })}
      </div>
    </div>
  );
}
