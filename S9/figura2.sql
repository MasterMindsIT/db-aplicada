SELECT
    ROWNUM AS "NRO POSTULANTE",

    -- ID POSTULANTE
    SUBSTR(TO_CHAR(p.rut_numero), -3) || 
    p.rut_dv || 
    REGEXP_REPLACE(UPPER(p.nombres), '([^A-Z]*)([A-Z])[A-Z]*', '\2') || 
    SUBSTR(LOWER(p.ap_paterno, 1, 1)) || 
    SUBSTR(LOWER(p.ap_materno, 1, 1)) ||  
    TO_CHAR(p.fecha_registro, 'MMYY') AS "ID POSTULANTE",

    -- RUN POSTULANTE
    TO_CHAR(p.rut_numero) || p.rut_dv AS "RUN POSTULANTE",

    -- NOMBRE POSTULANTE
    INITCAP(p.nombres || ' ' || p.ap_paterno || ' ' || p.ap_materno) AS "NOMBRE POSTULANTE",

    -- FECHA POSTULACION (dialiteral)
    TO_CHAR(p.fecha_registro, 'Day') || 
    TO_CHAR(p.fecha_registro, 'DD"-"Month"-"YYYY', 'nls_date_language=spanish') AS "FECHA POSTULACION",

    -- INST.EDUC EXTRANJERA
    NULL AS "INST.EDUC EXTRANJERA",

    -- PUNTAJE TRAYECTORIA
    NULL AS "PUNTAJE TRAYECTORIA",

    -- ETNIA
    CASE WHEN p.etnia IS NULL THEN 'No' ELSE 'Si' END AS "ETNIA",

    -- PTJ ETNIA
    CASE WHEN p.etnia IS NULL THEN '0' ELSE '0.1' END AS "PTJ ETNIA",

    -- DISCAPACIDAD
    CASE WHEN p.discapacidad IS NULL THEN 'No' ELSE 'Si' END AS "DISCAPACIDAD",

    -- PTJ DISCAPACIDAD
    CASE WHEN p.discapacidad IS NULL THEN '0' ELSE '0.1' END AS "PTJ DISCAPACIDAD",

    -- TITULO REGIONES
    CASE 
        WHEN LOWER(r.nombre_region) = 'región metropolitana' THEN 'No'
        ELSE 'Si'
    END AS "TITULO REGIONES",

    -- PTJ TITULO REGIONES
    CASE 
        WHEN LOWER(r.nombre_region) = 'región metropolitana' THEN '0'
        ELSE '0.1'
    END AS "PTJ TITULO REGIONES",

    -- BECA REP
    CASE WHEN p.beca_reparacion IS NULL THEN 'No' ELSE 'Si' END AS "BECA REP",

    -- PTJ BECA REP
    CASE WHEN p.beca_reparacion IS NULL THEN '0' ELSE '0.1' END AS "PTJ BECA REP"

FROM
    postulante p
    LEFT JOIN region r ON p.id_region_titulacion = r.id_region;
