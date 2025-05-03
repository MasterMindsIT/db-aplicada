-- elimimina todas las tablas y secuencias si existen que vamos a crear en este script.
DROP TABLE Evaluaciones;
DROP TABLE Plan_Estudio;
DROP TABLE Cursos_Apoyo;
DROP TABLE Cursos_Formacion;
DROP TABLE Pregrado_Postgrado_Docentes;
DROP TABLE Docentes;
DROP TABLE Infraestructura;
DROP TABLE Acreditacion_Normativa;
DROP TABLE Normativas;
DROP TABLE Carreras;
DROP TABLE Acreditaciones;
DROP TABLE Sedes;
DROP TABLE Instituciones;
DROP TABLE Encargado_Acreditacion;
DROP TABLE Areas;
DROP TABLE Regiones;
DROP TABLE DET_FORMACION_DOCENTE;
DROP TABLE DET_INSTALACIONES_DECLARADA;

-- Eliminamos las secuencias si existen
DROP SEQUENCE seq_regiones;
DROP SEQUENCE seq_areas;
DROP SEQUENCE seq_instituciones;
DROP SEQUENCE seq_docentes;
DROP SEQUENCE seq_sedes;


-- Secuencias para todos los autoincrementales
CREATE SEQUENCE seq_regiones START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_areas START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_instituciones START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_docentes START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_sedes START WITH 1 INCREMENT BY 1;



-- Creación de la base de datos
-- En Oracle no se utiliza CREATE DATABASE dentro de un script de usuario.
-- Se asume que ya estás conectado a un esquema específico.
-- created_at TIMESTAMP DEFAULT SYSDATE, updated_at TIMESTAMP DEFAULT SYSDATE, se agrega para auditoria de todas las tablas
-- existen demasiadas validaciones que podriamos hacer pero asumimos queel bakcend se encargara para evitar mas trabajo a la DB

CREATE TABLE Regiones (
    id NUMBER PRIMARY KEY,
    nombre VARCHAR2(255) NOT NULL,
    created_at TIMESTAMP DEFAULT SYSDATE,
    updated_at TIMESTAMP DEFAULT SYSDATE
);
CREATE TABLE Areas (
    id NUMBER PRIMARY KEY,
    nombre VARCHAR2(255) NOT NULL,
    estado VARCHAR2(20) CHECK (estado IN ('Activa', 'Inactiva')) NOT NULL,
    created_at TIMESTAMP DEFAULT SYSDATE,
    updated_at TIMESTAMP DEFAULT SYSDATE
);

