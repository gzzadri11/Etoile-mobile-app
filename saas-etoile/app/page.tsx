import Link from "next/link";
import { Button } from "@/components/ui/button";
import { ROUTES } from "@/lib/constants/routes";

export default function LandingPage() {
  return (
    <div className="flex min-h-screen flex-col">
      {/* Header */}
      <header className="flex items-center justify-between border-b border-border px-8 py-4">
        <div className="flex items-center gap-2">
          <div className="flex h-8 w-8 items-center justify-center rounded-lg bg-primary">
            <span className="text-sm font-bold text-primary-foreground">E</span>
          </div>
          <span className="text-lg font-semibold">Etoile</span>
        </div>
        <div className="flex items-center gap-3">
          <Link href={ROUTES.LOGIN}>
            <Button variant="outline">Se connecter</Button>
          </Link>
          <Link href={ROUTES.REGISTER}>
            <Button>Créer un compte</Button>
          </Link>
        </div>
      </header>

      {/* Hero */}
      <main className="flex flex-1 flex-col items-center justify-center px-4 text-center">
        <h1 className="max-w-2xl text-4xl font-bold tracking-tight text-foreground sm:text-5xl">
          Recrutez vos alternants
          <br />
          <span className="text-secondary">par la vidéo</span>
        </h1>
        <p className="mt-6 max-w-lg text-lg text-muted-foreground">
          Découvrez les soft skills de vos candidats en 40 secondes.
          Pré-sélectionnez les profils qui correspondent à votre entreprise,
          avant même l'entretien.
        </p>
        <div className="mt-10 flex items-center gap-4">
          <Link href={ROUTES.REGISTER}>
            <Button size="lg">
              Commencer gratuitement
            </Button>
          </Link>
          <Link href={ROUTES.LOGIN}>
            <Button variant="outline" size="lg">
              J&apos;ai déjà un compte
            </Button>
          </Link>
        </div>

        {/* Features */}
        <div className="mt-20 grid max-w-4xl gap-8 sm:grid-cols-3">
          <div className="rounded-xl border border-border p-6 text-left">
            <div className="mb-3 text-2xl">🎬</div>
            <h3 className="mb-2 font-semibold">Vidéos 40s</h3>
            <p className="text-sm text-muted-foreground">
              Les candidats se présentent en vidéo courte. Evaluez leur
              motivation et personnalité en un clin d&apos;oeil.
            </p>
          </div>
          <div className="rounded-xl border border-border p-6 text-left">
            <div className="mb-3 text-2xl">🎯</div>
            <h3 className="mb-2 font-semibold">Matching intelligent</h3>
            <p className="text-sm text-muted-foreground">
              Notre algorithme vous propose les profils les plus pertinents
              selon votre secteur et localisation.
            </p>
          </div>
          <div className="rounded-xl border border-border p-6 text-left">
            <div className="mb-3 text-2xl">💬</div>
            <h3 className="mb-2 font-semibold">Messagerie directe</h3>
            <p className="text-sm text-muted-foreground">
              Contactez les candidats qui vous intéressent directement depuis
              la plateforme.
            </p>
          </div>
        </div>
      </main>

      {/* Footer */}
      <footer className="border-t border-border px-8 py-6 text-center text-sm text-muted-foreground">
        Etoile — Recrutement par vidéo pour l&apos;alternance en
        Île-de-France
      </footer>
    </div>
  );
}
