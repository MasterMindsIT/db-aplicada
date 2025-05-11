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
   NVL(CASE WHEN p.etnia IS NULL THEN 0 ELSE 0.1 END, 0) +
   NVL(CASE WHEN p.discapacidad IS NULL THEN 0 ELSE 0.1 END, 0) +
   NVL(CASE WHEN LOWER(r.nombre_region) = 'región metropolitana' THEN 0 ELSE 0.1 END, 0) +
   NVL(CASE WHEN p.beca_reparacion IS NULL THEN 0 ELSE 0.1 END, 0),
   NULL
FROM postulante p
LEFT JOIN region r ON p.id_region_titulacion = r.id_region;
commit;