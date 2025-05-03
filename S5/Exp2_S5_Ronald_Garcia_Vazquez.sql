/* 
 * FORMATO DE RESPUESTA 
 * SCRIPT SQL 
 * ACTIVIDAD SEMANAL
 * 
 * En esta quinta semana realizarás una actividad sumativa individual
 * denominada Construyendo sentencias SQL complejas usando funciones,
 * JOINS de tablas y subconsultas, en la cual deberás resolver un caso
 * planteado en un contexto de negocio para entregar sentencias SQL 
 * que recuperen datos de múltiples tablas usando funciones de una fila,
 * funciones de grupo, JOINS de múltiples tablas y subconsultas.
 * 
 * A continuación, documenta de forma ordenada y con comentarios
 * cada una de las partes del código a desarrollar. 
 * 
 * Script de sentencias SQL requeridas. 
 * 
 */
 -- 
 --###############  SCRIPT 1 ##############
 
SELECT -- cuarto nivel solo se formatean los resultados con un decimal
    tot.periodo AS "Periodo",
    ROUND(tot.magister * 100 / tot.total_docentes, 1) || '%' AS "Magister",
    ROUND(tot.doctorado * 100 / tot.total_docentes, 1) || '%' AS "Doctorado",
    ROUND(tot.dependiente * 100 / tot.total_docentes, 1) || '%' AS "Dependiente",
    ROUND(tot.mas_2_hijos * 100 / tot.total_docentes, 1) || '%' AS "+2 hijo",
    ROUND(tot.menores_25 * 100 / tot.total_docentes, 1) || '%' AS "-25 años",
    ROUND(tot.hombres * 100 / tot.total_docentes, 1) || '%' AS "Hombres",
    ROUND(tot.mujeres * 100 / tot.total_docentes, 1) || '%' AS "Mujeres"
FROM (
    SELECT --select tercer nivel para traer los datos contados o sumados por los 3 anios antes depasarlos a porcentajes
        df.periodo,
        COUNT(*) AS total_docentes,
        SUM(CASE WHEN LOWER(df.estudios) LIKE '%magister%' THEN 1 ELSE 0 END) AS magister,
        SUM(CASE WHEN LOWER(df.estudios) LIKE '%doctorado%' THEN 1 ELSE 0 END) AS doctorado,
        SUM(CASE WHEN df.tipo_trabajador = 'D' THEN 1 ELSE 0 END) AS dependiente,
        SUM(CASE WHEN df.num_hijos > 2 THEN 1 ELSE 0 END) AS mas_2_hijos,
        SUM(CASE WHEN MONTHS_BETWEEN(SYSDATE, df.fecha_nac_doc)/12 < 25 THEN 1 ELSE 0 END) AS menores_25,
        SUM(CASE WHEN df.genero_doc = 'M' THEN 1 ELSE 0 END) AS hombres,
        SUM(CASE WHEN df.genero_doc = 'F' THEN 1 ELSE 0 END) AS mujeres
    FROM (
        SELECT --segundo nivel, se traen los docentes y sus encuenstas vinculados a la consulta mas interna para que solo sea de la carrera con mas inscritos
            s.cod_docente,
            s.annio_sec AS periodo,
            d.fecha_nac_doc,
            d.genero_doc,
            ed.estudios,
            ed.tipo_trabajador,
            ed.num_hijos
        FROM seccion s
        JOIN (
            SELECT cod_carrera --select mas interno para 
            FROM matricula
            --WHERE EXTRACT(YEAR FROM fecha_inscripcion) BETWEEN EXTRACT(YEAR FROM SYSDATE) - 2 AND EXTRACT(YEAR FROM SYSDATE)
            --linea superior comentada para que sea en base a la carrera con mas inscritos en total de su historia, 
            --si lo habilitamos sera la con mas inscritos los ultimos 3 anios
            GROUP BY cod_carrera
            ORDER BY COUNT(*) DESC
            FETCH FIRST 1 ROWS ONLY
        ) carrera_top ON s.cod_carrera = carrera_top.cod_carrera
        JOIN docente d ON d.id_docente = s.cod_docente
        JOIN encuesta_docente ed ON ed.cod_docente = d.id_docente
        WHERE s.annio_sec BETWEEN EXTRACT(YEAR FROM SYSDATE) - 2 AND EXTRACT(YEAR FROM SYSDATE)
    ) df
    GROUP BY df.periodo
) tot
ORDER BY tot.periodo;

 --###############  SCRIPT 2 ##############(DEMASIADO LARGO SI SE CONSIDERAN TODAS LAS RELACIONES QUE PARTICIPAN)
