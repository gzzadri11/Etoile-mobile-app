-- =============================================================================
-- TRIGGER: Creation automatique du profil utilisateur
-- Executez ce script dans: Supabase > SQL Editor > New Query
-- =============================================================================

-- Fonction qui cree le profil apres inscription
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
DECLARE
    user_role TEXT;
    user_first_name TEXT;
BEGIN
    -- Recuperer le role et le prenom depuis les metadonnees
    user_role := COALESCE(NEW.raw_user_meta_data->>'role', 'seeker');
    user_first_name := COALESCE(NEW.raw_user_meta_data->>'first_name', 'Utilisateur');

    -- 1. Creer l'entree dans user_roles
    INSERT INTO public.user_roles (user_id, role)
    VALUES (NEW.id, user_role);

    -- 2. Creer le profil selon le role
    IF user_role = 'seeker' THEN
        -- Creer un profil chercheur d'emploi
        INSERT INTO public.seeker_profiles (user_id, first_name)
        VALUES (NEW.id, user_first_name);
    ELSE
        -- Creer un profil recruteur (company_name a completer)
        INSERT INTO public.recruiter_profiles (user_id, company_name)
        VALUES (NEW.id, 'A completer');
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Supprimer le trigger s'il existe deja (pour pouvoir re-executer ce script)
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;

-- Creer le trigger qui s'execute apres chaque nouvelle inscription
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_new_user();

-- =============================================================================
-- VERIFICATION
-- =============================================================================
-- Pour verifier que le trigger est bien cree, executez:
-- SELECT * FROM pg_trigger WHERE tgname = 'on_auth_user_created';

-- =============================================================================
-- TEST (optionnel)
-- =============================================================================
-- Apres avoir execute ce script:
-- 1. Inscrivez-vous dans l'app avec un nouveau compte
-- 2. Verifiez dans Supabase > Table Editor > user_roles
-- 3. Verifiez dans seeker_profiles ou recruiter_profiles
