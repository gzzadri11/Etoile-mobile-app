"use client";

import { useState } from "react";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { uploadFile } from "@/lib/uploadFile";
import { Upload, FileText, Loader2, ExternalLink } from "lucide-react";

interface DocumentUploadSectionProps {
  currentDocumentUrl: string | null;
  documentType: string | null;
  verificationStatus: "pending" | "verified" | "rejected";
  rejectionReason: string | null;
  userId: string;
  onDocumentUpdated: (url: string) => void;
}

export function DocumentUploadSection({
  currentDocumentUrl,
  documentType,
  verificationStatus,
  rejectionReason,
  userId,
  onDocumentUpdated,
}: DocumentUploadSectionProps) {
  const [uploading, setUploading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const handleFileChange = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (!file) return;

    // Validation
    const validTypes = ["application/pdf", "image/jpeg", "image/png"];
    if (!validTypes.includes(file.type)) {
      setError("Format invalide. Accepté : PDF, JPG, PNG");
      return;
    }

    if (file.size > 5 * 1024 * 1024) {
      setError("Fichier trop volumineux (max 5 Mo)");
      return;
    }

    setError(null);
    setUploading(true);

    try {
      const result = await uploadFile(file, "verification-docs", userId);
      onDocumentUpdated(result.url);
    } catch (err) {
      setError(err instanceof Error ? err.message : "Erreur d'upload");
    } finally {
      setUploading(false);
    }
  };

  const getStatusBadge = () => {
    switch (verificationStatus) {
      case "verified":
        return <Badge variant="default">Vérifié</Badge>;
      case "pending":
        return <Badge variant="secondary">En attente de vérification</Badge>;
      case "rejected":
        return <Badge variant="destructive">Rejeté</Badge>;
      default:
        return <Badge variant="outline">Aucun document</Badge>;
    }
  };

  const showUploadButton = !currentDocumentUrl || verificationStatus === "rejected";

  return (
    <div className="space-y-4">
      <div className="flex items-center gap-3">
        {currentDocumentUrl && (
          <div className="flex h-12 w-12 items-center justify-center rounded-lg border-2 border-border bg-muted">
            <FileText className="h-6 w-6 text-muted-foreground" />
          </div>
        )}
        <div className="flex-1">
          <div className="flex items-center gap-2">
            {getStatusBadge()}
            {documentType && (
              <span className="text-sm text-muted-foreground">({documentType})</span>
            )}
          </div>
          {currentDocumentUrl && (
            <a
              href={currentDocumentUrl}
              target="_blank"
              rel="noopener noreferrer"
              className="mt-1 flex items-center gap-1 text-sm text-primary hover:underline"
            >
              Voir le document
              <ExternalLink className="h-3 w-3" />
            </a>
          )}
        </div>
      </div>

      {verificationStatus === "rejected" && rejectionReason && (
        <div className="rounded-lg border border-destructive/50 bg-destructive/10 p-3">
          <p className="text-sm font-medium text-destructive">Raison du rejet</p>
          <p className="mt-1 text-sm text-destructive/80">{rejectionReason}</p>
        </div>
      )}

      {showUploadButton && (
        <div>
          <input
            type="file"
            id="document-upload"
            accept=".pdf,.jpg,.jpeg,.png"
            onChange={handleFileChange}
            className="hidden"
            disabled={uploading}
          />
          <label htmlFor="document-upload">
            <Button
              type="button"
              variant="outline"
              disabled={uploading}
              className="w-full cursor-pointer"
              onClick={() => document.getElementById("document-upload")?.click()}
            >
              {uploading ? (
                <>
                  <Loader2 className="mr-2 h-4 w-4 animate-spin" />
                  Upload en cours...
                </>
              ) : (
                <>
                  <Upload className="mr-2 h-4 w-4" />
                  {currentDocumentUrl ? "Remplacer le document" : "Uploader un document"}
                </>
              )}
            </Button>
          </label>
          <p className="mt-2 text-xs text-muted-foreground">
            PDF, JPG ou PNG - Max 5 Mo
          </p>
        </div>
      )}

      {error && (
        <p className="text-sm font-medium text-destructive">{error}</p>
      )}
    </div>
  );
}
