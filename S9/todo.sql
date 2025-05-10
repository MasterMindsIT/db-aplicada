-- BORRADO DE TODAS LAS TABLAS SIN IMPORTAR EL ORDEN NI LAS RESTRICCIONES
BEGIN
    FOR t IN (
        SELECT table_name FROM user_tables 
        WHERE table_name IN (
            'PAIS',
            'REGION',
            'GENERO',
            'ESTADO_CIVIL',
            'POSTULANTE',
            'TIPO_DOCUMENTO',
            'TIPO_SISTEMA',
            'DOCUMENTO',
            'TIPO_PROGRAMA',
            'AREA_PROGRAMA',
            'PROGRAMA_BECAS',
            'INSTITUCION_DESTINO',
            'ESTADO_POSTULACION',
            'POSTULACION',
            'DOCUMENTO_PRESENTADO',
            'EVALUA_COMITE',
            'CONFIGURACION_OCDE',
            'PONDERACION'
        )
    ) LOOP
        BEGIN
            EXECUTE IMMEDIATE 'DROP TABLE ' || t.table_name || ' CASCADE CONSTRAINTS';
        EXCEPTION
            WHEN OTHERS THEN
                DBMS_OUTPUT.PUT_LINE('No se pudo eliminar la tabla: ' || t.table_name || ' - Error: ' || SQLERRM);-- para verificar NOWAIT 
        END;
    END LOOP;
END;
/

COMMIT;

--Eliminacion de las secuencias
DROP SEQUENCE seq_pais;
DROP SEQUENCE seq_region;
DROP SEQUENCE seq_genero;
DROP SEQUENCE seq_estado_civil;
DROP SEQUENCE seq_tipo_programa;

-- Secuencias para todos los autoincrementales
CREATE SEQUENCE seq_pais START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_region START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_genero START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_estado_civil START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_tipo_programa START WITH 1 INCREMENT BY 1;

-- Tabla 1 pais para relacionar la region con el país y el origen de la institución
CREATE TABLE pais (
    id_pais NUMBER PRIMARY KEY,
    nombre_pais VARCHAR2(100) NOT NULL UNIQUE
);

-- Tabla 2: region para determinar la región de residencia del postulante y ver la bonificacion de puntaje por donde estudia
CREATE TABLE region (
    id_region NUMBER PRIMARY KEY,
    nombre_region VARCHAR2(100) NOT NULL,
    id_pais NUMBER NOT NULL,
    FOREIGN KEY (id_pais) REFERENCES pais(id_pais)
);


-- Tabla 3: genero para determinar el género del postulante el cual se usara acorde a la ley de inclusión o no segun el país
CREATE TABLE genero (
    id_genero NUMBER PRIMARY KEY,
    desc_genero VARCHAR2(50) NOT NULL UNIQUE
);

-- Tabla 4: estado_civil para guardar el estado civil del postulante dado que hay beneficios por carga familiar
CREATE TABLE estado_civil (
    id_estado_civil NUMBER PRIMARY KEY,
    desc_estado VARCHAR2(50) NOT NULL UNIQUE
);

-- Tabla 5: tipo_documento, para guardar los tipos de documentos que se deben presentar
CREATE TABLE tipo_documento (
    id_tipo_documento NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    descripcion VARCHAR2(20) CHECK (descripcion IN ('OBLIGATORIO', 'OPCIONAL', 'BONIFICABLE','LIBRE','CERTIFICADO'))
);
-- Tabla 6: tipo_sistema, para guardar los tipos de sistema que se deben presentar
CREATE TABLE tipo_sistema (
    id_tipo_sistema NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    descripcion VARCHAR2(20) CHECK (descripcion IN ('PARAMETRIZADO', 'NO PARAMETRIZADO','ANUAL','BIMESTRAL','CUATRIMESTRAL'))
);
-- Tabla 7: documento, para guardar los documentos que se deben presentar, esta forma permite que sea dinamico
CREATE TABLE documento (
    id_documento NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre VARCHAR2(100),
    id_tipo_documento NUMBER NOT NULL,
    id_tipo_sistema NUMBER NOT NULL,
    FOREIGN KEY (id_tipo_documento) REFERENCES tipo_documento(id_tipo_documento),
    FOREIGN KEY (id_tipo_sistema) REFERENCES tipo_sistema(id_tipo_sistema)
);

-- Tabla 8: tipo_programa, becas de postgrado, programas y concursos, etc.
CREATE TABLE tipo_programa (
    id_tipo_programa NUMBER PRIMARY KEY,
    nombre_tipo VARCHAR2(100) NOT NULL UNIQUE
);

-- Tabla 9: area_programa Capital Humano, Proyectos de Investigación, Centros e Investigación Asociativa, Investigación Aplicada y Redes, Estrategia y Conocimiento
CREATE TABLE area_programa (
    id_area NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre_area VARCHAR2(100) NOT NULL UNIQUE
);

-- Tabla 10: programa_becas, características de los programas de becas
CREATE TABLE programa_becas (
    id_programa NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre_programa VARCHAR2(150) NOT NULL,
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE NOT NULL,
    id_area NUMBER NOT NULL,
    id_tipo_programa NUMBER NOT NULL,
    CONSTRAINT chk_fechas_programa CHECK (fecha_fin > fecha_inicio),
    FOREIGN KEY (id_area) REFERENCES area_programa(id_area),
    FOREIGN KEY (id_tipo_programa) REFERENCES tipo_programa(id_tipo_programa)
);

-- Tabla 11: institucion_destino, para guardar los datos de la institución a la cual postula el postulante
-- (nombre, país, ranking OCDE, url)
CREATE TABLE institucion_destino (
    id_institucion NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre_institucion VARCHAR2(150) NOT NULL,
    id_pais NUMBER NOT NULL,
    ranking_ocde NUMBER(4),
    puntaje_ocde NUMBER(5,3) DEFAULT NULL CHECK (puntaje_ocde IS NULL OR (puntaje_ocde >= 0 AND puntaje_ocde <= 5)), --Usuario administrador_system
    url VARCHAR2(250),
    FOREIGN KEY (id_pais) REFERENCES pais(id_pais)
);

