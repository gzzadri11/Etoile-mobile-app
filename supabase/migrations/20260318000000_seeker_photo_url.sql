-- Sprint 24: Add photo_url column to seeker_profiles
ALTER TABLE seeker_profiles ADD COLUMN IF NOT EXISTS photo_url VARCHAR(500);

-- Create storage bucket for seeker photos (public, max 5MB, images only)
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'seeker-photos',
  'seeker-photos',
  true,
  5242880,
  ARRAY['image/jpeg', 'image/png', 'image/webp']
)
ON CONFLICT (id) DO NOTHING;

-- RLS: allow authenticated users to upload to their own folder
CREATE POLICY "Users can upload their own photo"
  ON storage.objects FOR INSERT
  TO authenticated
  WITH CHECK (
    bucket_id = 'seeker-photos'
    AND (storage.foldername(name))[1] = auth.uid()::text
  );

-- RLS: allow authenticated users to update (upsert) their own photo
CREATE POLICY "Users can update their own photo"
  ON storage.objects FOR UPDATE
  TO authenticated
  USING (
    bucket_id = 'seeker-photos'
    AND (storage.foldername(name))[1] = auth.uid()::text
  );

-- RLS: public read access for seeker photos
CREATE POLICY "Public read access for seeker photos"
  ON storage.objects FOR SELECT
  TO public
  USING (bucket_id = 'seeker-photos');
