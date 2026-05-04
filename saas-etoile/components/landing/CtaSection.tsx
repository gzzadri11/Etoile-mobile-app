"use client";

import Link from "next/link";
import { Button } from "@/components/ui/button";

export function CtaSection() {
  return (
    <section className="bg-accent px-6 py-24">
      <div className="mx-auto max-w-4xl text-center">
        <h2 className="heading-lg mb-6 text-white">
          Prêt à transformer votre recrutement ?
        </h2>
        <p className="body-lg mb-8 text-white/90">
          Rejoignez les centaines de recruteurs qui utilisent Étoile pour
          trouver leurs alternants.
        </p>
        <Link href="/login">
          <Button
            size="lg"
            className="h-14 bg-white px-10 text-base font-semibold text-accent hover:bg-white/90"
          >
            Démarrer l'essai gratuit →
          </Button>
        </Link>
      </div>
    </section>
  );
}
