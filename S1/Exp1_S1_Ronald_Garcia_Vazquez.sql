-- se ha considerado la implementa la base de datos  segun el enunciado del ejercicio 1 de la semana 1
-- Claves Primarias, Claves Foráneas, NOT NULL,CHECK, UNIQUE, SECUENCIAS, DEFAULT y COLUMNAS AUTOINCREMENTALES
-- Poblado de las tablas con a lo menos 5 filas

-- Secuencias para todos los autoincrementales
CREATE SEQUENCE seq_pacientes START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_empleadores START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_medicos START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_centros_medicos START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_medicos_centros_medicos START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_licencias_medicas START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_control_fisico START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_notificaciones START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_recetas START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_seguimientos START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_tratamientos START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_aseguradoras START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_tipos_licencias START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_cargas_familiares START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_regiones START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_municipalidades START WITH 1 INCREMENT BY 1;


-- Tabla Pacientes que reciben licencias médicas
CREATE TABLE Pacientes (
    id_paciente NUMBER PRIMARY KEY ,
    nombre_completo VARCHAR2(255) NOT NULL,
    rut VARCHAR2(12) NOT NULL UNIQUE,
    fecha_nacimiento DATE NOT NULL,
    genero CHAR(1) NOT NULL CHECK (genero IN ('M', 'F')),
    telefono_contacto VARCHAR2(15)
);

-- Tabla Empleadores de los pacientes
CREATE TABLE Empleadores (
    id_empleador NUMBER PRIMARY KEY,
    nombre_empresa VARCHAR2(255) NOT NULL,
    rut VARCHAR2(12) NOT NULL UNIQUE,
    direccion VARCHAR2(255) NOT NULL
);

-- Tabla Regiones del país
CREATE TABLE Regiones (
    id_region NUMBER PRIMARY KEY,
    nombre_region VARCHAR2(255) NOT NULL
);

-- Tabla Municipalidades pertenecientes a las regiones
CREATE TABLE Municipalidades (
    id_municipalidad NUMBER PRIMARY KEY,
    nombre_municipalidad VARCHAR2(255) NOT NULL,
    id_region NUMBER NOT NULL,
    FOREIGN KEY (id_region) REFERENCES Regiones(id_region)
);

-- Tabla Centros_Medicos autorizados para emitir licencias médicas
CREATE TABLE Centros_Medicos (
    id_centro_medico NUMBER PRIMARY KEY,
    nombre_centro VARCHAR2(255) NOT NULL,
    rut VARCHAR2(12) NOT NULL UNIQUE,
    direccion VARCHAR2(255) NOT NULL,
    telefono VARCHAR2(15) NOT NULL,
    id_municipalidad NUMBER NOT NULL,
    FOREIGN KEY (id_municipalidad) REFERENCES Municipalidades(id_municipalidad)
);

-- Tabla Medicos que emiten las licencias médicas
CREATE TABLE Medicos (
    id_medico NUMBER PRIMARY KEY,
    nombre_completo VARCHAR2(255) NOT NULL,
    rut VARCHAR2(12) NOT NULL UNIQUE,
    numero_registro VARCHAR2(50) NOT NULL UNIQUE,
    firma VARCHAR2(2000) NOT NULL,
    registro_profesional VARCHAR2(2000) NOT NULL
);

-- Tabla Medicos_Centros_Medicos (relación muchos a muchos) o tabla pivote para la relación entre Medicos y Centros_Medicos
-- Un médico puede trabajar en varios centros médicos y un centro médico puede tener varios médicos
CREATE TABLE Medicos_Centros_Medicos (
    id_medico_centro_medico NUMBER PRIMARY KEY,
    id_medico NUMBER NOT NULL,
    id_centro_medico NUMBER NOT NULL,
    FOREIGN KEY (id_medico) REFERENCES Medicos(id_medico),
    FOREIGN KEY (id_centro_medico) REFERENCES Centros_Medicos(id_centro_medico)
);

-- Tabla Aseguradoras que cubren las licencias médicas
CREATE TABLE Aseguradoras (
    id_aseguradora NUMBER PRIMARY KEY,
    sigla VARCHAR2(50) NOT NULL,
    nombre_aseguradora VARCHAR2(255) NOT NULL
);

