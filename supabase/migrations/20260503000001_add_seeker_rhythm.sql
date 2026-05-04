-- Migration: Ajout du champ rythme d'alternance pour les chercheurs
-- Date: 2026-05-03
-- Description: Ajoute la colonne rhythm (VARCHAR nullable) à seeker_profiles
--              pour stocker le rythme d'alternance souhaité par le chercheur
--              (3j/2j, 1sem/1sem, 2sem/2sem, 3sem/1sem, mensuel)

ALTER TABLE seeker_profiles
ADD COLUMN IF NOT EXISTS rhythm VARCHAR;

COMMENT ON COLUMN seeker_profiles.rhythm IS 'Rythme d''alternance souhaité (3j/2j, 1sem/1sem, 2sem/2sem, 3sem/1sem, mensuel)';
