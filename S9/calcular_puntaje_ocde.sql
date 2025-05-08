DROP FUNCTION calcular_puntaje_ocde; -- Eliminar la función si existe
DROP TRIGGER trg_actualizar_puntaje_ocde; -- Eliminar el trigger si existe


CREATE OR REPLACE FUNCTION calcular_puntaje_ocde (
    ranking_destino IN NUMBER
) RETURN NUMBER IS
    posicion_chilena NUMBER;
    puntaje NUMBER;
BEGIN
    -- Leer valor actual de posición chilena desde tabla auxiliar
    SELECT posicion_chilena
    INTO posicion_chilena
    FROM configuracion_ocde
    WHERE ROWNUM = 1;

    -- Validación
    IF ranking_destino IS NULL OR posicion_chilena IS NULL THEN
        RETURN NULL;
    END IF;

    -- Caso 1: Top 1 al 100
    IF ranking_destino <= 100 THEN
        puntaje := 5;

    -- Caso 2: Entre 101 y la posición de la primera chilena
    ELSIF ranking_destino > 100 AND ranking_destino < posicion_chilena THEN
        puntaje := 5 - ((posicion_chilena - 100) / (ranking_destino - 100)) * 4;

    -- Caso 3: Desde la posición de la primera chilena en adelante
    ELSIF ranking_destino >= posicion_chilena THEN
        puntaje := 1;

    ELSE
        puntaje := 0;
    END IF;

    RETURN ROUND(puntaje, 3);
END calcular_puntaje_ocde;


-- Trigger para actualizar el puntaje OCDE al insertar o actualizar los datos del postulante
CREATE OR REPLACE TRIGGER trg_actualizar_puntaje_ocde
AFTER INSERT OR UPDATE OF ranking_ocde
ON institucion
FOR EACH ROW
WHEN (NEW.ranking_ocde IS NOT NULL)
BEGIN
    UPDATE institucion
    SET puntaje_ocde = calcular_puntaje_ocde(:NEW.ranking_ocde)
    WHERE id_institucion = :NEW.id_institucion;
END;

-- Trigger para recalcular el puntaje OCDE global al actualizar la posición chilena
CREATE OR REPLACE TRIGGER trg_recalcular_puntaje_ocde_global
AFTER UPDATE OF posicion_chilena ON configuracion_ocde
FOR EACH ROW
BEGIN
    -- Recalcular los puntajes de todas las instituciones
    UPDATE institucion
    SET puntaje_ocde = calcular_puntaje_ocde(ranking_ocde)
    WHERE ranking_ocde IS NOT NULL;
END;

