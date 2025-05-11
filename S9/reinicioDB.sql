SELECT
   ROWNUM AS "NRO POSTULANTE",
    SUBSTR(TO_CHAR(p.rut_numero), -3) || p.rut_dv || 
    REGEXP_REPLACE(UPPER(p.nombres), '([^A-Z]*)([A-Z])[A-Z]*', '\2') || 
    SUBSTR(LOWER(p.ap_paterno), 1, 1) || 
    SUBSTR(LOWER(p.ap_materno), 1, 1) ||  
    TO_CHAR(p.fecha_registro, 'MMYY') AS "ID POSTULANTE",
    TO_CHAR(p.rut_numero, 'FM999G999G999', 'NLS_NUMERIC_CHARACTERS='',.''') || '-' || p.rut_dv AS "RUN POSTULANTE",
    INITCAP(p.nombres || ' ' || p.ap_paterno || ' ' || p.ap_materno) AS "NOMBRE POSTULANTE",
    TO_CHAR(po.fecha_postulacion, 'fmDay') || '.' ||
    TO_CHAR(po.fecha_postulacion, 'DD"-"fmMonth"-"YYYY', 'nls_date_language=spanish') AS "FECHA POSTULACION",
    po1.descripcion AS "OBJETIVO ESTUDIO",
    CAST(ec.objetivo AS NUMBER(5,3)) AS "PTJE OBJETIVO ESTUDIO",
    po2.descripcion AS "INTERESES",
    CAST(ec.intereses AS NUMBER(5,3)) AS "PTJE INTERESES",
    po3.descripcion AS "RETRIBUCION",
    CAST(ec.retribucion AS NUMBER(5,3)) AS "PTJE RETRIBUCION",
    ind.ranking_ocde AS "INST.EDUC EXTRANJERA",
    ind.puntaje_ocde AS "PUNTAJE TRAYECTORIA",
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
    CASE WHEN p.beca_reparacion IS NULL THEN CAST(0 AS NUMBER(5,3)) ELSE CAST(0.1 AS NUMBER(5,3)) END AS "PTJ BECA REP",
    LPAD(TO_CHAR(CAST(
        NVL(CASE WHEN p.etnia IS NULL THEN 0 ELSE 0.1 END, 0) +
        NVL(CASE WHEN p.discapacidad IS NULL THEN 0 ELSE 0.1 END, 0) +
        NVL(CASE WHEN LOWER(r.nombre_region) = 'región metropolitana' THEN 0 ELSE 0.1 END, 0) +
        NVL(CASE WHEN p.beca_reparacion IS NULL THEN 0 ELSE 0.1 END, 0) +
        NVL(ec.objetivo, 0) +
        NVL(ec.intereses, 0) +
        NVL(ec.retribucion, 0)
    AS NUMBER(5,3)),'FM999990.000'), 10) AS "PTJE TOTAL",
    LPAD(TO_CHAR(CAST(
        NVL(ec.actividades, 0) * 0.05 +
        NVL(ec.experiencia, 0) * 0.05 +
        NVL(ec.recomendacion, 0) * 0.05 +
        NVL(ec.objetivo, 0) * 0.10 +
        NVL(ec.intereses, 0) * 0.05 +
        NVL(ec.retribucion, 0) * 0.10
    AS NUMBER(5,3)),'FM999990.000'), 10) AS "POND TRAYECTORIA"

FROM
    postulante p
    LEFT JOIN region r ON p.id_region_titulacion = r.id_region
    LEFT JOIN postulacion po ON po.id_postulante = p.id_postulante
    LEFT JOIN institucion_destino ind ON ind.id_institucion = po.id_institucion
    LEFT JOIN evalua_comite ec ON ec.id_postulacion = po.id_postulacion
    LEFT JOIN ponderacion po1 ON po1.id_ponderacion = ec.objetivo
    LEFT JOIN ponderacion po2 ON po2.id_ponderacion = ec.intereses
    LEFT JOIN ponderacion po3 ON po3.id_ponderacion = ec.retribucion
ORDER BY po.fecha_postulacion
FETCH FIRST 5 ROWS ONLY;


