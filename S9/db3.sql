-- BORRADO DE TODAS LAS TABLAS SIN IMPORTAR EL ORDEN
BEGIN
    FOR t IN (
        SELECT table_name FROM user_tables 
        WHERE table_name IN (
            'DETALLE_PUNTAJE_POSTULANTE',
            'BONIFICACION_POSTULANTE',
            'BENEFICIO_PROGRAMA',
            'DOCUMENTO_PROGRAMA', 
            'DOCUMENTO_POSTULANTE', 
            'TIPO_DOCUMENTO_ESTUDIANTE',
            'POSTULACION',
            'ESTADO_POSTULACION',
            'INSTITUCION_DESTINO',
            'PROGRAMA_BECAS',
            'AREA_PROGRAMA',
            'TIPO_PROGRAMA',
            'CARGA_FAMILIAR',
            'POSTULANTE',
            'ESTADO_CIVIL',
            'GENERO',
            'CIUDAD',
            'REGION',
            'PAIS'
        )
    ) LOOP
        EXECUTE IMMEDIATE 'DROP TABLE ' || t.table_name || ' CASCADE CONSTRAINTS';
    END LOOP;
END;

-- SCRIPT MODELO RELACIONAL POSTULANTE BECA ANID
-- Tabla 1: pais
CREATE TABLE pais (
    id_pais NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre_pais VARCHAR2(100) NOT NULL UNIQUE
);

-- Tabla 2: region
CREATE TABLE region (
    id_region NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre_region VARCHAR2(100) NOT NULL,
    id_pais NUMBER NOT NULL,
    FOREIGN KEY (id_pais) REFERENCES pais(id_pais)
);

-- Tabla 3: ciudad
CREATE TABLE ciudad (
    id_ciudad NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre_ciudad VARCHAR2(100) NOT NULL,
    id_region NUMBER NOT NULL,
    FOREIGN KEY (id_region) REFERENCES region(id_region)
);

-- Tabla 4: genero
CREATE TABLE genero (
    id_genero NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    desc_genero VARCHAR2(50) NOT NULL UNIQUE
);

-- Tabla 5: estado_civil
CREATE TABLE estado_civil (
    id_estado_civil NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    desc_estado VARCHAR2(50) NOT NULL UNIQUE
);

-- Tabla 6: postulante
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
    id_genero NUMBER NOT NULL,
    id_estado_civil NUMBER NOT NULL,
    id_ciudad_residencia NUMBER NOT NULL,
    id_region_titulacion NUMBER NOT NULL,
    titulo_profesional VARCHAR2(100) NOT NULL,
    promedio_notas NUMBER(4,2) CHECK (promedio_notas BETWEEN 1 AND 7),
    ranking_egreso NUMBER(3) CHECK (ranking_egreso BETWEEN 0 AND 100),
    total_egresados NUMBER(4) CHECK (total_egresados > 0),
    es_extranjero CHAR(1) CHECK (es_extranjero IN ('S','N')),
    vigencia_residencia VARCHAR2(50),
    FOREIGN KEY (id_genero) REFERENCES genero(id_genero),
    FOREIGN KEY (id_estado_civil) REFERENCES estado_civil(id_estado_civil),
    FOREIGN KEY (id_ciudad_residencia) REFERENCES ciudad(id_ciudad),
    FOREIGN KEY (id_region_titulacion) REFERENCES region(id_region),
    CONSTRAINT uq_postulante_rut UNIQUE (rut_numero, rut_dv)
);


-- Tabla 7: carga_familiar
CREATE TABLE carga_familiar (
    id_carga_familiar NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_postulante NUMBER NOT NULL,
    rut_numero NUMBER(8) NOT NULL,
    rut_dv CHAR(1) NOT NULL,
    nombres VARCHAR2(100) NOT NULL,
    ap_paterno VARCHAR2(50) NOT NULL,
    ap_materno VARCHAR2(50),
    fecha_nacimiento DATE NOT NULL,
    vinculo VARCHAR2(50) NOT NULL,
    vive_con_postulante CHAR(1) CHECK (vive_con_postulante IN ('S','N')),
    FOREIGN KEY (id_postulante) REFERENCES postulante(id_postulante),
    CONSTRAINT uq_carga_familiar_rut UNIQUE (rut_numero, rut_dv)
);

