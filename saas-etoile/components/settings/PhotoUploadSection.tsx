'use client';

/**
 * PhotoUploadSection - Photo profile upload with interactive crop
 * Allows recruiters to upload and crop their profile photo
 */

import { useState, useCallback, useRef } from 'react';
import Cropper, { Area } from 'react-easy-crop';
import { RecruiterAvatar } from './RecruiterAvatar';
import { Button } from '@/components/ui/button';
import { uploadFile } from '@/lib/uploadFile';
import { updateRecruiterPhoto } from '@/app/(dashboard)/settings/actions';

interface PhotoUploadSectionProps {
  currentPhotoUrl: string | null;
  companyName: string;
  userId: string;
  onPhotoUpdated: (newPhotoUrl: string) => void;
}

/**
 * Create cropped image blob from original image + crop area
 */
async function getCroppedImg(
  imageSrc: string,
  pixelCrop: Area
): Promise<Blob> {
  const image = await createImage(imageSrc);
  const canvas = document.createElement('canvas');
  const ctx = canvas.getContext('2d');

  if (!ctx) {
    throw new Error('No 2D context');
  }

  // Set canvas size to crop size
  canvas.width = pixelCrop.width;
  canvas.height = pixelCrop.height;

  // Draw cropped image
  ctx.drawImage(
    image,
    pixelCrop.x,
    pixelCrop.y,
    pixelCrop.width,
    pixelCrop.height,
    0,
    0,
    pixelCrop.width,
    pixelCrop.height
  );

  // Convert to blob
  return new Promise((resolve, reject) => {
    canvas.toBlob((blob) => {
      if (blob) {
        resolve(blob);
      } else {
        reject(new Error('Canvas is empty'));
      }
    }, 'image/jpeg', 0.95);
  });
}

/**
 * Create HTML image element from data URL
 */
function createImage(url: string): Promise<HTMLImageElement> {
  return new Promise((resolve, reject) => {
    const image = new Image();
    image.addEventListener('load', () => resolve(image));
    image.addEventListener('error', (error) => reject(error));
    image.src = url;
  });
}

export function PhotoUploadSection({
  currentPhotoUrl,
  companyName,
  userId,
  onPhotoUpdated,
}: PhotoUploadSectionProps) {
  const [selectedImage, setSelectedImage] = useState<string | null>(null);
  const [crop, setCrop] = useState({ x: 0, y: 0 });
  const [zoom, setZoom] = useState(1);
  const [croppedAreaPixels, setCroppedAreaPixels] = useState<Area | null>(null);
  const [isUploading, setIsUploading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [success, setSuccess] = useState(false);

  const fileInputRef = useRef<HTMLInputElement>(null);

  const onCropComplete = useCallback((_: Area, croppedAreaPixels: Area) => {
    setCroppedAreaPixels(croppedAreaPixels);
  }, []);

  const handleFileSelect = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (!file) return;

    // Validate file type
    if (!['image/jpeg', 'image/png'].includes(file.type)) {
      setError('Format invalide. Utilisez JPG ou PNG.');
      return;
    }

    // Validate file size (5MB max)
    if (file.size > 5 * 1024 * 1024) {
      setError('Fichier trop volumineux. Maximum 5MB.');
      return;
    }

    // Read file as data URL for preview
    const reader = new FileReader();
    reader.onload = () => {
      setSelectedImage(reader.result as string);
      setError(null);
      setSuccess(false);
    };
    reader.readAsDataURL(file);
  };

  const handleSave = async () => {
    if (!selectedImage || !croppedAreaPixels) return;

    setIsUploading(true);
    setError(null);

    try {
      // Generate cropped image blob
      const croppedBlob = await getCroppedImg(selectedImage, croppedAreaPixels);

      // Validate min size (200x200px)
      if (
        croppedAreaPixels.width < 200 ||
        croppedAreaPixels.height < 200
      ) {
        throw new Error('Image trop petite. Minimum 200x200px.');
      }

      // Convert blob to File
      const file = new File([croppedBlob], `photo-${userId}.jpg`, {
        type: 'image/jpeg',
      });

      // Upload to R2
      const result = await uploadFile(file, 'etoile-photos', userId);

      // Update DB via Server Action
      const updateResult = await updateRecruiterPhoto(result.url);

      if (!updateResult.success) {
        throw new Error(updateResult.error || 'Erreur lors de la mise à jour du profil');
      }

      // Notify parent component
      onPhotoUpdated(result.url);

      setSuccess(true);
      setSelectedImage(null);

      // Reset file input
      if (fileInputRef.current) {
        fileInputRef.current.value = '';
      }
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Erreur lors de l\'upload');
    } finally {
      setIsUploading(false);
    }
  };

  const handleCancel = () => {
    setSelectedImage(null);
    setError(null);
    setSuccess(false);
    if (fileInputRef.current) {
      fileInputRef.current.value = '';
    }
  };

  return (
    <div className="space-y-4">
      <div className="flex items-center gap-6">
        <RecruiterAvatar
          photoUrl={currentPhotoUrl}
          companyName={companyName}
          size="lg"
        />
        <div className="flex flex-col gap-2">
          <Button
            type="button"
            variant="outline"
            onClick={() => fileInputRef.current?.click()}
            disabled={isUploading}
          >
            {currentPhotoUrl ? 'Modifier la photo' : 'Ajouter une photo'}
          </Button>
          <p className="text-sm text-muted-foreground">
            JPG ou PNG, max 5MB
          </p>
        </div>
      </div>

      <input
        ref={fileInputRef}
        type="file"
        accept="image/jpeg,image/png"
        onChange={handleFileSelect}
        className="hidden"
      />

      {selectedImage && (
        <div className="space-y-4 rounded-lg border p-4">
          <h3 className="font-medium">Recadrer votre photo</h3>

          <div className="relative h-[400px] w-full bg-muted">
            <Cropper
              image={selectedImage}
              crop={crop}
              zoom={zoom}
              aspect={1}
              onCropChange={setCrop}
              onZoomChange={setZoom}
              onCropComplete={onCropComplete}
            />
          </div>

          <div className="space-y-2">
            <label className="text-sm font-medium">Zoom</label>
            <input
              type="range"
              min={1}
              max={3}
              step={0.1}
              value={zoom}
              onChange={(e) => setZoom(Number(e.target.value))}
              className="w-full"
            />
          </div>

          <div className="flex gap-2">
            <Button
              onClick={handleSave}
              disabled={isUploading}
            >
              {isUploading ? 'Upload en cours...' : 'Enregistrer'}
            </Button>
            <Button
              variant="outline"
              onClick={handleCancel}
              disabled={isUploading}
            >
              Annuler
            </Button>
          </div>
        </div>
      )}

      {error && (
        <div className="rounded-lg bg-destructive/10 p-3 text-sm text-destructive">
          {error}
        </div>
      )}

      {success && (
        <div className="rounded-lg bg-green-500/10 p-3 text-sm text-green-600">
          Photo mise à jour avec succès !
        </div>
      )}
    </div>
  );
}
