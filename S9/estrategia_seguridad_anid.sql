-- ejecutar desde el admin de la DB
CREATE ROLE Rol_AdminSuperANID; --Es el super admin de la DB
CREATE ROLE Rol_VerificadorANID; --Puede hacer selcet de (documentos_presentados y postulante) ademas actualiza algunos campos necesarios para evaluar en tabla postulante
CREATE ROLE Rol_ComiteEvaluacionANID; --Este rol accede a vistas postulante y hace insert o update en comite_evaluacion
CREATE ROLE Rol_VistasANID; --Especialista en crear vistas para ver resultados o analisis de los postulantes
CREATE ROLE Rol_PostulanteANID; --Puede insert y update en tabla postulantes(no todos los campos) y tabla documentos_presentados


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

-- GRANT CREATE SESSION PARA TODOS

GRANT CREATE SESSION TO Rol_AdminSuperANID;
GRANT CREATE SESSION TO Rol_VerificadorANID;
GRANT CREATE SESSION TO Rol_ComiteEvaluacionANID;
GRANT CREATE SESSION TO Rol_VistasANID;
GRANT CREATE SESSION TO Rol_PostulanteANID;

-- ASIGNACIÓN DE ROLES A LOS USUARIOS
GRANT Rol_AdminSuperANID TO AdminSuperANID; --Creara, las tablas indices, poblado de datos, funciones, triggers,dara permisos de sus tablas
GRANT Rol_VerificadorANID TO VerificadorANID; -- podra ver a cada postulante y sus documentos presentados adeas podra actualizar algunos campos del postulante
GRANT Rol_ComiteEvaluacionANID TO ComiteEvaluacionANID; -- Podra ver vistas e insertar o actualizar la tabla evalua_comite
GRANT Rol_VistasANID TO VistasANID; --Se encargara de crear todas las vistas requeridas
GRANT Rol_PostulanteANID TO PostulanteANID; -- Podra insertar y actualizar algunos campos de las tablas postulante  y documentos_presentados

-- PERMISOS ADMIN
GRANT RESOURCE TO Rol_AdminSuperANID; --CREATE TABLE, CREATE SEQUENCE, CREATE PROCEDURE, CREATE TRIGGER, CREATE TYPE, CREATE OPERATOR
GRANT CREATE USER, DROP USER, ALTER USER, CREATE ROLE TO AdminSuperANID;
GRANT Rol_AdminSuperANID TO AdminSuperANID;

--Ejecutar desde AdminSuperANID

