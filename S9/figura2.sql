CREATE TABLE DET_PUNTAJE_TRAYECTORIA_POSTULANTES (
    id_postulante VARCHAR2(30),
    run_postulante VARCHAR2(20),
    nombre_postulante VARCHAR2(100),
    fecha_postulacion VARCHAR2(40),
    objetivo_estudio VARCHAR2(50),
    ptje_objetivo_estudio NUMBER(5,3),
    intereses VARCHAR2(50),
    ptje_intereses NUMBER(5,3),
    retribucion VARCHAR2(50),
    ptje_retribucion NUMBER(5,3),
    institucion_extranjera VARCHAR2(100),
    puntaje_trayectoria NUMBER(5,3),
    etnia VARCHAR2(2),
    ptj_etnia NUMBER(5,3),
    discapacidad VARCHAR2(2),
    ptj_discapacidad NUMBER(5,3),
    titulo_regiones VARCHAR2(2),
    ptj_titulo_regiones NUMBER(5,3),
    beca_rep VARCHAR2(2),
    ptj_beca_rep NUMBER(5,3),
    ptj_total NUMBER(5,3),
    pond_trayectoria NUMBER(5,3),
    CONSTRAINT pk_resumen_postulante PRIMARY KEY (id_postulante)
);

SELECT
    ROWNUM AS "NRO POSTULANTE",
    SUBSTR(TO_CHAR(p.rut_numero), -3) || p.rut_dv || 
    REGEXP_REPLACE(UPPER(p.nombres), '([^A-Z]*)([A-Z])[A-Z]*', '\2') || 
    SUBSTR(LOWER(p.ap_paterno), 1, 1) || 
    SUBSTR(LOWER(p.ap_materno), 1, 1) ||  
    TO_CHAR(p.fecha_registro, 'MMYY') AS "ID POSTULANTE",
    TO_CHAR(p.rut_numero) || p.rut_dv AS "RUN POSTULANTE",
    INITCAP(p.nombres || ' ' || p.ap_paterno || ' ' || p.ap_materno) AS "NOMBRE POSTULANTE",
    TO_CHAR(p.fecha_postulacion, 'fmDay') || '.' ||
    TO_CHAR(p.fecha_postulacion, 'DD"-"fmMonth"-"YYYY', 'nls_date_language=spanish') AS "FECHA POSTULACION",
    NULL AS "INST.EDUC EXTRANJERA",
    NULL AS "PUNTAJE TRAYECTORIA",
    CASE WHEN p.etnia IS NULL THEN 'No' ELSE 'Si' END AS "ETNIA",
    CASE WHEN p.etnia IS NULL THEN '0' ELSE '0.1' END AS "PTJ ETNIA",
    CASE WHEN p.discapacidad IS NULL THEN 'No' ELSE 'Si' END AS "DISCAPACIDAD",
    CASE WHEN p.discapacidad IS NULL THEN '0' ELSE '0.1' END AS "PTJ DISCAPACIDAD",
    CASE 
        WHEN LOWER(r.nombre_region) = 'región metropolitana' THEN 'No'
        ELSE 'Si'
    END AS "TITULO REGIONES",
    CASE 
        WHEN LOWER(r.nombre_region) = 'región metropolitana' THEN '0'
        ELSE '0.1'
    END AS "PTJ TITULO REGIONES",
    CASE WHEN p.beca_reparacion IS NULL THEN 'No' ELSE 'Si' END AS "BECA REP",
    CASE WHEN p.beca_reparacion IS NULL THEN '0' ELSE '0.1' END AS "PTJ BECA REP"
FROM
    postulante p
    LEFT JOIN region r ON p.id_region_titulacion = r.id_region;
