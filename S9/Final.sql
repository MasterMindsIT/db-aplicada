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
            'CRITERIO_EVALUACION',
            'SUBCRITERIO_EVALUACION',
            'PONDERACION_SUBCRITERIO',
            'EVALUACION_DOCUMENTO',
            'CONFIGURACION_CODE'
        )
    ) LOOP
        EXECUTE IMMEDIATE 'DROP TABLE ' || t.table_name || ' CASCADE CONSTRAINTS';
    END LOOP;
END;
-- Tabla 1 pais para relacionar la region con el país y el origen de la institución
CREATE TABLE pais (
    id_pais NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre_pais VARCHAR2(100) NOT NULL UNIQUE
);

-- Tabla 2: region para determinar la región de residencia del postulante y ver la bonificacion de puntaje por donde estudia
CREATE TABLE region (
    id_region NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre_region VARCHAR2(100) NOT NULL,
    id_pais NUMBER NOT NULL,
    FOREIGN KEY (id_pais) REFERENCES pais(id_pais)
);


-- Tabla 3: genero para determinar el género del postulante el cual se usara acorde a la ley de inclusión o no segun el país
CREATE TABLE genero (
    id_genero NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    desc_genero VARCHAR2(50) NOT NULL UNIQUE
);

-- Tabla 4: estado_civil para guardar el estado civil del postulante dado que hay beneficios por carga familiar
CREATE TABLE estado_civil (
    id_estado_civil NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    desc_estado VARCHAR2(50) NOT NULL UNIQUE
);

-- Tabla 5: postulante para guardar los datos del postulante
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
    etnia VARCHAR2(40) CHECK (etnia IS NULL OR etnia IN ('Mapuche', 'Aymara', 'Rapa Nui', 'Atacameño', 'Diaguita','Colla', 'Quechua', 'Chango', 'Kawésqar', 'Yagán','Otro', 'No especificado'),
    id_genero NUMBER NOT NULL,
    id_estado_civil NUMBER NOT NULL,
    id_region_residencia NUMBER NOT NULL,
    id_region_titulacion NUMBER NOT NULL,
    fecha_registro DATE DEFAULT SYSDATE,
    nota_media_pregrado NUMBER(3, 2) DEFAULT null CHECK (nota_media_pregrado IS NULL OR (nota_media_pregrado >= 0 AND nota_media_pregrado <= 7)),--usuario verificador_notas
    posicion_ranking NUMBER DEFAULT null CHECK (posicion_ranking IS NULL OR posicion_ranking > 0), --Usuario verificador_notas
    total_egresados NUMBER DEFAULT null CHECK (total_egresados IS NULL OR total_egresados > 0),--Usuario verificador_notas
    puntaje_aa NUMBER(5, 3) DEFAULT null CHECK (puntaje_aa IS NULL OR (puntaje_aa >= 0 AND puntaje_aa <= 5)), --Usuario administrador_system
    CONSTRAINT chk_telefono_contacto CHECK (telefono_contacto IS NULL OR LENGTH(telefono_contacto) <= 20),
    CONSTRAINT chk_fecha_nacimiento CHECK (fecha_nacimiento < SYSDATE),
    CONSTRAINT chk_rut CHECK (rut_numero > 0 AND LENGTH(rut_numero) <= 8),
    FOREIGN KEY (id_genero) REFERENCES genero(id_genero),
    FOREIGN KEY (id_estado_civil) REFERENCES estado_civil(id_estado_civil),
    FOREIGN KEY (id_region_residencia) REFERENCES region(id_region),
    FOREIGN KEY (id_region_titulacion) REFERENCES region(id_region),
    CONSTRAINT uq_postulante_rut UNIQUE (rut_numero, rut_dv)
);
-- Tabla 6: tipo_documento, para guardar los tipos de documentos que se deben presentar
CREATE TABLE tipo_documento (
    id_tipo_documento NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    descripcion VARCHAR2(20) CHECK (tipo IN ('OBLIGATORIO', 'OPCIONAL', 'BONIFICABLE'))
);
-- Tabla 7: tipo_sistema, para guardar los tipos de sistema que se deben presentar
CREATE TABLE tipo_sistema (
    id_tipo_sistema NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    descripcion VARCHAR2(20) CHECK (descripcion IN ('PARAMETRIZADO', 'NO PARAMETRIZADO'))
);
-- Tabla 8: documento, para guardar los documentos que se deben presentar, esta forma permite que sea dinamico
CREATE TABLE documento (
    id_documento NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre VARCHAR2(100),
    id_tipo_documento NUMBER NOT NULL,
    id_tipo_sistema NUMBER NOT NULL,
    FOREIGN KEY (id_tipo_documento) REFERENCES tipo_documento(id_tipo_documento),
    FOREIGN KEY (id_tipo_sistema) REFERENCES tipo_sistema(id_tipo_sistema)
);