-- Tabla Diagnosticos de las enfermedades o accidentes que generan las licencias médicas
CREATE TABLE Diagnosticos (
    codigo_diagnostico VARCHAR2(10) PRIMARY KEY,
    descripcion_diagnostico VARCHAR2(2000) NOT NULL
);

-- Tabla Tipos_Licencias que pueden ser emitidas por los médicos
CREATE TABLE Tipos_Licencias (
    id_tipo_licencia NUMBER PRIMARY KEY,
    descripcion VARCHAR2(255) NOT NULL
);

-- Tabla Cargas_Familiares de los pacientes que pueden ser consideradas en las licencias médicas
CREATE TABLE Cargas_Familiares (
    id_carga NUMBER PRIMARY KEY,
    id_paciente NUMBER NOT NULL,
    nombre_completo VARCHAR2(255) NOT NULL,
    fecha_nacimiento DATE NOT NULL,
    genero CHAR(1) NOT NULL CHECK (genero IN ('M', 'F')),
    FOREIGN KEY (id_paciente) REFERENCES Pacientes(id_paciente)
);

-- Tabla Licencias_Medicas emitidas por los médicos a los pacientes con reposo médico
-- Se consideran los campos necesarios para la emisión de licencias médicas
CREATE TABLE Licencias_Medicas (
    id_licencia NUMBER PRIMARY KEY,
    id_paciente NUMBER NOT NULL,
    id_tipo_licencia NUMBER NOT NULL,
    codigo_diagnostico VARCHAR2(10) NOT NULL,
    fecha_inicio DATE NOT NULL,
    fecha_termino DATE NOT NULL,
    id_empleador NUMBER,
    id_medico NUMBER NOT NULL,
    id_aseguradora NUMBER NOT NULL,
    id_carga NUMBER,
    codigo_verificacion VARCHAR2(32) NOT NULL UNIQUE, --UUID PARA VERIFICACIONES ONLINE
    tipo_reposo VARCHAR2(7) CHECK (tipo_reposo IN ('Total', 'Parcial')),
    turno_reposo VARCHAR2(10) CHECK (turno_reposo IN ('Mañana', 'Tarde', 'Noche')),
    lugar_reposo VARCHAR2(9) CHECK (lugar_reposo IN ('Domicilio', 'Hospital', 'Otro')),
    recuperabilidad VARCHAR2(2) CHECK (recuperabilidad IN ('Si', 'No')),
    tramite_invalidez VARCHAR2(2) CHECK (tramite_invalidez IN ('Si', 'No')),
    fecha_accidente DATE,
    hora_accidente VARCHAR2(5),
    trayecto VARCHAR2(2) CHECK (trayecto IN ('Si', 'No')),
    fecha_concepcion DATE,
    FOREIGN KEY (id_paciente) REFERENCES Pacientes(id_paciente),
    FOREIGN KEY (id_empleador) REFERENCES Empleadores(id_empleador),
    FOREIGN KEY (id_medico) REFERENCES Medicos(id_medico),
    FOREIGN KEY (id_aseguradora) REFERENCES Aseguradoras(id_aseguradora),
    FOREIGN KEY (codigo_diagnostico) REFERENCES Diagnosticos(codigo_diagnostico),
    FOREIGN KEY (id_tipo_licencia) REFERENCES Tipos_Licencias(id_tipo_licencia),
    FOREIGN KEY (id_carga) REFERENCES Cargas_Familiares(id_carga),
    CHECK (fecha_termino >= fecha_inicio),
    CHECK ((tipo_reposo = 'Total' AND turno_reposo IS NULL) OR (tipo_reposo = 'Parcial' AND turno_reposo IS NOT NULL)),
    CHECK ((fecha_accidente IS NULL AND hora_accidente IS NULL) OR (fecha_accidente IS NOT NULL AND hora_accidente IS NOT NULL))
);


-- Tabla Notificaciones de las licencias médicas emitidas a los pacientes para que puedan imprimir y presentar a sus empleadores
CREATE TABLE Notificaciones (
    id_notificacion NUMBER PRIMARY KEY,
    id_licencia NUMBER NOT NULL,
    fecha DATE NOT NULL,
    metodo VARCHAR2(50) NOT NULL,
    FOREIGN KEY (id_licencia) REFERENCES Licencias_Medicas(id_licencia)
);

