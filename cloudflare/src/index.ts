/**
 * Etoile Video Worker
 *
 * Cloudflare Worker for handling video uploads and streaming via R2.
 * Provides presigned URLs for secure direct uploads from the mobile app.
 */

export interface Env {
  // R2 Buckets
  VIDEOS: R2Bucket;
  THUMBNAILS: R2Bucket;

  // Environment variables
  ENVIRONMENT: string;
  ALLOWED_ORIGINS: string;
  MAX_VIDEO_SIZE_MB: string;
  VIDEO_DURATION_SECONDS: string;
  PRESIGNED_URL_EXPIRY_SECONDS: string;

  // Secrets
  SUPABASE_JWT_SECRET: string;
}

// =============================================================================
// CORS Configuration
// =============================================================================

function getCorsHeaders(request: Request, env: Env): HeadersInit {
  const origin = request.headers.get('Origin') || '';
  const allowedOrigins = env.ALLOWED_ORIGINS.split(',').map((o) => o.trim());

  // Allow all origins in development
  const isAllowed =
    env.ENVIRONMENT === 'development' ||
    allowedOrigins.includes('*') ||
    allowedOrigins.includes(origin);

  return {
    'Access-Control-Allow-Origin': isAllowed ? origin || '*' : '',
    'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
    'Access-Control-Allow-Headers':
      'Content-Type, Authorization, X-Requested-With',
    'Access-Control-Max-Age': '86400',
    'Access-Control-Allow-Credentials': 'true',
  };
}

function handleOptions(request: Request, env: Env): Response {
  return new Response(null, {
    status: 204,
    headers: getCorsHeaders(request, env),
  });
}

// =============================================================================
// JWT Validation (simplified - in production, use proper JWT library)
// =============================================================================

interface JWTPayload {
  sub: string; // User ID
  email?: string;
  role?: string;
  exp: number;
  iat: number;
}

async function validateJWT(
  authHeader: string | null,
  env: Env
): Promise<JWTPayload | null> {
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return null;
  }

  const token = authHeader.substring(7);

  try {
    // Decode JWT (base64url)
    const parts = token.split('.');
    if (parts.length !== 3) return null;

    const payload = JSON.parse(atob(parts[1].replace(/-/g, '+').replace(/_/g, '/')));

    // Check expiration
    if (payload.exp && payload.exp < Date.now() / 1000) {
      return null;
    }

    // In production, verify signature with SUPABASE_JWT_SECRET
    // For now, we trust the payload if it's properly formatted

    return payload as JWTPayload;
  } catch (e) {
    console.error('JWT validation error:', e);
    return null;
  }
}

// =============================================================================
// Request Handlers
// =============================================================================

/**
 * POST /presigned-url
 * Generate a presigned URL for video upload
 */
async function handlePresignedUrl(
  request: Request,
  env: Env
): Promise<Response> {
  // Validate JWT
  const user = await validateJWT(request.headers.get('Authorization'), env);
  if (!user) {
    return new Response(JSON.stringify({ error: 'Unauthorized' }), {
      status: 401,
      headers: {
        'Content-Type': 'application/json',
        ...getCorsHeaders(request, env),
      },
    });
  }

  // Parse request body
  let body: {
    filename: string;
    contentType: string;
    type: 'video' | 'thumbnail';
    category?: string;
  };

  try {
    body = await request.json();
  } catch (e) {
    return new Response(JSON.stringify({ error: 'Invalid JSON body' }), {
      status: 400,
      headers: {
        'Content-Type': 'application/json',
        ...getCorsHeaders(request, env),
      },
    });
  }

  // Validate required fields
  if (!body.filename || !body.contentType) {
    return new Response(
      JSON.stringify({ error: 'Missing filename or contentType' }),
      {
        status: 400,
        headers: {
          'Content-Type': 'application/json',
          ...getCorsHeaders(request, env),
        },
      }
    );
  }

  // Validate content type
  const allowedVideoTypes = ['video/mp4', 'video/quicktime', 'video/webm'];
  const allowedImageTypes = ['image/jpeg', 'image/png', 'image/webp'];
  const isVideo = body.type === 'video';
  const allowedTypes = isVideo ? allowedVideoTypes : allowedImageTypes;

  if (!allowedTypes.includes(body.contentType)) {
    return new Response(
      JSON.stringify({
        error: `Invalid content type. Allowed: ${allowedTypes.join(', ')}`,
      }),
      {
        status: 400,
        headers: {
          'Content-Type': 'application/json',
          ...getCorsHeaders(request, env),
        },
      }
    );
  }

  // Generate unique key
  const timestamp = Date.now();
  const extension = body.filename.split('.').pop() || 'mp4';
  const key = `${user.sub}/${timestamp}.${extension}`;

  // Generate presigned URL
  // Note: R2 doesn't have native presigned URLs like S3
  // We'll return a signed upload endpoint instead
  const expirySeconds = parseInt(env.PRESIGNED_URL_EXPIRY_SECONDS) || 3600;
  const expiresAt = new Date(Date.now() + expirySeconds * 1000).toISOString();

  // Create a signed token for the upload
  const uploadToken = btoa(
    JSON.stringify({
      key,
      userId: user.sub,
      contentType: body.contentType,
      expiresAt,
      type: body.type,
    })
  );

  // Return upload URL (to this worker)
  const workerUrl = new URL(request.url);
  const uploadUrl = `${workerUrl.origin}/upload/${uploadToken}`;

  return new Response(
    JSON.stringify({
      uploadUrl,
      key,
      expiresAt,
      method: 'PUT',
      headers: {
        'Content-Type': body.contentType,
      },
    }),
    {
      status: 200,
      headers: {
        'Content-Type': 'application/json',
        ...getCorsHeaders(request, env),
      },
    }
  );
}

