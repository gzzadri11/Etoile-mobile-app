-- Fix handle_new_user trigger to copy siret/siren/legal_form from auth metadata
-- into recruiter_profiles on registration.
-- Previously the trigger only set company_name and ignored SIRET fields.

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
DECLARE
    user_role TEXT;
    user_first_name TEXT;
    user_company_name TEXT;
    user_siret TEXT;
    user_siren TEXT;
    user_legal_form TEXT;
BEGIN
    user_role := COALESCE(NEW.raw_user_meta_data->>'role', 'seeker');
    user_first_name := COALESCE(NEW.raw_user_meta_data->>'first_name', 'Utilisateur');

    INSERT INTO public.user_roles (user_id, role)
    VALUES (NEW.id, user_role);

    IF user_role = 'seeker' THEN
        INSERT INTO public.seeker_profiles (user_id, first_name)
        VALUES (NEW.id, user_first_name);
    ELSE
        user_company_name := COALESCE(NEW.raw_user_meta_data->>'company_name', 'A completer');
        user_siret := NEW.raw_user_meta_data->>'siret';
        user_siren := NEW.raw_user_meta_data->>'siren';
        user_legal_form := NEW.raw_user_meta_data->>'legal_form';

        INSERT INTO public.recruiter_profiles (user_id, company_name, siret, siren, legal_form)
        VALUES (NEW.id, user_company_name, user_siret, user_siren, user_legal_form);
    END IF;

    RETURN NEW;
EXCEPTION WHEN OTHERS THEN
    RAISE LOG 'handle_new_user error: %', SQLERRM;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Backfill existing recruiters: copy SIRET from auth.users metadata to recruiter_profiles
UPDATE public.recruiter_profiles rp
SET
    siret = COALESCE(rp.siret, u.raw_user_meta_data->>'siret'),
    siren = COALESCE(rp.siren, u.raw_user_meta_data->>'siren'),
    legal_form = COALESCE(rp.legal_form, u.raw_user_meta_data->>'legal_form'),
    company_name = CASE
        WHEN rp.company_name = 'A completer' AND u.raw_user_meta_data->>'company_name' IS NOT NULL
        THEN u.raw_user_meta_data->>'company_name'
        ELSE rp.company_name
    END
FROM auth.users u
WHERE rp.user_id = u.id
  AND rp.siret IS NULL
  AND u.raw_user_meta_data->>'siret' IS NOT NULL;