INSERT INTO DET_PUNTAJE_TRAYECTORIA_POSTULANTES (
    id_postulante, run_postulante, nombre_postulante, fecha_postulacion,
    objetivo_estudio, ptje_objetivo_estudio,
    intereses, ptje_intereses,
    retribucion, ptje_retribucion,
    institucion_extranjera, puntaje_trayectoria,
    etnia, ptj_etnia,
    discapacidad, ptj_discapacidad,
    titulo_regiones, ptj_titulo_regiones,
    beca_rep, ptj_beca_rep,
    ptj_total, pond_trayectoria
)
-- aquí comienza tu SELECT
SELECT
   SUBSTR(TO_CHAR(p.rut_numero), -3) || p.rut_dv || 
   REGEXP_REPLACE(UPPER(p.nombres), '([^A-Z]*)([A-Z])[A-Z]*', '\2') || 
   SUBSTR(LOWER(p.ap_paterno), 1, 1) || 
   SUBSTR(LOWER(p.ap_materno), 1, 1) ||  
   TO_CHAR(p.fecha_registro, 'MMYY'),
   TO_CHAR(p.rut_numero) || p.rut_dv,
   INITCAP(p.nombres || ' ' || p.ap_paterno || ' ' || p.ap_materno),
   TO_CHAR(p.fecha_registro, 'fmDay') || '.' ||
   TO_CHAR(p.fecha_registro, 'DD"-"fmMonth"-"YYYY', 'nls_date_language=spanish'),
   NULL, NULL, -- objetivo_estudio, ptje_objetivo_estudio
   NULL, NULL, -- intereses, ptje_intereses
   NULL, NULL, -- retribucion, ptje_retribucion
   NULL, NULL, -- institucion_extranjera, puntaje_trayectoria
   CASE WHEN p.etnia IS NULL THEN 'No' ELSE 'Si' END,
   CASE WHEN p.etnia IS NULL THEN 0 ELSE 0.1 END,
   CASE WHEN p.discapacidad IS NULL THEN 'No' ELSE 'Si' END,
   CASE WHEN p.discapacidad IS NULL THEN 0 ELSE 0.1 END,
   CASE WHEN LOWER(r.nombre_region) = 'región metropolitana' THEN 'No' ELSE 'Si' END,
   CASE WHEN LOWER(r.nombre_region) = 'región metropolitana' THEN 0 ELSE 0.1 END,
   CASE WHEN p.beca_reparacion IS NULL THEN 'No' ELSE 'Si' END,
   CASE WHEN p.beca_reparacion IS NULL THEN 0 ELSE 0.1 END,
   -- PTJ_TOTAL = suma de 4 componentes anteriores
   NVL(CASE WHEN p.etnia IS NULL THEN 0 ELSE 0.1 END, 0) +
   NVL(CASE WHEN p.discapacidad IS NULL THEN 0 ELSE 0.1 END, 0) +
   NVL(CASE WHEN LOWER(r.nombre_region) = 'región metropolitana' THEN 0 ELSE 0.1 END, 0) +
   NVL(CASE WHEN p.beca_reparacion IS NULL THEN 0 ELSE 0.1 END, 0),
   NULL
FROM postulante p
LEFT JOIN region r ON p.id_region_titulacion = r.id_region;
commit;

