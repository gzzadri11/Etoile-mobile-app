import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  images: {
    remotePatterns: [
      {
        protocol: "https",
        hostname: "etoile-video-worker.gzzadri11.workers.dev",
        pathname: "/**",
      },
      {
        protocol: "https",
        hostname: "ojslqytmuifaofojutgb.supabase.co",
        pathname: "/storage/v1/object/public/**",
      },
    ],
  },
};

export default nextConfig;
