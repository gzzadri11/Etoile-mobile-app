/**
 * Generalized file upload to Cloudflare R2 via Worker
 * Supports 3 buckets: etoile-videos, etoile-photos, verification-docs
 */

export interface UploadResult {
  key: string;
  url: string;
  size: number;
}

export type Bucket = 'etoile-videos' | 'etoile-photos' | 'verification-docs';

/**
 * Upload a file to Cloudflare R2 bucket
 * @param file - File to upload
 * @param bucket - Target R2 bucket
 * @param userId - User ID for file organization
 * @param onProgress - Optional progress callback (0-100)
 * @returns Upload result with key, url, and size
 */
export async function uploadFile(
  file: File,
  bucket: Bucket,
  userId: string,
  onProgress?: (percent: number) => void
): Promise<UploadResult> {
  // Validation
  const MAX_SIZE_MB = bucket === 'etoile-videos' ? 50 : 5;
  const maxBytes = MAX_SIZE_MB * 1024 * 1024;

  if (file.size > maxBytes) {
    throw new Error(`File too large. Maximum size: ${MAX_SIZE_MB}MB`);
  }

  // Validate file type
  const allowedVideoTypes = ['video/mp4', 'video/quicktime', 'video/webm'];
  const allowedImageTypes = ['image/jpeg', 'image/png', 'image/webp'];
  const allowedDocTypes = ['application/pdf', 'image/jpeg', 'image/png'];

  let allowedTypes: string[];
  if (bucket === 'etoile-videos') {
    allowedTypes = allowedVideoTypes;
  } else if (bucket === 'verification-docs') {
    allowedTypes = allowedDocTypes;
  } else {
    allowedTypes = allowedImageTypes;
  }

  if (!allowedTypes.includes(file.type)) {
    throw new Error(`Invalid file type. Allowed: ${allowedTypes.join(', ')}`);
  }

  // Map bucket to Worker type
  // Note: Worker currently supports 'video' | 'thumbnail'
  // photos and docs use 'thumbnail' bucket temporarily
  const workerType = bucket === 'etoile-videos' ? 'video' : 'thumbnail';

  // Step 1: Get presigned URL from API route
  const presignedResponse = await fetch('/api/upload/presigned-url', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      filename: file.name,
      contentType: file.type,
      type: workerType,
    }),
  });

  if (!presignedResponse.ok) {
    const err = await presignedResponse.json();
    throw new Error(err.error || 'Failed to get upload URL');
  }

  const { uploadUrl, key } = await presignedResponse.json();

  // Step 2: PUT file to Worker
  const uploadResult = await new Promise<UploadResult>((resolve, reject) => {
    const xhr = new XMLHttpRequest();

    xhr.upload.onprogress = (event) => {
      if (event.lengthComputable && onProgress) {
        onProgress(Math.round((event.loaded / event.total) * 100));
      }
    };

    xhr.onload = () => {
      if (xhr.status >= 200 && xhr.status < 300) {
        try {
          const data = JSON.parse(xhr.responseText);
          resolve({ key: data.key, url: data.url, size: data.size });
        } catch {
          reject(new Error('Invalid response from upload'));
        }
      } else {
        reject(new Error(`Upload failed: ${xhr.status}`));
      }
    };

    xhr.onerror = () => reject(new Error('Network error during upload'));

    xhr.open('PUT', uploadUrl);
    xhr.setRequestHeader('Content-Type', file.type);
    xhr.send(file);
  });

  return uploadResult;
}
