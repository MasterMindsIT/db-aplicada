CREATE INDEX idx_fecha_otorgamiento ON licencia (fecha_otorgamiento);
--CREATE INDEX idx_fecha_otorgamiento_trunc  NO AYUDA YA QUE INTERNAMENTE ORACLE LO HARA PARA LOS FILTROS DE FECHA
CREATE INDEX idx_licencia_fecha_id_prof ON licencia(fecha_otorgamiento, id_prof);
--CREATE INDEX idx_profesional_id_especialidad ON profesional(id_especialidad); al ser vinculados por llaves pk y fk no es necesario
--CREATE INDEX idx_licencias_id_prof ON licencia(id_prof);
CREATE OR REPLACE VIEW vw_licencias_profesionales AS 
WITH 
 ahora AS (SELECT SYSDATE AS hoy FROM dual), -- SE CREA ESTA TABLA PARA NO CALCULAR MAS EL VALOR Y UTILIZARLO DE FORMA DIRECTA APROVECHANDO CTE EN ORACLE
media_licencias_2meses AS (
    SELECT 
        AVG(cantidad_licencias) AS media_general --SE BUSCA LA MEDIA PARA OBTENER DESPUES SOLO LOS > A ESTA
    FROM (
        SELECT 
            l.id_prof, --IMPRESINDIBLE PARA AGRUPAR Y CONTAR
            COUNT(l.id_licencia) AS cantidad_licencias 
        FROM 
            licencia l
        WHERE 
            l.fecha_otorgamiento BETWEEN ADD_MONTHS((SELECT hoy FROM ahora), -2) AND ADD_MONTHS((SELECT hoy FROM ahora), -1) --SE BUSCA UN MES ANTES DEL DESAADO PARA CUMPLIR REQUERIMIENTO
        GROUP BY  
            l.id_prof
    )
),
licencias_1mes_mayor_media AS (
    SELECT 
        l.id_prof, -- IMPORTANTE PARA AGRUPAR
        COUNT(l.id_licencia) AS licencias_ultimo_mes --SE PUEDE CONTAR POR CADA PROFESIONAL
    FROM 
        licencia l
        CROSS JOIN media_licencias_2meses m -- NECESARIO  PARA COMPARAR LA MEDIA DE LA CONSULTA ANTERIOR
    WHERE 
        l.fecha_otorgamiento BETWEEN ADD_MONTHS((SELECT hoy FROM ahora), -1) AND (SELECT hoy FROM ahora) -- ESTE FILTRO DEVUELVE LOS DEL INFORME, MES ANTERIOR AL MOMENTO DE LA EJECUCION
    GROUP BY 
        l.id_prof
    HAVING 
        COUNT(l.id_licencia) > MAX(m.media_general) -- FILTRO QUE OBTIENE SOLO QUIENES CUMPLEN LA CONDICION
),
total_licencias AS (
    SELECT SUM(licencias_ultimo_mes) AS total -- TRAE EL TOTAL DE LAS LICENCIAS MES ANTERIORI PARA CALCULAR PORCENTAJE
    FROM licencias_1mes_mayor_media
)
SELECT --TABLA RESULTADO O FINAL SEGUN REQUERIMIENTOS
    LPAD(p.run_prof || ' ' || p.dv_prof, 15) AS rut, --UNIDOS POR ESPACIO Y ALINEADO POR ESPACIOS A LA IZQUIERDA
    INITCAP(p.pnombre_prof) || ' ' || INITCAP(p.appaterno_prof) || ' ' || INITCAP(p.apmaterno_prof) AS profesional,
    e.nombre_esp AS especialidad,
    l1m.licencias_ultimo_mes licencias_emitidas, --SE TRAJERON LAS LICENCIAS CONTADAS
    ROUND((l1m.licencias_ultimo_mes / t.total) * 100, 2) AS porcentaje --SE CALCULA EL %
FROM 
    licencias_1mes_mayor_media l1m
    JOIN profesional p ON l1m.id_prof = p.id_prof
    JOIN especialidad e ON p.id_especialidad = e.id_especialidad
    CROSS JOIN total_licencias t --SE APROVECHA EL CTE Y QUE DA UNA SOLA COLUMNA DE RESPUESTA PARA AGREGAR A CADA RESULTADO
ORDER BY 
    porcentaje DESC; --ORDENA POR EL PORCENTAJE