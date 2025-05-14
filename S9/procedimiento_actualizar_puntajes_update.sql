
CREATE OR REPLACE PROCEDURE actualizar_puntajes_postulantes IS
BEGIN
    UPDATE DET_PUNTAJE_TRAYECTORIA_POSTULANTES dp
    SET
        ptje_objetivo_estudio = (
            SELECT ec.objetivo
            FROM postulacion po
            JOIN evalua_comite ec ON ec.id_postulacion = po.id_postulacion
            WHERE po.id_postulante = dp.id_postulante
        ),
        ptje_intereses = (
            SELECT ec.intereses
            FROM postulacion po
            JOIN evalua_comite ec ON ec.id_postulacion = po.id_postulacion
            WHERE po.id_postulante = dp.id_postulante
        ),
        ptje_retribucion = (
            SELECT ec.retribucion
            FROM postulacion po
            JOIN evalua_comite ec ON ec.id_postulacion = po.id_postulante
            WHERE po.id_postulante = dp.id_postulante
        ),
        puntaje_trayectoria = (
            SELECT ind.puntaje_ocde
            FROM postulacion po
            JOIN institucion_destino ind ON ind.id_institucion = po.id_institucion
            WHERE po.id_postulante = dp.id_postulante
        ),
        ptj_etnia = CASE 
            WHEN EXISTS (SELECT 1 FROM postulante p WHERE p.id_postulante = dp.id_postulante AND p.etnia IS NOT NULL) 
            THEN 0.1 ELSE 0 END,
        ptj_discapacidad = CASE 
            WHEN EXISTS (SELECT 1 FROM postulante p WHERE p.id_postulante = dp.id_postulante AND p.discapacidad IS NOT NULL) 
            THEN 0.1 ELSE 0 END,
        ptj_titulo_regiones = (
            SELECT CASE 
                WHEN LOWER(r.nombre_region) <> 'región metropolitana' THEN 0.1 ELSE 0 
            END
            FROM postulante p
            JOIN region r ON r.id_region = p.id_region_titulacion
            WHERE p.id_postulante = dp.id_postulante
        ),
        ptj_beca_rep = CASE 
            WHEN EXISTS (SELECT 1 FROM postulante p WHERE p.id_postulante = dp.id_postulante AND p.beca_reparacion IS NOT NULL) 
            THEN 0.1 ELSE 0 END,
        ptj_total = (
            SELECT 
                NVL(p.puntaje_aa, 0) +
                NVL(ind.puntaje_ocde * 0.3, 0) +
                NVL(ec.objetivo, 0) + NVL(ec.intereses, 0) + NVL(ec.retribucion, 0) +
                NVL(ec.actividades, 0) + NVL(ec.experiencia, 0) + NVL(ec.recomendacion, 0) +
                NVL(CASE WHEN p.etnia IS NULL THEN 0 ELSE 0.1 END, 0) +
                NVL(CASE WHEN p.discapacidad IS NULL THEN 0 ELSE 0.1 END, 0) +
                NVL(CASE WHEN LOWER(r.nombre_region) = 'región metropolitana' THEN 0 ELSE 0.1 END, 0) +
                NVL(CASE WHEN p.beca_reparacion IS NULL THEN 0 ELSE 0.1 END, 0)
            FROM postulante p
            JOIN postulacion po ON po.id_postulante = p.id_postulante
            JOIN institucion_destino ind ON ind.id_institucion = po.id_institucion
            JOIN region r ON r.id_region = p.id_region_titulacion
            JOIN evalua_comite ec ON ec.id_postulacion = po.id_postulacion
            WHERE p.id_postulante = dp.id_postulante
        )
    WHERE EXISTS (
        SELECT 1
        FROM postulacion po
        WHERE po.id_postulante = dp.id_postulante
    );
END;
/
