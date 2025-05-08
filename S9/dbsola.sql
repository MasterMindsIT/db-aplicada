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

