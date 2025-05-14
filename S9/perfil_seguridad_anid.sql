
-- ============================================
-- PERFIL DE SEGURIDAD PERSONALIZADO - ANID
-- ============================================

-- 1. CREACIÓN DEL PERFIL
CREATE PROFILE perfil_seguridad_anid LIMIT
    FAILED_LOGIN_ATTEMPTS 5
    PASSWORD_LOCK_TIME 1/24 -- 1 hora de bloqueo
    PASSWORD_LIFE_TIME 180 -- caduca cada 180 días
    PASSWORD_GRACE_TIME 10 -- 10 días de gracia para cambiarla
    PASSWORD_REUSE_TIME 365 -- no puede repetir por 1 año
    PASSWORD_REUSE_MAX 5    -- no repetir las últimas 5
    PASSWORD_VERIFY_FUNCTION verify_function;

-- 2. ASIGNACIÓN DEL PERFIL A LOS USUARIOS
ALTER USER AdminSuperANID PROFILE perfil_seguridad_anid;
ALTER USER VerificadorANID PROFILE perfil_seguridad_anid;
ALTER USER ComiteEvaluacionANID PROFILE perfil_seguridad_anid;
ALTER USER VistasANID PROFILE perfil_seguridad_anid;
ALTER USER PostulanteANID PROFILE perfil_seguridad_anid;
