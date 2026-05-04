"use client";

import { motion } from "framer-motion";
import { BarChart3, Users, Briefcase, MessageSquare } from "lucide-react";

export function AppPreview() {
  return (
    <section className="px-6 py-16">
      <motion.div
        initial={{ opacity: 0, y: 40 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.6, delay: 0.4 }}
        className="mx-auto max-w-6xl"
      >
        <div className="overflow-hidden rounded-2xl border border-border bg-white shadow-xl">
          {/* Fausse interface */}
          <div className="flex h-[480px]">
            {/* Sidebar miniature */}
            <div className="w-56 shrink-0 border-r border-border bg-bg-subtle p-4">
              <div className="mb-6 flex items-center gap-2">
                <div className="flex h-8 w-8 items-center justify-center rounded-lg bg-accent">
                  <span className="text-sm font-bold text-white">★</span>
                </div>
                <span className="text-sm font-bold">Étoile</span>
              </div>

              <div className="space-y-1">
                <div className="flex items-center gap-2.5 rounded-lg bg-accent-bg px-3 py-2 text-sm font-semibold text-accent">
                  <BarChart3 className="h-4 w-4" />
                  <span>Dashboard</span>
                </div>
                <div className="flex items-center gap-2.5 rounded-lg px-3 py-2 text-sm font-medium text-text-secondary">
                  <Users className="h-4 w-4" />
                  <span>Candidats</span>
                  <span className="ml-auto flex h-5 w-5 items-center justify-center rounded-full bg-accent text-xs text-white">
                    12
                  </span>
                </div>
                <div className="flex items-center gap-2.5 rounded-lg px-3 py-2 text-sm font-medium text-text-secondary">
                  <Briefcase className="h-4 w-4" />
                  <span>Mes offres</span>
                </div>
                <div className="flex items-center gap-2.5 rounded-lg px-3 py-2 text-sm font-medium text-text-secondary">
                  <MessageSquare className="h-4 w-4" />
                  <span>Messages</span>
                  <span className="ml-auto flex h-5 w-5 items-center justify-center rounded-full bg-accent text-xs text-white">
                    3
                  </span>
                </div>
              </div>
            </div>

            {/* Grille de candidats miniature */}
            <div className="flex-1 p-6">
              <div className="mb-4 flex items-center justify-between">
                <h2 className="text-lg font-bold">Candidats</h2>
                <span className="text-sm text-text-secondary">28 candidats</span>
              </div>

              <div className="grid grid-cols-4 gap-4">
                {[
                  { name: "LM", color: "from-violet-500 to-purple-500", score: 92 },
                  { name: "SB", color: "from-blue-500 to-cyan-500", score: 88 },
                  { name: "AD", color: "from-pink-500 to-rose-500", score: 85 },
                  { name: "TM", color: "from-green-500 to-emerald-500", score: 82 },
                  { name: "NC", color: "from-orange-500 to-amber-500", score: 78 },
                  { name: "ML", color: "from-indigo-500 to-violet-500", score: 76 },
                  { name: "EL", color: "from-teal-500 to-cyan-500", score: 74 },
                  { name: "JD", color: "from-red-500 to-pink-500", score: 71 },
                ].map((candidate, i) => (
                  <div
                    key={i}
                    className="overflow-hidden rounded-lg border border-border bg-white shadow-xs transition-shadow hover:shadow-md"
                  >
                    <div className="relative aspect-[3/4] bg-gradient-to-br ${candidate.color}">
                      <div className="flex h-full items-center justify-center">
                        <span className="text-3xl font-bold text-white opacity-90">
                          {candidate.name}
                        </span>
                      </div>
                      <div
                        className={`absolute right-2 top-2 rounded-full px-2 py-0.5 text-xs font-bold text-white ${
                          candidate.score >= 80 ? "bg-success" : "bg-warning"
                        }`}
                      >
                        {candidate.score}%
                      </div>
                    </div>
                    <div className="p-2">
                      <div className="text-xs font-semibold text-text-primary">
                        Candidat {i + 1}
                      </div>
                      <div className="text-xs text-text-tertiary">Paris · Bac+3</div>
                    </div>
                  </div>
                ))}
              </div>
            </div>
          </div>
        </div>
      </motion.div>
    </section>
  );
}
