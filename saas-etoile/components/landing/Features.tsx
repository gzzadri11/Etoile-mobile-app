"use client";

import { Grid3x3, Target, MessageCircle, Search, BarChart3, ShieldCheck } from "lucide-react";

export function Features() {
  const features = [
    {
      icon: Grid3x3,
      title: "Grille vidéo interactive",
      description:
        "Parcourez les candidatures en un coup d'œil. Filtrez par secteur, score de matching, et localisation.",
    },
    {
      icon: Target,
      title: "Score de matching",
      description:
        "Algorithme intelligent qui calcule la compatibilité entre votre offre et le profil du candidat.",
    },
    {
      icon: MessageCircle,
      title: "Messagerie temps réel",
      description:
        "Contactez directement les candidats qui vous intéressent. Chat intégré style WhatsApp.",
    },
    {
      icon: Search,
      title: "Recherche @username",
      description:
        "Retrouvez un candidat rencontré en physique en saisissant son @username unique.",
    },
    {
      icon: BarChart3,
      title: "Dashboard & pipeline",
      description:
        "Suivez vos KPIs : candidatures reçues, shortlistés, contactés. Funnel de conversion visuel.",
    },
    {
      icon: ShieldCheck,
      title: "Recruteurs vérifiés",
      description:
        "Tous les comptes recruteurs sont vérifiés par SIRET. Profils candidats authentiques.",
    },
  ];

  return (
    <section id="features" className="scroll-mt-16 bg-white px-6 py-24">
      <div className="mx-auto max-w-6xl">
        <div className="mb-16 text-center">
          <h2 className="heading-lg mb-4 text-text-primary">
            Tout ce dont vous avez besoin
          </h2>
          <p className="body-lg mx-auto max-w-2xl text-text-secondary">
            Une plateforme complète pour recruter vos alternants en vidéo.
            Simple, efficace, humaine.
          </p>
        </div>

        <div className="grid gap-8 md:grid-cols-2 lg:grid-cols-3">
          {features.map((feature, i) => (
            <div
              key={i}
              className="group rounded-xl border border-border bg-white p-6 transition-all hover:-translate-y-0.5 hover:border-accent/30 hover:shadow-md"
            >
              <div className="mb-4 flex h-12 w-12 items-center justify-center rounded-lg bg-accent-bg">
                <feature.icon className="h-6 w-6 text-accent" strokeWidth={2} />
              </div>
              <h3 className="mb-2 text-lg font-semibold text-text-primary">
                {feature.title}
              </h3>
              <p className="text-sm leading-relaxed text-text-secondary">
                {feature.description}
              </p>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}
