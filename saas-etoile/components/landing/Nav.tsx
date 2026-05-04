"use client";

import Link from "next/link";
import { Star } from "lucide-react";
import { Button } from "@/components/ui/button";

export function Nav() {
  return (
    <nav className="sticky top-0 z-50 h-16 border-b border-border/50 bg-white/80 backdrop-blur-lg">
      <div className="mx-auto flex h-full max-w-7xl items-center justify-between px-6">
        {/* Logo */}
        <Link href="/" className="flex items-center gap-2.5">
          <div className="flex h-9 w-9 items-center justify-center rounded-lg bg-accent">
            <Star className="h-5 w-5 text-white" fill="white" />
          </div>
          <span className="text-lg font-bold tracking-tight text-text-primary">
            Étoile
          </span>
        </Link>

        {/* Nav links */}
        <div className="hidden items-center gap-8 md:flex">
          <a
            href="#features"
            className="text-sm font-medium text-text-secondary transition-colors hover:text-text-primary"
          >
            Fonctionnalités
          </a>
          <a
            href="#how-it-works"
            className="text-sm font-medium text-text-secondary transition-colors hover:text-text-primary"
          >
            Comment ça marche
          </a>
          <a
            href="#pricing"
            className="text-sm font-medium text-text-secondary transition-colors hover:text-text-primary"
          >
            Tarifs
          </a>
        </div>

        {/* Actions */}
        <div className="flex items-center gap-3">
          <Link href="/login">
            <Button variant="ghost" size="sm">
              Se connecter
            </Button>
          </Link>
          <Link href="/login">
            <Button size="sm">
              Démarrer gratuitement →
            </Button>
          </Link>
        </div>
      </div>
    </nav>
  );
}
