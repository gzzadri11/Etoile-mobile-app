-- Migration: Add RPC functions for incrementing recruiter credits
-- Used by stripe-webhook Edge Function after successful credit purchases

-- Increment video credits for a recruiter
CREATE OR REPLACE FUNCTION public.increment_video_credits(
  p_user_id UUID,
  p_amount INTEGER DEFAULT 1
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  UPDATE recruiter_profiles
  SET video_credits = video_credits + p_amount,
      updated_at = NOW()
  WHERE user_id = p_user_id;

  IF NOT FOUND THEN
    RAISE WARNING '[increment_video_credits] No recruiter_profile found for user %', p_user_id;
  END IF;
END;
$$;

-- Increment poster credits for a recruiter
CREATE OR REPLACE FUNCTION public.increment_poster_credits(
  p_user_id UUID,
  p_amount INTEGER DEFAULT 1
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  UPDATE recruiter_profiles
  SET poster_credits = poster_credits + p_amount,
      updated_at = NOW()
  WHERE user_id = p_user_id;

  IF NOT FOUND THEN
    RAISE WARNING '[increment_poster_credits] No recruiter_profile found for user %', p_user_id;
  END IF;
END;
$$;

-- Grant execute to service_role (used by Edge Functions)
GRANT EXECUTE ON FUNCTION public.increment_video_credits(UUID, INTEGER) TO service_role;
GRANT EXECUTE ON FUNCTION public.increment_poster_credits(UUID, INTEGER) TO service_role;
