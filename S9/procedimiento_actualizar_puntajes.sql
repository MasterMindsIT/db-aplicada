
CREATE OR REPLACE PROCEDURE actualizar_puntajes_postulantes IS
BEGIN
    MERGE INTO DET_PUNTAJE_TRAYECTORIA_POSTULANTES dest
USING (
    SELECT
        SUBSTR(TO_CHAR(p.rut_numero), -3) || p.rut_dv || 
        REGEXP_REPLACE(UPPER(p.nombres), '([^A-Z]*)([A-Z])[A-Z]*', '\2') || 
        SUBSTR(LOWER(p.ap_paterno), 1, 1) || 
        SUBSTR(LOWER(p.ap_materno), 1, 1) ||  
        TO_CHAR(p.fecha_registro, 'MMYY') AS id_postulante,
        TO_CHAR(p.rut_numero, 'FM999G999G999', 'NLS_NUMERIC_CHARACTERS='',.''') || '-' || p.rut_dv AS run_postulante,
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
    LEFT JOIN region r ON p.id_region_titulacion = r.id_region
    LEFT JOIN postulacion po ON po.id_postulante = p.id_postulante
    LEFT JOIN institucion_destino ind ON ind.id_institucion = po.id_institucion
    LEFT JOIN evalua_comite ec ON ec.id_postulacion = po.id_postulacion
    LEFT JOIN ponderacion po1 ON po1.id_ponderacion = ec.objetivo
    LEFT JOIN ponderacion po2 ON po2.id_ponderacion = ec.intereses
    LEFT JOIN ponderacion po3 ON po3.id_ponderacion = ec.retribucion
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


commit
    ;
END;
/
