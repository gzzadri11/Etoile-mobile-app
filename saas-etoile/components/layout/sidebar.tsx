"use client";

import { usePathname } from "next/navigation";
import Link from "next/link";
import { Star, BarChart3, Users, Briefcase, Search, Settings } from "lucide-react";
import { RecruiterAvatar } from "@/components/settings/RecruiterAvatar";

interface SidebarProps {
  userInfo: {
    email: string;
    companyName: string;
    photoUrl: string | null;
  } | null;
}

export function Sidebar({ userInfo }: SidebarProps) {
  const pathname = usePathname();

  const navItems = [
    { href: "/home", label: "Dashboard", icon: BarChart3, badge: null },
    { href: "/candidates", label: "Candidats", icon: Users, badge: null },
    { href: "/offers", label: "Mes offres", icon: Briefcase, badge: null },
  ];

  const toolsItems = [
    { href: "/search", label: "Rechercher", icon: Search },
    { href: "/settings", label: "Paramètres", icon: Settings },
  ];

  function isActive(href: string) {
    return pathname === href || pathname?.startsWith(href + "/");
  }

  return (
    <aside className="fixed left-0 top-0 z-40 h-screen w-[220px] border-r border-border bg-white">
      {/* Header Logo */}
      <div className="flex h-16 items-center gap-2.5 border-b border-border px-5">
        <div className="flex h-9 w-9 items-center justify-center rounded-lg bg-accent">
          <Star className="h-5 w-5 text-white" fill="white" />
        </div>
        <span className="text-lg font-bold tracking-tight text-text-primary">
          Étoile
        </span>
      </div>

      {/* Nav */}
      <nav className="flex flex-col justify-between p-3" style={{ height: "calc(100vh - 64px - 72px)" }}>
        <div className="space-y-1">
          {navItems.map((item) => {
              const Icon = item.icon;
              const active = isActive(item.href);

              return (
                <Link
                  key={item.href}
                  href={item.href}
                  className={`group flex items-center gap-2.5 rounded-lg px-2.5 py-2 text-sm font-medium transition-all ${
                    active
                      ? "bg-accent-bg text-accent"
                      : "text-text-secondary hover:bg-bg-muted hover:text-text-primary"
                  }`}
                >
                  <Icon className="h-4 w-4 shrink-0" strokeWidth={2} />
                  <span className="flex-1">{item.label}</span>
                  {item.badge !== null && (
                    <span className="flex h-5 w-5 items-center justify-center rounded-full bg-accent text-xs font-semibold text-white">
                      {item.badge}
                    </span>
                  )}
                </Link>
              );
            })}

            {/* Section Outils */}
            <div className="my-3 border-t border-border pt-3">
              <div className="label mb-2 px-2.5 text-text-tertiary">Outils</div>
              {toolsItems.map((item) => {
                const Icon = item.icon;
                const active = isActive(item.href);

                return (
                  <Link
                    key={item.href}
                    href={item.href}
                    className={`group flex items-center gap-2.5 rounded-lg px-2.5 py-2 text-sm font-medium transition-all ${
                      active
                        ? "bg-accent-bg text-accent"
                        : "text-text-secondary hover:bg-bg-muted hover:text-text-primary"
                    }`}
                  >
                    <Icon className="h-4 w-4 shrink-0" strokeWidth={2} />
                    <span>{item.label}</span>
                  </Link>
                );
              })}
            </div>
        </div>
      </nav>

      {/* Footer User */}
      <div className="absolute bottom-0 left-0 right-0 border-t border-border bg-white p-3">
        {userInfo ? (
          <div className="flex items-center gap-2.5">
            <RecruiterAvatar
              photoUrl={userInfo.photoUrl}
              companyName={userInfo.companyName}
              size="sm"
              className="!h-9 !w-9 !text-sm shrink-0"
            />
            <div className="flex-1 overflow-hidden">
              <div className="truncate text-sm font-semibold text-text-primary">
                {userInfo.companyName}
              </div>
              <div className="truncate text-xs text-text-tertiary">
                {userInfo.email}
              </div>
            </div>
          </div>
        ) : (
          <div className="flex items-center gap-2.5">
            <div className="flex h-9 w-9 shrink-0 items-center justify-center rounded-full bg-bg-muted text-sm font-bold text-text-tertiary">
              ?
            </div>
            <div className="flex-1 overflow-hidden">
              <div className="truncate text-sm font-semibold text-text-secondary">
                Non connecté
              </div>
            </div>
          </div>
        )}
      </div>
    </aside>
  );
}