-- Tabla Recetas medicas
CREATE TABLE Recetas (
    id_receta NUMBER PRIMARY KEY,
    id_licencia NUMBER NOT NULL,
    medicamento VARCHAR2(255) NOT NULL,
    dosificacion VARCHAR2(100) NOT NULL,
    FOREIGN KEY (id_licencia) REFERENCES Licencias_Medicas(id_licencia)
);

-- Tabla Seguimientos siempre que se realice un seguimiento a la licencia médica
CREATE TABLE Seguimientos (
    id_seguimiento NUMBER PRIMARY KEY,
    id_licencia NUMBER NOT NULL,
    fecha DATE NOT NULL,
    resultados VARCHAR2(255) NOT NULL,
    id_medico NUMBER NOT NULL,
    FOREIGN KEY (id_licencia) REFERENCES Licencias_Medicas(id_licencia),
    FOREIGN KEY (id_medico) REFERENCES Medicos(id_medico)
);

-- Tabla Tratamientos que se realizan a los pacientes
CREATE TABLE Tratamientos (
    id_tratamiento NUMBER PRIMARY KEY,
    id_licencia NUMBER NOT NULL,
    descripcion VARCHAR2(255) NOT NULL,
    fecha DATE NOT NULL,
    FOREIGN KEY (id_licencia) REFERENCES Licencias_Medicas(id_licencia)
);

-- Poblado de las tablas con al menos 5 filas para todas las tablas.
INSERT INTO Pacientes (id_paciente, nombre_completo, rut, fecha_nacimiento, genero, telefono_contacto) VALUES (seq_pacientes.NEXTVAL, 'Juan Perez', '12345678-9', TO_DATE('1980-01-01', 'YYYY-MM-DD'), 'M', '123456789');
INSERT INTO Pacientes (id_paciente, nombre_completo, rut, fecha_nacimiento, genero, telefono_contacto) VALUES (seq_pacientes.NEXTVAL, 'Maria Lopez', '98765432-1', TO_DATE('1990-02-02', 'YYYY-MM-DD'), 'F', '987654321');
INSERT INTO Pacientes (id_paciente, nombre_completo, rut, fecha_nacimiento, genero, telefono_contacto) VALUES (seq_pacientes.NEXTVAL, 'Carlos Sanchez', '11223344-5', TO_DATE('1985-03-03', 'YYYY-MM-DD'), 'M', '112233445');
INSERT INTO Pacientes (id_paciente, nombre_completo, rut, fecha_nacimiento, genero, telefono_contacto) VALUES (seq_pacientes.NEXTVAL, 'Ana Gonzalez', '55667788-9', TO_DATE('1995-04-04', 'YYYY-MM-DD'), 'F', '556677889');
INSERT INTO Pacientes (id_paciente, nombre_completo, rut, fecha_nacimiento, genero, telefono_contacto) VALUES (seq_pacientes.NEXTVAL, 'Luis Ramirez', '99887766-5', TO_DATE('1975-05-05', 'YYYY-MM-DD'), 'M', '998877665');



INSERT INTO Empleadores (id_empleador, nombre_empresa, rut, direccion) VALUES (seq_empleadores.NEXTVAL, 'Empresa A', '11111111-1', 'Direccion A');
INSERT INTO Empleadores (id_empleador, nombre_empresa, rut, direccion) VALUES (seq_empleadores.NEXTVAL, 'Empresa B', '22222222-2', 'Direccion B');
INSERT INTO Empleadores (id_empleador, nombre_empresa, rut, direccion) VALUES (seq_empleadores.NEXTVAL, 'Empresa C', '33333333-3', 'Direccion C');
INSERT INTO Empleadores (id_empleador, nombre_empresa, rut, direccion) VALUES (seq_empleadores.NEXTVAL, 'Empresa D', '44444444-4', 'Direccion D');
INSERT INTO Empleadores (id_empleador, nombre_empresa, rut, direccion) VALUES (seq_empleadores.NEXTVAL, 'Empresa E', '55555555-5', 'Direccion E');


