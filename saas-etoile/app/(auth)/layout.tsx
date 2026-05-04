import { Star, Shield } from "lucide-react";

export default function AuthLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <div className="flex min-h-screen">
      {/* Colonne gauche — Violet #635BFF */}
      <div className="hidden lg:flex lg:w-1/2 bg-accent flex-col justify-between p-12 text-white">
        {/* Logo */}
        <div className="flex items-center gap-3">
          <div className="flex h-11 w-11 items-center justify-center rounded-lg bg-white">
            <Star className="h-6 w-6 text-accent" fill="currentColor" />
          </div>
          <span className="text-2xl font-bold tracking-tight">Étoile</span>
        </div>

        {/* Tagline */}
        <div className="space-y-6">
          <h2 className="heading-lg text-white">
            Le recrutement vidéo<br />enfin simple
          </h2>
          <p className="body-lg text-white/90 max-w-md">
            Découvrez les soft skills de vos candidats en 40 secondes.
            Pré-sélectionnez les profils qui correspondent vraiment à votre entreprise.
          </p>
        </div>

        {/* Footer */}
        <div className="flex items-center gap-2 text-sm text-white/80">
          <Shield className="h-4 w-4" />
          <span>Données hébergées en UE — Conforme RGPD</span>
        </div>
      </div>

      {/* Colonne droite — Blanche avec formulaire */}
      <div className="flex flex-1 flex-col items-center justify-center bg-white px-6 lg:px-12">
        {/* Logo mobile */}
        <div className="mb-10 flex flex-col items-center gap-3 lg:hidden">
          <div className="flex h-11 w-11 items-center justify-center rounded-lg bg-accent">
            <Star className="h-6 w-6 text-white" fill="white" />
          </div>
          <h1 className="text-2xl font-bold tracking-tight text-text-primary">
            Étoile Recruteurs
          </h1>
        </div>

        {/* Formulaire */}
        <div className="w-full max-w-md">{children}</div>
      </div>
    </div>
  );
}
