"use client";

import { useState } from "react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { createClient } from "@/lib/supabase/client";
import { ROUTES } from "@/lib/constants/routes";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";

export default function RegisterPage() {
  const router = useRouter();
  const [companyName, setCompanyName] = useState("");
  const [email, setEmail] = useState("");
  const [siret, setSiret] = useState("");
  const [password, setPassword] = useState("");
  const [confirmPassword, setConfirmPassword] = useState("");
  const [acceptCgu, setAcceptCgu] = useState(false);
  const [error, setError] = useState("");
  const [loading, setLoading] = useState(false);

  function validateSiret(value: string): boolean {
    return /^\d{14}$/.test(value);
  }

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    setError("");

    if (password !== confirmPassword) {
      setError("Les mots de passe ne correspondent pas");
      return;
    }

    if (password.length < 8) {
      setError("Le mot de passe doit contenir au moins 8 caractères");
      return;
    }

    if (!validateSiret(siret)) {
      setError("Le SIRET doit contenir exactement 14 chiffres");
      return;
    }

    if (!acceptCgu) {
      setError("Veuillez accepter les conditions générales d'utilisation");
      return;
    }

    setLoading(true);

    const supabase = createClient();
    const { error: authError } = await supabase.auth.signUp({
      email,
      password,
      options: {
        data: {
          role: "recruiter",
          first_name: companyName,
          siret,
        },
      },
    });

    if (authError) {
      setError(mapAuthError(authError.message));
      setLoading(false);
      return;
    }

    // Redirect to OTP verification
    router.push(`${ROUTES.VERIFY}?email=${encodeURIComponent(email)}`);
  }

  return (
    <Card>
      <CardHeader>
        <CardTitle>Créer un compte</CardTitle>
        <CardDescription>
          Inscrivez votre entreprise sur Etoile
        </CardDescription>
      </CardHeader>
      <CardContent>
        <form onSubmit={handleSubmit} className="flex flex-col gap-4">
          <div className="flex flex-col gap-2">
            <Label htmlFor="companyName">Nom de l&apos;entreprise</Label>
            <Input
              id="companyName"
              type="text"
              placeholder="Mon Entreprise SAS"
              value={companyName}
              onChange={(e) => setCompanyName(e.target.value)}
              required
            />
          </div>

          <div className="flex flex-col gap-2">
            <Label htmlFor="email">Email professionnel</Label>
            <Input
              id="email"
              type="email"
              placeholder="contact@entreprise.fr"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              required
            />
          </div>

          <div className="flex flex-col gap-2">
            <Label htmlFor="siret">SIRET (14 chiffres)</Label>
            <Input
              id="siret"
              type="text"
              placeholder="12345678901234"
              maxLength={14}
              value={siret}
              onChange={(e) => {
                const digits = e.target.value.replace(/\D/g, "");
                setSiret(digits);
              }}
              required
            />
            {siret.length > 0 && siret.length < 14 && (
              <p className="text-xs text-muted-foreground">
                {siret.length}/14 chiffres
              </p>
            )}
          </div>

          <div className="flex flex-col gap-2">
            <Label htmlFor="password">Mot de passe</Label>
            <Input
              id="password"
              type="password"
              placeholder="Minimum 8 caractères"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              required
              minLength={8}
            />
          </div>

          <div className="flex flex-col gap-2">
            <Label htmlFor="confirmPassword">Confirmer le mot de passe</Label>
            <Input
              id="confirmPassword"
              type="password"
              placeholder="••••••••"
              value={confirmPassword}
              onChange={(e) => setConfirmPassword(e.target.value)}
              required
            />
          </div>

          <div className="flex items-start gap-2">
            <input
              id="cgu"
              type="checkbox"
              checked={acceptCgu}
              onChange={(e) => setAcceptCgu(e.target.checked)}
              className="mt-1"
            />
            <Label htmlFor="cgu" className="text-sm text-muted-foreground">
              J&apos;accepte les conditions générales d&apos;utilisation
              et la politique de confidentialité
            </Label>
          </div>

          {error && (
            <p className="text-sm text-destructive">{error}</p>
          )}

          <Button type="submit" disabled={loading} className="w-full">
            {loading ? "Inscription..." : "Créer mon compte"}
          </Button>

          <p className="text-center text-sm text-muted-foreground">
            Déjà un compte ?{" "}
            <Link
              href={ROUTES.LOGIN}
              className="font-medium text-secondary hover:underline"
            >
              Se connecter
            </Link>
          </p>
        </form>
      </CardContent>
    </Card>
  );
}

function mapAuthError(msg: string): string {
  const lower = msg.toLowerCase();
  if (lower.includes("user already registered") || lower.includes("email already exists")) {
    return "Cet email est déjà utilisé";
  }
  if (lower.includes("password") && (lower.includes("weak") || lower.includes("short"))) {
    return "Le mot de passe doit contenir au moins 8 caractères";
  }
  if (lower.includes("invalid email")) {
    return "Veuillez entrer un email valide";
  }
  if (lower.includes("rate limit") || lower.includes("too many")) {
    return "Trop de tentatives. Veuillez patienter.";
  }
  return msg;
}
