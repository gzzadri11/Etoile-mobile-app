export interface UploadResult {
  key: string;
  url: string;
  size: number;
}

export async function uploadFile(
  file: File,
  type: "video" | "thumbnail",
  onProgress?: (percent: number) => void
): Promise<UploadResult> {
  // Step 1: Get presigned URL from our API route (same-origin, no CORS)
  const presignedResponse = await fetch("/api/upload/presigned-url", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      filename: file.name,
      contentType: file.type,
      type,
    }),
  });

  if (!presignedResponse.ok) {
    const err = await presignedResponse.json();
    throw new Error(err.error || "Failed to get upload URL");
  }

  const { uploadUrl, key } = await presignedResponse.json();

  // Step 2: PUT file to Worker (cross-origin, Worker handles CORS)
  // Use XMLHttpRequest for progress tracking (fetch doesn't support upload.onprogress)
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
          reject(new Error("Invalid response from upload"));
        }
      } else {
        reject(new Error(`Upload failed: ${xhr.status}`));
      }
    };

    xhr.onerror = () => reject(new Error("Network error during upload"));

    xhr.open("PUT", uploadUrl);
    xhr.setRequestHeader("Content-Type", file.type);
    xhr.send(file);
  });

  return uploadResult;
}
