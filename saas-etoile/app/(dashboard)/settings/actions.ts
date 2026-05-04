'use server';

/**
 * Server Actions for Settings page
 * Handles recruiter profile updates with RLS security
 */

import { createClient } from '@/lib/supabase/server';
import { recruiterSettingsSchema, type RecruiterSettingsFormData } from '@/lib/validations/recruiter-settings';

export interface ActionResult {
  success: boolean;
  error?: string;
}

/**
 * Update recruiter photo URL
 * RLS Policy ensures only the owner can update their profile
 */
export async function updateRecruiterPhoto(
  photoUrl: string
): Promise<ActionResult> {
  try {
    const supabase = await createClient();

    // Get current user
    const {
      data: { user },
    } = await supabase.auth.getUser();

    if (!user) {
      return { success: false, error: 'Not authenticated' };
    }

    // Update photo_url (RLS policy will enforce user_id = auth.uid())
    const { error } = await supabase
      .from('recruiter_profiles')
      .update({ photo_url: photoUrl })
      .eq('user_id', user.id);

    if (error) {
      console.error('updateRecruiterPhoto error:', error);
      return { success: false, error: error.message };
    }

    return { success: true };
  } catch (err) {
    console.error('updateRecruiterPhoto exception:', err);
    return {
      success: false,
      error: err instanceof Error ? err.message : 'Unknown error',
    };
  }
}

/**
 * Update recruiter profile (all editable fields)
 * RLS Policy ensures only the owner can update their profile
 * SIRET is intentionally NOT updated (security — fraud prevention)
 */
export async function updateRecruiterProfile(
  data: RecruiterSettingsFormData
): Promise<ActionResult> {
  try {
    // Server-side validation with Zod
    const validated = recruiterSettingsSchema.parse(data);

    const supabase = await createClient();

    // Get current user
    const {
      data: { user },
    } = await supabase.auth.getUser();

    if (!user) {
      return { success: false, error: 'Non authentifié' };
    }

    // Update profile (RLS policy will enforce user_id = auth.uid())
    // Note: SIRET is intentionally excluded for security (no update allowed)
    const { error } = await supabase
      .from('recruiter_profiles')
      .update({
        photo_url: validated.photo_url,
        company_name: validated.company_name,
        sector: validated.sector,
        description: validated.description,
        address: validated.address,
        document_url: validated.document_url,
      })
      .eq('user_id', user.id);

    if (error) {
      console.error('updateRecruiterProfile error:', error);
      return { success: false, error: error.message };
    }

    return { success: true };
  } catch (err) {
    console.error('updateRecruiterProfile exception:', err);

    // Zod validation errors
    if (err && typeof err === 'object' && 'issues' in err) {
      const zodError = err as { issues: Array<{ message: string }> };
      const firstError = zodError.issues[0]?.message || 'Validation échouée';
      return { success: false, error: firstError };
    }

    return {
      success: false,
      error: err instanceof Error ? err.message : 'Erreur inconnue',
    };
  }
}