INSERT INTO Regiones (id_region, nombre_region) VALUES (seq_regiones.NEXTVAL, 'Region A');
INSERT INTO Regiones (id_region, nombre_region) VALUES (seq_regiones.NEXTVAL, 'Region B');
INSERT INTO Regiones (id_region, nombre_region) VALUES (seq_regiones.NEXTVAL, 'Region C');
INSERT INTO Regiones (id_region, nombre_region) VALUES (seq_regiones.NEXTVAL, 'Region D');
INSERT INTO Regiones (id_region, nombre_region) VALUES (seq_regiones.NEXTVAL, 'Region E');


INSERT INTO Municipalidades (id_municipalidad, nombre_municipalidad, id_region) VALUES (seq_municipalidades.NEXTVAL, 'Municipalidad A1', 1);
INSERT INTO Municipalidades (id_municipalidad, nombre_municipalidad, id_region) VALUES (seq_municipalidades.NEXTVAL, 'Municipalidad A2', 1);
INSERT INTO Municipalidades (id_municipalidad, nombre_municipalidad, id_region) VALUES (seq_municipalidades.NEXTVAL, 'Municipalidad B1', 2);
INSERT INTO Municipalidades (id_municipalidad, nombre_municipalidad, id_region) VALUES (seq_municipalidades.NEXTVAL, 'Municipalidad B2', 2);
INSERT INTO Municipalidades (id_municipalidad, nombre_municipalidad, id_region) VALUES (seq_municipalidades.NEXTVAL, 'Municipalidad C1', 3);
INSERT INTO Municipalidades (id_municipalidad, nombre_municipalidad, id_region) VALUES (seq_municipalidades.NEXTVAL, 'Municipalidad C2', 3);
INSERT INTO Municipalidades (id_municipalidad, nombre_municipalidad, id_region) VALUES (seq_municipalidades.NEXTVAL, 'Municipalidad D1', 4);
INSERT INTO Municipalidades (id_municipalidad, nombre_municipalidad, id_region) VALUES (seq_municipalidades.NEXTVAL, 'Municipalidad D2', 4);
INSERT INTO Municipalidades (id_municipalidad, nombre_municipalidad, id_region) VALUES (seq_municipalidades.NEXTVAL, 'Municipalidad E1', 5);
INSERT INTO Municipalidades (id_municipalidad, nombre_municipalidad, id_region) VALUES (seq_municipalidades.NEXTVAL, 'Municipalidad E2', 5);


INSERT INTO Centros_Medicos (id_centro_medico, nombre_centro, rut, direccion, telefono, id_municipalidad) VALUES (seq_centros_medicos.NEXTVAL, 'Centro Medico A', '11111111-1', 'Direccion A', '123456789', 1);
INSERT INTO Centros_Medicos (id_centro_medico, nombre_centro, rut, direccion, telefono, id_municipalidad) VALUES (seq_centros_medicos.NEXTVAL, 'Centro Medico B', '22222222-2', 'Direccion B', '987654321', 2);
INSERT INTO Centros_Medicos (id_centro_medico, nombre_centro, rut, direccion, telefono, id_municipalidad) VALUES (seq_centros_medicos.NEXTVAL, 'Centro Medico C', '33333333-3', 'Direccion C', '112233445', 3);
INSERT INTO Centros_Medicos (id_centro_medico, nombre_centro, rut, direccion, telefono, id_municipalidad) VALUES (seq_centros_medicos.NEXTVAL, 'Centro Medico D', '44444444-4', 'Direccion D', '556677889', 4);
INSERT INTO Centros_Medicos (id_centro_medico, nombre_centro, rut, direccion, telefono, id_municipalidad) VALUES (seq_centros_medicos.NEXTVAL, 'Centro Medico E', '55555555-5', 'Direccion E', '998877665', 5);


