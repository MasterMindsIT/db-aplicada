INSERT INTO resumen_postulante (
    nro_postulante, id_postulante, run_postulante, nombre_postulante,
    fecha_postulacion, objetivo_estudio, ptje_objetivo_estudio,
    intereses, ptje_intereses, retribucion, ptje_retribucion,
    institucion_extranjera, puntaje_trayectoria,
    etnia, ptj_etnia, discapacidad, ptj_discapacidad,
    titulo_regiones, ptj_titulo_regiones,
    beca_rep, ptj_beca_rep, ptj_total, pond_trayectoria
)
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