-- Tabla 12: postulante para guardar los datos del postulante
CREATE TABLE postulante (
    id_postulante NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    rut_numero NUMBER(8) NOT NULL,
    rut_dv CHAR(1) NOT NULL,
    nombres VARCHAR2(100) NOT NULL,
    ap_paterno VARCHAR2(50) NOT NULL,
    ap_materno VARCHAR2(50),
    fecha_nacimiento DATE NOT NULL,
    correo_electronico VARCHAR2(100) NOT NULL,
    telefono_contacto VARCHAR2(20),
    nacionalidad VARCHAR2(30) NOT NULL,
    discapacidad VARCHAR2(30) DEFAULT NULL  CHECK (discapacidad IS NULL OR REGEXP_LIKE(discapacidad, '^[A-Z0-9]{6,}$')),
    beca_reparacion VARCHAR2(30) CHECK (beca_reparacion IS NULL OR REGEXP_LIKE(beca_reparacion, '^[A-Z0-9\\-/]{6,}$')),
    etnia VARCHAR2(40) CHECK (etnia IS NULL OR etnia IN ('Mapuche', 'Aymara', 'Rapa Nui', 'Atacameño', 'Diaguita','Colla', 'Quechua', 'Chango', 'Kawésqar', 'Yagán','Otro', 'No especificado')),
    id_genero NUMBER NOT NULL,
    id_estado_civil NUMBER NOT NULL,
    id_region_residencia NUMBER NOT NULL,
    id_region_titulacion NUMBER NOT NULL,
    fecha_registro DATE DEFAULT SYSDATE,
    nota_media_pregrado NUMBER(3, 2) DEFAULT null CHECK (nota_media_pregrado IS NULL OR (nota_media_pregrado >= 5 AND nota_media_pregrado <= 7)),--usuario verificador_notas
    posicion_ranking NUMBER(3,0) DEFAULT null, --Usuario verificador_notas
    total_egresados NUMBER(3,0) DEFAULT null,--Usuario verificador_notas
    puntaje_aa NUMBER(5, 3) DEFAULT null CHECK (puntaje_aa IS NULL OR (puntaje_aa >= 0 AND puntaje_aa <= 5)), --Usuario administrador_system
    CONSTRAINT chk_telefono_contacto CHECK (telefono_contacto IS NULL OR LENGTH(telefono_contacto) <= 20),
    CONSTRAINT chk_rut CHECK (rut_numero > 0 AND LENGTH(rut_numero) <= 8),
    FOREIGN KEY (id_genero) REFERENCES genero(id_genero),
    FOREIGN KEY (id_estado_civil) REFERENCES estado_civil(id_estado_civil),
    FOREIGN KEY (id_region_residencia) REFERENCES region(id_region),
    FOREIGN KEY (id_region_titulacion) REFERENCES region(id_region),
    CONSTRAINT uq_postulante_rut UNIQUE (rut_numero, rut_dv),
    CONSTRAINT chk_posicion_ranking CHECK (posicion_ranking IS NULL OR (posicion_ranking >= 1 AND total_egresados IS NOT NULL AND posicion_ranking <= total_egresados)
)

);


-- Tabla 13: estado_postulacion, para guardar los estados de la postulacion
-- (en espera, aceptado, rechazado, etc.)
CREATE TABLE estado_postulacion (
    id_estado NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    estado VARCHAR2(50) NOT NULL UNIQUE
);

-- Tabla 14: postulacion, para guardar los datos de la postulacion
-- (id_postulante, id_programa, id_institucion, id_estado, fecha_postulacion)
CREATE TABLE postulacion (
    id_postulacion NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_postulante NUMBER NOT NULL,
    id_programa NUMBER NOT NULL,
    id_institucion NUMBER NOT NULL,
    id_estado NUMBER NOT NULL,
    fecha_postulacion DATE NOT NULL,
    FOREIGN KEY (id_postulante) REFERENCES postulante(id_postulante),
    FOREIGN KEY (id_programa) REFERENCES programa_becas(id_programa),
    FOREIGN KEY (id_institucion) REFERENCES institucion_destino(id_institucion),
    FOREIGN KEY (id_estado) REFERENCES estado_postulacion(id_estado)
);



-- Tabla 15: documento_postulante, para guardar los documentos presentados por el postulante 
CREATE TABLE documento_presentado (
    id_documento_presentado NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_postulacion NUMBER NOT NULL,
    id_documento NUMBER NOT NULL,
    url_archivo VARCHAR2(255) NOT NULL,
    fecha_entrega DATE NOT NULL,
    FOREIGN KEY (id_postulacion) REFERENCES postulacion(id_postulacion),
    FOREIGN KEY (id_documento) REFERENCES documento(id_documento)
);


---- Tabla 19: Tabla evaluacion donde se ingreasan los datos evaluados que 
CREATE TABLE evalua_comite (
    id_postulacion NUMBER PRIMARY KEY,
    actividades NUMBER(1) NOT NULL CHECK (actividades IN (1,2,3,4,5)),
    experiencia NUMBER(1) NOT NULL CHECK (experiencia IN (1,2,3,4,5)),
    recomendacion NUMBER(1) NOT NULL CHECK (recomendacion IN (1,2,3,4,5)),
    objetivo NUMBER(1) NOT NULL CHECK (objetivo IN (1,2,3,4,5)),
    intereses NUMBER(1) NOT NULL CHECK (intereses IN (1,2,3,4,5)),
    retribucion NUMBER(1) NOT NULL CHECK (retribucion IN (1,2,3,4,5)),
    comentario VARCHAR2(200),
    CONSTRAINT fk_id_postulacion FOREIGN KEY (id_postulacion) REFERENCES postulacion(id_postulacion)
);

--Tabla 20: tabla configuracion_ocde para guardar la posicion chilena en el ranking OCDE
CREATE TABLE configuracion_ocde (
    id_config NUMBER PRIMARY KEY,
    posicion_chilena NUMBER NOT NULL
);

--Tabla 21: tabla ponderacion para guardar la ponderacion de los puntajes
CREATE TABLE ponderacion (
    id_ponderacion NUMBER PRIMARY KEY,
    posicion_chilena VARCHAR2(10) NOT NULL,
);

commit;


DROP FUNCTION calcular_puntaje_aa; -- Eliminar la función si existe
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
/
DROP TRIGGER trg_actualizar_puntaje_aa; -- Eliminar el trigger si existe
--trigger para actualizar el puntaje AA al insertar o actualizar los datos del postulante
CREATE OR REPLACE TRIGGER trg_actualizar_puntaje_aa
BEFORE INSERT OR UPDATE OF --no debe funcionar de esta forma ya que los campos deben actualizarse solo en update pero para casosopracticos lo hago asi
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
    :NEW.puntaje_aa := calcular_puntaje_aa(
        :NEW.nota_media_pregrado,
        :NEW.posicion_ranking,
        :NEW.total_egresados
    );
