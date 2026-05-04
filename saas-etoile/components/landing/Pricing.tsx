"use client";

import Link from "next/link";
import { Check } from "lucide-react";
import { Button } from "@/components/ui/button";

export function Pricing() {
  const plans = [
    {
      name: "Gratuit",
      price: "0€",
      period: "/mois",
      description: "Pour tester la plateforme",
      features: [
        "1 offre active",
        "10 candidatures max",
        "Messagerie limitée",
        "Support par email",
      ],
      cta: "Commencer gratuitement",
      popular: false,
    },
    {
      name: "Premium",
      price: "499€",
      period: "/mois",
      description: "Pour recruter en continu",
      features: [
        "Offres illimitées",
        "Candidatures illimitées",
        "Messagerie temps réel illimitée",
        "Score de matching avancé",
        "Recherche @username",
        "Dashboard & analytics",
        "Support prioritaire",
        "Export des données",
      ],
      cta: "Démarrer l'essai 14 jours",
      popular: true,
    },
  ];

  return (
    <section id="pricing" className="scroll-mt-16 bg-white px-6 py-24">
      <div className="mx-auto max-w-6xl">
        <div className="mb-16 text-center">
          <h2 className="heading-lg mb-4 text-text-primary">
            Tarifs simples et transparents
          </h2>
          <p className="body-lg text-text-secondary">
            Essai gratuit 14 jours. Pas de carte bancaire requise.
          </p>
        </div>

        <div className="grid gap-8 md:grid-cols-2">
          {plans.map((plan, i) => (
            <div
              key={i}
              className={`relative overflow-hidden rounded-2xl border ${
                plan.popular
                  ? "border-accent shadow-lg"
                  : "border-border shadow-sm"
              } bg-white p-8`}
            >
              {plan.popular && (
                <div className="absolute left-1/2 top-0 -translate-x-1/2 -translate-y-1/2">
                  <div className="whitespace-nowrap rounded-full bg-accent px-4 py-1 text-xs font-semibold text-white">
                    Le plus populaire
                  </div>
                </div>
              )}

              <div className="mb-6">
                <h3 className="mb-2 text-2xl font-bold text-text-primary">
                  {plan.name}
                </h3>
                <p className="text-sm text-text-secondary">{plan.description}</p>
              </div>

              <div className="mb-6 flex items-baseline">
                <span className="text-5xl font-bold text-text-primary">
                  {plan.price}
                </span>
                <span className="ml-2 text-text-secondary">{plan.period}</span>
              </div>

              <Link href="/login" className="block">
                <Button
                  variant={plan.popular ? "default" : "outline"}
                  size="lg"
                  className="mb-8 w-full"
                >
                  {plan.cta}
                </Button>
              </Link>

              <div className="space-y-3">
                {plan.features.map((feature, j) => (
                  <div key={j} className="flex items-start gap-3">
                    <Check className="h-5 w-5 shrink-0 text-accent" strokeWidth={2.5} />
                    <span className="text-sm text-text-secondary">{feature}</span>
                  </div>
                ))}
              </div>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}