drop table DET_PUNTAJE_TRAYECTORIA_POSTULANTES;
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
commit;
MERGE INTO DET_PUNTAJE_TRAYECTORIA_POSTULANTES dest
USING (
    SELECT
        SUBSTR(TO_CHAR(p.rut_numero), -3) || p.rut_dv || 
        REGEXP_REPLACE(UPPER(p.nombres), '([^A-Z]*)([A-Z])[A-Z]*', '\2') || 
        SUBSTR(LOWER(p.ap_paterno), 1, 1) || 
        SUBSTR(LOWER(p.ap_materno), 1, 1) ||  
        TO_CHAR(p.fecha_registro, 'MMYY') AS id_postulante,
        TO_CHAR(p.rut_numero, 'FM999G999G999', 'NLS_NUMERIC_CHARACTERS=''.,''') || '-' || p.rut_dv AS run_postulante,
        INITCAP(p.nombres || ' ' || p.ap_paterno || ' ' || p.ap_materno) AS nombre_postulante,
        TO_CHAR(po.fecha_postulacion, 'fmDay') || '.' ||
        TO_CHAR(po.fecha_postulacion, 'DD"-"fmMonth"-"YYYY', 'nls_date_language=spanish') AS fecha_postulacion,
        po1.descripcion AS objetivo_estudio,
        CAST(ec.objetivo AS NUMBER(5,3)) AS ptje_objetivo_estudio,
        po2.descripcion AS intereses,
        CAST(ec.intereses AS NUMBER(5,3)) AS ptje_intereses,
        po3.descripcion AS retribucion,
        CAST(ec.retribucion AS NUMBER(5,3)) AS ptje_retribucion,
        ind.ranking_ocde AS institucion_extranjera,
        ind.puntaje_ocde AS puntaje_trayectoria,
        CASE WHEN p.etnia IS NULL THEN 'No' ELSE 'Si' END AS etnia,
        CASE WHEN p.etnia IS NULL THEN 0 ELSE 0.1 END AS ptj_etnia,
        CASE WHEN p.discapacidad IS NULL THEN 'No' ELSE 'Si' END AS discapacidad,
        CASE WHEN p.discapacidad IS NULL THEN 0 ELSE 0.1 END AS ptj_discapacidad,
        CASE WHEN LOWER(r.nombre_region) = 'región metropolitana' THEN 'No' ELSE 'Si' END AS titulo_regiones,
        CASE WHEN LOWER(r.nombre_region) = 'región metropolitana' THEN 0 ELSE 0.1 END AS ptj_titulo_regiones,
        CASE WHEN p.beca_reparacion IS NULL THEN 'No' ELSE 'Si' END AS beca_rep,
        CASE WHEN p.beca_reparacion IS NULL THEN 0 ELSE 0.1 END AS ptj_beca_rep,
        NVL(CASE WHEN p.etnia IS NULL THEN 0 ELSE 0.1 END, 0) +
        NVL(CASE WHEN p.discapacidad IS NULL THEN 0 ELSE 0.1 END, 0) +
        NVL(CASE WHEN LOWER(r.nombre_region) = 'región metropolitana' THEN 0 ELSE 0.1 END, 0) +
        NVL(CASE WHEN p.beca_reparacion IS NULL THEN 0 ELSE 0.1 END, 0) +
        NVL(ec.objetivo, 0) +
        NVL(ec.intereses, 0) +
        NVL(ec.retribucion, 0) AS ptj_total,
        NVL(ec.actividades, 0) * 0.05 +
        NVL(ec.experiencia, 0) * 0.05 +
        NVL(ec.recomendacion, 0) * 0.05 +
        NVL(ec.objetivo, 0) * 0.10 +
        NVL(ec.intereses, 0) * 0.05 +
        NVL(ec.retribucion, 0) * 0.10 AS pond_trayectoria
    FROM postulante p
    LEFT JOIN postulacion po ON po.id_postulante = p.id_postulante
    LEFT JOIN evalua_comite ec ON ec.id_postulacion = po.id_postulacion
    LEFT JOIN ponderacion po1 ON po1.id_ponderacion = ec.objetivo
    LEFT JOIN ponderacion po2 ON po2.id_ponderacion = ec.intereses
    LEFT JOIN ponderacion po3 ON po3.id_ponderacion = ec.retribucion
    LEFT JOIN institucion_destino ind ON po.id_institucion_destino = ind.id_institucion_destino
    LEFT JOIN region r ON p.id_region = r.id_region
) src
ON (dest.id_postulante = src.id_postulante)
WHEN MATCHED THEN
UPDATE SET
    dest.run_postulante = src.run_postulante,
    dest.nombre_postulante = src.nombre_postulante,
    dest.fecha_postulacion = src.fecha_postulacion,
    dest.objetivo_estudio = src.objetivo_estudio,
    dest.ptje_objetivo_estudio = src.ptje_objetivo_estudio,
    dest.intereses = src.intereses,
    dest.ptje_intereses = src.ptje_intereses,
    dest.retribucion = src.retribucion,
    dest.ptje_retribucion = src.ptje_retribucion,
    dest.institucion_extranjera = src.institucion_extranjera,
    dest.puntaje_trayectoria = src.puntaje_trayectoria,
    dest.etnia = src.etnia,
    dest.ptj_etnia = src.ptj_etnia,
    dest.discapacidad = src.discapacidad,
    dest.ptj_discapacidad = src.ptj_discapacidad,
    dest.titulo_regiones = src.titulo_regiones,
    dest.ptj_titulo_regiones = src.ptj_titulo_regiones,
    dest.beca_rep = src.beca_rep,
    dest.ptj_beca_rep = src.ptj_beca_rep,
    dest.ptj_total = src.ptj_total,
    dest.pond_trayectoria = src.pond_trayectoria;
