"use client";

import Link from "next/link";
import { motion } from "framer-motion";
import { Button } from "@/components/ui/button";
import { Sparkles } from "lucide-react";

export function Hero() {
  return (
    <section className="relative overflow-hidden bg-white px-6 py-24">
      <div className="mx-auto max-w-5xl text-center">
        {/* Badge */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.5 }}
          className="mb-8 inline-flex"
        >
          <div className="inline-flex items-center gap-2 rounded-full border border-accent/20 bg-accent-bg px-4 py-1.5 text-sm font-medium text-accent">
            <Sparkles className="h-3.5 w-3.5" />
            Recrutement alternance France
          </div>
        </motion.div>

        {/* Heading */}
        <motion.h1
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.5, delay: 0.1 }}
          className="heading-xl mb-6 text-text-primary"
        >
          Recrutez avec{" "}
          <span className="text-accent">la vidéo</span>, pas le CV
        </motion.h1>

        {/* Subtitle */}
        <motion.p
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.5, delay: 0.2 }}
          className="body-lg mx-auto mb-10 max-w-2xl text-text-secondary"
        >
          Découvrez les soft skills de vos candidats en 40 secondes.
          Pré-sélectionnez les profils qui correspondent vraiment à votre
          entreprise, avant même l'entretien.
        </motion.p>

        {/* CTAs */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.5, delay: 0.3 }}
          className="flex flex-col items-center justify-center gap-4 sm:flex-row"
        >
          <Link href="/login">
            <Button size="lg" className="h-12 px-8 text-base">
              Démarrer l'essai gratuit
            </Button>
          </Link>
          <Button variant="outline" size="lg" className="h-12 px-8 text-base">
            Voir une démo →
          </Button>
        </motion.div>
      </div>
    </section>
  );
}