CREATE TABLE Encargado_Acreditacion (
    id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre VARCHAR2(255) NOT NULL,
    email VARCHAR2(255),
    codigo_pais VARCHAR2(4) NOT NULL,  -- + seguido de hasta 3 dígitos
    codigo_area VARCHAR2(5) NOT NULL,  -- 1 a 5 dígitos
    numero_telefono VARCHAR2(10) NOT NULL, -- 6 a 10 dígitos
    created_at TIMESTAMP DEFAULT SYSDATE,
    updated_at TIMESTAMP DEFAULT SYSDATE,
    CONSTRAINT chk_email CHECK (REGEXP_LIKE(email, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,6}$')),
    CONSTRAINT chk_telefono_formato CHECK (
        REGEXP_LIKE(codigo_pais, '^\+\d{1,3}$') AND  -- Código de país con "+"
        REGEXP_LIKE(codigo_area, '^\d{1,5}$') AND  -- Código de área solo números
        REGEXP_LIKE(numero_telefono, '^\d{6,10}$') -- Número de teléfono solo números
    )
);

-- Tabla de Instituciones
CREATE TABLE Instituciones (
    id NUMBER PRIMARY KEY,
    nombre_institucion VARCHAR2(255) NOT NULL,
    rut_institucion VARCHAR2(20) NOT NULL UNIQUE,
    nombre_max_autoridad VARCHAR2(255) NOT NULL,
    rut_autoridad VARCHAR2(20) NOT NULL UNIQUE,
    direccion_legal VARCHAR2(255) NOT NULL,
    fecha_escritura_publica DATE NOT NULL,
    personeria_juridica_url VARCHAR2(255) NOT NULL,
    tipo VARCHAR2(50) CHECK (tipo IN ('Universidad', 'Instituto Profesional', 'Centro de Formación Técnica')) NOT NULL,
    estado_acreditacion VARCHAR2(20) DEFAULT 'Solicitud' CHECK (estado_acreditacion IN ('Acreditado', 'No Acreditado', 'En Proceso', 'Solicitud')) NOT NULL,
    fecha_fundacion DATE,
    fecha_acreditacion DATE,
    created_at TIMESTAMP DEFAULT SYSDATE,
    updated_at TIMESTAMP DEFAULT SYSDATE,
    CONSTRAINT chk_rut_autoridad CHECK (REGEXP_LIKE(rut_autoridad, '^[0-9]{7,8}-[0-9kK]$')),
    CONSTRAINT chk_rut_institucion CHECK (REGEXP_LIKE(rut_institucion, '^[0-9]{7,8}-[0-9kK]$')),
    CONSTRAINT chk_fecha_fundacion_acreditacion CHECK (fecha_acreditacion > fecha_fundacion) --verificamos que la fecha fundacion es anterior a la fecha de acreditación
);

-- Tabla de sedes
CREATE TABLE Sedes (
    id NUMBER PRIMARY KEY,
    institucion_id NUMBER NOT NULL,
    nombre VARCHAR2(255) NOT NULL,
    direccion VARCHAR2(255),
    region_id NUMBER NOT NULL,
    created_at TIMESTAMP DEFAULT SYSDATE,
    updated_at TIMESTAMP DEFAULT SYSDATE,
    CONSTRAINT fk_sedes_instituciones FOREIGN KEY (institucion_id) REFERENCES Instituciones(id),
    CONSTRAINT fk_sedes_regiones FOREIGN KEY (region_id) REFERENCES Regiones(id)
);

-- Tabla de Acreditaciones y sus estados
-- Se asume que una acreditación puede estar en 3 estados: Vigente, Expirada o En Evaluación
CREATE TABLE Acreditaciones (
    id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    institucion_id NUMBER NOT NULL,
    sede_id NUMBER,
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE NOT NULL,
    estado VARCHAR2(20) CHECK (estado IN ('Vigente', 'Expirada', 'En Evaluación')) NOT NULL,
    resolucion VARCHAR2(255),
    created_at TIMESTAMP DEFAULT SYSDATE,
    updated_at TIMESTAMP DEFAULT SYSDATE,
    CONSTRAINT chk_fecha_inicio_fin_acreditacion CHECK (fecha_fin >= ADD_MONTHS(fecha_inicio, 12)), --asuminos que la acreditación dura al menos 1 año
    CONSTRAINT fk_acreditaciones_instituciones FOREIGN KEY (institucion_id) REFERENCES Instituciones(id),
    CONSTRAINT fk_acreditaciones_sedes FOREIGN KEY (sede_id) REFERENCES sedes(id)
);

-- Tabla de Carreras o Programas
CREATE TABLE Carreras (
    id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    institucion_id NUMBER NOT NULL,
    sede_id NUMBER NOT NULL,
    nombre VARCHAR2(255) NOT NULL,
    area_id NUMBER NOT NULL,
    nivel VARCHAR2(50) CHECK (nivel IN ('Técnico', 'Profesional', 'Postgrado')) NOT NULL,
    estado_acreditacion VARCHAR2(50) CHECK (estado_acreditacion IN ('Acreditado', 'No Acreditado', 'En Proceso')) NOT NULL,
    fecha_acreditacion DATE,
    created_at TIMESTAMP DEFAULT SYSDATE,
    updated_at TIMESTAMP DEFAULT SYSDATE,
    CONSTRAINT fk_carreras_instituciones FOREIGN KEY (institucion_id) REFERENCES Instituciones(id),
    CONSTRAINT fk_carreras_sedes FOREIGN KEY (sede_id) REFERENCES sedes(id),
    CONSTRAINT fk_carreras_area FOREIGN KEY (area_id) REFERENCES Areas(id)
);


-- Tabla de Normativas
CREATE TABLE Normativas (
    id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    codigo VARCHAR2(50) UNIQUE NOT NULL,
    documentoUrl VARCHAR2(255) NOT NULL,
    updated_at TIMESTAMP DEFAULT SYSDATE
);

-- Relación entre Acreditaciones y Normativas
CREATE TABLE Acreditacion_Normativa (
    id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    acreditacion_id NUMBER NOT NULL,
    normativa_id NUMBER NOT NULL,
    created_at TIMESTAMP DEFAULT SYSDATE,
    updated_at TIMESTAMP DEFAULT SYSDATE,
    CONSTRAINT fk_acreditacion_normativa_acreditaciones FOREIGN KEY (acreditacion_id) REFERENCES Acreditaciones(id),
    CONSTRAINT fk_acreditacion_normativa_normativas FOREIGN KEY (normativa_id) REFERENCES Normativas(id)
);

-- Tabla de Infraestructura
CREATE TABLE Infraestructura (
    id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    institucion_id NUMBER NOT NULL,
    sede_id NUMBER NOT NULL,
    recinto VARCHAR2(255) NOT NULL,
    zona VARCHAR2(100),
    piso NUMBER,
    numero_sala NUMBER,
    metros_cuadrados NUMBER(10,2),
    capacidad_estudiantes NUMBER,
    cantidad_sillas NUMBER,
    cantidad_pc NUMBER,
    cantidad_maquinas NUMBER,
    cantidad_cocinas NUMBER,
    cantidad_meson NUMBER,
    created_at TIMESTAMP DEFAULT SYSDATE,
    updated_at TIMESTAMP DEFAULT SYSDATE,
    CONSTRAINT fk_infraestructura_instituciones FOREIGN KEY (institucion_id) REFERENCES Instituciones(id),
    CONSTRAINT fk_infraestructura_sedes FOREIGN KEY (sede_id) REFERENCES sedes(id)
);

-- Tabla de Formación Docente
CREATE TABLE Docentes (
    id NUMBER PRIMARY KEY,
    nombre_completo VARCHAR2(255) NOT NULL,
    rut VARCHAR2(20) UNIQUE NOT NULL,
    fecha_nacimiento DATE,
    nacionalidad VARCHAR2(100),
    codigo_pais VARCHAR2(4) NOT NULL,  -- + seguido de hasta 3 dígitos
    codigo_area VARCHAR2(5) NOT NULL,  -- 1 a 5 dígitos
    numero_telefono VARCHAR2(10) NOT NULL, -- 6 a 10 dígitos
    created_at TIMESTAMP DEFAULT SYSDATE,
    updated_at TIMESTAMP DEFAULT SYSDATE,
     CONSTRAINT chk_telefono_formato_completo CHECK (
        REGEXP_LIKE(codigo_pais, '^\+\d{1,3}$') AND  -- Código de país con "+"
        REGEXP_LIKE(codigo_area, '^\d{1,5}$') AND  -- Código de área solo números
        REGEXP_LIKE(numero_telefono, '^\d{6,10}$') -- Número de teléfono solo números
    ),
    CONSTRAINT chk_rut_docentes CHECK (REGEXP_LIKE(rut, '^[0-9]{7,8}-[0-9kK]$'))
);

-- Tabla de Estudios de los Docentes
CREATE TABLE Pregrado_Postgrado_Docentes (
    id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    institucion VARCHAR2(255) NOT NULL,
    docente_id NUMBER NOT NULL,
    titulo VARCHAR2(255) NOT NULL,
    anio NUMBER NOT NULL,
    codigo_validacion VARCHAR2(50),
    tipo_estudio VARCHAR2(20) CHECK (tipo_estudio IN ('Pregrado', 'Postgrado')) NOT NULL,
    created_at TIMESTAMP DEFAULT SYSDATE,
    updated_at TIMESTAMP DEFAULT SYSDATE,
    CONSTRAINT fk_estudios_docentes FOREIGN KEY (docente_id) REFERENCES Docentes(id)
);

-- Tabla de Cursos de Formación Universitaria o actualizacion de conocimientos de los Docentes
CREATE TABLE Cursos_Formacion (
    id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    institucion VARCHAR2(255) NOT NULL,
    docente_id NUMBER NOT NULL,
    fecha DATE NOT NULL,
    cantidad_horas NUMBER,
    codigo_validacion VARCHAR2(50),
    tipo_estudio VARCHAR2(20) CHECK (tipo_estudio IN ('Curso', 'Capacitación', 'Formación')) NOT NULL,
    created_at TIMESTAMP DEFAULT SYSDATE,
    updated_at TIMESTAMP DEFAULT SYSDATE,
    CONSTRAINT fk_cursos_formacion_docentes FOREIGN KEY (docente_id) REFERENCES Docentes(id)
);

-- Tabla de Cursos de Apoyo para los nuevos estudiantes
CREATE TABLE Cursos_Apoyo (
    id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre VARCHAR2(255) NOT NULL,
    tipo VARCHAR2(50) CHECK (tipo IN ('Curricular', 'Extracurricular')) NOT NULL,
    descripcion VARCHAR2(500),
    carrera_id NUMBER NOT NULL,
    sede_id NUMBER NOT NULL,
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE,
    created_at TIMESTAMP DEFAULT SYSDATE,
    updated_at TIMESTAMP DEFAULT SYSDATE,
    CONSTRAINT chk_fecha_cursos_apoyos CHECK (fecha_fin > fecha_inicio), --verificamos que la fecha de inicio sea anterior a la fecha de término
    CONSTRAINT fk_cursos_apoyo_carrera FOREIGN KEY (carrera_id) REFERENCES Carreras(id),
    CONSTRAINT fk_cursos_apoyo_sedes FOREIGN KEY (sede_id) REFERENCES Sedes(id)
);

CREATE TABLE Plan_Estudio (
    id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    carrera_id NUMBER NOT NULL,
    asignatura VARCHAR2(255) NOT NULL,
    semestre NUMBER NOT NULL,
    horas_teoricas NUMBER NOT NULL,
    horas_practicas NUMBER NOT NULL,
    created_at TIMESTAMP DEFAULT SYSDATE,
    updated_at TIMESTAMP DEFAULT SYSDATE,
    CONSTRAINT fk_plan_estudio_carreras FOREIGN KEY (carrera_id) REFERENCES Carreras(id)
);

-- Tabla de Evaluaciones
CREATE TABLE Evaluaciones (
    id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    carrera_id NUMBER NOT NULL,
    criterio VARCHAR2(255) NOT NULL,
    resultado NUMBER CHECK (resultado BETWEEN 0 AND 7) NOT NULL,
    fecha_evaluacion DATE NOT NULL,
    created_at TIMESTAMP DEFAULT SYSDATE,
    updated_at TIMESTAMP DEFAULT SYSDATE,
    CONSTRAINT fk_evaluacion_carreras FOREIGN KEY (carrera_id) REFERENCES Carreras(id)
);

-- Poblado de datos para todas las tablas
-- Regiones
INSERT INTO Regiones (id, nombre) VALUES (seq_regiones.NEXTVAL, 'Región de Arica y Parinacota');
INSERT INTO Regiones (id, nombre) VALUES (seq_regiones.NEXTVAL, 'Región de Tarapacá');
INSERT INTO Regiones (id, nombre) VALUES (seq_regiones.NEXTVAL, 'Región de Antofagasta');
INSERT INTO Regiones (id, nombre) VALUES (seq_regiones.NEXTVAL, 'Región de Atacama');
INSERT INTO Regiones (id, nombre) VALUES (seq_regiones.NEXTVAL, 'Región de Coquimbo');
INSERT INTO Regiones (id, nombre) VALUES (seq_regiones.NEXTVAL, 'Región de Valparaíso');

-- Areas
INSERT INTO Areas (id, nombre, estado) VALUES (seq_areas.NEXTVAL, 'Ciencias', 'Activa');
INSERT INTO Areas (id, nombre, estado) VALUES (seq_areas.NEXTVAL, 'Ingeniería', 'Activa');
INSERT INTO Areas (id, nombre, estado) VALUES (seq_areas.NEXTVAL, 'Salud', 'Activa');
INSERT INTO Areas (id, nombre, estado) VALUES (seq_areas.NEXTVAL, 'Educación', 'Activa');
INSERT INTO Areas (id, nombre, estado) VALUES (seq_areas.NEXTVAL, 'Humanidades', 'Activa');

-- Encargado_Acreditacion
INSERT INTO Encargado_Acreditacion (nombre, email, codigo_pais, codigo_area, numero_telefono) 
VALUES ('Juan Pérez', 'juan@example.com', '+56', '2', '22222222');
INSERT INTO Encargado_Acreditacion (nombre, email, codigo_pais, codigo_area, numero_telefono)
VALUES ('María González', 'maria@example.com', '+56', '2', '33333333');
INSERT INTO Encargado_Acreditacion (nombre, email, codigo_pais, codigo_area, numero_telefono)
VALUES ('Pedro Rodríguez', 'pedro@example.com', '+56', '2', '44444444');

-- Instituciones
INSERT INTO Instituciones (id, nombre_institucion, rut_institucion, nombre_max_autoridad, rut_autoridad, direccion_legal, fecha_escritura_publica, personeria_juridica_url, tipo, estado_acreditacion, fecha_fundacion, fecha_acreditacion)
VALUES (seq_instituciones.NEXTVAL, 'Universidad de Chile', '60805000-1', 'Enrique Mardones', '7123450-1', 'Av. Libertador Bernardo O''Higgins 1058', TO_DATE('01-01-1842', 'DD-MM-YYYY'), 'https://www.uchile.cl/documentos/personeria-juridica.pdf', 'Universidad', 'Acreditado', TO_DATE('01-01-1842', 'DD-MM-YYYY'), TO_DATE('01-01-2020', 'DD-MM-YYYY'));
INSERT INTO Instituciones (id, nombre_institucion, rut_institucion, nombre_max_autoridad, rut_autoridad, direccion_legal, fecha_escritura_publica, personeria_juridica_url, tipo, estado_acreditacion, fecha_fundacion, fecha_acreditacion)
VALUES (seq_instituciones.NEXTVAL, 'Universidad de Santiago', '60805001-2', 'Enrique Mardones', '7123451-2', 'Av. Libertador Bernardo O''Higgins 1058', TO_DATE('01-01-1842', 'DD-MM-YYYY'), 'https://www.uchile.cl/documentos/personeria-juridica.pdf', 'Universidad', 'Acreditado', TO_DATE('01-01-1842', 'DD-MM-YYYY'), TO_DATE('01-01-2020', 'DD-MM-YYYY'));
INSERT INTO Instituciones (id, nombre_institucion, rut_institucion, nombre_max_autoridad, rut_autoridad, direccion_legal, fecha_escritura_publica, personeria_juridica_url, tipo, estado_acreditacion, fecha_fundacion, fecha_acreditacion)
VALUES (seq_instituciones.NEXTVAL, 'Universidad de Concepción', '60805002-3', 'Enrique Mardones', '7123452-3', 'Av. Libertador Bernardo O''Higgins 1058', TO_DATE('01-01-1842', 'DD-MM-YYYY'), 'https://www.uchile.cl/documentos/personeria-juridica.pdf', 'Universidad', 'Acreditado', TO_DATE('01-01-1842', 'DD-MM-YYYY'), TO_DATE('01-01-2020', 'DD-MM-YYYY'));
INSERT INTO Instituciones (id, nombre_institucion, rut_institucion, nombre_max_autoridad, rut_autoridad, direccion_legal, fecha_escritura_publica, personeria_juridica_url, tipo, estado_acreditacion, fecha_fundacion, fecha_acreditacion)
VALUES (seq_instituciones.NEXTVAL, 'Universidad de Valparaíso', '60805003-4', 'Enrique Mardones', '7123453-4', 'Av. Libertador Bernardo O''Higgins 1058', TO_DATE('01-01-1842', 'DD-MM-YYYY'), 'https://www.uchile.cl/documentos/personeria-juridica.pdf', 'Universidad', 'Acreditado', TO_DATE('01-01-1842', 'DD-MM-YYYY'), TO_DATE('01-01-2020', 'DD-MM-YYYY'));
INSERT INTO Instituciones (id, nombre_institucion, rut_institucion, nombre_max_autoridad, rut_autoridad, direccion_legal, fecha_escritura_publica, personeria_juridica_url, tipo, estado_acreditacion, fecha_fundacion, fecha_acreditacion)
VALUES (seq_instituciones.NEXTVAL, 'Universidad de Talca', '60805004-5', 'Enrique Mardones', '7123454-5', 'Av. Libertador Bernardo O''Higgins 1058', TO_DATE('01-01-1842', 'DD-MM-YYYY'), 'https://www.uchile.cl/documentos/personeria-juridica.pdf', 'Universidad', 'Acreditado', TO_DATE('01-01-1842', 'DD-MM-YYYY'), TO_DATE('01-01-2020', 'DD-MM-YYYY'));
INSERT INTO Instituciones (id, nombre_institucion, rut_institucion, nombre_max_autoridad, rut_autoridad, direccion_legal, fecha_escritura_publica, personeria_juridica_url, tipo, estado_acreditacion, fecha_fundacion, fecha_acreditacion)
VALUES (seq_instituciones.NEXTVAL, 'Universidad de Los Lagos', '60805005-6', 'Enrique Mardones', '7123455-6', 'Av. Libertador Bernardo O''Higgins 1058', TO_DATE('01-01-1842', 'DD-MM-YYYY'), 'https://www.uchile.cl/documentos/personeria-juridica.pdf', 'Universidad', 'Acreditado', TO_DATE('01-01-1842', 'DD-MM-YYYY'), TO_DATE('01-01-2020', 'DD-MM-YYYY'));

-- Sedes
INSERT INTO Sedes (id, institucion_id, nombre, direccion, region_id) VALUES (seq_sedes.NEXTVAL, 1, 'Sede Central', 'Av. Libertador Bernardo O''Higgins 1058', 6);
INSERT INTO Sedes (id, institucion_id, nombre, direccion, region_id) VALUES (seq_sedes.NEXTVAL, 2, 'Sede Central', 'Av. Libertador Bernardo O''Higgins 1058', 6);
INSERT INTO Sedes (id, institucion_id, nombre, direccion, region_id) VALUES (seq_sedes.NEXTVAL, 3, 'Sede Central', 'Av. Libertador Bernardo O''Higgins 1058', 6);
INSERT INTO Sedes (id, institucion_id, nombre, direccion, region_id) VALUES (seq_sedes.NEXTVAL, 4, 'Sede Central', 'Av. Libertador Bernardo O''Higgins 1058', 6);
INSERT INTO Sedes (id, institucion_id, nombre, direccion, region_id) VALUES (seq_sedes.NEXTVAL, 5, 'Sede Central', 'Av. Libertador Bernardo O''Higgins 1058', 6);
INSERT INTO Sedes (id, institucion_id, nombre, direccion, region_id) VALUES (seq_sedes.NEXTVAL, 6, 'Sede Central', 'Av. Libertador Bernardo O''Higgins 1058', 6);


-- Acreditaciones
INSERT INTO Acreditaciones (institucion_id, sede_id, fecha_inicio, fecha_fin, estado, resolucion) VALUES (1, 1, TO_DATE('01-01-2020', 'DD-MM-YYYY'), TO_DATE('01-01-2025', 'DD-MM-YYYY'), 'Vigente', 'Resolución 123');
INSERT INTO Acreditaciones (institucion_id, sede_id, fecha_inicio, fecha_fin, estado, resolucion) VALUES (2, 2, TO_DATE('01-01-2020', 'DD-MM-YYYY'), TO_DATE('01-01-2025', 'DD-MM-YYYY'), 'Vigente', 'Resolución 123');
INSERT INTO Acreditaciones (institucion_id, sede_id, fecha_inicio, fecha_fin, estado, resolucion) VALUES (3, 3, TO_DATE('01-01-2020', 'DD-MM-YYYY'), TO_DATE('01-01-2025', 'DD-MM-YYYY'), 'Vigente', 'Resolución 123');
INSERT INTO Acreditaciones (institucion_id, sede_id, fecha_inicio, fecha_fin, estado, resolucion) VALUES (4, 4, TO_DATE('01-01-2020', 'DD-MM-YYYY'), TO_DATE('01-01-2025', 'DD-MM-YYYY'), 'Vigente', 'Resolución 123');

-- Carreras
INSERT INTO Carreras (institucion_id, sede_id, nombre, area_id, nivel, estado_acreditacion, fecha_acreditacion) VALUES (1, 1, 'Ingeniería Civil', 2, 'Profesional', 'Acreditado', TO_DATE('01-01-2020', 'DD-MM-YYYY'));
INSERT INTO Carreras (institucion_id, sede_id, nombre, area_id, nivel, estado_acreditacion, fecha_acreditacion) VALUES (2, 2, 'Ingeniería Informatica', 2, 'Profesional', 'Acreditado', TO_DATE('01-01-2020', 'DD-MM-YYYY'));
INSERT INTO Carreras (institucion_id, sede_id, nombre, area_id, nivel, estado_acreditacion, fecha_acreditacion) VALUES (3, 3, 'Ingeniería Comercial', 2, 'Profesional', 'Acreditado', TO_DATE('01-01-2020', 'DD-MM-YYYY'));
INSERT INTO Carreras (institucion_id, sede_id, nombre, area_id, nivel, estado_acreditacion, fecha_acreditacion) VALUES (4, 4, 'Ingeniería Industrial', 2, 'Profesional', 'Acreditado', TO_DATE('01-01-2020', 'DD-MM-YYYY'));
INSERT INTO Carreras (institucion_id, sede_id, nombre, area_id, nivel, estado_acreditacion, fecha_acreditacion) VALUES (5, 5, 'Ingeniería Robotica', 2, 'Profesional', 'Acreditado', TO_DATE('01-01-2020', 'DD-MM-YYYY'));
INSERT INTO Carreras (institucion_id, sede_id, nombre, area_id, nivel, estado_acreditacion, fecha_acreditacion) VALUES (6, 6, 'Ingeniería Ciencia de Datos', 2, 'Profesional', 'Acreditado', TO_DATE('01-01-2020', 'DD-MM-YYYY'));
INSERT INTO Carreras (institucion_id, sede_id, nombre, area_id, nivel, estado_acreditacion, fecha_acreditacion) VALUES (1, 1, 'Ingeniería Forestal', 2, 'Profesional', 'Acreditado', TO_DATE('01-01-2020', 'DD-MM-YYYY'));
INSERT INTO Carreras (institucion_id, sede_id, nombre, area_id, nivel, estado_acreditacion, fecha_acreditacion) VALUES (2, 2, 'Medicina', 2, 'Profesional', 'Acreditado', TO_DATE('01-01-2020', 'DD-MM-YYYY'));

-- Normativas
INSERT INTO Normativas (codigo, documentoUrl) VALUES ('Ley 20.126', 'https://www.leychile.cl/Navegar?idNorma=30689');
INSERT INTO Normativas (codigo, documentoUrl) VALUES ('Ley 20.127', 'https://www.leychile.cl/Navegar?idNorma=30689');
INSERT INTO Normativas (codigo, documentoUrl) VALUES ('Ley 20.128', 'https://www.leychile.cl/Navegar?idNorma=30689');
INSERT INTO Normativas (codigo, documentoUrl) VALUES ('Ley 20.129', 'https://www.leychile.cl/Navegar?idNorma=30689');

-- Acreditacion_Normativa
INSERT INTO Acreditacion_Normativa (acreditacion_id, normativa_id) VALUES (1, 1);
INSERT INTO Acreditacion_Normativa (acreditacion_id, normativa_id) VALUES (2, 2);
INSERT INTO Acreditacion_Normativa (acreditacion_id, normativa_id) VALUES (3, 3);
INSERT INTO Acreditacion_Normativa (acreditacion_id, normativa_id) VALUES (4, 4);
INSERT INTO Acreditacion_Normativa (acreditacion_id, normativa_id) VALUES (1, 3);
INSERT INTO Acreditacion_Normativa (acreditacion_id, normativa_id) VALUES (2, 4);

-- Infraestructura
INSERT INTO Infraestructura (institucion_id, sede_id, recinto, zona, piso, numero_sala, metros_cuadrados, capacidad_estudiantes, cantidad_sillas, cantidad_pc, cantidad_maquinas, cantidad_cocinas, cantidad_meson) VALUES (1, 1, 'Edificio Central', 'Zona Norte', 1, 101, 1000, 100, 100, 50, 10, 5, 2);
INSERT INTO Infraestructura (institucion_id, sede_id, recinto, zona, piso, numero_sala, metros_cuadrados, capacidad_estudiantes, cantidad_sillas, cantidad_pc, cantidad_maquinas, cantidad_cocinas, cantidad_meson) VALUES (2, 2, 'Edificio Central', 'Zona Norte', 1, 101, 1000, 100, 100, 50, 10, 5, 2);
INSERT INTO Infraestructura (institucion_id, sede_id, recinto, zona, piso, numero_sala, metros_cuadrados, capacidad_estudiantes, cantidad_sillas, cantidad_pc, cantidad_maquinas, cantidad_cocinas, cantidad_meson) VALUES (3, 3, 'Edificio Central', 'Zona Norte', 1, 101, 1000, 100, 100, 50, 10, 5, 2);
INSERT INTO Infraestructura (institucion_id, sede_id, recinto, zona, piso, numero_sala, metros_cuadrados, capacidad_estudiantes, cantidad_sillas, cantidad_pc, cantidad_maquinas, cantidad_cocinas, cantidad_meson) VALUES (4, 4, 'Edificio Central', 'Zona Norte', 1, 101, 1000, 100, 100, 50, 10, 5, 2);
INSERT INTO Infraestructura (institucion_id, sede_id, recinto, zona, piso, numero_sala, metros_cuadrados, capacidad_estudiantes, cantidad_sillas, cantidad_pc, cantidad_maquinas, cantidad_cocinas, cantidad_meson) VALUES (5, 5, 'Edificio Central', 'Zona Norte', 1, 101, 1000, 100, 100, 50, 10, 5, 2);
INSERT INTO Infraestructura (institucion_id, sede_id, recinto, zona, piso, numero_sala, metros_cuadrados, capacidad_estudiantes, cantidad_sillas, cantidad_pc, cantidad_maquinas, cantidad_cocinas, cantidad_meson) VALUES (6, 6, 'Edificio Central', 'Zona Norte', 1, 101, 1000, 100, 100, 50, 10, 5, 2);

-- Docentes
INSERT INTO Docentes (id, nombre_completo, rut, fecha_nacimiento, nacionalidad, codigo_pais, codigo_area, numero_telefono) VALUES (seq_docentes.NEXTVAL, 'Juan Pérez', '12345678-1', TO_DATE('01-01-1980', 'DD-MM-YYYY'), 'Chilena', '+56', '2', '22222222');
INSERT INTO Docentes (id, nombre_completo, rut, fecha_nacimiento, nacionalidad, codigo_pais, codigo_area, numero_telefono) VALUES (seq_docentes.NEXTVAL, 'María González', '12345678-2', TO_DATE('01-01-1980', 'DD-MM-YYYY'), 'Chilena', '+56', '2', '33333333');
INSERT INTO Docentes (id, nombre_completo, rut, fecha_nacimiento, nacionalidad, codigo_pais, codigo_area, numero_telefono) VALUES (seq_docentes.NEXTVAL, 'Pedro Rodríguez', '12345678-3', TO_DATE('01-01-1980', 'DD-MM-YYYY'), 'Chilena', '+56', '2', '44444444');
INSERT INTO Docentes (id, nombre_completo, rut, fecha_nacimiento, nacionalidad, codigo_pais, codigo_area, numero_telefono) VALUES (seq_docentes.NEXTVAL, 'Juan Pérez', '12345678-4', TO_DATE('01-01-1980', 'DD-MM-YYYY'), 'Chilena', '+56', '2', '22222222');
INSERT INTO Docentes (id, nombre_completo, rut, fecha_nacimiento, nacionalidad, codigo_pais, codigo_area, numero_telefono) VALUES (seq_docentes.NEXTVAL, 'María González', '12345678-5', TO_DATE('01-01-1980', 'DD-MM-YYYY'), 'Chilena', '+56', '2', '33333333');
INSERT INTO Docentes (id, nombre_completo, rut, fecha_nacimiento, nacionalidad, codigo_pais, codigo_area, numero_telefono) VALUES (seq_docentes.NEXTVAL, 'Pedro Rodríguez', '12345678-6', TO_DATE('01-01-1980', 'DD-MM-YYYY'), 'Chilena', '+56', '2', '44444444');

-- REGISTRO Pregrado_Postgrado_Docentes
INSERT INTO Pregrado_Postgrado_Docentes (institucion, docente_id, titulo, anio, codigo_validacion, tipo_estudio) VALUES ('Universidad de Chile', 1, 'Ingeniero Civil', 2000, '123456', 'Pregrado');
INSERT INTO Pregrado_Postgrado_Docentes (institucion, docente_id, titulo, anio, codigo_validacion, tipo_estudio) VALUES ('Universidad de Chile', 2, 'Ingeniero Civil', 2000, '123456', 'Pregrado');
INSERT INTO Pregrado_Postgrado_Docentes (institucion, docente_id, titulo, anio, codigo_validacion, tipo_estudio) VALUES ('Universidad de Chile', 3, 'Ingeniero Civil', 2000, '123456', 'Pregrado');
INSERT INTO Pregrado_Postgrado_Docentes (institucion, docente_id, titulo, anio, codigo_validacion, tipo_estudio) VALUES ('Universidad de Chile', 4, 'Ingeniero Civil', 2000, '123456', 'Pregrado');
INSERT INTO Pregrado_Postgrado_Docentes (institucion, docente_id, titulo, anio, codigo_validacion, tipo_estudio) VALUES ('Universidad de Chile', 5, 'Ingeniero Civil', 2000, '123456', 'Pregrado');
INSERT INTO Pregrado_Postgrado_Docentes (institucion, docente_id, titulo, anio, codigo_validacion, tipo_estudio) VALUES ('Universidad de Chile', 6, 'Ingeniero Civil', 2000, '123456', 'Pregrado');
INSERT INTO Pregrado_Postgrado_Docentes (institucion, docente_id, titulo, anio, codigo_validacion, tipo_estudio) VALUES ('Universidad de Chile', 4, 'Ingeniero Civil', 2000, '123456', 'Pregrado');
INSERT INTO Pregrado_Postgrado_Docentes (institucion, docente_id, titulo, anio, codigo_validacion, tipo_estudio) VALUES ('Universidad de Chile', 1, 'Ingeniero Civil', 2000, '123456', 'Pregrado');
INSERT INTO Pregrado_Postgrado_Docentes (institucion, docente_id, titulo, anio, codigo_validacion, tipo_estudio) VALUES ('Universidad de Chile', 2, 'Ingeniero Civil', 2000, '123456', 'Pregrado');
INSERT INTO Pregrado_Postgrado_Docentes (institucion, docente_id, titulo, anio, codigo_validacion, tipo_estudio) VALUES ('Universidad de Chile', 3, 'Ingeniero Civil', 2000, '123456', 'Pregrado');
INSERT INTO Pregrado_Postgrado_Docentes (institucion, docente_id, titulo, anio, codigo_validacion, tipo_estudio) VALUES ('Universidad de Chile', 4, 'Ingeniero Civil', 2000, '123456', 'Pregrado');
INSERT INTO Pregrado_Postgrado_Docentes (institucion, docente_id, titulo, anio, codigo_validacion, tipo_estudio) VALUES ('Universidad de Chile', 5, 'Ingeniero Civil', 2000, '123456', 'Pregrado');

-- REGISTRO Cursos_Formacion
INSERT INTO Cursos_Formacion (institucion, docente_id, fecha, cantidad_horas, codigo_validacion, tipo_estudio) VALUES ('Universidad de Chile', 1, TO_DATE('01-01-2020', 'DD-MM-YYYY'), 40, '123456', 'Curso');
INSERT INTO Cursos_Formacion (institucion, docente_id, fecha, cantidad_horas, codigo_validacion, tipo_estudio) VALUES ('Universidad de Chile', 2, TO_DATE('01-01-2020', 'DD-MM-YYYY'), 40, '123456', 'Curso');
INSERT INTO Cursos_Formacion (institucion, docente_id, fecha, cantidad_horas, codigo_validacion, tipo_estudio) VALUES ('Universidad de Chile', 3, TO_DATE('01-01-2020', 'DD-MM-YYYY'), 40, '123456', 'Curso');
INSERT INTO Cursos_Formacion (institucion, docente_id, fecha, cantidad_horas, codigo_validacion, tipo_estudio) VALUES ('Universidad de Chile', 4, TO_DATE('01-01-2020', 'DD-MM-YYYY'), 40, '123456', 'Curso');
INSERT INTO Cursos_Formacion (institucion, docente_id, fecha, cantidad_horas, codigo_validacion, tipo_estudio) VALUES ('Universidad de Chile', 5, TO_DATE('01-01-2020', 'DD-MM-YYYY'), 40, '123456', 'Curso');
INSERT INTO Cursos_Formacion (institucion, docente_id, fecha, cantidad_horas, codigo_validacion, tipo_estudio) VALUES ('Universidad de Chile', 6, TO_DATE('01-01-2020', 'DD-MM-YYYY'), 40, '123456', 'Curso');
INSERT INTO Cursos_Formacion (institucion, docente_id, fecha, cantidad_horas, codigo_validacion, tipo_estudio) VALUES ('Universidad de Chile', 6, TO_DATE('01-01-2020', 'DD-MM-YYYY'), 40, '123456', 'Curso');
INSERT INTO Cursos_Formacion (institucion, docente_id, fecha, cantidad_horas, codigo_validacion, tipo_estudio) VALUES ('Universidad de Chile', 1, TO_DATE('01-01-2020', 'DD-MM-YYYY'), 40, '123456', 'Curso');
INSERT INTO Cursos_Formacion (institucion, docente_id, fecha, cantidad_horas, codigo_validacion, tipo_estudio) VALUES ('Universidad de Chile', 2, TO_DATE('01-01-2020', 'DD-MM-YYYY'), 40, '123456', 'Curso');
INSERT INTO Cursos_Formacion (institucion, docente_id, fecha, cantidad_horas, codigo_validacion, tipo_estudio) VALUES ('Universidad de Chile', 3, TO_DATE('01-01-2020', 'DD-MM-YYYY'), 40, '123456', 'Curso');
INSERT INTO Cursos_Formacion (institucion, docente_id, fecha, cantidad_horas, codigo_validacion, tipo_estudio) VALUES ('Universidad de Chile', 4, TO_DATE('01-01-2020', 'DD-MM-YYYY'), 40, '123456', 'Curso');
INSERT INTO Cursos_Formacion (institucion, docente_id, fecha, cantidad_horas, codigo_validacion, tipo_estudio) VALUES ('Universidad de Chile', 5, TO_DATE('01-01-2020', 'DD-MM-YYYY'), 40, '123456', 'Curso');

--Crear registros de Cursos_Apoyo
INSERT INTO Cursos_Apoyo (nombre, tipo, descripcion, carrera_id, sede_id, fecha_inicio, fecha_fin) VALUES ('Curso de Matemáticas', 'Curricular', 'Curso de Matemáticas para estudiantes de primer año', 1, 1, TO_DATE('01-01-2020', 'DD-MM-YYYY'), TO_DATE('01-02-2020', 'DD-MM-YYYY'));
INSERT INTO Cursos_Apoyo (nombre, tipo, descripcion, carrera_id, sede_id, fecha_inicio, fecha_fin) VALUES ('Curso de Matemáticas', 'Curricular', 'Curso de Matemáticas para estudiantes de primer año', 2, 2, TO_DATE('01-01-2020', 'DD-MM-YYYY'), TO_DATE('01-02-2020', 'DD-MM-YYYY'));
INSERT INTO Cursos_Apoyo (nombre, tipo, descripcion, carrera_id, sede_id, fecha_inicio, fecha_fin) VALUES ('Curso de Matemáticas', 'Curricular', 'Curso de Matemáticas para estudiantes de primer año', 3, 3, TO_DATE('01-01-2020', 'DD-MM-YYYY'), TO_DATE('01-02-2020', 'DD-MM-YYYY'));
INSERT INTO Cursos_Apoyo (nombre, tipo, descripcion, carrera_id, sede_id, fecha_inicio, fecha_fin) VALUES ('Curso de Matemáticas', 'Extracurricular', 'Curso de Matemáticas para estudiantes de primer año', 4, 4, TO_DATE('01-01-2020', 'DD-MM-YYYY'), TO_DATE('01-02-2020', 'DD-MM-YYYY'));
INSERT INTO Cursos_Apoyo (nombre, tipo, descripcion, carrera_id, sede_id, fecha_inicio, fecha_fin) VALUES ('Curso de Matemáticas', 'Curricular', 'Curso de Matemáticas para estudiantes de primer año', 1, 1, TO_DATE('01-01-2020', 'DD-MM-YYYY'), TO_DATE('01-02-2020', 'DD-MM-YYYY'));
INSERT INTO Cursos_Apoyo (nombre, tipo, descripcion, carrera_id, sede_id, fecha_inicio, fecha_fin) VALUES ('Curso de Matemáticas', 'Curricular', 'Curso de Matemáticas para estudiantes de primer año', 2, 2, TO_DATE('01-01-2020', 'DD-MM-YYYY'), TO_DATE('01-02-2020', 'DD-MM-YYYY'));
INSERT INTO Cursos_Apoyo (nombre, tipo, descripcion, carrera_id, sede_id, fecha_inicio, fecha_fin) VALUES ('Curso de Matemáticas', 'Extracurricular', 'Curso de Matemáticas para estudiantes de primer año', 3, 3, TO_DATE('01-01-2020', 'DD-MM-YYYY'), TO_DATE('01-02-2020', 'DD-MM-YYYY'));
INSERT INTO Cursos_Apoyo (nombre, tipo, descripcion, carrera_id, sede_id, fecha_inicio, fecha_fin) VALUES ('Curso de Matemáticas', 'Curricular', 'Curso de Matemáticas para estudiantes de primer año', 4, 4, TO_DATE('01-01-2020', 'DD-MM-YYYY'), TO_DATE('01-02-2020', 'DD-MM-YYYY'));
INSERT INTO Cursos_Apoyo (nombre, tipo, descripcion, carrera_id, sede_id, fecha_inicio, fecha_fin) VALUES ('Curso de Matemáticas', 'Curricular', 'Curso de Matemáticas para estudiantes de primer año', 1, 1, TO_DATE('01-01-2020', 'DD-MM-YYYY'), TO_DATE('01-02-2020', 'DD-MM-YYYY'));
INSERT INTO Cursos_Apoyo (nombre, tipo, descripcion, carrera_id, sede_id, fecha_inicio, fecha_fin) VALUES ('Curso de Matemáticas', 'Curricular', 'Curso de Matemáticas para estudiantes de primer año', 2, 2, TO_DATE('01-01-2020', 'DD-MM-YYYY'), TO_DATE('01-02-2020', 'DD-MM-YYYY'));
INSERT INTO Cursos_Apoyo (nombre, tipo, descripcion, carrera_id, sede_id, fecha_inicio, fecha_fin) VALUES ('Curso de Matemáticas', 'Extracurricular', 'Curso de Matemáticas para estudiantes de primer año', 3, 3, TO_DATE('01-01-2020', 'DD-MM-YYYY'), TO_DATE('01-02-2020', 'DD-MM-YYYY'));
INSERT INTO Cursos_Apoyo (nombre, tipo, descripcion, carrera_id, sede_id, fecha_inicio, fecha_fin) VALUES ('Curso de Matemáticas', 'Curricular', 'Curso de Matemáticas para estudiantes de primer año', 4, 4, TO_DATE('01-01-2020', 'DD-MM-YYYY'), TO_DATE('01-02-2020', 'DD-MM-YYYY'));
INSERT INTO Cursos_Apoyo (nombre, tipo, descripcion, carrera_id, sede_id, fecha_inicio, fecha_fin) VALUES ('Curso de Matemáticas', 'Curricular', 'Curso de Matemáticas para estudiantes de primer año', 1, 1, TO_DATE('01-01-2020', 'DD-MM-YYYY'), TO_DATE('01-02-2020', 'DD-MM-YYYY'));
INSERT INTO Cursos_Apoyo (nombre, tipo, descripcion, carrera_id, sede_id, fecha_inicio, fecha_fin) VALUES ('Curso de Matemáticas', 'Curricular', 'Curso de Matemáticas para estudiantes de primer año', 2, 2, TO_DATE('01-01-2020', 'DD-MM-YYYY'), TO_DATE('01-02-2020', 'DD-MM-YYYY'));
INSERT INTO Cursos_Apoyo (nombre, tipo, descripcion, carrera_id, sede_id, fecha_inicio, fecha_fin) VALUES ('Curso de Matemáticas', 'Curricular', 'Curso de Matemáticas para estudiantes de primer año', 3, 3, TO_DATE('01-01-2020', 'DD-MM-YYYY'), TO_DATE('01-02-2020', 'DD-MM-YYYY'));
INSERT INTO Cursos_Apoyo (nombre, tipo, descripcion, carrera_id, sede_id, fecha_inicio, fecha_fin) VALUES ('Curso de Matemáticas', 'Curricular', 'Curso de Matemáticas para estudiantes de primer año', 4, 4, TO_DATE('01-01-2020', 'DD-MM-YYYY'), TO_DATE('01-02-2020', 'DD-MM-YYYY'));
INSERT INTO Cursos_Apoyo (nombre, tipo, descripcion, carrera_id, sede_id, fecha_inicio, fecha_fin) VALUES ('Curso de Matemáticas', 'Extracurricular', 'Curso de Matemáticas para estudiantes de primer año', 1, 1, TO_DATE('01-01-2020', 'DD-MM-YYYY'), TO_DATE('01-02-2020', 'DD-MM-YYYY'));
INSERT INTO Cursos_Apoyo (nombre, tipo, descripcion, carrera_id, sede_id, fecha_inicio, fecha_fin) VALUES ('Curso de Matemáticas', 'Curricular', 'Curso de Matemáticas para estudiantes de primer año', 2, 2, TO_DATE('01-01-2020', 'DD-MM-YYYY'), TO_DATE('01-02-2020', 'DD-MM-YYYY'));
INSERT INTO Cursos_Apoyo (nombre, tipo, descripcion, carrera_id, sede_id, fecha_inicio, fecha_fin) VALUES ('Curso de Matemáticas', 'Curricular', 'Curso de Matemáticas para estudiantes de primer año', 3, 3, TO_DATE('01-01-2020', 'DD-MM-YYYY'), TO_DATE('01-02-2020', 'DD-MM-YYYY'));

-- plan de estudio
INSERT INTO Plan_Estudio (carrera_id, asignatura, semestre, horas_teoricas, horas_practicas) VALUES (1, 'Matemáticas', 1, 4, 2);
INSERT INTO Plan_Estudio (carrera_id, asignatura, semestre, horas_teoricas, horas_practicas) VALUES (1, 'Física', 1, 4, 2);
INSERT INTO Plan_Estudio (carrera_id, asignatura, semestre, horas_teoricas, horas_practicas) VALUES (1, 'Química', 1, 4, 2);
INSERT INTO Plan_Estudio (carrera_id, asignatura, semestre, horas_teoricas, horas_practicas) VALUES (1, 'Programación', 2, 4, 2);
INSERT INTO Plan_Estudio (carrera_id, asignatura, semestre, horas_teoricas, horas_practicas) VALUES (1, 'Base de Datos', 2, 4, 2);
INSERT INTO Plan_Estudio (carrera_id, asignatura, semestre, horas_teoricas, horas_practicas) VALUES (1, 'Inglés', 2, 4, 2);
INSERT INTO Plan_Estudio (carrera_id, asignatura, semestre, horas_teoricas, horas_practicas) VALUES (1, 'Matemáticas', 2, 4, 2);   

-- Evaluaciones
INSERT INTO Evaluaciones (carrera_id, criterio, resultado, fecha_evaluacion) VALUES (1, 'Infraestructura', 7, TO_DATE('01-01-2020', 'DD-MM-YYYY'));
INSERT INTO Evaluaciones (carrera_id, criterio, resultado, fecha_evaluacion) VALUES (2, 'Infraestructura', 7, TO_DATE('01-01-2020', 'DD-MM-YYYY'));
INSERT INTO Evaluaciones (carrera_id, criterio, resultado, fecha_evaluacion) VALUES (3, 'Infraestructura', 7, TO_DATE('01-01-2020', 'DD-MM-YYYY'));
INSERT INTO Evaluaciones (carrera_id, criterio, resultado, fecha_evaluacion) VALUES (4, 'Infraestructura', 7, TO_DATE('01-01-2020', 'DD-MM-YYYY'));
INSERT INTO Evaluaciones (carrera_id, criterio, resultado, fecha_evaluacion) VALUES (5, 'Infraestructura', 7, TO_DATE('01-01-2020', 'DD-MM-YYYY'));
INSERT INTO Evaluaciones (carrera_id, criterio, resultado, fecha_evaluacion) VALUES (6, 'Infraestructura', 7, TO_DATE('01-01-2020', 'DD-MM-YYYY'));
INSERT INTO Evaluaciones (carrera_id, criterio, resultado, fecha_evaluacion) VALUES (7, 'Infraestructura', 7, TO_DATE('01-01-2020', 'DD-MM-YYYY'));

-- Confirmando la escritura de todos los datos
COMMIT;

--Creando la primera tabla usando SQL simple
CREATE TABLE DET_FORMACION_DOCENTE
AS
SELECT * 
FROM DOCENTES;


--Creando segunda tabla personalizando los campo y usando where
CREATE TABLE  DET_INSTALACIONES_DECLARADA(ZONA, PISO, SALA, SILLAS,COMPUTADORAS )
AS
SELECT ZONA, PISO, NUMERO_SALA, CANTIDAD_SILLAS, CANTIDAD_PC
FROM INFRAESTRUCTURA
WHERE RECINTO LIKE '%Central%';




