-- Ejecutar como usuario ADMIN ORACLE
-- CREACION DE PERFIL PERSONALIZADO PARA BECAS-ANID
CREATE PROFILE perfil_seguridad_anid LIMIT
    FAILED_LOGIN_ATTEMPTS 5
    PASSWORD_LOCK_TIME 1/24 -- 1 hora de bloqueo SIN USO
    PASSWORD_LIFE_TIME 30 -- caduca cada 30 días LA CONTRASENIA
    PASSWORD_GRACE_TIME 10 -- 10 días de gracia para cambiarla LA CONTRASENIA
    PASSWORD_REUSE_TIME 365 -- no puede repetir por 1 año
    PASSWORD_REUSE_MAX 5    -- no repetir las últimas 5 CONTRASENBIA
    PASSWORD_VERIFY_FUNCTION verify_function;

-- CREACIÓN DE ROLES
CREATE ROLE Rol_AdminSuperANID;         -- Rol con mayores privilegios
CREATE ROLE Rol_VerificadorANID;        -- Verifica y actualiza ciertos campos
CREATE ROLE Rol_ComiteEvaluacionANID;   -- Inserta evaluaciones del comité
CREATE ROLE Rol_VistasANID;             -- Crea vistas para análisis
CREATE ROLE Rol_PostulanteANID;         -- Inserta y actualiza datos personales

-- CREACIÓN DE USUARIOS
CREATE USER AdminSuperANID IDENTIFIED BY "Super.Anid123"
    DEFAULT TABLESPACE DATA
    QUOTA UNLIMITED ON DATA;

CREATE USER VerificadorANID IDENTIFIED BY "Verif.Anid123"
    DEFAULT TABLESPACE DATA
    QUOTA 50M ON DATA;

CREATE USER ComiteEvaluacionANID IDENTIFIED BY "Comite.Anid123"
    DEFAULT TABLESPACE DATA
    QUOTA 10M ON DATA;

CREATE USER VistasANID IDENTIFIED BY "Vistas.Anid123"
    DEFAULT TABLESPACE DATA
    QUOTA 100M ON DATA;

CREATE USER PostulanteANID IDENTIFIED BY "Postula.Anid123"
    DEFAULT TABLESPACE DATA
    QUOTA UNLIMITED ON DATA;

-- CONCEDER PERMISO PARA CONECTARSE
GRANT CREATE SESSION TO AdminSuperANID;
GRANT CREATE SESSION TO VerificadorANID;
GRANT CREATE SESSION TO ComiteEvaluacionANID;
GRANT CREATE SESSION TO VistasANID;
GRANT CREATE SESSION TO PostulanteANID;

-- ASIGNACIÓN DE ROLES
GRANT Rol_AdminSuperANID TO AdminSuperANID;
GRANT Rol_VerificadorANID TO VerificadorANID;
GRANT Rol_ComiteEvaluacionANID TO ComiteEvaluacionANID;
GRANT Rol_VistasANID TO VistasANID;
GRANT Rol_PostulanteANID TO PostulanteANID;

-- ADMIN: Puede hacer de todo lo necesario para el proyecto ANID
GRANT RESOURCE TO Rol_AdminSuperANID; -- Incluye CREATE TABLE, INDEX, etc.
GRANT CREATE USER, DROP USER, ALTER USER TO AdminSuperANID; -- Creara los usuarios si se desea agregar otros

-- EJECUTAR DESDE EL AdminSuperANID DUENIO DE LAS TABLAS
--acceso a datos y update específicOS PARA Rol_VerificadorANID
GRANT SELECT ON postulante TO Rol_VerificadorANID;
GRANT SELECT ON documentos_presentados TO Rol_VerificadorANID;
GRANT UPDATE (nota_media_pregrado, posicion_ranking, total_egresados)
    ON postulante TO Rol_VerificadorANID;

-- acceso a vistas + insertar evaluación para rol Rol_ComiteEvaluacionANID
GRANT SELECT ON postulante TO Rol_ComiteEvaluacionANID;
GRANT INSERT ON evalua_comite TO Rol_ComiteEvaluacionANID;
GRANT UPDATE ON evalua_comite TO Rol_ComiteEvaluacionANID;

-- puede crear vistas para rol Rol_VistasANID
GRANT CREATE VIEW TO Rol_VistasANID;
GRANT SELECT ON postulante TO Rol_VistasANID;
GRANT SELECT ON postulacion TO Rol_VistasANID;
GRANT SELECT ON region TO Rol_VistasANID;
GRANT SELECT ON estado_postulacion TO Rol_VistasANID;
GRANT SELECT ON institucion_destino TO Rol_VistasANID;
GRANT SELECT ON documento TO Rol_VistasANID;

-- Puede insertar y actualizar sus propios datos
GRANT INSERT ON postulante TO Rol_PostulanteANID;
GRANT UPDATE (nombres, ap_paterno, ap_materno, fecha_nacimiento, correo, telefono, etnia, discapacidad, nacionalidad)
    ON postulante TO Rol_PostulanteANID;
GRANT INSERT ON documentos_presentados TO Rol_PostulanteANID;


--Ademas debe crear y ejecutar los scrip de creacion de la DB, Funciones, Trigger, Insert, Index 
