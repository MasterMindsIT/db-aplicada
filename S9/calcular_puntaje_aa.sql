DROP FUNCTION calcular_puntaje_aa; -- Eliminar la función si existe
DROP TRIGGER trg_actualizar_puntaje_aa; -- Eliminar el trigger si existe


--  función para calcular el puntaje AA de un postulante
CREATE OR REPLACE FUNCTION calcular_puntaje_aa (
    nota_media_pregrado IN NUMBER,
    posicion_ranking IN NUMBER,
    total_egresados IN NUMBER
) RETURN NUMBER IS
    y NUMBER;
    p NUMBER;
    q NUMBER;
    z NUMBER;
    w NUMBER;
BEGIN
    -- Validación mínima
    IF nota_media_pregrado IS NULL OR posicion_ranking IS NULL OR total_egresados IS NULL THEN
        RETURN NULL;
    END IF;

    -- Cálculo de y
    y := 10 - (35 / nota_media_pregrado);

    -- Cálculo de p (porcentaje del ranking)
    p := (posicion_ranking / total_egresados) * 100;

    -- Cálculo de q según p
    IF p <= 30 THEN
        q := (-0.002 * POWER(p, 2)) - (0.0666667 * p) + 5;
    ELSE
        q := (-0.042 * p) + 4.29;
    END IF;

    -- Cálculo de z según total de egresados
    IF total_egresados < 30 THEN
        z := y * ((50 - total_egresados) / 20);
    ELSIF total_egresados <= 50 THEN
        z := y * ((50 - total_egresados) / 20) + ((total_egresados - 30) / 20) * q;
    ELSE
        z := q;
    END IF;

    -- Puntaje AA final
    w := ROUND((y * 0.5 + z * 0.5), 3);
    RETURN w;
END calcular_puntaje_aa;

--trigger para actualizar el puntaje AA al insertar o actualizar los datos del postulante
CREATE OR REPLACE TRIGGER trg_actualizar_puntaje_aa
AFTER INSERT OR UPDATE OF 
    nota_media_pregrado, 
    posicion_ranking, 
    total_egresados
ON postulante
FOR EACH ROW
WHEN (
    NEW.nota_media_pregrado IS NOT NULL AND 
    NEW.posicion_ranking IS NOT NULL AND 
    NEW.total_egresados IS NOT NULL
)
BEGIN
    UPDATE postulante
    SET puntaje_aa = calcular_puntaje_aa(
        :NEW.nota_media_pregrado,
        :NEW.posicion_ranking,
        :NEW.total_egresados
    )
    WHERE id_postulante = :NEW.id_postulante;
END;