END;
/
DROP TRIGGER trg_actualizar_puntaje_aa; -- Eliminar el trigger si existe
--asi deberia quedar
CREATE OR REPLACE TRIGGER trg_actualizar_puntaje_aa
BEFORE UPDATE ON postulante
FOR EACH ROW
BEGIN
    IF :NEW.nota_media_pregrado IS NOT NULL AND 
       :NEW.posicion_ranking IS NOT NULL AND 
       :NEW.total_egresados IS NOT NULL THEN

        :NEW.puntaje_aa := calcular_puntaje_aa(
            :NEW.nota_media_pregrado,
            :NEW.posicion_ranking,
            :NEW.total_egresados
        );
    END IF;
END;
/
--para entregar

DROP FUNCTION calcular_puntaje_ocde; -- Eliminar la función si existe
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
/

DROP TRIGGER trg_actualizar_puntaje_ocde; -- Eliminar el trigger si existe
-- Trigger para actualizar el puntaje OCDE al insertar o actualizar los datos del postulante
CREATE OR REPLACE TRIGGER trg_actualizar_puntaje_ocde
BEFORE INSERT OR UPDATE OF ranking_ocde
ON institucion_destino
FOR EACH ROW
WHEN (NEW.ranking_ocde IS NOT NULL)
BEGIN
    :NEW.puntaje_ocde := calcular_puntaje_ocde(:NEW.ranking_ocde);
END;
/
DROP TRIGGER trg_recalcular_puntaje_ocde_global;
-- Trigger para recalcular el puntaje OCDE global al actualizar la posición chilena
CREATE OR REPLACE TRIGGER trg_recalcular_puntaje_ocde_global
AFTER UPDATE OF posicion_chilena ON configuracion_ocde
FOR EACH ROW
BEGIN
    -- Recalcular los puntajes de todas las instituciones
    UPDATE institucion_destino
    SET puntaje_ocde = calcular_puntaje_ocde(ranking_ocde)
    WHERE ranking_ocde IS NOT NULL;
END;
/

