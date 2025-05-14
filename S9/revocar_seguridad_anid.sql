
-- ============================================
-- SCRIPT DE REVOCACIÓN Y LIMPIEZA - ANID
-- ============================================

-- 1. REVOCAR PRIVILEGIOS Y ROLES DE USUARIOS
REVOKE Rol_AdminSuperANID FROM AdminSuperANID;
REVOKE Rol_VerificadorANID FROM VerificadorANID;
REVOKE Rol_ComiteEvaluacionANID FROM ComiteEvaluacionANID;
REVOKE Rol_VistasANID FROM VistasANID;
REVOKE Rol_PostulanteANID FROM PostulanteANID;

-- 2. ELIMINAR USUARIOS (ejecutar como ADMIN)
DROP USER AdminSuperANID CASCADE;
DROP USER VerificadorANID CASCADE;
DROP USER ComiteEvaluacionANID CASCADE;
DROP USER VistasANID CASCADE;
DROP USER PostulanteANID CASCADE;

-- 3. ELIMINAR ROLES
DROP ROLE Rol_AdminSuperANID;
DROP ROLE Rol_VerificadorANID;
DROP ROLE Rol_ComiteEvaluacionANID;
DROP ROLE Rol_VistasANID;
DROP ROLE Rol_PostulanteANID;

-- 4. ELIMINAR PERFIL PERSONALIZADO (debe asegurarse que ningún usuario lo use antes)
ALTER USER AdminSuperANID PROFILE DEFAULT;
ALTER USER VerificadorANID PROFILE DEFAULT;
ALTER USER ComiteEvaluacionANID PROFILE DEFAULT;
ALTER USER VistasANID PROFILE DEFAULT;
ALTER USER PostulanteANID PROFILE DEFAULT;

DROP PROFILE perfil_seguridad_anid CASCADE;
