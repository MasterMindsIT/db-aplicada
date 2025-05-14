SELECT
    TO_CHAR(p.rut_numero) AS "RUN POSTULANTE",
    INITCAP(p.nombres || ' ' || p.ap_paterno || ' ' || p.ap_materno) AS "NOMBRE POSTULANTE",
    pa.nombre_pais AS "PAIS DESTINO",
    ind.nombre_institucion AS "INSTITUCION DESTINO",
    ind.ranking_ocde AS "RANKING",
    p.puntaje_aa AS "PTJE ANT ACAD PREGRADO",

    po1.descripcion AS "DES ACTIVIDADES",
    po2.id_ponderacion||' años'  AS "EXP LABORAL",
    po3.descripcion AS "CARTAS",

    po4.descripcion AS "OBJ ESTUDIO",
    po5.descripcion AS "INTERESES",
    po6.descripcion AS "RETRIBUCION",

    CAST(ind.puntaje_ocde AS NUMBER(5,3)) AS "PTJE. RANKING INST. DESTINO",

    CASE 
        WHEN p.etnia IS NULL THEN 'No pertenece'
        ELSE INITCAP(p.etnia)
    END AS "ETNIA",

    CASE 
        WHEN p.discapacidad IS NULL THEN 'No tiene'
        ELSE  INITCAP(p.discapacidad)
    END AS "DISCAPACIDAD",

    CASE 
        WHEN r.nombre_region IS NULL OR LOWER(r.nombre_region) = 'región metropolitana' THEN 'No tiene'
        ELSE INITCAP(r.nombre_region)
    END AS "TITULO REGIONES",

    CASE 
        WHEN p.beca_reparacion IS NULL THEN 'No ha sido beneficiado'
        ELSE 'Ha sido beneficiado'
    END AS "BECA REP",

    -- PTJE TOTAL = puntajes sociales + puntaje_ocde * 0.3 + nota_media_pregrado
    CAST(
        NVL(CASE WHEN p.etnia IS NULL THEN 0 ELSE 0.1 END, 0) +
        NVL(CASE WHEN p.discapacidad IS NULL THEN 0 ELSE 0.1 END, 0) +
        NVL(CASE WHEN LOWER(r.nombre_region) = 'región metropolitana' THEN 0 ELSE 0.1 END, 0) +
        NVL(CASE WHEN p.beca_reparacion IS NULL THEN 0 ELSE 0.1 END, 0) +
        --las evaluaciones de los expertos
        NVL(ec.objetivo, 0) +
        NVL(ec.intereses, 0) +
        NVL(ec.retribucion, 0) +
        NVL(ec.actividades, 0) +
        NVL(ec.experiencia, 0) +
        NVL(ec.recomendacion, 0) +
        --Antecedentes academicos
        NVL(p.puntaje_aa, 0) +
        --trayectoria institucional
        NVL(ind.puntaje_ocde, 0) 
    AS NUMBER(5,3)) AS "PTE TOTAL",

    CAST( NVL(CASE WHEN p.etnia IS NULL THEN 0 ELSE 0.1 END, 0) +
        NVL(CASE WHEN p.discapacidad IS NULL THEN 0 ELSE 0.1 END, 0) +
        NVL(CASE WHEN LOWER(r.nombre_region) = 'región metropolitana' THEN 0 ELSE 0.1 END, 0) +
        NVL(CASE WHEN p.beca_reparacion IS NULL THEN 0 ELSE 0.1 END, 0) +
        --las evaluaciones de los expertos
        NVL(ec.objetivo * 0.1 , 0) +
        NVL(ec.intereses * 0.05 , 0) +
        NVL(ec.retribucion * 0.1 , 0) +
         NVL(ec.actividades * 0.05 , 0) +
        NVL(ec.experiencia * 0.05 , 0) +
        NVL(ec.recomendacion * 0.05 , 0) +
        --Antecedentes academicos
        NVL(p.puntaje_aa * 0.3 , 0) +
        --trayectoria institucional
        NVL(ind.puntaje_ocde * 0.3 , 0)  
    AS NUMBER(5,3)) AS "POND FINAL", -- si aún no tienes fórmula para este, queda en NULL

    ep.estado AS "ESTADO POSTULACIÓN"

FROM postulante p
JOIN postulacion post ON post.id_postulante = p.id_postulante
LEFT JOIN estado_postulacion ep ON ep.id_estado = post.id_estado
LEFT JOIN region r ON p.id_region_titulacion = r.id_region
LEFT JOIN institucion_destino ind ON ind.id_institucion = post.id_institucion
LEFT JOIN pais pa ON pa.id_pais = ind.id_pais
LEFT JOIN evalua_comite ec ON ec.id_postulacion = post.id_postulacion

-- JOINS múltiples para cada criterio
LEFT JOIN ponderacion po1 ON po1.id_ponderacion = ec.actividades
LEFT JOIN ponderacion po2 ON po2.id_ponderacion = ec.experiencia
LEFT JOIN ponderacion po3 ON po3.id_ponderacion = ec.recomendacion
LEFT JOIN ponderacion po4 ON po4.id_ponderacion = ec.objetivo
LEFT JOIN ponderacion po5 ON po5.id_ponderacion = ec.intereses
LEFT JOIN ponderacion po6 ON po6.id_ponderacion = ec.retribucion
ORDER BY "PTE TOTAL" DESC
FETCH FIRST 5 ROWS ONLY;
