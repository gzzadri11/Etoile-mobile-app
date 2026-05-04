"use client";

import { useState } from "react";
import { createClient } from "@/lib/supabase/client";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";

export function SecuritySection() {
  const [newPassword, setNewPassword] = useState("");
  const [confirmPassword, setConfirmPassword] = useState("");
  const [updating, setUpdating] = useState(false);

  async function handleChangePassword() {
    if (newPassword !== confirmPassword) {
      alert("❌ Les mots de passe ne correspondent pas.");
      return;
    }

    if (newPassword.length < 8) {
      alert("❌ Le mot de passe doit contenir au moins 8 caractères.");
      return;
    }

    setUpdating(true);
    const supabase = createClient();

    const { error } = await supabase.auth.updateUser({
      password: newPassword,
    });

    if (!error) {
      alert("✅ Mot de passe mis à jour avec succès !");
      setNewPassword("");
      setConfirmPassword("");
    } else {
      alert("❌ Erreur : " + error.message);
    }

    setUpdating(false);
  }

  return (
    <Card>
      <CardHeader>
        <CardTitle>Sécurité</CardTitle>
        <CardDescription>
          Modifiez votre mot de passe pour sécuriser votre compte.
        </CardDescription>
      </CardHeader>
      <CardContent className="space-y-4">
        <div className="space-y-2">
          <Label htmlFor="new-password">Nouveau mot de passe</Label>
          <Input
            id="new-password"
            type="password"
            value={newPassword}
            onChange={(e) => setNewPassword(e.target.value)}
            placeholder="Minimum 8 caractères"
          />
        </div>

        <div className="space-y-2">
          <Label htmlFor="confirm-password">Confirmer le mot de passe</Label>
          <Input
            id="confirm-password"
            type="password"
            value={confirmPassword}
            onChange={(e) => setConfirmPassword(e.target.value)}
            placeholder="Retapez le mot de passe"
          />
        </div>

        <div className="flex justify-end pt-4">
          <Button
            variant="default"
            onClick={handleChangePassword}
            disabled={!newPassword || !confirmPassword || updating}
          >
            {updating ? "Modification..." : "Changer le mot de passe"}
          </Button>
        </div>
      </CardContent>
    </Card>
  );
}
