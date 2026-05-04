"use client";

import { useCallback, useRef, useState } from "react";
import { Upload } from "lucide-react";

interface FileDropZoneProps {
  accept: string;
  maxSizeMB: number;
  onFileSelected: (file: File) => void;
  label: string;
  hint: string;
}

export function FileDropZone({
  accept,
  maxSizeMB,
  onFileSelected,
  label,
  hint,
}: FileDropZoneProps) {
  const [dragging, setDragging] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const inputRef = useRef<HTMLInputElement>(null);

  const validateAndSelect = useCallback(
    (file: File) => {
      setError(null);

      // Check size
      if (file.size > maxSizeMB * 1024 * 1024) {
        setError(`Oups ! Ce fichier est trop volumineux (maximum ${maxSizeMB} Mo). Essayez un fichier plus léger.`);
        return;
      }

      // Check MIME type
      const acceptedTypes = accept.split(",").map((t) => t.trim());
      if (!acceptedTypes.includes(file.type)) {
        setError("Ce type de fichier n'est pas supporté. Vérifiez le format demandé.");
        return;
      }

      onFileSelected(file);
    },
    [accept, maxSizeMB, onFileSelected]
  );

  function handleDrop(e: React.DragEvent) {
    e.preventDefault();
    setDragging(false);
    const file = e.dataTransfer.files[0];
    if (file) validateAndSelect(file);
  }

  function handleDragOver(e: React.DragEvent) {
    e.preventDefault();
    setDragging(true);
  }

  function handleDragLeave(e: React.DragEvent) {
    e.preventDefault();
    setDragging(false);
  }

  function handleInputChange(e: React.ChangeEvent<HTMLInputElement>) {
    const file = e.target.files?.[0];
    if (file) validateAndSelect(file);
  }

  return (
    <div
      onDrop={handleDrop}
      onDragOver={handleDragOver}
      onDragLeave={handleDragLeave}
      onClick={() => inputRef.current?.click()}
      className={`flex cursor-pointer flex-col items-center justify-center rounded-lg border-2 border-dashed p-12 text-center transition-fast ${
        dragging
          ? "border-primary bg-primary/5"
          : "border-border hover:border-primary/50"
      }`}
    >
      <input
        ref={inputRef}
        type="file"
        accept={accept}
        onChange={handleInputChange}
        className="hidden"
      />

      <Upload className="h-12 w-12 text-muted-foreground mb-4" />
      <p className="text-lg font-medium">{label}</p>
      <p className="mt-1 text-sm text-muted-foreground">{hint}</p>
      <p className="mt-1 text-xs text-muted-foreground">
        Maximum {maxSizeMB} Mo
      </p>

      {error && <p className="mt-3 text-sm text-destructive">{error}</p>}
    </div>
  );
}