INSERT INTO Medicos (id_medico, nombre_completo, rut, numero_registro, firma, registro_profesional) VALUES (seq_medicos.NEXTVAL, 'Dr. Juan Martinez', '11112222-3', 'REG12345', 'Firma1', 'registro_profesional1');
INSERT INTO Medicos (id_medico, nombre_completo, rut, numero_registro, firma, registro_profesional) VALUES (seq_medicos.NEXTVAL, 'Dr. Ana Torres', '22223333-4', 'REG12346', 'Firma2', 'registro_profesional2');
INSERT INTO Medicos (id_medico, nombre_completo, rut, numero_registro, firma, registro_profesional) VALUES (seq_medicos.NEXTVAL, 'Dr. Pedro Diaz', '33334444-5', 'REG12347', 'Firma3', 'registro_profesional3');
INSERT INTO Medicos (id_medico, nombre_completo, rut, numero_registro, firma, registro_profesional) VALUES (seq_medicos.NEXTVAL, 'Dr. Lucia Fernandez', '44445555-6', 'REG12348', 'Firma4', 'registro_profesional4');
INSERT INTO Medicos (id_medico, nombre_completo, rut, numero_registro, firma, registro_profesional) VALUES (seq_medicos.NEXTVAL, 'Dr. Carlos Ruiz', '55556666-7', 'REG12349', 'Firma5', 'registro_profesional5');



INSERT INTO Medicos_Centros_Medicos (id_medico_centro_medico, id_medico, id_centro_medico) VALUES (seq_medicos_centros_medicos.NEXTVAL, 1, 1);
INSERT INTO Medicos_Centros_Medicos (id_medico_centro_medico, id_medico, id_centro_medico) VALUES (seq_medicos_centros_medicos.NEXTVAL, 1, 2);
INSERT INTO Medicos_Centros_Medicos (id_medico_centro_medico, id_medico, id_centro_medico) VALUES (seq_medicos_centros_medicos.NEXTVAL, 2, 2);
INSERT INTO Medicos_Centros_Medicos (id_medico_centro_medico, id_medico, id_centro_medico) VALUES (seq_medicos_centros_medicos.NEXTVAL, 3, 3);
INSERT INTO Medicos_Centros_Medicos (id_medico_centro_medico, id_medico, id_centro_medico) VALUES (seq_medicos_centros_medicos.NEXTVAL, 4, 4);
INSERT INTO Medicos_Centros_Medicos (id_medico_centro_medico, id_medico, id_centro_medico) VALUES (seq_medicos_centros_medicos.NEXTVAL, 5, 5);



INSERT INTO Aseguradoras (id_aseguradora, sigla, nombre_aseguradora) VALUES (seq_aseguradoras.NEXTVAL, 'Fonasa', 'Fondo Nacional de Salud');
INSERT INTO Aseguradoras (id_aseguradora, sigla, nombre_aseguradora) VALUES (seq_aseguradoras.NEXTVAL, 'Isapre A', 'Instituciones de Salud Previsional A');
INSERT INTO Aseguradoras (id_aseguradora, sigla, nombre_aseguradora) VALUES (seq_aseguradoras.NEXTVAL, 'Isapre B', 'Instituciones de Salud Previsional B');
INSERT INTO Aseguradoras (id_aseguradora, sigla, nombre_aseguradora) VALUES (seq_aseguradoras.NEXTVAL, 'Isapre C', 'Instituciones de Salud Previsional C');
INSERT INTO Aseguradoras (id_aseguradora, sigla, nombre_aseguradora) VALUES (seq_aseguradoras.NEXTVAL, 'Isapre D', 'Instituciones de Salud Previsional D');



INSERT INTO Diagnosticos (codigo_diagnostico, descripcion_diagnostico) VALUES ('A00', 'Cólera');
INSERT INTO Diagnosticos (codigo_diagnostico, descripcion_diagnostico) VALUES ('S00', 'Herida en la cabeza');
INSERT INTO Diagnosticos (codigo_diagnostico, descripcion_diagnostico) VALUES ('O00', 'Embarazo');
INSERT INTO Diagnosticos (codigo_diagnostico, descripcion_diagnostico) VALUES ('J00', 'Gripe');
INSERT INTO Diagnosticos (codigo_diagnostico, descripcion_diagnostico) VALUES ('T00', 'Trauma múltiple');



