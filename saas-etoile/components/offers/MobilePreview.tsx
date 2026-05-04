'use client';

/**
 * MobilePreview - Preview how offer appears in mobile app
 * Toggle between mobile (9:16) and desktop (16:9) formats
 */

import { useState } from 'react';
import { Smartphone, Monitor } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { MOBILE_PREVIEW, DESKTOP_PREVIEW } from '@/lib/constants/mobile-preview';

type PreviewMode = 'mobile' | 'desktop';

interface MobilePreviewProps {
  videoUrl?: string | null;
  posterUrl?: string | null;
  title: string;
  companyName: string;
  sector: string;
}

export function MobilePreview({
  videoUrl,
  posterUrl,
  title,
  companyName,
  sector,
}: MobilePreviewProps) {
  const [mode, setMode] = useState<PreviewMode>('mobile');

  const isMobile = mode === 'mobile';
  const mediaUrl = videoUrl || posterUrl;
  const isVideo = !!videoUrl;

  // Calculate container dimensions
  const containerStyle = isMobile
    ? {
        width: MOBILE_PREVIEW.WIDTH,
        height: MOBILE_PREVIEW.HEIGHT,
        aspectRatio: `${MOBILE_PREVIEW.ASPECT}`,
      }
    : {
        width: DESKTOP_PREVIEW.WIDTH,
        height: DESKTOP_PREVIEW.HEIGHT,
        aspectRatio: `${DESKTOP_PREVIEW.ASPECT}`,
      };

  return (
    <div className="space-y-4">
      {/* Toggle Buttons */}
      <div className="flex gap-2">
        <Button
          variant={isMobile ? 'default' : 'outline'}
          size="sm"
          onClick={() => setMode('mobile')}
          className="gap-2"
        >
          <Smartphone className="h-4 w-4" />
          Mobile (9:16)
        </Button>
        <Button
          variant={!isMobile ? 'default' : 'outline'}
          size="sm"
          onClick={() => setMode('desktop')}
          className="gap-2"
        >
          <Monitor className="h-4 w-4" />
          Desktop (16:9)
        </Button>
      </div>

      {/* Preview Container */}
      <div className="flex justify-center">
        <div
          className={`
            relative overflow-hidden bg-black transition-all duration-300
            ${isMobile ? 'rounded-[40px] shadow-2xl border-[12px] border-gray-800' : 'rounded-lg shadow-lg'}
          `}
          style={containerStyle}
        >
          {/* Media (Video or Poster) */}
          {mediaUrl ? (
            isVideo ? (
              <video
                src={mediaUrl}
                className="h-full w-full object-contain"
                controls
                playsInline
              />
            ) : (
              <img
                src={mediaUrl}
                alt="Preview"
                className="h-full w-full object-contain"
              />
            )
          ) : (
            <div className="flex h-full w-full items-center justify-center text-white/50">
              <div className="text-center">
                <div className="text-4xl mb-2">📹</div>
                <p className="text-sm">Aucune vidéo/affiche</p>
              </div>
            </div>
          )}

          {/* Metadata Overlay (Mobile Feed Style) */}
          {mediaUrl && (
            <div className="absolute bottom-0 left-0 right-0 bg-gradient-to-t from-black/80 via-black/40 to-transparent p-4">
              <h3 className="font-semibold text-white text-lg line-clamp-2">
                {title || 'Titre du poste'}
              </h3>
              <p className="text-white/90 text-sm mt-1">
                {companyName} • {sector || 'Secteur'}
              </p>
            </div>
          )}
        </div>
      </div>

      {/* Preview Info */}
      <div className="text-center text-sm text-muted-foreground">
        {isMobile ? (
          <>
            📱 Aperçu format mobile ({MOBILE_PREVIEW.WIDTH}x{MOBILE_PREVIEW.HEIGHT})
          </>
        ) : (
          <>
            🖥️ Aperçu format desktop ({DESKTOP_PREVIEW.WIDTH}x{DESKTOP_PREVIEW.HEIGHT})
          </>
        )}
      </div>
    </div>
  );
}
