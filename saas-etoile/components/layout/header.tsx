"use client";

import { usePathname } from "next/navigation";

const pageTitles: Record<string, string> = {
  "/dashboard": "Dashboard",
  "/candidates": "Candidats",
  "/offers": "Offres",
  "/messages": "Messages",
  "/settings": "Paramètres",
};

export function Header() {
  const pathname = usePathname();
  const title = pageTitles[pathname] ?? "Etoile";

  return (
    <header className="flex h-16 items-center border-b border-border bg-background px-8">
      <h2 className="text-lg font-semibold text-foreground">{title}</h2>
    </header>
  );
}