INSERT INTO Tipos_Licencias (id_tipo_licencia, descripcion) VALUES (1, 'Enfermedad o Accidente Común');
INSERT INTO Tipos_Licencias (id_tipo_licencia, descripcion) VALUES (2, 'Prórroga Medicina Preventiva');
INSERT INTO Tipos_Licencias (id_tipo_licencia, descripcion) VALUES (3, 'Licencia Maternal Pre y Post Natal');
INSERT INTO Tipos_Licencias (id_tipo_licencia, descripcion) VALUES (4, 'Enfermedad Grave Niño Menor de 1 Año');
INSERT INTO Tipos_Licencias (id_tipo_licencia, descripcion) VALUES (5, 'Accidente del Trabajo o del Trayecto');
INSERT INTO Tipos_Licencias (id_tipo_licencia, descripcion) VALUES (6, 'Enfermedad Profesional');


INSERT INTO Cargas_Familiares (id_carga, id_paciente, nombre_completo, fecha_nacimiento, genero) VALUES (seq_cargas_familiares.NEXTVAL, 1, 'Pedro Perez',TO_DATE('2020-01-01', 'YYYY-MM-DD'), 'M');
INSERT INTO Cargas_Familiares (id_carga, id_paciente, nombre_completo, fecha_nacimiento, genero) VALUES (seq_cargas_familiares.NEXTVAL, 2, 'Ana Lopez', TO_DATE('2021-02-02', 'YYYY-MM-DD'), 'F');
INSERT INTO Cargas_Familiares (id_carga, id_paciente, nombre_completo, fecha_nacimiento, genero) VALUES (seq_cargas_familiares.NEXTVAL, 3, 'Luis Sanchez', TO_DATE('2019-03-03', 'YYYY-MM-DD'), 'M');
INSERT INTO Cargas_Familiares (id_carga, id_paciente, nombre_completo, fecha_nacimiento, genero) VALUES (seq_cargas_familiares.NEXTVAL, 4, 'Maria Gonzalez', TO_DATE('2022-04-04', 'YYYY-MM-DD'), 'F');
INSERT INTO Cargas_Familiares (id_carga, id_paciente, nombre_completo, fecha_nacimiento, genero) VALUES (seq_cargas_familiares.NEXTVAL, 5, 'Carlos Ramirez', TO_DATE('2023-05-05', 'YYYY-MM-DD'), 'M');