COMMIT;
--Dato para calcular los puntajes de las instituciones extranjeras
INSERT INTO configuracion_ocde(id_config,posicion_chilena) VALUES (1,101);
--Tabla 1
INSERT INTO pais (id_pais, nombre_pais) VALUES (seq_pais.NEXTVAL, 'Chile');
INSERT INTO pais (id_pais, nombre_pais) VALUES (seq_pais.NEXTVAL, 'USA');
INSERT INTO pais (id_pais, nombre_pais) VALUES (seq_pais.NEXTVAL, 'Australia');
INSERT INTO pais (id_pais, nombre_pais) VALUES (seq_pais.NEXTVAL, 'España');
INSERT INTO pais (id_pais, nombre_pais) VALUES (seq_pais.NEXTVAL, 'Canadá');
--Tabla 2
INSERT INTO region (id_region, nombre_region, id_pais) VALUES (seq_region.NEXTVAL, 'Región Metropolitana', 1);
INSERT INTO region (id_region, nombre_region, id_pais) VALUES (seq_region.NEXTVAL, 'Valparaíso', 1);
INSERT INTO region (id_region, nombre_region, id_pais) VALUES (seq_region.NEXTVAL, 'Biobío', 1);
INSERT INTO region (id_region, nombre_region, id_pais) VALUES (seq_region.NEXTVAL, 'Antofagasta', 1);
INSERT INTO region (id_region, nombre_region, id_pais) VALUES (seq_region.NEXTVAL, 'Los Lagos', 1);
--Tabla 3
INSERT INTO genero (id_genero, desc_genero) VALUES (seq_genero.NEXTVAL, 'Masculino');
INSERT INTO genero (id_genero, desc_genero) VALUES (seq_genero.NEXTVAL, 'Femenino');
INSERT INTO genero (id_genero, desc_genero) VALUES (seq_genero.NEXTVAL, 'No binario');
INSERT INTO genero (id_genero, desc_genero) VALUES (seq_genero.NEXTVAL, 'Otro');
INSERT INTO genero (id_genero, desc_genero) VALUES (seq_genero.NEXTVAL, 'Prefiere no decir');
--Tabla 4
INSERT INTO estado_civil (id_estado_civil, desc_estado) VALUES (seq_estado_civil.NEXTVAL, 'Soltero');
INSERT INTO estado_civil (id_estado_civil, desc_estado) VALUES (seq_estado_civil.NEXTVAL, 'Casado');
INSERT INTO estado_civil (id_estado_civil, desc_estado) VALUES (seq_estado_civil.NEXTVAL, 'Divorciado');
INSERT INTO estado_civil (id_estado_civil, desc_estado) VALUES (seq_estado_civil.NEXTVAL, 'Viudo');
INSERT INTO estado_civil (id_estado_civil, desc_estado) VALUES (seq_estado_civil.NEXTVAL, 'Conviviente');
--Tabla 5
INSERT INTO estado_postulacion (estado) VALUES ('En revisión');
INSERT INTO estado_postulacion (estado) VALUES ('Seleccionada');
INSERT INTO estado_postulacion (estado) VALUES ('Rechazado');
INSERT INTO estado_postulacion (estado) VALUES ('Nuevo requerimiento');
INSERT INTO estado_postulacion (estado) VALUES ('En proceso');
--Tabla 7
INSERT INTO tipo_programa (id_tipo_programa, nombre_tipo) VALUES (seq_tipo_programa.NEXTVAL, 'Becas de Postgrado');
INSERT INTO tipo_programa (id_tipo_programa, nombre_tipo) VALUES (seq_tipo_programa.NEXTVAL, 'Programas');
INSERT INTO tipo_programa (id_tipo_programa, nombre_tipo) VALUES (seq_tipo_programa.NEXTVAL, 'Concursos');
INSERT INTO tipo_programa (id_tipo_programa, nombre_tipo) VALUES (seq_tipo_programa.NEXTVAL, 'Convenios');
INSERT INTO tipo_programa (id_tipo_programa, nombre_tipo) VALUES (seq_tipo_programa.NEXTVAL, 'Ayudas Académicas');
--Tabla 9
INSERT INTO area_programa (nombre_area) VALUES ('Capital Humano');
INSERT INTO area_programa (nombre_area) VALUES ('Proyectos de Investigación');
INSERT INTO area_programa (nombre_area) VALUES ('Centros e Investigación Asociativa');
INSERT INTO area_programa (nombre_area) VALUES ('Investigación Aplicada');
INSERT INTO area_programa (nombre_area) VALUES ('Redes');
INSERT INTO area_programa (nombre_area) VALUES ('Estrategia y Conocimiento');
--Tabla 6
INSERT INTO programa_becas (nombre_programa, fecha_inicio, fecha_fin, id_area, id_tipo_programa) VALUES ('Programa Beca 1', TO_DATE('2024-03-01','YYYY-MM-DD'), TO_DATE('2024-08-28','YYYY-MM-DD'), 3, 3);
INSERT INTO programa_becas (nombre_programa, fecha_inicio, fecha_fin, id_area, id_tipo_programa) VALUES ('Programa Beca 2', TO_DATE('2024-05-01','YYYY-MM-DD'), TO_DATE('2024-10-28','YYYY-MM-DD'), 1, 1);
INSERT INTO programa_becas (nombre_programa, fecha_inicio, fecha_fin, id_area, id_tipo_programa) VALUES ('Programa Beca 3', TO_DATE('2024-06-01','YYYY-MM-DD'), TO_DATE('2024-12-28','YYYY-MM-DD'), 5, 2);
INSERT INTO programa_becas (nombre_programa, fecha_inicio, fecha_fin, id_area, id_tipo_programa) VALUES ('Beca Chile 2025', TO_DATE('2024-02-01','YYYY-MM-DD'), TO_DATE('2024-07-28','YYYY-MM-DD'), 1, 1);
INSERT INTO programa_becas (nombre_programa, fecha_inicio, fecha_fin, id_area, id_tipo_programa) VALUES ('Beca Internacional 2025', TO_DATE('2024-03-01','YYYY-MM-DD'), TO_DATE('2024-08-28','YYYY-MM-DD'), 2, 2);
COMMIT; --PARA TRABAJAR EL VALOR INGRESADO EN LA TABLA configuracion_ocde Y ASI REALIZAR EL CALCULO CON EL TRIGGER Y LA FUNCION
--Tabla 7
INSERT INTO institucion_destino (nombre_institucion, id_pais, ranking_ocde, url) VALUES ('Harvard', 2, 1,'https://www.harvard.edu/');
INSERT INTO institucion_destino (nombre_institucion, id_pais, ranking_ocde, url) VALUES ('MIT', 2, 4, 'https://www.mit.edu/');
INSERT INTO institucion_destino (nombre_institucion, id_pais, ranking_ocde, url) VALUES ('Complutense de Madrid', 4, 34, 'https://www.ucm.es/');
INSERT INTO institucion_destino (nombre_institucion, id_pais, ranking_ocde, url) VALUES ('University of Oxford',  5, 3, 'https://www.ox.ac.uk/');
INSERT INTO institucion_destino (nombre_institucion, id_pais, ranking_ocde, url) VALUES ('University Toronto', 2, 8, 'https://www.utoronto.ca/');
--Tabla 10
INSERT INTO tipo_documento (descripcion) VALUES ('OBLIGATORIO');
INSERT INTO tipo_documento (descripcion) VALUES ('OPCIONAL');
INSERT INTO tipo_documento (descripcion) VALUES ('BONIFICABLE');
INSERT INTO tipo_documento (descripcion) VALUES ('LIBRE');
INSERT INTO tipo_documento (descripcion) VALUES ('CERTIFICADO');
--Tabla 11
INSERT INTO tipo_sistema (descripcion) VALUES ('PARAMETRIZADO');
INSERT INTO tipo_sistema (descripcion) VALUES ('NO PARAMETRIZADO');
INSERT INTO tipo_sistema (descripcion) VALUES ('ANUAL');
INSERT INTO tipo_sistema (descripcion) VALUES ('BIMESTRAL');
INSERT INTO tipo_sistema (descripcion) VALUES ('CUATRIMESTRAL');
COMMIT;
--Tabla 15
INSERT INTO postulante (rut_numero, rut_dv, nombres, ap_paterno, ap_materno, fecha_nacimiento, correo_electronico, telefono_contacto, nacionalidad, discapacidad, id_genero, id_estado_civil, id_region_residencia, id_region_titulacion) VALUES (15006225, '4', 'Genoveva', 'Ojeda', 'Pineda', TO_DATE('1995-02-22','YYYY-MM-DD'), 'drios@bellido.org', '+34956333843', 'Chilena', '', 1, 1, 3, 1);
INSERT INTO postulante (rut_numero, rut_dv, nombres, ap_paterno, ap_materno, fecha_nacimiento, correo_electronico, telefono_contacto, nacionalidad, discapacidad, id_genero, id_estado_civil, id_region_residencia, id_region_titulacion) VALUES (20766437, '7', 'Priscila', 'Mateos', 'Arce', TO_DATE('1986-11-03','YYYY-MM-DD'), 'iglesiatania@bautista.com', '+34 724124489', 'Chilena', '', 2, 2, 3, 3);
INSERT INTO postulante (rut_numero, rut_dv, nombres, ap_paterno, ap_materno, fecha_nacimiento, correo_electronico, telefono_contacto, nacionalidad, discapacidad, id_genero, id_estado_civil, id_region_residencia, id_region_titulacion) VALUES (25822756, '0', 'Donato', 'Gámez', 'Pinedo', TO_DATE('2000-01-11','YYYY-MM-DD'), 'eanaya@yahoo.com', '+34889782938', 'Chilena', '', 2, 2, 1, 3);
INSERT INTO postulante (rut_numero, rut_dv, nombres, ap_paterno, ap_materno, fecha_nacimiento, correo_electronico, telefono_contacto, nacionalidad, discapacidad, id_genero, id_estado_civil, id_region_residencia, id_region_titulacion) VALUES (25072703, '0', 'Alfredo', 'Robles', 'Blanch', TO_DATE('1987-05-04','YYYY-MM-DD'), 'barbamaura@vives.org', '+34717 491 544', 'Chilena', '', 2, 2, 1, 1);
INSERT INTO postulante (rut_numero, rut_dv, nombres, ap_paterno, ap_materno, fecha_nacimiento, correo_electronico, telefono_contacto, nacionalidad, discapacidad, id_genero, id_estado_civil, id_region_residencia, id_region_titulacion) VALUES (26514443, '5', 'Felipa', 'Berenguer', 'Navas', TO_DATE('2000-04-12','YYYY-MM-DD'), 'bmata@yahoo.com', '+34707948874', 'Chilena', 'Visual', 2, 2, 1, 1);
INSERT INTO postulante (rut_numero, rut_dv, nombres, ap_paterno, ap_materno, fecha_nacimiento, correo_electronico, telefono_contacto, nacionalidad, discapacidad, id_genero, id_estado_civil, id_region_residencia, id_region_titulacion) VALUES (23592425, '1', 'Lilia', 'Alberola', 'Belmonte', TO_DATE('1991-11-19','YYYY-MM-DD'), 'ktalavera@gmail.com', '+34729 249 911', 'Chilena', '', 2, 1, 2, 2);
INSERT INTO postulante (rut_numero, rut_dv, nombres, ap_paterno, ap_materno, fecha_nacimiento, correo_electronico, telefono_contacto, nacionalidad, discapacidad, id_genero, id_estado_civil, id_region_residencia, id_region_titulacion) VALUES (17443478, '0', 'Íngrid', 'Hurtado', 'Iniesta', TO_DATE('1988-11-20','YYYY-MM-DD'), 'oguijarro@yahoo.com', '+34 707 997 749', 'Chilena', '', 2, 2, 2, 2);
INSERT INTO postulante (rut_numero, rut_dv, nombres, ap_paterno, ap_materno, fecha_nacimiento, correo_electronico, telefono_contacto, nacionalidad, discapacidad, id_genero, id_estado_civil, id_region_residencia, id_region_titulacion) VALUES (13501709, 'K', 'Sandra', 'Araujo', 'Bauzà', TO_DATE('2001-07-21','YYYY-MM-DD'), 'bzamora@gracia.com', '+34 894 45 24 77', 'Chilena', '', 1, 2, 2, 3);
INSERT INTO postulante (rut_numero, rut_dv, nombres, ap_paterno, ap_materno, fecha_nacimiento, correo_electronico, telefono_contacto, nacionalidad, discapacidad, id_genero, id_estado_civil, id_region_residencia, id_region_titulacion) VALUES (15607658, '0', 'Narciso', 'Palomares', 'Torre', TO_DATE('1991-04-03','YYYY-MM-DD'), 'amadorriquelme@gmail.com', '+34709240112', 'Chilena', 'Auditiva', 2, 1, 1, 3);
INSERT INTO postulante (rut_numero, rut_dv, nombres, ap_paterno, ap_materno, fecha_nacimiento, correo_electronico, telefono_contacto, nacionalidad, discapacidad, id_genero, id_estado_civil, id_region_residencia, id_region_titulacion) VALUES (24109551, '0', 'Amelia', 'Alberto', 'Robledo', TO_DATE('1994-01-03','YYYY-MM-DD'), 'lurena@solano-peralta.com', '+34743 71 61 88', 'Chilena', '', 1, 2, 3, 3);
commit;
UPDATE postulante SET nota_media_pregrado = 5.5, posicion_ranking = 15, total_egresados = 30 WHERE rut_numero = 15006225;
UPDATE postulante SET nota_media_pregrado = 6.3, posicion_ranking = 10, total_egresados = 45 WHERE rut_numero = 20766437;
UPDATE postulante SET nota_media_pregrado = 5.8, posicion_ranking = 4, total_egresados = 35 WHERE rut_numero = 25822756;
UPDATE postulante SET nota_media_pregrado = 5.5, posicion_ranking = 6, total_egresados = 45 WHERE rut_numero = 25072703;
UPDATE postulante SET nota_media_pregrado = 6.3, posicion_ranking = 10, total_egresados = 50 WHERE rut_numero = 26514443;
UPDATE postulante SET nota_media_pregrado = 5.8, posicion_ranking = 8, total_egresados = 35 WHERE rut_numero = 17443478;
UPDATE postulante SET nota_media_pregrado = 5.5, posicion_ranking = 9, total_egresados = 37 WHERE rut_numero = 13501709;
UPDATE postulante SET nota_media_pregrado = 6.3, posicion_ranking = 11, total_egresados = 50 WHERE rut_numero = 15607658;
UPDATE postulante SET nota_media_pregrado = 5.8, posicion_ranking = 14, total_egresados = 35 WHERE rut_numero = 24109551;
UPDATE postulante SET nota_media_pregrado = 5.8, posicion_ranking = 18, total_egresados = 35 WHERE rut_numero = 23592425;
commit;
--Tabla 16
INSERT INTO documento (nombre, id_tipo_documento, id_tipo_sistema) VALUES ('Formulario de postulación y currículum vitae', 1, 2);
INSERT INTO documento (nombre, id_tipo_documento, id_tipo_sistema) VALUES ('Copia Cédula de Identidad', 1, 2);
INSERT INTO documento (nombre, id_tipo_documento, id_tipo_sistema) VALUES ('Carta de aceptación al programa', 1, 1);
INSERT INTO documento (nombre, id_tipo_documento, id_tipo_sistema) VALUES ('Certificado de Alumno regular', 1, 2);
INSERT INTO documento (nombre, id_tipo_documento, id_tipo_sistema) VALUES ('Copia de Título Profesional', 1, 1);
INSERT INTO documento (nombre, id_tipo_documento, id_tipo_sistema) VALUES ('Certificado de ranking de egreso', 2, 2);
INSERT INTO documento (nombre, id_tipo_documento, id_tipo_sistema) VALUES ('Certificado de notas final', 2, 2);
INSERT INTO documento (nombre, id_tipo_documento, id_tipo_sistema) VALUES ('Certificado de vigencia de permanencia definitiva', 2, 2);
INSERT INTO documento (nombre, id_tipo_documento, id_tipo_sistema) VALUES ('Sección Socioeconómica', 2, 2);
INSERT INTO documento (nombre, id_tipo_documento, id_tipo_sistema) VALUES ('Certificados de idioma', 2, 1);
INSERT INTO documento (nombre, id_tipo_documento, id_tipo_sistema) VALUES ('Cartas de Recomendación', 2, 2);
INSERT INTO documento (nombre, id_tipo_documento, id_tipo_sistema) VALUES ('Certificado de ETNIA', 3, 2);
INSERT INTO documento (nombre, id_tipo_documento, id_tipo_sistema) VALUES ('Certificado Discapacidad', 3, 2);
INSERT INTO documento (nombre, id_tipo_documento, id_tipo_sistema) VALUES ('Concentración de notas otros postgrados', 1, 2);
INSERT INTO documento (nombre, id_tipo_documento, id_tipo_sistema) VALUES ('Certificado de CONADI', 2, 2);