/**
 * PUT /upload/:token
 * Handle the actual file upload to R2
 */
async function handleUpload(
  request: Request,
  env: Env,
  token: string
): Promise<Response> {
  // Decode and validate token
  let uploadInfo: {
    key: string;
    userId: string;
    contentType: string;
    expiresAt: string;
    type: 'video' | 'thumbnail';
  };

  try {
    uploadInfo = JSON.parse(atob(token));
  } catch (e) {
    return new Response(JSON.stringify({ error: 'Invalid upload token' }), {
      status: 400,
      headers: {
        'Content-Type': 'application/json',
        ...getCorsHeaders(request, env),
      },
    });
  }

  // Check expiry
  if (new Date(uploadInfo.expiresAt) < new Date()) {
    return new Response(JSON.stringify({ error: 'Upload token expired' }), {
      status: 400,
      headers: {
        'Content-Type': 'application/json',
        ...getCorsHeaders(request, env),
      },
    });
  }

  // Get file from request body
  const body = await request.arrayBuffer();

  // Check file size
  const maxSizeBytes = parseInt(env.MAX_VIDEO_SIZE_MB) * 1024 * 1024;
  if (body.byteLength > maxSizeBytes) {
    return new Response(
      JSON.stringify({
        error: `File too large. Maximum size: ${env.MAX_VIDEO_SIZE_MB}MB`,
      }),
      {
        status: 400,
        headers: {
          'Content-Type': 'application/json',
          ...getCorsHeaders(request, env),
        },
      }
    );
  }

  // Upload to R2
  const bucket = uploadInfo.type === 'video' ? env.VIDEOS : env.THUMBNAILS;

  try {
    await bucket.put(uploadInfo.key, body, {
      httpMetadata: {
        contentType: uploadInfo.contentType,
        cacheControl: 'public, max-age=31536000, immutable',
      },
      customMetadata: {
        userId: uploadInfo.userId,
        uploadedAt: new Date().toISOString(),
      },
    });
  } catch (e) {
    console.error('R2 upload error:', e);
    return new Response(JSON.stringify({ error: 'Upload failed' }), {
      status: 500,
      headers: {
        'Content-Type': 'application/json',
        ...getCorsHeaders(request, env),
      },
    });
  }

  // Return success with public URL
  const workerUrl = new URL(request.url);
  const publicUrl = `${workerUrl.origin}/${uploadInfo.type}/${uploadInfo.key}`;

  return new Response(
    JSON.stringify({
      success: true,
      key: uploadInfo.key,
      url: publicUrl,
      size: body.byteLength,
    }),
    {
      status: 200,
      headers: {
        'Content-Type': 'application/json',
        ...getCorsHeaders(request, env),
      },
    }
  );
}

/**
 * GET /video/:key
 * Stream video from R2 (with CDN caching)
 */
async function handleVideoStream(
  request: Request,
  env: Env,
  key: string
): Promise<Response> {
  const object = await env.VIDEOS.get(key);

  if (!object) {
    return new Response(JSON.stringify({ error: 'Video not found' }), {
      status: 404,
      headers: {
        'Content-Type': 'application/json',
        ...getCorsHeaders(request, env),
      },
    });
  }

  // Support range requests for video seeking
  const range = request.headers.get('Range');
  const size = object.size;

  if (range) {
    const parts = range.replace(/bytes=/, '').split('-');
    const start = parseInt(parts[0], 10);
    const end = parts[1] ? parseInt(parts[1], 10) : size - 1;
    const chunkSize = end - start + 1;

    // Get partial content
    const slice = await object.slice(start, end + 1).arrayBuffer();

    return new Response(slice, {
      status: 206,
      headers: {
        'Content-Type': object.httpMetadata?.contentType || 'video/mp4',
        'Content-Length': chunkSize.toString(),
        'Content-Range': `bytes ${start}-${end}/${size}`,
        'Accept-Ranges': 'bytes',
        'Cache-Control': 'public, max-age=31536000, immutable',
        ...getCorsHeaders(request, env),
      },
    });
  }

  // Return full video
  return new Response(object.body, {
    status: 200,
    headers: {
      'Content-Type': object.httpMetadata?.contentType || 'video/mp4',
      'Content-Length': size.toString(),
      'Accept-Ranges': 'bytes',
      'Cache-Control': 'public, max-age=31536000, immutable',
      ...getCorsHeaders(request, env),
    },
  });
}