INSERT INTO Licencias_Medicas (id_licencia, id_paciente, id_tipo_licencia, codigo_diagnostico, fecha_inicio, fecha_termino, id_empleador, id_medico, id_aseguradora, id_carga, codigo_verificacion, tipo_reposo, turno_reposo, lugar_reposo, recuperabilidad, tramite_invalidez, fecha_accidente, hora_accidente, trayecto, fecha_concepcion) VALUES
(seq_licencias_medicas.NEXTVAL, 1, 1, 'A00',TO_DATE( '2023-01-01', 'YYYY-MM-DD'),TO_DATE( '2023-01-10', 'YYYY-MM-DD'), 1, 1, 1, NULL,'1e2d3c4b5a6f7e8d9c0b1a2f3e4d5c6b', 'Total', NULL, 'Domicilio', 'Si', 'No', NULL, NULL, 'No', NULL);
INSERT INTO Licencias_Medicas (id_licencia, id_paciente, id_tipo_licencia, codigo_diagnostico, fecha_inicio, fecha_termino, id_empleador, id_medico, id_aseguradora, id_carga, codigo_verificacion, tipo_reposo, turno_reposo, lugar_reposo, recuperabilidad, tramite_invalidez, fecha_accidente, hora_accidente, trayecto, fecha_concepcion) VALUES
(seq_licencias_medicas.NEXTVAL, 2, 5, 'S00', TO_DATE('2023-02-01', 'YYYY-MM-DD'), TO_DATE('2023-02-15', 'YYYY-MM-DD'), 2, 2, 2, NULL,'7f8e9d0c1b2a3f4e5d6c7b8a9e0d1c2b', 'Parcial', 'Mañana', 'Hospital', 'No', 'Si',TO_DATE( '2023-01-31', 'YYYY-MM-DD'), '08:30', 'Si', NULL);
INSERT INTO Licencias_Medicas (id_licencia, id_paciente, id_tipo_licencia, codigo_diagnostico, fecha_inicio, fecha_termino, id_empleador, id_medico, id_aseguradora, id_carga, codigo_verificacion, tipo_reposo, turno_reposo, lugar_reposo, recuperabilidad, tramite_invalidez, fecha_accidente, hora_accidente, trayecto, fecha_concepcion) VALUES
(seq_licencias_medicas.NEXTVAL, 3, 3, 'O00',TO_DATE( '2023-03-01', 'YYYY-MM-DD'),TO_DATE( '2023-03-30', 'YYYY-MM-DD'), 3, 3, 3, NULL,'3e4d5c6b7a8f9e0d1c2b3a4f5e6d7c8b', 'Total', NULL, 'Otro', 'Si', 'No', NULL, NULL, 'No',TO_DATE( '2023-02-01', 'YYYY-MM-DD'));
INSERT INTO Licencias_Medicas (id_licencia, id_paciente, id_tipo_licencia, codigo_diagnostico, fecha_inicio, fecha_termino, id_empleador, id_medico, id_aseguradora, id_carga, codigo_verificacion, tipo_reposo, turno_reposo, lugar_reposo, recuperabilidad, tramite_invalidez, fecha_accidente, hora_accidente, trayecto, fecha_concepcion) VALUES
(seq_licencias_medicas.NEXTVAL, 4, 1, 'J00',TO_DATE( '2023-04-01', 'YYYY-MM-DD'), TO_DATE('2023-04-10', 'YYYY-MM-DD'), 4, 4, 4, NULL,'9e0d1c2b3a4f5e6d7c8b9a0d1e2c3b4a', 'Parcial', 'Tarde', 'Domicilio', 'No', 'No', NULL, NULL, 'No', NULL);
INSERT INTO Licencias_Medicas (id_licencia, id_paciente, id_tipo_licencia, codigo_diagnostico, fecha_inicio, fecha_termino, id_empleador, id_medico, id_aseguradora, id_carga, codigo_verificacion, tipo_reposo, turno_reposo, lugar_reposo, recuperabilidad, tramite_invalidez, fecha_accidente, hora_accidente, trayecto, fecha_concepcion) VALUES
(seq_licencias_medicas.NEXTVAL, 5, 5, 'T00',TO_DATE( '2023-05-01', 'YYYY-MM-DD'), TO_DATE('2023-05-20', 'YYYY-MM-DD'), 5, 5, 5, NULL,'5e6d7c8b9a0d1e2c3b4a5f6d7e8c9b0a', 'Total', NULL, 'Hospital', 'Si', 'No',TO_DATE( '2023-04-30', 'YYYY-MM-DD'), '14:00', 'Si', NULL);
INSERT INTO Licencias_Medicas (id_licencia, id_paciente, id_tipo_licencia, codigo_diagnostico, fecha_inicio, fecha_termino, id_empleador, id_medico, id_aseguradora, id_carga, codigo_verificacion, tipo_reposo, turno_reposo, lugar_reposo, recuperabilidad, tramite_invalidez, fecha_accidente, hora_accidente, trayecto, fecha_concepcion) VALUES
(seq_licencias_medicas.NEXTVAL, 1, 4, 'J00', TO_DATE('2023-06-01', 'YYYY-MM-DD'),TO_DATE( '2023-06-10', 'YYYY-MM-DD'), 1, 1, 1, 1,'6f7e8d9c0b1a2f3e4d5c6b7a8f9e0d1c', 'Parcial', 'Noche', 'Otro', 'No', 'Si', NULL, NULL, 'No', NULL);


INSERT INTO Notificaciones (id_notificacion, id_licencia, fecha, metodo) VALUES (seq_notificaciones.NEXTVAL, 1, TO_DATE('2023-01-02', 'YYYY-MM-DD'), 'Email');
INSERT INTO Notificaciones (id_notificacion, id_licencia, fecha, metodo) VALUES (seq_notificaciones.NEXTVAL, 2, TO_DATE('2023-02-02', 'YYYY-MM-DD'), 'Email');
INSERT INTO Notificaciones (id_notificacion, id_licencia, fecha, metodo) VALUES (seq_notificaciones.NEXTVAL, 3, TO_DATE('2023-03-02', 'YYYY-MM-DD'), 'Email');
INSERT INTO Notificaciones (id_notificacion, id_licencia, fecha, metodo) VALUES (seq_notificaciones.NEXTVAL, 4, TO_DATE('2023-04-02', 'YYYY-MM-DD'), 'Email');
INSERT INTO Notificaciones (id_notificacion, id_licencia, fecha, metodo) VALUES (seq_notificaciones.NEXTVAL, 5, TO_DATE('2023-05-02', 'YYYY-MM-DD'), 'Email');