COMMIT; --NECESARIO PARA TRAER LAS FK DE OTRAS TABLAS QUE NECESITA
--Tabla 17
INSERT INTO postulacion (id_postulante, id_programa, id_institucion, id_estado, fecha_postulacion) VALUES (1, 1, 1, 5, TO_DATE('2024-04-03','YYYY-MM-DD'));
INSERT INTO postulacion (id_postulante, id_programa, id_institucion, id_estado, fecha_postulacion) VALUES (2, 2, 2, 5, TO_DATE('2024-04-11','YYYY-MM-DD'));
INSERT INTO postulacion (id_postulante, id_programa, id_institucion, id_estado, fecha_postulacion) VALUES (3, 3, 3, 5, TO_DATE('2024-04-19','YYYY-MM-DD'));
INSERT INTO postulacion (id_postulante, id_programa, id_institucion, id_estado, fecha_postulacion) VALUES (4, 1, 1, 5, TO_DATE('2024-04-14','YYYY-MM-DD'));
INSERT INTO postulacion (id_postulante, id_programa, id_institucion, id_estado, fecha_postulacion) VALUES (5, 2, 2, 5, TO_DATE('2024-04-05','YYYY-MM-DD'));
INSERT INTO postulacion (id_postulante, id_programa, id_institucion, id_estado, fecha_postulacion) VALUES (6, 3, 3, 5, TO_DATE('2024-04-21','YYYY-MM-DD'));
INSERT INTO postulacion (id_postulante, id_programa, id_institucion, id_estado, fecha_postulacion) VALUES (7, 1, 1, 5, TO_DATE('2024-04-27','YYYY-MM-DD'));
INSERT INTO postulacion (id_postulante, id_programa, id_institucion, id_estado, fecha_postulacion) VALUES (8, 2, 2, 5, TO_DATE('2024-04-10','YYYY-MM-DD'));
INSERT INTO postulacion (id_postulante, id_programa, id_institucion, id_estado, fecha_postulacion) VALUES (9, 3, 3, 5, TO_DATE('2024-04-24','YYYY-MM-DD'));
INSERT INTO postulacion (id_postulante, id_programa, id_institucion, id_estado, fecha_postulacion) VALUES (10, 1, 1,5, TO_DATE('2024-04-12','YYYY-MM-DD'));
COMMIT;
--Tabla 18
INSERT INTO documento_presentado (id_postulacion, id_documento, url_archivo, fecha_entrega) VALUES (1, 1, 'https://archivo.com/doc_1.pdf', TO_DATE('2024-04-25', 'YYYY-MM-DD'));
INSERT INTO documento_presentado (id_postulacion, id_documento, url_archivo, fecha_entrega) VALUES (1, 2, 'https://archivo.com/doc_2.pdf', TO_DATE('2024-04-14', 'YYYY-MM-DD'));
INSERT INTO documento_presentado (id_postulacion, id_documento, url_archivo, fecha_entrega) VALUES (1, 3, 'https://archivo.com/doc_3.pdf', TO_DATE('2024-04-13', 'YYYY-MM-DD'));
INSERT INTO documento_presentado (id_postulacion, id_documento, url_archivo, fecha_entrega) VALUES (1, 4, 'https://archivo.com/doc_4.pdf', TO_DATE('2024-04-18', 'YYYY-MM-DD'));
INSERT INTO documento_presentado (id_postulacion, id_documento, url_archivo, fecha_entrega) VALUES (1, 5, 'https://archivo.com/doc_5.pdf', TO_DATE('2024-04-21', 'YYYY-MM-DD'));
INSERT INTO documento_presentado (id_postulacion, id_documento, url_archivo, fecha_entrega) VALUES (1, 12, 'https://archivo.com/doc_6.pdf', TO_DATE('2024-04-05', 'YYYY-MM-DD'));
INSERT INTO documento_presentado (id_postulacion, id_documento, url_archivo, fecha_entrega) VALUES (2, 1, 'https://archivo.com/doc_7.pdf', TO_DATE('2024-04-12', 'YYYY-MM-DD'));
INSERT INTO documento_presentado (id_postulacion, id_documento, url_archivo, fecha_entrega) VALUES (2, 2, 'https://archivo.com/doc_8.pdf', TO_DATE('2024-04-22', 'YYYY-MM-DD'));
INSERT INTO documento_presentado (id_postulacion, id_documento, url_archivo, fecha_entrega) VALUES (2, 3, 'https://archivo.com/doc_9.pdf', TO_DATE('2024-04-02', 'YYYY-MM-DD'));
INSERT INTO documento_presentado (id_postulacion, id_documento, url_archivo, fecha_entrega) VALUES (2, 4, 'https://archivo.com/doc_10.pdf', TO_DATE('2024-04-28', 'YYYY-MM-DD'));
INSERT INTO documento_presentado (id_postulacion, id_documento, url_archivo, fecha_entrega) VALUES (2, 5, 'https://archivo.com/doc_11.pdf', TO_DATE('2024-04-05', 'YYYY-MM-DD'));
INSERT INTO documento_presentado (id_postulacion, id_documento, url_archivo, fecha_entrega) VALUES (2, 6, 'https://archivo.com/doc_12.pdf', TO_DATE('2024-04-11', 'YYYY-MM-DD'));
INSERT INTO documento_presentado (id_postulacion, id_documento, url_archivo, fecha_entrega) VALUES (2, 13, 'https://archivo.com/doc_13.pdf', TO_DATE('2024-04-01', 'YYYY-MM-DD'));
INSERT INTO documento_presentado (id_postulacion, id_documento, url_archivo, fecha_entrega) VALUES (3, 1, 'https://archivo.com/doc_14.pdf', TO_DATE('2024-04-11', 'YYYY-MM-DD'));
INSERT INTO documento_presentado (id_postulacion, id_documento, url_archivo, fecha_entrega) VALUES (3, 2, 'https://archivo.com/doc_15.pdf', TO_DATE('2024-04-07', 'YYYY-MM-DD'));
INSERT INTO documento_presentado (id_postulacion, id_documento, url_archivo, fecha_entrega) VALUES (3, 3, 'https://archivo.com/doc_16.pdf', TO_DATE('2024-04-21', 'YYYY-MM-DD'));
INSERT INTO documento_presentado (id_postulacion, id_documento, url_archivo, fecha_entrega) VALUES (3, 4, 'https://archivo.com/doc_17.pdf', TO_DATE('2024-04-08', 'YYYY-MM-DD'));
INSERT INTO documento_presentado (id_postulacion, id_documento, url_archivo, fecha_entrega) VALUES (3, 5, 'https://archivo.com/doc_18.pdf', TO_DATE('2024-04-06', 'YYYY-MM-DD'));
INSERT INTO documento_presentado (id_postulacion, id_documento, url_archivo, fecha_entrega) VALUES (4, 1, 'https://archivo.com/doc_19.pdf', TO_DATE('2024-04-27', 'YYYY-MM-DD'));
INSERT INTO documento_presentado (id_postulacion, id_documento, url_archivo, fecha_entrega) VALUES (4, 2, 'https://archivo.com/doc_20.pdf', TO_DATE('2024-04-20', 'YYYY-MM-DD'));
INSERT INTO documento_presentado (id_postulacion, id_documento, url_archivo, fecha_entrega) VALUES (4, 3, 'https://archivo.com/doc_20.pdf', TO_DATE('2024-04-20', 'YYYY-MM-DD'));
INSERT INTO documento_presentado (id_postulacion, id_documento, url_archivo, fecha_entrega) VALUES (4, 4, 'https://archivo.com/doc_20.pdf', TO_DATE('2024-04-20', 'YYYY-MM-DD'));
INSERT INTO documento_presentado (id_postulacion, id_documento, url_archivo, fecha_entrega) VALUES (4, 5, 'https://archivo.com/doc_20.pdf', TO_DATE('2024-04-20', 'YYYY-MM-DD'));
INSERT INTO documento_presentado (id_postulacion, id_documento, url_archivo, fecha_entrega) VALUES (5, 1, 'https://archivo.com/doc_1.pdf', TO_DATE('2024-04-25', 'YYYY-MM-DD'));
INSERT INTO documento_presentado (id_postulacion, id_documento, url_archivo, fecha_entrega) VALUES (5, 2, 'https://archivo.com/doc_2.pdf', TO_DATE('2024-04-14', 'YYYY-MM-DD'));
INSERT INTO documento_presentado (id_postulacion, id_documento, url_archivo, fecha_entrega) VALUES (5, 3, 'https://archivo.com/doc_3.pdf', TO_DATE('2024-04-13', 'YYYY-MM-DD'));
INSERT INTO documento_presentado (id_postulacion, id_documento, url_archivo, fecha_entrega) VALUES (5, 4, 'https://archivo.com/doc_4.pdf', TO_DATE('2024-04-18', 'YYYY-MM-DD'));
INSERT INTO documento_presentado (id_postulacion, id_documento, url_archivo, fecha_entrega) VALUES (5, 5, 'https://archivo.com/doc_5.pdf', TO_DATE('2024-04-21', 'YYYY-MM-DD'));
INSERT INTO documento_presentado (id_postulacion, id_documento, url_archivo, fecha_entrega) VALUES (5, 12, 'https://archivo.com/doc_6.pdf', TO_DATE('2024-04-05', 'YYYY-MM-DD'));
INSERT INTO documento_presentado (id_postulacion, id_documento, url_archivo, fecha_entrega) VALUES (6, 1, 'https://archivo.com/doc_7.pdf', TO_DATE('2024-04-12', 'YYYY-MM-DD'));
INSERT INTO documento_presentado (id_postulacion, id_documento, url_archivo, fecha_entrega) VALUES (6, 2, 'https://archivo.com/doc_8.pdf', TO_DATE('2024-04-22', 'YYYY-MM-DD'));
INSERT INTO documento_presentado (id_postulacion, id_documento, url_archivo, fecha_entrega) VALUES (6, 3, 'https://archivo.com/doc_9.pdf', TO_DATE('2024-04-02', 'YYYY-MM-DD'));
INSERT INTO documento_presentado (id_postulacion, id_documento, url_archivo, fecha_entrega) VALUES (6, 4, 'https://archivo.com/doc_10.pdf', TO_DATE('2024-04-28', 'YYYY-MM-DD'));
INSERT INTO documento_presentado (id_postulacion, id_documento, url_archivo, fecha_entrega) VALUES (6, 5, 'https://archivo.com/doc_11.pdf', TO_DATE('2024-04-05', 'YYYY-MM-DD'));
INSERT INTO documento_presentado (id_postulacion, id_documento, url_archivo, fecha_entrega) VALUES (6, 6, 'https://archivo.com/doc_12.pdf', TO_DATE('2024-04-11', 'YYYY-MM-DD'));
INSERT INTO documento_presentado (id_postulacion, id_documento, url_archivo, fecha_entrega) VALUES (6, 13, 'https://archivo.com/doc_13.pdf', TO_DATE('2024-04-01', 'YYYY-MM-DD'));
INSERT INTO documento_presentado (id_postulacion, id_documento, url_archivo, fecha_entrega) VALUES (7, 1, 'https://archivo.com/doc_14.pdf', TO_DATE('2024-04-11', 'YYYY-MM-DD'));
INSERT INTO documento_presentado (id_postulacion, id_documento, url_archivo, fecha_entrega) VALUES (7, 2, 'https://archivo.com/doc_15.pdf', TO_DATE('2024-04-07', 'YYYY-MM-DD'));
INSERT INTO documento_presentado (id_postulacion, id_documento, url_archivo, fecha_entrega) VALUES (7, 3, 'https://archivo.com/doc_16.pdf', TO_DATE('2024-04-21', 'YYYY-MM-DD'));
INSERT INTO documento_presentado (id_postulacion, id_documento, url_archivo, fecha_entrega) VALUES (7, 4, 'https://archivo.com/doc_17.pdf', TO_DATE('2024-04-08', 'YYYY-MM-DD'));
INSERT INTO documento_presentado (id_postulacion, id_documento, url_archivo, fecha_entrega) VALUES (7, 5, 'https://archivo.com/doc_18.pdf', TO_DATE('2024-04-06', 'YYYY-MM-DD'));
INSERT INTO documento_presentado (id_postulacion, id_documento, url_archivo, fecha_entrega) VALUES (8, 1, 'https://archivo.com/doc_19.pdf', TO_DATE('2024-04-27', 'YYYY-MM-DD'));
INSERT INTO documento_presentado (id_postulacion, id_documento, url_archivo, fecha_entrega) VALUES (8, 2, 'https://archivo.com/doc_20.pdf', TO_DATE('2024-04-20', 'YYYY-MM-DD'));
INSERT INTO documento_presentado (id_postulacion, id_documento, url_archivo, fecha_entrega) VALUES (8, 3, 'https://archivo.com/doc_20.pdf', TO_DATE('2024-04-20', 'YYYY-MM-DD'));
INSERT INTO documento_presentado (id_postulacion, id_documento, url_archivo, fecha_entrega) VALUES (8, 4, 'https://archivo.com/doc_20.pdf', TO_DATE('2024-04-20', 'YYYY-MM-DD'));
INSERT INTO documento_presentado (id_postulacion, id_documento, url_archivo, fecha_entrega) VALUES (8, 5, 'https://archivo.com/doc_20.pdf', TO_DATE('2024-04-20', 'YYYY-MM-DD'));
INSERT INTO documento_presentado (id_postulacion, id_documento, url_archivo, fecha_entrega) VALUES (9, 1, 'https://archivo.com/doc_14.pdf', TO_DATE('2024-04-11', 'YYYY-MM-DD'));
INSERT INTO documento_presentado (id_postulacion, id_documento, url_archivo, fecha_entrega) VALUES (9, 2, 'https://archivo.com/doc_15.pdf', TO_DATE('2024-04-07', 'YYYY-MM-DD'));
INSERT INTO documento_presentado (id_postulacion, id_documento, url_archivo, fecha_entrega) VALUES (9, 3, 'https://archivo.com/doc_16.pdf', TO_DATE('2024-04-21', 'YYYY-MM-DD'));
INSERT INTO documento_presentado (id_postulacion, id_documento, url_archivo, fecha_entrega) VALUES (9, 4, 'https://archivo.com/doc_17.pdf', TO_DATE('2024-04-08', 'YYYY-MM-DD'));
INSERT INTO documento_presentado (id_postulacion, id_documento, url_archivo, fecha_entrega) VALUES (9, 5, 'https://archivo.com/doc_18.pdf', TO_DATE('2024-04-06', 'YYYY-MM-DD'));
INSERT INTO documento_presentado (id_postulacion, id_documento, url_archivo, fecha_entrega) VALUES (10, 1, 'https://archivo.com/doc_19.pdf', TO_DATE('2024-04-27', 'YYYY-MM-DD'));
INSERT INTO documento_presentado (id_postulacion, id_documento, url_archivo, fecha_entrega) VALUES (10, 2, 'https://archivo.com/doc_20.pdf', TO_DATE('2024-04-20', 'YYYY-MM-DD'));
INSERT INTO documento_presentado (id_postulacion, id_documento, url_archivo, fecha_entrega) VALUES (10, 3, 'https://archivo.com/doc_20.pdf', TO_DATE('2024-04-20', 'YYYY-MM-DD'));
INSERT INTO documento_presentado (id_postulacion, id_documento, url_archivo, fecha_entrega) VALUES (10, 4, 'https://archivo.com/doc_20.pdf', TO_DATE('2024-04-20', 'YYYY-MM-DD'));
INSERT INTO documento_presentado (id_postulacion, id_documento, url_archivo, fecha_entrega) VALUES (10, 5, 'https://archivo.com/doc_20.pdf', TO_DATE('2024-04-20', 'YYYY-MM-DD'));
COMMIT;
--Tabla 19
INSERT INTO evalua_comite (id_postulacion, actividades, experiencia, recomendacion, objetivo, intereses, retribucion, comentario) VALUES (1, 3, 3, 1, 1, 1, 5, 'El postulante tararara..');
INSERT INTO evalua_comite (id_postulacion, actividades, experiencia, recomendacion, objetivo, intereses, retribucion, comentario) VALUES (2, 4, 2, 2, 2, 2, 3, 'El postulante tararara..');
INSERT INTO evalua_comite (id_postulacion, actividades, experiencia, recomendacion, objetivo, intereses, retribucion, comentario) VALUES (3, 3, 1, 3, 3, 3, 2, 'El postulante tararara..');
INSERT INTO evalua_comite (id_postulacion, actividades, experiencia, recomendacion, objetivo, intereses, retribucion, comentario) VALUES (4, 4, 1, 4, 4, 4, 3, 'El postulante tararara..');
INSERT INTO evalua_comite (id_postulacion, actividades, experiencia, recomendacion, objetivo, intereses, retribucion, comentario) VALUES (5, 3, 5, 5, 5, 5, 2, 'El postulante tararara..');
INSERT INTO evalua_comite (id_postulacion, actividades, experiencia, recomendacion, objetivo, intereses, retribucion, comentario) VALUES (6, 4, 4, 1, 1, 1, 2, 'El postulante tararara..');
INSERT INTO evalua_comite (id_postulacion, actividades, experiencia, recomendacion, objetivo, intereses, retribucion, comentario) VALUES (7, 3, 3, 2, 2, 2, 2, 'El postulante tararara..');
INSERT INTO evalua_comite (id_postulacion, actividades, experiencia, recomendacion, objetivo, intereses, retribucion, comentario) VALUES (8, 4, 4, 3, 3, 3, 3, 'El postulante tararara..');
INSERT INTO evalua_comite (id_postulacion, actividades, experiencia, recomendacion, objetivo, intereses, retribucion, comentario) VALUES (9, 1, 5, 4, 4, 4, 4, 'El postulante tararara..');
INSERT INTO evalua_comite (id_postulacion, actividades, experiencia, recomendacion, objetivo, intereses, retribucion, comentario) VALUES (10, 2, 5, 5, 5, 5, 5, 'El postulante tararara..');
--Tabla 20
INSERT INTO ponderacion (id_ponderacion, descripcion) VALUES (0,"No califica");
INSERT INTO ponderacion (id_ponderacion, descripcion) VALUES (1,"Deficiente");
INSERT INTO ponderacion (id_ponderacion, descripcion) VALUES (2,"Regular");
INSERT INTO ponderacion (id_ponderacion, descripcion) VALUES (3,"Bueno");
INSERT INTO ponderacion (id_ponderacion, descripcion) VALUES (4,"Muy bueno");
INSERT INTO ponderacion (id_ponderacion, descripcion) VALUES (5,"Excelente");
commit;

