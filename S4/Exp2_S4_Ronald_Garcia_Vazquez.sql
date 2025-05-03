-- Consulta principal que devuelve, para cada tipo de licencia, al doctor que tiene
-- la mayor cantidad de licencias. En caso de empate, el que acumule más días de reposo.
SELECT
  final.tipo_licencia,
  
  -- Construcción del RUT con nombre en mayúsculas
  final.run_prof || '-' || final.dv_prof || ' ' ||
    UPPER(final.pnombre_prof) || ' ' || UPPER(final.appaterno_prof) || ' ' || UPPER(final.apmaterno_prof) AS Rut,

  final.especialidad,

  -- Renombramos los campos finales para mejorar la presentación
  final.Cantidad AS "Cantidad",
  final.Dias AS "Dias",
  final.total_monto AS "Monto Pagado"

FROM (
  -- Segunda capa: asigna un número de fila a cada médico dentro de cada tipo de licencia
  -- usando ROW_NUMBER ordenado por cantidad (descendente) y días (descendente) regreso los mismo 355 con un id rn para el orden
  SELECT
    la.*,
    ROW_NUMBER() OVER (                               -- ROW_NUMBER funcion para asignar numeracion
      PARTITION BY la.id_tipo_licencia                -- PARTITION BY Agrupa por tipo de licencia
      ORDER BY la.Cantidad DESC, la.Dias DESC         -- Dentro de cada grupo, ordena por cantidad y días(este para definir ganador en caso de empate)
    ) AS rn                                           -- Número de fila según orden establecido

  FROM (
    -- Primer nivel: agrupamos las licencias por médico y tipo de licencia
    -- y calculamos cuántas tiene, cuántos días acumula y el monto estimado regreso 355 registros
    SELECT
      tl.id_tipo_licencia,

      -- Armamos un campo de tipo de licencia con id + nombre formateado
      TO_CHAR(tl.id_tipo_licencia) || ' - ' || INITCAP(tl.nombre_tipo_lic) AS tipo_licencia,

      -- Datos personales del médico
      p.run_prof,
      p.dv_prof,
      p.pnombre_prof,
      p.appaterno_prof,
      p.apmaterno_prof,
      e.nombre_esp AS especialidad,

      -- Cantidad total de licencias por ese tipo
      COUNT(l.id_licencia) AS Cantidad,

      -- Suma total de días de reposo (resta de fechas)
      SUM(l.fecha_reposo_fin - l.fecha_reposo_inicio) AS Dias,

      -- Monto calculado estimando 40.000 diarios y formateado con separadores
      TO_CHAR(SUM((l.fecha_reposo_fin - l.fecha_reposo_inicio) * 40000), 'L999G999G999G999') AS total_monto

    FROM
      licencia l
    JOIN profesional p ON l.id_prof = p.id_prof
    JOIN especialidad e ON p.id_especialidad = e.id_especialidad
    JOIN tipo_licencia tl ON l.id_tipo_lic = tl.id_tipo_licencia

    -- Filtros para asegurarnos de que los campos relevantes no sean nulos
    WHERE
      l.id_licencia IS NOT NULL AND
      l.fecha_reposo_inicio IS NOT NULL AND
      l.fecha_reposo_fin IS NOT NULL AND
      l.id_prof IS NOT NULL AND
      p.run_prof IS NOT NULL AND
      p.dv_prof IS NOT NULL AND
      p.pnombre_prof IS NOT NULL AND
      p.appaterno_prof IS NOT NULL AND
      p.apmaterno_prof IS NOT NULL AND
      p.id_especialidad IS NOT NULL AND
      e.nombre_esp IS NOT NULL AND
      l.id_tipo_lic IS NOT NULL AND
      tl.nombre_tipo_lic IS NOT NULL AND
      l.FECHA_OTORGAMIENTO >= ADD_MONTHS(SYSDATE, -36) --restriccion a 3 anios

    -- Agrupamos por los datos que identifican al médico y el tipo de licencia
    GROUP BY
      tl.id_tipo_licencia,
      tl.nombre_tipo_lic,
      p.run_prof,
      p.dv_prof,
      p.pnombre_prof,
      p.appaterno_prof,
      p.apmaterno_prof,
      e.nombre_esp
  ) la  -- Fin del subquery que agrupa y calcula
) final  -- Fin del subquery que numera con ROW_NUMBER

-- Solo nos quedamos con la primera fila por tipo de licencia (el mejor según los criterios) rn =1
WHERE final.rn = 1

-- Ordenamos por tipo de licencia
ORDER BY final.id_tipo_licencia;
