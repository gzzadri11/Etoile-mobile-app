/**
 * RecruiterAvatar - Reusable recruiter photo avatar component
 * Displays photo if available, otherwise shows company initials
 */

import { cn } from "@/lib/utils";

export type AvatarSize = 'sm' | 'md' | 'lg';

interface RecruiterAvatarProps {
  photoUrl: string | null;
  companyName: string;
  size?: AvatarSize;
  className?: string;
}

const SIZES = {
  sm: 'h-12 w-12 text-sm', // 48px
  md: 'h-20 w-20 text-2xl', // 80px
  lg: 'h-[200px] w-[200px] text-6xl', // 200px
} as const;

/**
 * Get company initials (max 2 letters)
 * Examples: "UDI" → "UD", "Boulangerie Paul" → "BP"
 */
function getInitials(companyName: string): string {
  if (!companyName) return '?';

  const words = companyName.trim().split(/\s+/);

  if (words.length === 1) {
    // Single word: take first 2 letters
    return companyName.slice(0, 2).toUpperCase();
  }

  // Multiple words: take first letter of first 2 words
  return words
    .slice(0, 2)
    .map(word => word[0])
    .join('')
    .toUpperCase();
}

export function RecruiterAvatar({
  photoUrl,
  companyName,
  size = 'md',
  className,
}: RecruiterAvatarProps) {
  const sizeClasses = SIZES[size];

  if (photoUrl) {
    return (
      <div className={cn('relative rounded-full overflow-hidden', sizeClasses, className)}>
        <img
          src={photoUrl}
          alt={companyName}
          className="h-full w-full object-cover"
        />
      </div>
    );
  }

  // Fallback: initials with gradient background
  const initials = getInitials(companyName);

  return (
    <div
      className={cn(
        'flex items-center justify-center rounded-full bg-gradient-to-br from-primary/90 to-secondary/90 font-semibold text-white',
        sizeClasses,
        className
      )}
    >
      {initials}
    </div>
  );
}