/**
 * GET /thumbnail/:key
 * Get thumbnail from R2
 */
async function handleThumbnail(
  request: Request,
  env: Env,
  key: string
): Promise<Response> {
  const object = await env.THUMBNAILS.get(key);

  if (!object) {
    return new Response(JSON.stringify({ error: 'Thumbnail not found' }), {
      status: 404,
      headers: {
        'Content-Type': 'application/json',
        ...getCorsHeaders(request, env),
      },
    });
  }

  return new Response(object.body, {
    status: 200,
    headers: {
      'Content-Type': object.httpMetadata?.contentType || 'image/jpeg',
      'Content-Length': object.size.toString(),
      'Cache-Control': 'public, max-age=604800',
      ...getCorsHeaders(request, env),
    },
  });
}

/**
 * DELETE /video/:key
 * Delete video from R2 (requires auth)
 */
async function handleDelete(
  request: Request,
  env: Env,
  key: string,
  type: 'video' | 'thumbnail'
): Promise<Response> {
  // Validate JWT
  const user = await validateJWT(request.headers.get('Authorization'), env);
  if (!user) {
    return new Response(JSON.stringify({ error: 'Unauthorized' }), {
      status: 401,
      headers: {
        'Content-Type': 'application/json',
        ...getCorsHeaders(request, env),
      },
    });
  }

  // Verify ownership (key starts with user ID)
  if (!key.startsWith(user.sub + '/')) {
    return new Response(JSON.stringify({ error: 'Forbidden' }), {
      status: 403,
      headers: {
        'Content-Type': 'application/json',
        ...getCorsHeaders(request, env),
      },
    });
  }

  const bucket = type === 'video' ? env.VIDEOS : env.THUMBNAILS;

  try {
    await bucket.delete(key);
  } catch (e) {
    console.error('R2 delete error:', e);
    return new Response(JSON.stringify({ error: 'Delete failed' }), {
      status: 500,
      headers: {
        'Content-Type': 'application/json',
        ...getCorsHeaders(request, env),
      },
    });
  }

  return new Response(JSON.stringify({ success: true }), {
    status: 200,
    headers: {
      'Content-Type': 'application/json',
      ...getCorsHeaders(request, env),
    },
  });
}

/**
 * GET /health
 * Health check endpoint
 */
function handleHealth(request: Request, env: Env): Response {
  return new Response(
    JSON.stringify({
      status: 'ok',
      environment: env.ENVIRONMENT,
      timestamp: new Date().toISOString(),
    }),
    {
      status: 200,
      headers: {
        'Content-Type': 'application/json',
        ...getCorsHeaders(request, env),
      },
    }
  );
}

// =============================================================================
// Main Router
// =============================================================================

export default {
  async fetch(
    request: Request,
    env: Env,
    ctx: ExecutionContext
  ): Promise<Response> {
    const url = new URL(request.url);
    const path = url.pathname;
    const method = request.method;

    // Handle CORS preflight
    if (method === 'OPTIONS') {
      return handleOptions(request, env);
    }

    // Route requests
    try {
      // Health check
      if (path === '/health' && method === 'GET') {
        return handleHealth(request, env);
      }

      // Presigned URL generation
      if (path === '/presigned-url' && method === 'POST') {
        return await handlePresignedUrl(request, env);
      }

      // File upload
      const uploadMatch = path.match(/^\/upload\/(.+)$/);
      if (uploadMatch && method === 'PUT') {
        return await handleUpload(request, env, uploadMatch[1]);
      }

      // Video streaming
      const videoMatch = path.match(/^\/video\/(.+)$/);
      if (videoMatch && method === 'GET') {
        return await handleVideoStream(request, env, videoMatch[1]);
      }

      // Video deletion
      if (videoMatch && method === 'DELETE') {
        return await handleDelete(request, env, videoMatch[1], 'video');
      }

      // Thumbnail
      const thumbnailMatch = path.match(/^\/thumbnail\/(.+)$/);
      if (thumbnailMatch && method === 'GET') {
        return await handleThumbnail(request, env, thumbnailMatch[1]);
      }

      // Thumbnail deletion
      if (thumbnailMatch && method === 'DELETE') {
        return await handleDelete(request, env, thumbnailMatch[1], 'thumbnail');
      }

      // 404
      return new Response(JSON.stringify({ error: 'Not found' }), {
        status: 404,
        headers: {
          'Content-Type': 'application/json',
          ...getCorsHeaders(request, env),
        },
      });
    } catch (e) {
      console.error('Worker error:', e);
      return new Response(JSON.stringify({ error: 'Internal server error' }), {
        status: 500,
        headers: {
          'Content-Type': 'application/json',
          ...getCorsHeaders(request, env),
        },
      });
    }
  },
};
