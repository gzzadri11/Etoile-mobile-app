import type { Metadata } from "next";
import { Sora } from "next/font/google";
import { Toaster } from "@/components/ui/sonner";
import "./globals.css";

const sora = Sora({
  subsets: ["latin"],
  weight: ["300", "400", "500", "600", "700", "800"],
  variable: "--font-sans",
});

export const metadata: Metadata = {
  title: "Étoile Recruteurs",
  description:
    "Plateforme de recrutement par vidéo courte pour l'alternance en France",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="fr" className={sora.variable}>
      <body className="min-h-screen antialiased" style={{ fontFamily: 'var(--font-sans)' }}>
        {children}
        <Toaster />
      </body>
    </html>
  );
}
