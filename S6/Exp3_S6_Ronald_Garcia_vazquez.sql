/* 
 * FORMATO DE RESPUESTA 
 * SCRIPT SQL 
 * ACTIVIDAD SEMANAL
 * 
 * En esta sexta semana realizarás una actividad formativa individual
 * denominada Construyendo sentencias DML para manipular datos almacenados
 * en la base de datos, en la cual deberás resolver un caso para
 * construir sentencias SQL que manipulen datos en la inserción,
 * actualización y eliminación de datos en la resolución de casos planteados. 
 *
 * En la segunda parte, deberás desarrollar un Quiz con preguntas de selección única 
 * basadas en el desarrollo del caso planteado. 
 * 
 * A continuación, documenta de forma ordenada y con comentarios
 * cada una de las partes del código a desarrollar. 
 * 
 * 
 */
--truncate table estados_licencia ; -- para limpiar la tabla de otras ejecuciones
INSERT INTO estados_licencia (
  id_licencia,
  run_empleado,
  id_ent_salud,
  id_tipo_lic,
  dias_reposo,
  fecha_reposo_inicio,
  fecha_reposo_fin,
  fecha_otorgamiento,
  inicio_tramite,
  dias_tramite,
  id_tipo_estado
)
SELECT *
FROM (
  WITH licencias_mes_anterior AS ( --creo una tabla temporal con las licencias del mes anterior
    SELECT *
    FROM licencia
    WHERE fecha_otorgamiento BETWEEN TRUNC(ADD_MONTHS(SYSDATE, -1), 'MM') --paso a mes anterior y al primer dia del mes
                            AND LAST_DAY(ADD_MONTHS(SYSDATE, -1)) --ademas del ultimo dia del mes anterior
  ),
  top_3_tipos_licencia AS ( --creo una tabla temporal filtrando 3 tipos de licencia mas frecuentes
    SELECT id_tipo_lic
    FROM licencias_mes_anterior
    GROUP BY id_tipo_lic
    ORDER BY COUNT(*)  --me aseguro por el orden de tomar las que tiene mayor frecuencia
    FETCH FIRST 3 ROWS ONLY --traigo los 3 tipos de licencia mas frecuentes similar a limit en otros gestores
  )
  SELECT
    l.id_licencia,
    TO_CHAR(t.run_trab) || '-' || t.dv_trab AS run_empleado,
    t.id_ent_salud,
    l.id_tipo_lic,
    TRUNC(l.fecha_reposo_fin - l.fecha_reposo_inicio) AS dias_reposo,--retorna la cantidad de dias pudiendo ser 0 si es la misma fecha, puedo usar ABS e ignorar la forma de preguntar ya que siempre tendre un positivo
    l.fecha_reposo_inicio,
    l.fecha_reposo_fin,
    l.fecha_otorgamiento,
    CASE
      WHEN l.fecha_tramite IS NULL THEN TO_DATE('01-01-1900', 'DD-MM-YYYY') 
      ELSE l.fecha_tramite
    END AS inicio_tramite,
    CASE
        WHEN l.fecha_tramite IS NULL THEN NULL
      ELSE l.fecha_tramite - l.fecha_otorgamiento
    END AS dias_tramite,
    CASE
        WHEN l.fecha_tramite IS NULL THEN 1
        WHEN (l.fecha_tramite - l.fecha_otorgamiento) <= 2 THEN 2
      ELSE 3
    END AS id_tipo_estado
  FROM licencias_mes_anterior l
  JOIN trabajador t ON l.id_trab = t.id_trab
  WHERE l.id_tipo_lic IN (SELECT id_tipo_lic FROM top_3_tipos_licencia)
);


