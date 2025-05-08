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


-- Tabla 4: genero para determinar el género del postulante el cual se usara acorde a la ley de inclusión o no segun el país
CREATE TABLE genero (
    id_genero NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    desc_genero VARCHAR2(50) NOT NULL UNIQUE
);

-- Tabla 5: estado_civil para guardar el estado civil del postulante dado que hay beneficios por carga familiar
CREATE TABLE estado_civil (
    id_estado_civil NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    desc_estado VARCHAR2(50) NOT NULL UNIQUE
);

-- Tabla 6: postulante para guardar los datos del postulante
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
    discapacidad VARCHAR2(30) DEFAULT NULL,
    id_genero NUMBER NOT NULL,
    id_estado_civil NUMBER NOT NULL,
    id_region_residencia NUMBER NOT NULL,
    id_region_titulacion NUMBER NOT NULL,
    FOREIGN KEY (id_genero) REFERENCES genero(id_genero),
    FOREIGN KEY (id_estado_civil) REFERENCES estado_civil(id_estado_civil),
    FOREIGN KEY (id_region_residencia) REFERENCES region(id_region),
    FOREIGN KEY (id_region_titulacion) REFERENCES region(id_region),
    CONSTRAINT uq_postulante_rut UNIQUE (rut_numero, rut_dv)
);

CREATE TABLE tipo_documento (
    id_tipo_documento NUMBER PRIMARY KEY,
    descripcion VARCHAR2(20) CHECK (tipo IN ('OBLIGATORIO', 'OPCIONAL', 'BONIFICABLE'))
);
CREATE TABLE tipo_sistema (
    id_tipo_sistema NUMBER PRIMARY KEY,
    descripcion VARCHAR2(20) CHECK (descripcion IN ('PARAMETRIZADO', 'NO PARAMETRIZADO'))
);

CREATE TABLE documento (
    id_documento NUMBER PRIMARY KEY,
    nombre VARCHAR2(100),
    id_tipo_documento NUMBER NOT NULL,
    id_tipo_sistema NUMBER NOT NULL,
    FOREIGN KEY (id_tipo_documento) REFERENCES tipo_documento(id_tipo_documento),
    FOREIGN KEY (id_tipo_sistema) REFERENCES tipo_sistema(id_tipo_sistema)
);

-- CONTINUACIÓN: TABLAS DE PROGRAMA, INSTITUCIÓN, DOCUMENTOS, BENEFICIOS Y PUNTAJES
-- Tabla 8: tipo_programa, becas de postgrado, programas y concursos, etc.
CREATE TABLE tipo_programa (
    id_tipo_programa NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre_tipo VARCHAR2(100) NOT NULL UNIQUE
);

-- Tabla 9: area_programa Capital Humano, Proyectos de Investigación, Centros e Investigación Asociativa, Investigación Aplicada y Redes, Estrategia y Conocimiento
CREATE TABLE area_programa (
    id_area NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre_area VARCHAR2(100) NOT NULL UNIQUE
);

-- Tabla 10: programa_becas, características de los programas de becas
-- (nombre, cantidad de becas, área, tipo de programa)
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
    url VARCHAR2(250),
    FOREIGN KEY (id_pais) REFERENCES pais(id_pais)
);

-- Tabla 12: estado_postulacion, para guardar los estados de la postulacion
-- (en espera, aceptado, rechazado, etc.)
CREATE TABLE estado_postulacion (
    id_estado NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    estado VARCHAR2(50) NOT NULL UNIQUE
);

-- Tabla 13: postulacion, para guardar los datos de la postulacion
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
-- criterio de evaluacion
CREATE TABLE criterio_evaluacion (
    id_criterio NUMBER PRIMARY KEY,
    nombre VARCHAR2(100) -- 'Antecedentes Académicos', 'Objetivos Académicos'
);
--subcriterio de evaluacion 
CREATE TABLE subcriterio_evaluacion (
    id_subcriterio NUMBER PRIMARY KEY,
    id_criterio NUMBER REFERENCES criterio_evaluacion,
    nombre VARCHAR2(100)
);
--ponderaciones clave valor
CREATE TABLE ponderacion_subcriterio (
    id_ponderacion NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_subcriterio NUMBER REFERENCES subcriterio_evaluacion,
    clave VARCHAR2(100),
    valor NUMBER,
    CONSTRAINT uq_subcriterio_clave UNIQUE (id_subcriterio, clave)
);

--Tabla evaluacion donde se ingreasan los datos evaluados que 
CREATE TABLE evaluacion_documento (
    id_evaluacion_documento NUMBER PRIMARY KEY,
    id_documento_presentado NUMBER REFERENCES documento_postulante,
    id_subcriterio NUMBER REFERENCES subcriterio_evaluacion,
    id_ponderacion NUMBER REFERENCES ponderacion_subcriterio,
    id_evaluador NUMBER,
    comentario VARCHAR2(200),
    CONSTRAINT uq_doc_subcriterio UNIQUE (id_documento_presentado, id_subcriterio) --verificamos que no se repita una evaluacion
);