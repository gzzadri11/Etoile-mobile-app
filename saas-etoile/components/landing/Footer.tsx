import Link from "next/link";
import { Star } from "lucide-react";

export function Footer() {
  return (
    <footer className="border-t border-border bg-white px-6 py-12">
      <div className="mx-auto max-w-6xl">
        <div className="mb-8 flex items-center gap-2.5">
          <div className="flex h-9 w-9 items-center justify-center rounded-lg bg-accent">
            <Star className="h-5 w-5 text-white" fill="white" />
          </div>
          <span className="text-lg font-bold tracking-tight text-text-primary">
            Étoile
          </span>
        </div>

        <div className="grid gap-8 md:grid-cols-4">
          <div>
            <h3 className="mb-4 text-sm font-semibold text-text-primary">
              Produit
            </h3>
            <ul className="space-y-2">
              <li>
                <a href="#features" className="text-sm text-text-secondary hover:text-text-primary">
                  Fonctionnalités
                </a>
              </li>
              <li>
                <a href="#pricing" className="text-sm text-text-secondary hover:text-text-primary">
                  Tarifs
                </a>
              </li>
              <li>
                <Link href="/login" className="text-sm text-text-secondary hover:text-text-primary">
                  Se connecter
                </Link>
              </li>
            </ul>
          </div>

          <div>
            <h3 className="mb-4 text-sm font-semibold text-text-primary">
              Entreprise
            </h3>
            <ul className="space-y-2">
              <li>
                <a href="#" className="text-sm text-text-secondary hover:text-text-primary">
                  À propos
                </a>
              </li>
              <li>
                <a href="#" className="text-sm text-text-secondary hover:text-text-primary">
                  Blog
                </a>
              </li>
              <li>
                <a href="#" className="text-sm text-text-secondary hover:text-text-primary">
                  Nous contacter
                </a>
              </li>
            </ul>
          </div>

          <div>
            <h3 className="mb-4 text-sm font-semibold text-text-primary">
              Légal
            </h3>
            <ul className="space-y-2">
              <li>
                <a href="#" className="text-sm text-text-secondary hover:text-text-primary">
                  Conditions générales
                </a>
              </li>
              <li>
                <a href="#" className="text-sm text-text-secondary hover:text-text-primary">
                  Politique de confidentialité
                </a>
              </li>
              <li>
                <a href="#" className="text-sm text-text-secondary hover:text-text-primary">
                  Mentions légales
                </a>
              </li>
            </ul>
          </div>

          <div>
            <h3 className="mb-4 text-sm font-semibold text-text-primary">
              Ressources
            </h3>
            <ul className="space-y-2">
              <li>
                <a href="#" className="text-sm text-text-secondary hover:text-text-primary">
                  Centre d'aide
                </a>
              </li>
              <li>
                <a href="#" className="text-sm text-text-secondary hover:text-text-primary">
                  Documentation
                </a>
              </li>
              <li>
                <a href="#" className="text-sm text-text-secondary hover:text-text-primary">
                  Statut du service
                </a>
              </li>
            </ul>
          </div>
        </div>

        <div className="mt-12 border-t border-border pt-8 text-center">
          <p className="text-sm text-text-tertiary">
            © 2026 Étoile. Recrutement par vidéo pour l'alternance en France.
          </p>
        </div>
      </div>
    </footer>
  );
}