-- Prompt para solicitar el nombre de la carrera tal cual esta en la base de datos ya que no es like
ACCEPT nombre_carrera CHAR PROMPT 'Ingrese el nombre de la carrera: '
-- Paso 2: CTE para obtener el ID de la carrera
WITH carrera_objetivo AS (
    SELECT id_carrera
    FROM carrera
    WHERE UPPER(nombre_car) = UPPER('&nombre_carrera')
),
-- Paso 3: Seleccionar los alumnos que aprobaron una asignatura SIN repetirla
aprobaciones_unicas AS (
    SELECT 
        s.annio_sec,
        s.cod_asignatura,
        s.cod_carrera,
        s.promedio_sec,
        s.id_seccion,
        m.cod_estudiante
    FROM seccion s
    JOIN matricula m ON s.cod_carrera = m.cod_carrera
    JOIN carrera_objetivo co ON s.cod_carrera = co.id_carrera
    WHERE s.annio_sec >= EXTRACT(YEAR FROM SYSDATE) - 2
      AND s.promedio_sec >= 4
      AND EXISTS (
          SELECT 1
          FROM seccion s2
          JOIN matricula m2 ON s2.cod_carrera = m2.cod_carrera
          WHERE s2.cod_asignatura = s.cod_asignatura
            AND m2.cod_estudiante = m.cod_estudiante
            AND s2.promedio_sec >= 4
          GROUP BY m2.cod_estudiante, s2.cod_asignatura
          HAVING COUNT(*) = 1  -- Solo una vez la aprobaron => no la repitieron
      )
),
-- Paso 4: Relacionar con tipo de asignatura
aprobaciones_clasificadas AS (
    SELECT 
        a.annio_sec AS periodo,
        ta.nombre_tipo_asig,
        COUNT(*) AS cantidad
    FROM aprobaciones_unicas a
    JOIN asignatura asi ON asi.id_asignatura = a.cod_asignatura
    JOIN tipo_asignatura ta ON ta.id_tipo_asig = asi.cod_tipo_asig
    GROUP BY a.annio_sec, ta.nombre_tipo_asig
),
-- Paso 5: Total de aprobados por año
totales_anuales AS (
    SELECT 
        annio_sec AS periodo,
        COUNT(*) AS total
    FROM aprobaciones_unicas
    GROUP BY annio_sec
)
-- Paso 6: Reporte final con porcentajes
SELECT 
    t.periodo,
    t.total AS "Total AA",
    NVL(cb.cantidad, 0) || ' – ' || NVL(TO_CHAR(ROUND(cb.cantidad * 100 / t.total)), '0') || '%' AS "Ciencias Básicas",
    NVL(d.cantidad, 0) || ' – ' || NVL(TO_CHAR(ROUND(d.cantidad * 100 / t.total)), '0') || '%' AS "Disciplinar",
    NVL(i.cantidad, 0) || ' – ' || NVL(TO_CHAR(ROUND(i.cantidad * 100 / t.total)), '0') || '%' AS "Integradora",
    NVL(vcm.cantidad, 0) || ' – ' || NVL(TO_CHAR(ROUND(vcm.cantidad * 100 / t.total)), '0') || '%' AS "VcM"
FROM totales_anuales t
LEFT JOIN aprobaciones_clasificadas cb ON cb.periodo = t.periodo AND cb.nombre_tipo_asig = 'Ciencias Básicas'
LEFT JOIN aprobaciones_clasificadas d  ON d.periodo = t.periodo AND d.nombre_tipo_asig = 'Disciplinar'
LEFT JOIN aprobaciones_clasificadas i  ON i.periodo = t.periodo AND i.nombre_tipo_asig = 'Integradora'
LEFT JOIN aprobaciones_clasificadas vcm ON vcm.periodo = t.periodo AND vcm.nombre_tipo_asig = 'VcM'
ORDER BY t.periodo;