-- Tabla 9: tipo_programa, becas de postgrado, programas y concursos, etc.
CREATE TABLE tipo_programa (
    id_tipo_programa NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre_tipo VARCHAR2(100) NOT NULL UNIQUE
);

-- Tabla 10: area_programa Capital Humano, Proyectos de Investigación, Centros e Investigación Asociativa, Investigación Aplicada y Redes, Estrategia y Conocimiento
CREATE TABLE area_programa (
    id_area NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre_area VARCHAR2(100) NOT NULL UNIQUE
);

-- Tabla 11: programa_becas, características de los programas de becas
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

-- Tabla 12: institucion_destino, para guardar los datos de la institución a la cual postula el postulante
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
    id_postulante NUMBER NOT NULL,
    id_postulacion NUMBER NOT NULL,
    id_documento NUMBER NOT NULL,
    url_archivo VARCHAR2(255) NOT NULL,
    fecha_entrega DATE NOT NULL,
    FOREIGN KEY (id_postulante) REFERENCES postulante(id_postulante),
    FOREIGN KEY (id_postulacion) REFERENCES postulacion(id_postulacion),
    FOREIGN KEY (id_documento) REFERENCES documento(id_documento)
);
---- Tabla 16: criterio de evaluacion
CREATE TABLE criterio_evaluacion (
    id_criterio NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre VARCHAR2(100) -- 'Antecedentes Académicos', 'Objetivos Académicos'
);
---- Tabla 17: subcriterio de evaluacion 
CREATE TABLE subcriterio_evaluacion (
    id_subcriterio NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_criterio NUMBER REFERENCES criterio_evaluacion,
    nombre VARCHAR2(100)
);
---- Tabla 18: ponderaciones clave valor
CREATE TABLE ponderacion_subcriterio (
    id_ponderacion NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_subcriterio NUMBER REFERENCES subcriterio_evaluacion,
    clave VARCHAR2(100),
    valor NUMBER,
    CONSTRAINT uq_subcriterio_clave UNIQUE (id_subcriterio, clave)
);

---- Tabla 19: Tabla evaluacion donde se ingreasan los datos evaluados que 
CREATE TABLE evaluacion_documento (
    id_evaluacion_documento NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_documento_presentado NUMBER REFERENCES documento_postulante,
    id_subcriterio NUMBER REFERENCES subcriterio_evaluacion,
    id_ponderacion NUMBER REFERENCES ponderacion_subcriterio,
    id_evaluador NUMBER,
    comentario VARCHAR2(200),
    CONSTRAINT uq_doc_subcriterio UNIQUE (id_documento_presentado, id_subcriterio) --verificamos que no se repita una evaluacion
);

--Tabla 20: tabla configuracion_ocde para guardar la posicion chilena en el ranking OCDE
CREATE TABLE configuracion_ocde (
    id_config NUMBER PRIMARY KEY,
    posicion_chilena NUMBER NOT NULL
);


--Verificacion que el Id ponderacion pertenece al subcriterio(Alto,5),etc
CREATE OR REPLACE TRIGGER trg_validar_ponderacion
BEFORE INSERT OR UPDATE ON evaluacion_documento
FOR EACH ROW
DECLARE
    v_subcriterio NUMBER;
BEGIN
    SELECT id_subcriterio INTO v_subcriterio
    FROM ponderacion_subcriterio
    WHERE id_ponderacion = :NEW.id_ponderacion; --busca que el id exista ya 

    IF v_subcriterio != :NEW.id_subcriterio THEN
        RAISE_APPLICATION_ERROR(-20001, 'El id_ponderacion no pertenece al subcriterio indicado.');
    END IF;