INSERT INTO Recetas (id_receta, id_licencia, medicamento, dosificacion) VALUES (seq_recetas.NEXTVAL, 1, 'Medicamento A', '1 vez al día');
INSERT INTO Recetas (id_receta, id_licencia, medicamento, dosificacion) VALUES (seq_recetas.NEXTVAL, 2, 'Medicamento B', '2 veces al día');
INSERT INTO Recetas (id_receta, id_licencia, medicamento, dosificacion) VALUES (seq_recetas.NEXTVAL, 3, 'Medicamento C', '3 veces al día');
INSERT INTO Recetas (id_receta, id_licencia, medicamento, dosificacion) VALUES (seq_recetas.NEXTVAL, 4, 'Medicamento D', '1 vez al día');
INSERT INTO Recetas (id_receta, id_licencia, medicamento, dosificacion) VALUES (seq_recetas.NEXTVAL, 5, 'Medicamento E', '2 veces al día');


INSERT INTO Seguimientos (id_seguimiento, id_licencia, fecha, resultados, id_medico) VALUES (seq_seguimientos.NEXTVAL, 1,TO_DATE( '2023-01-10', 'YYYY-MM-DD'), 'Mejoría', 1);
INSERT INTO Seguimientos (id_seguimiento, id_licencia, fecha, resultados, id_medico) VALUES (seq_seguimientos.NEXTVAL, 2,TO_DATE( '2023-02-15', 'YYYY-MM-DD'), 'Mejoría', 2);
INSERT INTO Seguimientos (id_seguimiento, id_licencia, fecha, resultados, id_medico) VALUES (seq_seguimientos.NEXTVAL, 3,TO_DATE( '2023-03-30', 'YYYY-MM-DD'), 'Mejoría', 3);
INSERT INTO Seguimientos (id_seguimiento, id_licencia, fecha, resultados, id_medico) VALUES (seq_seguimientos.NEXTVAL, 4, TO_DATE('2023-04-10', 'YYYY-MM-DD'), 'Mejoría', 4);
INSERT INTO Seguimientos (id_seguimiento, id_licencia, fecha, resultados, id_medico) VALUES (seq_seguimientos.NEXTVAL, 5, TO_DATE('2023-05-20', 'YYYY-MM-DD'), 'Mejoría', 5);

COMMIT;
/*
SELECT * FROM Pacientes;
SELECT * FROM Empleadores;
SELECT * FROM Regiones;
SELECT * FROM Municipalidades;
SELECT * FROM Centros_Medicos;
SELECT * FROM Medicos;
SELECT * FROM Medicos_Centros_Medicos;
SELECT * FROM Aseguradoras;
SELECT * FROM Diagnosticos;
SELECT * FROM Tipos_Licencias;
SELECT * FROM Cargas_Familiares;
SELECT * FROM Licencias_Medicas;
SELECT * FROM Notificaciones;
SELECT * FROM Recetas;
SELECT * FROM Seguimientos;

DROP TABLE Licencias_Medicas;
DROP TABLE Notificaciones;
DROP TABLE Recetas;
DROP TABLE Seguimientos;

BEGIN
    FOR cur IN (SELECT table_name FROM user_tables) LOOP
        EXECUTE IMMEDIATE 'DROP TABLE ' || cur.table_name || ' CASCADE CONSTRAINTS';
    END LOOP;
END;
BEGIN
    FOR cur IN (SELECT sequence_name FROM user_sequences) LOOP
        EXECUTE IMMEDIATE 'DROP SEQUENCE ' || cur.sequence_name;
    END LOOP;
END;

ALTER TABLE Cargas_Familiares DROP COLUMN id_carga;
ALTER TABLE Cargas_Familiares ADD id_carga INTEGER DEFAULT seq_cargas_familiares.NEXTVAL PRIMARY KEY;
*/