-- CONTINUACIÓN: TABLAS DE PROGRAMA, INSTITUCIÓN, DOCUMENTOS, BENEFICIOS Y PUNTAJES
-- Tabla 8: tipo_programa
CREATE TABLE tipo_programa (
    id_tipo_programa NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre_tipo VARCHAR2(100) NOT NULL UNIQUE
);

-- Tabla 9: area_programa
CREATE TABLE area_programa (
    id_area NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre_area VARCHAR2(100) NOT NULL UNIQUE
);

-- Tabla 10: programa_becas
CREATE TABLE programa_becas (
    id_programa NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre_programa VARCHAR2(150) NOT NULL,
    cantidad_becas NUMBER(4),
    id_area NUMBER NOT NULL,
    id_tipo_programa NUMBER NOT NULL,
    FOREIGN KEY (id_area) REFERENCES area_programa(id_area),
    FOREIGN KEY (id_tipo_programa) REFERENCES tipo_programa(id_tipo_programa)
);

-- Tabla 11: institucion_destino
CREATE TABLE institucion_destino (
    id_institucion NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre_institucion VARCHAR2(150) NOT NULL,
    id_ciudad NUMBER NOT NULL,
    id_pais NUMBER NOT NULL,
    ranking_ocde NUMBER(4),
    url VARCHAR2(250),
    FOREIGN KEY (id_ciudad) REFERENCES ciudad(id_ciudad),
    FOREIGN KEY (id_pais) REFERENCES pais(id_pais)
);

-- Tabla 12: estado_postulacion
CREATE TABLE estado_postulacion (
    id_estado NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    estado VARCHAR2(50) NOT NULL UNIQUE
);

-- Tabla 13: postulacion
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

-- Tabla 14: tipo_documento_estudiante
CREATE TABLE tipo_documento_estudiante (
    id_tipo_documento NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre_documento VARCHAR2(100) NOT NULL UNIQUE
);

-- Tabla 15: documento_postulante
CREATE TABLE documento_postulante (
    id_documento NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_postulante NUMBER NOT NULL,
    id_tipo_documento NUMBER NOT NULL,
    nombre_archivo VARCHAR2(150) NOT NULL,
    fecha_entrega DATE NOT NULL,
    FOREIGN KEY (id_postulante) REFERENCES postulante(id_postulante),
    FOREIGN KEY (id_tipo_documento) REFERENCES tipo_documento_estudiante(id_tipo_documento)
);

-- Tabla 16: documento_programa
CREATE TABLE documento_programa (
    id_documento_prog NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_programa NUMBER NOT NULL,
    nombre_documento VARCHAR2(100) NOT NULL,
    es_obligatorio CHAR(1) CHECK (es_obligatorio IN ('S','N')),
    FOREIGN KEY (id_programa) REFERENCES programa_becas(id_programa)
);

-- Tabla 17: beneficio_programa
CREATE TABLE beneficio_programa (
    id_beneficio NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_programa NUMBER NOT NULL,
    nombre_beneficio VARCHAR2(100) NOT NULL,
    FOREIGN KEY (id_programa) REFERENCES programa_becas(id_programa)
);

-- Tabla 18: bonificacion_postulante
CREATE TABLE bonificacion_postulante (
    id_bonificacion NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_postulante NUMBER NOT NULL,
    tipo_bonificacion VARCHAR2(100) NOT NULL,
    puntaje NUMBER(3,1) CHECK (puntaje BETWEEN 0 AND 5),
    FOREIGN KEY (id_postulante) REFERENCES postulante(id_postulante)
);

-- Tabla 19: detalle_puntaje_postulante
CREATE TABLE detalle_puntaje_postulante (
    id_detalle NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_postulacion NUMBER NOT NULL,
    puntaje_promedio NUMBER(4,2),
    puntaje_ranking NUMBER(4,2),
    puntaje_bonificacion NUMBER(4,2),
    puntaje_total NUMBER(5,2),
    FOREIGN KEY (id_postulacion) REFERENCES postulacion(id_postulacion)
);