END;


-- POBLACIÓN DE TABLAS BASE DE DATOS
--Tabla 1
INSERT INTO pais (nombre_pais) VALUES ('Chile');
INSERT INTO pais (nombre_pais) VALUES ('USA');
INSERT INTO pais (nombre_pais) VALUES ('Australia');
INSERT INTO pais (nombre_pais) VALUES ('España');
INSERT INTO pais (nombre_pais) VALUES ('Canadá');
--Tabla 2
INSERT INTO region (nombre_region, id_pais) VALUES ('Región Metropolitana', 1);
INSERT INTO region (nombre_region, id_pais) VALUES ('Valparaíso', 1);
INSERT INTO region (nombre_region, id_pais) VALUES ('Biobío', 1);
INSERT INTO region (nombre_region, id_pais) VALUES ('Antofagasta', 1);
INSERT INTO region (nombre_region, id_pais) VALUES ('Los Lagos', 1);
--Tabla 3
INSERT INTO genero (desc_genero) VALUES ('Masculino');
INSERT INTO genero (desc_genero) VALUES ('Femenino');
INSERT INTO genero (desc_genero) VALUES ('No binario');
INSERT INTO genero (desc_genero) VALUES ('Otro');
INSERT INTO genero (desc_genero) VALUES ('Prefiere no decir');
--Tabla 4
INSERT INTO estado_civil (desc_estado) VALUES ('Soltero');
INSERT INTO estado_civil (desc_estado) VALUES ('Casado');
INSERT INTO estado_civil (desc_estado) VALUES ('Divorciado');
INSERT INTO estado_civil (desc_estado) VALUES ('Viudo');
INSERT INTO estado_civil (desc_estado) VALUES ('Conviviente');
--Tabla 5
INSERT INTO estado_postulacion (estado) VALUES ('En revisión');
INSERT INTO estado_postulacion (estado) VALUES ('Aceptado');
INSERT INTO estado_postulacion (estado) VALUES ('Rechazado');
INSERT INTO estado_postulacion (estado) VALUES ('Nuevo requerimiento');
INSERT INTO estado_postulacion (estado) VALUES ('En proceso');
--Tabla 6
INSERT INTO programa_becas (nombre_programa, fecha_inicio, fecha_fin, id_area, id_tipo_programa) VALUES ('Programa Beca 1', TO_DATE('2024-03-01','YYYY-MM-DD'), TO_DATE('2024-08-28','YYYY-MM-DD'), 3, 3);
INSERT INTO programa_becas (nombre_programa, fecha_inicio, fecha_fin, id_area, id_tipo_programa) VALUES ('Programa Beca 2', TO_DATE('2024-05-01','YYYY-MM-DD'), TO_DATE('2024-10-28','YYYY-MM-DD'), 1, 1);
INSERT INTO programa_becas (nombre_programa, fecha_inicio, fecha_fin, id_area, id_tipo_programa) VALUES ('Programa Beca 3', TO_DATE('2024-06-01','YYYY-MM-DD'), TO_DATE('2024-12-28','YYYY-MM-DD'), 5, 2);
INSERT INTO programa_becas (nombre_programa, fecha_inicio, fecha_fin, id_area, id_tipo_programa) VALUES ('Beca Chile 2025', TO_DATE('2024-02-01','YYYY-MM-DD'), TO_DATE('2024-07-28','YYYY-MM-DD'), 1, 1);
INSERT INTO programa_becas (nombre_programa, fecha_inicio, fecha_fin, id_area, id_tipo_programa) VALUES ('Beca Internacional 2025', TO_DATE('2024-03-01','YYYY-MM-DD'), TO_DATE('2024-08-28','YYYY-MM-DD'), 2, 2);
--Tabla 7
INSERT INTO institucion_destino (nombre_institucion, id_pais, ranking_ocde, url) VALUES ('Harvard', 2, 1, 'https://www.harvard.edu/');
INSERT INTO institucion_destino (nombre_institucion, id_pais, ranking_ocde, url) VALUES ('MIT', 2, 4, 'https://www.mit.edu/');
INSERT INTO institucion_destino (nombre_institucion, id_pais, ranking_ocde, url) VALUES ('Complutense de Madrid', 4, 34, 'https://www.ucm.es/');
INSERT INTO institucion_destino (nombre_institucion, id_pais, ranking_ocde, url) VALUES ('University of Oxford',  5, 3, 'https://www.ox.ac.uk/');
INSERT INTO institucion_destino (nombre_institucion, id_pais, ranking_ocde, url) VALUES ('MIT', 'EE.UU.', 2, 8, 'https://www.utoronto.ca/');
--Tabla 7
INSERT INTO tipo_programa (nombre_tipo) VALUES ('Becas de Postgrado');
INSERT INTO tipo_programa (nombre_tipo) VALUES ('Programas');
INSERT INTO tipo_programa (nombre_tipo) VALUES ('Concursos');
INSERT INTO tipo_programa (nombre_tipo) VALUES ('Convenios');
INSERT INTO tipo_programa (nombre_tipo) VALUES ('Ayudas Académicas');
--Tabla 9
INSERT INTO area_programa (nombre_area) VALUES ('Capital Humano');
INSERT INTO area_programa (nombre_area) VALUES ('Proyectos de Investigación');
INSERT INTO area_programa (nombre_area) VALUES ('Centros e Investigación Asociativa');
INSERT INTO area_programa (nombre_area) VALUES ('Investigación Aplicada');
INSERT INTO area_programa (nombre_area) VALUES ('Redes');
INSERT INTO area_programa (nombre_area) VALUES ('Estrategia y Conocimiento');
--Tabla 10
INSERT INTO tipo_documento (descripcion) VALUES ('OBLIGATORIO');
INSERT INTO tipo_documento (descripcion) VALUES ('OPCIONAL');
INSERT INTO tipo_documento (descripcion) VALUES ('BONIFICABLE');
INSERT INTO tipo_documento (descripcion) VALUES ('LIBRE');
INSERT INTO tipo_documento (descripcion) VALUES ('CERTIFICADO');
--Tabla 11
INSERT INTO tipo_sistema (descripcion) VALUES ('PARAMETRIZADO');
INSERT INTO tipo_sistema (descripcion) VALUES ('NO PARAMETRIZADO');
INSERT INTO tipo_sistema (descripcion) VALUES ('Anual');
INSERT INTO tipo_sistema (descripcion) VALUES ('Bimestral');
INSERT INTO tipo_sistema (descripcion) VALUES ('Cuatrimestral');
--Tabla 12
INSERT INTO criterio_evaluacion (nombre) VALUES ('Antecedentes Académicos');
INSERT INTO criterio_evaluacion (nombre) VALUES ('Objetivos Académicos');
INSERT INTO criterio_evaluacion (descripcion) VALUES ('Bioculturales');
INSERT INTO criterio_evaluacion (descripcion) VALUES ('Cientificos');
INSERT INTO criterio_evaluacion (descripcion) VALUES ('Agnosticos');
--Tabla 13
INSERT INTO subcriterio_evaluacion (id_criterio, nombre) VALUES (2, 'Coherencia y claridad de intereses');
INSERT INTO subcriterio_evaluacion (id_criterio, nombre) VALUES (2, 'Objetivo de Estudio');
INSERT INTO subcriterio_evaluacion (id_criterio, nombre) VALUES (1, 'Desarrollo de actividades de docencia e investigación y estudios de postgrado');
INSERT INTO subcriterio_evaluacion (id_criterio, nombre) VALUES (1, 'Cartas de Recomendación');
INSERT INTO subcriterio_evaluacion (id_criterio, nombre) VALUES (1, 'Experiencia laboral relacionada con los objetivos de estudio');
INSERT INTO subcriterio_evaluacion (id_criterio, nombre) VALUES (2, 'Retribución del postulante al país');
--Tabla 14
INSERT INTO ponderacion_subcriterio (id_subcriterio, clave, valor) VALUES (3, 'Alta', 5);
INSERT INTO ponderacion_subcriterio (id_subcriterio, clave, valor) VALUES (3, 'Media', 3);
INSERT INTO ponderacion_subcriterio (id_subcriterio, clave, valor) VALUES (3, 'Baja', 2);
INSERT INTO ponderacion_subcriterio (id_subcriterio, clave, valor) VALUES (5, 'Más de 5 años', 5);
INSERT INTO ponderacion_subcriterio (id_subcriterio, clave, valor) VALUES (5, '5 años', 4);
INSERT INTO ponderacion_subcriterio (id_subcriterio, clave, valor) VALUES (5, '4 años', 3);
INSERT INTO ponderacion_subcriterio (id_subcriterio, clave, valor) VALUES (5, '3 años', 2);
INSERT INTO ponderacion_subcriterio (id_subcriterio, clave, valor) VALUES (5, '2 años', 1);
INSERT INTO ponderacion_subcriterio (id_subcriterio, clave, valor) VALUES (4, 'Alta', 5);
INSERT INTO ponderacion_subcriterio (id_subcriterio, clave, valor) VALUES (4, 'Media', 3);
INSERT INTO ponderacion_subcriterio (id_subcriterio, clave, valor) VALUES (4, 'Baja', 2);
INSERT INTO ponderacion_subcriterio (id_subcriterio, clave, valor) VALUES (1, 'Excelente', 5);
INSERT INTO ponderacion_subcriterio (id_subcriterio, clave, valor) VALUES (1, 'Muy bueno', 4);
INSERT INTO ponderacion_subcriterio (id_subcriterio, clave, valor) VALUES (1, 'Bueno', 3);
INSERT INTO ponderacion_subcriterio (id_subcriterio, clave, valor) VALUES (1, 'Regular', 1);
INSERT INTO ponderacion_subcriterio (id_subcriterio, clave, valor) VALUES (2, 'Excelente', 5);
INSERT INTO ponderacion_subcriterio (id_subcriterio, clave, valor) VALUES (2, 'Muy bueno', 4);
INSERT INTO ponderacion_subcriterio (id_subcriterio, clave, valor) VALUES (2, 'Bueno', 3);
INSERT INTO ponderacion_subcriterio (id_subcriterio, clave, valor) VALUES (2, 'Regular', 1);
INSERT INTO ponderacion_subcriterio (id_subcriterio, clave, valor) VALUES (6, 'Excelente', 5);
INSERT INTO ponderacion_subcriterio (id_subcriterio, clave, valor) VALUES (6, 'Muy bueno', 4);
INSERT INTO ponderacion_subcriterio (id_subcriterio, clave, valor) VALUES (6, 'Bueno', 3);
INSERT INTO ponderacion_subcriterio (id_subcriterio, clave, valor) VALUES (6, 'Regular', 1);
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
--Tabla 16
INSERT INTO documento (nombre, id_tipo_documento, id_tipo_sistema) VALUES ('Formulario de postulación y currículum vitae', 2, 2);
INSERT INTO documento (nombre, id_tipo_documento, id_tipo_sistema) VALUES ('Copia Cédula de Identidad', 1, 1);
INSERT INTO documento (nombre, id_tipo_documento, id_tipo_sistema) VALUES ('Carta de aceptación al programa', 1, 2);
INSERT INTO documento (nombre, id_tipo_documento, id_tipo_sistema) VALUES ('Certificado de Alumno regular', 1, 1);
INSERT INTO documento (nombre, id_tipo_documento, id_tipo_sistema) VALUES ('Copia de Título Profesional', 1, 1);
INSERT INTO documento (nombre, id_tipo_documento, id_tipo_sistema) VALUES ('Certificado de ranking de egreso', 1, 1);
INSERT INTO documento (nombre, id_tipo_documento, id_tipo_sistema) VALUES ('Certificado de notas final', 1, 1);
INSERT INTO documento (nombre, id_tipo_documento, id_tipo_sistema) VALUES ('Certificado de vigencia de permanencia definitiva', 3, 1);
INSERT INTO documento (nombre, id_tipo_documento, id_tipo_sistema) VALUES ('Sección Socioeconómica', 1, 2);
INSERT INTO documento (nombre, id_tipo_documento, id_tipo_sistema) VALUES ('Certificados de idioma', 3, 1);
INSERT INTO documento (nombre, id_tipo_documento, id_tipo_sistema) VALUES ('Cartas de Recomendación', 2, 2);
INSERT INTO documento (nombre, id_tipo_documento, id_tipo_sistema) VALUES ('Certificado de Veracidad', 3, 1);
INSERT INTO documento (nombre, id_tipo_documento, id_tipo_sistema) VALUES ('Copia de otros postgrados', 2, 1);
INSERT INTO documento (nombre, id_tipo_documento, id_tipo_sistema) VALUES ('Concentración de notas otros postgrados', 1, 2);
INSERT INTO documento (nombre, id_tipo_documento, id_tipo_sistema) VALUES ('Certificado de CONADI', 3, 1);
--Tabla 17
INSERT INTO postulacion (id_postulante, id_programa, id_institucion, id_estado, fecha_postulacion) VALUES (1, 1, 3, 1, TO_DATE('2024-04-03','YYYY-MM-DD'));
INSERT INTO postulacion (id_postulante, id_programa, id_institucion, id_estado, fecha_postulacion) VALUES (2, 1, 1, 3, TO_DATE('2024-04-11','YYYY-MM-DD'));
INSERT INTO postulacion (id_postulante, id_programa, id_institucion, id_estado, fecha_postulacion) VALUES (3, 1, 1, 2, TO_DATE('2024-04-19','YYYY-MM-DD'));
INSERT INTO postulacion (id_postulante, id_programa, id_institucion, id_estado, fecha_postulacion) VALUES (4, 1, 3, 1, TO_DATE('2024-04-14','YYYY-MM-DD'));
INSERT INTO postulacion (id_postulante, id_programa, id_institucion, id_estado, fecha_postulacion) VALUES (5, 1, 3, 1, TO_DATE('2024-04-05','YYYY-MM-DD'));
INSERT INTO postulacion (id_postulante, id_programa, id_institucion, id_estado, fecha_postulacion) VALUES (6, 2, 2, 3, TO_DATE('2024-04-21','YYYY-MM-DD'));
INSERT INTO postulacion (id_postulante, id_programa, id_institucion, id_estado, fecha_postulacion) VALUES (7, 1, 3, 1, TO_DATE('2024-04-27','YYYY-MM-DD'));
INSERT INTO postulacion (id_postulante, id_programa, id_institucion, id_estado, fecha_postulacion) VALUES (8, 1, 3, 2, TO_DATE('2024-04-10','YYYY-MM-DD'));
INSERT INTO postulacion (id_postulante, id_programa, id_institucion, id_estado, fecha_postulacion) VALUES (9, 2, 1, 1, TO_DATE('2024-04-24','YYYY-MM-DD'));
INSERT INTO postulacion (id_postulante, id_programa, id_institucion, id_estado, fecha_postulacion) VALUES (10, 2, 1, 1, TO_DATE('2024-04-12','YYYY-MM-DD'));
--Tabla 18
INSERT INTO documento_presentado (id_postulante, id_postulacion, id_documento, url_archivo, fecha_entrega) VALUES (1, 1, 2, 'https://archivo.com/doc_1.pdf', TO_DATE('2024-04-25', 'YYYY-MM-DD'));
INSERT INTO documento_presentado (id_postulante, id_postulacion, id_documento, url_archivo, fecha_entrega) VALUES (1, 1, 15, 'https://archivo.com/doc_2.pdf', TO_DATE('2024-04-14', 'YYYY-MM-DD'));
INSERT INTO documento_presentado (id_postulante, id_postulacion, id_documento, url_archivo, fecha_entrega) VALUES (2, 2, 3, 'https://archivo.com/doc_3.pdf', TO_DATE('2024-04-13', 'YYYY-MM-DD'));
INSERT INTO documento_presentado (id_postulante, id_postulacion, id_documento, url_archivo, fecha_entrega) VALUES (2, 2, 12, 'https://archivo.com/doc_4.pdf', TO_DATE('2024-04-18', 'YYYY-MM-DD'));
INSERT INTO documento_presentado (id_postulante, id_postulacion, id_documento, url_archivo, fecha_entrega) VALUES (3, 3, 5, 'https://archivo.com/doc_5.pdf', TO_DATE('2024-04-21', 'YYYY-MM-DD'));
INSERT INTO documento_presentado (id_postulante, id_postulacion, id_documento, url_archivo, fecha_entrega) VALUES (3, 3, 14, 'https://archivo.com/doc_6.pdf', TO_DATE('2024-04-05', 'YYYY-MM-DD'));
INSERT INTO documento_presentado (id_postulante, id_postulacion, id_documento, url_archivo, fecha_entrega) VALUES (4, 4, 7, 'https://archivo.com/doc_7.pdf', TO_DATE('2024-04-12', 'YYYY-MM-DD'));
INSERT INTO documento_presentado (id_postulante, id_postulacion, id_documento, url_archivo, fecha_entrega) VALUES (4, 4, 1, 'https://archivo.com/doc_8.pdf', TO_DATE('2024-04-22', 'YYYY-MM-DD'));
INSERT INTO documento_presentado (id_postulante, id_postulacion, id_documento, url_archivo, fecha_entrega) VALUES (5, 5, 5, 'https://archivo.com/doc_9.pdf', TO_DATE('2024-04-02', 'YYYY-MM-DD'));
INSERT INTO documento_presentado (id_postulante, id_postulacion, id_documento, url_archivo, fecha_entrega) VALUES (5, 5, 1, 'https://archivo.com/doc_10.pdf', TO_DATE('2024-04-28', 'YYYY-MM-DD'));
INSERT INTO documento_presentado (id_postulante, id_postulacion, id_documento, url_archivo, fecha_entrega) VALUES (6, 6, 11, 'https://archivo.com/doc_11.pdf', TO_DATE('2024-04-05', 'YYYY-MM-DD'));
INSERT INTO documento_presentado (id_postulante, id_postulacion, id_documento, url_archivo, fecha_entrega) VALUES (6, 6, 13, 'https://archivo.com/doc_12.pdf', TO_DATE('2024-04-11', 'YYYY-MM-DD'));
INSERT INTO documento_presentado (id_postulante, id_postulacion, id_documento, url_archivo, fecha_entrega) VALUES (7, 7, 3, 'https://archivo.com/doc_13.pdf', TO_DATE('2024-04-01', 'YYYY-MM-DD'));
INSERT INTO documento_presentado (id_postulante, id_postulacion, id_documento, url_archivo, fecha_entrega) VALUES (7, 7, 7, 'https://archivo.com/doc_14.pdf', TO_DATE('2024-04-11', 'YYYY-MM-DD'));
INSERT INTO documento_presentado (id_postulante, id_postulacion, id_documento, url_archivo, fecha_entrega) VALUES (8, 8, 3, 'https://archivo.com/doc_15.pdf', TO_DATE('2024-04-07', 'YYYY-MM-DD'));
INSERT INTO documento_presentado (id_postulante, id_postulacion, id_documento, url_archivo, fecha_entrega) VALUES (8, 8, 15, 'https://archivo.com/doc_16.pdf', TO_DATE('2024-04-21', 'YYYY-MM-DD'));
INSERT INTO documento_presentado (id_postulante, id_postulacion, id_documento, url_archivo, fecha_entrega) VALUES (9, 9, 12, 'https://archivo.com/doc_17.pdf', TO_DATE('2024-04-08', 'YYYY-MM-DD'));
INSERT INTO documento_presentado (id_postulante, id_postulacion, id_documento, url_archivo, fecha_entrega) VALUES (9, 9, 14, 'https://archivo.com/doc_18.pdf', TO_DATE('2024-04-06', 'YYYY-MM-DD'));
INSERT INTO documento_presentado (id_postulante, id_postulacion, id_documento, url_archivo, fecha_entrega) VALUES (10, 10, 10, 'https://archivo.com/doc_19.pdf', TO_DATE('2024-04-27', 'YYYY-MM-DD'));
INSERT INTO documento_presentado (id_postulante, id_postulacion, id_documento, url_archivo, fecha_entrega) VALUES (10, 10, 12, 'https://archivo.com/doc_20.pdf', TO_DATE('2024-04-20', 'YYYY-MM-DD'));
--Tabla 19
INSERT INTO evaluacion_documento (id_documento_presentado, id_subcriterio, id_ponderacion, id_evaluador, comentario) VALUES (1, 5, 1, 6564, 'Evaluación automática 1');
INSERT INTO evaluacion_documento (id_documento_presentado, id_subcriterio, id_ponderacion, id_evaluador, comentario) VALUES (2, 6, 2, 9934, 'Evaluación automática 2');
INSERT INTO evaluacion_documento (id_documento_presentado, id_subcriterio, id_ponderacion, id_evaluador, comentario) VALUES (3, 3, 3, 8303, 'Evaluación expertos G2');
INSERT INTO evaluacion_documento (id_documento_presentado, id_subcriterio, id_ponderacion, id_evaluador, comentario) VALUES (4, 6, 4, 2338, 'Evaluación automática 4');
INSERT INTO evaluacion_documento (id_documento_presentado, id_subcriterio, id_ponderacion, id_evaluador, comentario) VALUES (5, 4, 5, 3403, 'Evaluación  expertos G2');
INSERT INTO evaluacion_documento (id_documento_presentado, id_subcriterio, id_ponderacion, id_evaluador, comentario) VALUES (6, 6, 6, 7324, 'Evaluación automática 6');
INSERT INTO evaluacion_documento (id_documento_presentado, id_subcriterio, id_ponderacion, id_evaluador, comentario) VALUES (7, 2, 7, 5931, 'Evaluación automática 7');
INSERT INTO evaluacion_documento (id_documento_presentado, id_subcriterio, id_ponderacion, id_evaluador, comentario) VALUES (8, 1, 8, 1336, 'Evaluación  expertos G2');
INSERT INTO evaluacion_documento (id_documento_presentado, id_subcriterio, id_ponderacion, id_evaluador, comentario) VALUES (9, 6, 9, 3817, 'Evaluación automática 9');
INSERT INTO evaluacion_documento (id_documento_presentado, id_subcriterio, id_ponderacion, id_evaluador, comentario) VALUES (10, 3, 10, 4314, 'Evaluación automática 10');
INSERT INTO evaluacion_documento (id_documento_presentado, id_subcriterio, id_ponderacion, id_evaluador, comentario) VALUES (11, 5, 11, 3971, 'Evaluación automática 11');
INSERT INTO evaluacion_documento (id_documento_presentado, id_subcriterio, id_ponderacion, id_evaluador, comentario) VALUES (12, 1, 12, 7038, 'Evaluación  expertos G2');
INSERT INTO evaluacion_documento (id_documento_presentado, id_subcriterio, id_ponderacion, id_evaluador, comentario) VALUES (13, 3, 13, 9053, 'Evaluación automática 13');
INSERT INTO evaluacion_documento (id_documento_presentado, id_subcriterio, id_ponderacion, id_evaluador, comentario) VALUES (14, 3, 14, 1170, 'Evaluación automática 14');
INSERT INTO evaluacion_documento (id_documento_presentado, id_subcriterio, id_ponderacion, id_evaluador, comentario) VALUES (15, 2, 15, 3114, 'Evaluación expertos G2');
INSERT INTO evaluacion_documento (id_documento_presentado, id_subcriterio, id_ponderacion, id_evaluador, comentario) VALUES (16, 5, 16, 4711, 'Evaluación automática 16');
INSERT INTO evaluacion_documento (id_documento_presentado, id_subcriterio, id_ponderacion, id_evaluador, comentario) VALUES (17, 2, 17, 1126, 'Evaluación automática 17');
INSERT INTO evaluacion_documento (id_documento_presentado, id_subcriterio, id_ponderacion, id_evaluador, comentario) VALUES (18, 4, 18, 6952, 'Evaluación  expertos G2');
INSERT INTO evaluacion_documento (id_documento_presentado, id_subcriterio, id_ponderacion, id_evaluador, comentario) VALUES (19, 1, 19, 4222, 'Evaluación automática 19');
INSERT INTO evaluacion_documento (id_documento_presentado, id_subcriterio, id_ponderacion, id_evaluador, comentario) VALUES (20, 6, 20, 6783, 'Evaluación automática 20');

commit;