
-- =======================
-- POBLACIÓN DE TABLAS BASE
-- =======================

-- Tabla: tipo_programa
INSERT INTO tipo_programa (nombre_tipo) VALUES ('Becas de Postgrado');
INSERT INTO tipo_programa (nombre_tipo) VALUES ('Programas');
INSERT INTO tipo_programa (nombre_tipo) VALUES ('Concursos');

-- Tabla: area_programa
INSERT INTO area_programa (nombre_area) VALUES ('Capital Humano');
INSERT INTO area_programa (nombre_area) VALUES ('Proyectos de Investigación');
INSERT INTO area_programa (nombre_area) VALUES ('Centros e Investigación Asociativa');
INSERT INTO area_programa (nombre_area) VALUES ('Investigación Aplicada');
INSERT INTO area_programa (nombre_area) VALUES ('Redes');
INSERT INTO area_programa (nombre_area) VALUES ('Estrategia y Conocimiento');

-- Tabla: tipo_documento
INSERT INTO tipo_documento (id_tipo_documento, descripcion) VALUES (1, 'OBLIGATORIO');
INSERT INTO tipo_documento (id_tipo_documento, descripcion) VALUES (2, 'OPCIONAL');
INSERT INTO tipo_documento (id_tipo_documento, descripcion) VALUES (3, 'BONIFICABLE');

-- Tabla: tipo_sistema
INSERT INTO tipo_sistema (id_tipo_sistema, descripcion) VALUES (1, 'PARAMETRIZADO');
INSERT INTO tipo_sistema (id_tipo_sistema, descripcion) VALUES (2, 'NO PARAMETRIZADO');

-- Tabla: criterio_evaluacion
INSERT INTO criterio_evaluacion (id_criterio, nombre) VALUES (1, 'Antecedentes Académicos');
INSERT INTO criterio_evaluacion (id_criterio, nombre) VALUES (2, 'Objetivos Académicos');

-- Tabla: subcriterio_evaluacion
INSERT INTO subcriterio_evaluacion (id_subcriterio, id_criterio, nombre) VALUES (1, 2, 'Coherencia y claridad de intereses');
INSERT INTO subcriterio_evaluacion (id_subcriterio, id_criterio, nombre) VALUES (2, 2, 'Objetivo de Estudio');
INSERT INTO subcriterio_evaluacion (id_subcriterio, id_criterio, nombre) VALUES (3, 1, 'Desarrollo de actividades de docencia e investigación y estudios de postgrado');
INSERT INTO subcriterio_evaluacion (id_subcriterio, id_criterio, nombre) VALUES (4, 1, 'Cartas de Recomendación');
INSERT INTO subcriterio_evaluacion (id_subcriterio, id_criterio, nombre) VALUES (5, 1, 'Experiencia laboral relacionada con los objetivos de estudio');
INSERT INTO subcriterio_evaluacion (id_subcriterio, id_criterio, nombre) VALUES (6, 2, 'Retribución del postulante al país');

-- Tabla: ponderacion_subcriterio
-- Subcriterio 3
INSERT INTO ponderacion_subcriterio (id_subcriterio, clave, valor) VALUES (3, 'Alta', 5);
INSERT INTO ponderacion_subcriterio (id_subcriterio, clave, valor) VALUES (3, 'Media', 3);
INSERT INTO ponderacion_subcriterio (id_subcriterio, clave, valor) VALUES (3, 'Baja', 2);

-- Subcriterio 5
INSERT INTO ponderacion_subcriterio (id_subcriterio, clave, valor) VALUES (5, 'Más de 5 años', 5);
INSERT INTO ponderacion_subcriterio (id_subcriterio, clave, valor) VALUES (5, '5 años', 4);
INSERT INTO ponderacion_subcriterio (id_subcriterio, clave, valor) VALUES (5, '4 años', 3);
INSERT INTO ponderacion_subcriterio (id_subcriterio, clave, valor) VALUES (5, '3 años', 2);
INSERT INTO ponderacion_subcriterio (id_subcriterio, clave, valor) VALUES (5, '2 años', 1);

-- Subcriterio 4
INSERT INTO ponderacion_subcriterio (id_subcriterio, clave, valor) VALUES (4, 'Alta', 5);
INSERT INTO ponderacion_subcriterio (id_subcriterio, clave, valor) VALUES (4, 'Media', 3);
INSERT INTO ponderacion_subcriterio (id_subcriterio, clave, valor) VALUES (4, 'Baja', 2);

-- Subcriterios 1, 2, 6
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

INSERT INTO pais (id_pais, nombre_pais) VALUES (1, 'Chile');

INSERT INTO region (id_region, nombre_region, id_pais) VALUES (1, 'Región Metropolitana', 1);
INSERT INTO region (id_region, nombre_region, id_pais) VALUES (2, 'Valparaíso', 1);
INSERT INTO region (id_region, nombre_region, id_pais) VALUES (3, 'Biobío', 1);

INSERT INTO genero (id_genero, desc_genero) VALUES (1, 'Masculino');
INSERT INTO genero (id_genero, desc_genero) VALUES (2, 'Femenino');

INSERT INTO estado_civil (id_estado_civil, desc_estado) VALUES (1, 'Soltero');
INSERT INTO estado_civil (id_estado_civil, desc_estado) VALUES (2, 'Casado');

INSERT INTO estado_postulacion (id_estado, estado) VALUES (1, 'En revisión');
INSERT INTO estado_postulacion (id_estado, estado) VALUES (2, 'Aceptado');
INSERT INTO estado_postulacion (id_estado, estado) VALUES (3, 'Rechazado');

INSERT INTO institucion_destino (id_institucion, nombre_institucion, id_ciudad, id_pais, ranking_ocde, url) VALUES (1, 'Universidad de Chile', 1, 1, 45, 'https://uchile.cl');
INSERT INTO institucion_destino (id_institucion, nombre_institucion, id_ciudad, id_pais, ranking_ocde, url) VALUES (2, 'PUC', 2, 1, 32, 'https://puc.cl');
INSERT INTO institucion_destino (id_institucion, nombre_institucion, id_ciudad, id_pais, ranking_ocde, url) VALUES (3, 'Universidad Técnica Federico Santa María', 3, 1, 60, 'https://usm.cl');

INSERT INTO postulante (id_postulante, rut_numero, rut_dv, nombres, ap_paterno, ap_materno, fecha_nacimiento, correo_electronico, telefono_contacto, nacionalidad, discapacidad, id_genero, id_estado_civil, id_region_residencia, id_region_titulacion) VALUES (1, 15006225, '4', 'Genoveva', 'Ojeda', 'Pineda', TO_DATE('1995-02-22','YYYY-MM-DD'), 'drios@bellido.org', '+34956333843', 'Chilena', '', 1, 1, 3, 1);
INSERT INTO postulante (id_postulante, rut_numero, rut_dv, nombres, ap_paterno, ap_materno, fecha_nacimiento, correo_electronico, telefono_contacto, nacionalidad, discapacidad, id_genero, id_estado_civil, id_region_residencia, id_region_titulacion) VALUES (2, 20766437, '7', 'Priscila', 'Mateos', 'Arce', TO_DATE('1986-11-03','YYYY-MM-DD'), 'iglesiatania@bautista.com', '+34 724124489', 'Chilena', '', 2, 2, 3, 3);
INSERT INTO postulante (id_postulante, rut_numero, rut_dv, nombres, ap_paterno, ap_materno, fecha_nacimiento, correo_electronico, telefono_contacto, nacionalidad, discapacidad, id_genero, id_estado_civil, id_region_residencia, id_region_titulacion) VALUES (3, 25822756, '0', 'Donato', 'Gámez', 'Pinedo', TO_DATE('2000-01-11','YYYY-MM-DD'), 'eanaya@yahoo.com', '+34889782938', 'Chilena', '', 2, 2, 1, 3);
INSERT INTO postulante (id_postulante, rut_numero, rut_dv, nombres, ap_paterno, ap_materno, fecha_nacimiento, correo_electronico, telefono_contacto, nacionalidad, discapacidad, id_genero, id_estado_civil, id_region_residencia, id_region_titulacion) VALUES (4, 25072703, '0', 'Alfredo', 'Robles', 'Blanch', TO_DATE('1987-05-04','YYYY-MM-DD'), 'barbamaura@vives.org', '+34717 491 544', 'Chilena', '', 2, 2, 1, 1);
INSERT INTO postulante (id_postulante, rut_numero, rut_dv, nombres, ap_paterno, ap_materno, fecha_nacimiento, correo_electronico, telefono_contacto, nacionalidad, discapacidad, id_genero, id_estado_civil, id_region_residencia, id_region_titulacion) VALUES (5, 26514443, '5', 'Felipa', 'Berenguer', 'Navas', TO_DATE('2000-04-12','YYYY-MM-DD'), 'bmata@yahoo.com', '+34707948874', 'Chilena', 'Visual', 2, 2, 1, 1);
INSERT INTO postulante (id_postulante, rut_numero, rut_dv, nombres, ap_paterno, ap_materno, fecha_nacimiento, correo_electronico, telefono_contacto, nacionalidad, discapacidad, id_genero, id_estado_civil, id_region_residencia, id_region_titulacion) VALUES (6, 23592425, '1', 'Lilia', 'Alberola', 'Belmonte', TO_DATE('1991-11-19','YYYY-MM-DD'), 'ktalavera@gmail.com', '+34729 249 911', 'Chilena', '', 2, 1, 2, 2);
INSERT INTO postulante (id_postulante, rut_numero, rut_dv, nombres, ap_paterno, ap_materno, fecha_nacimiento, correo_electronico, telefono_contacto, nacionalidad, discapacidad, id_genero, id_estado_civil, id_region_residencia, id_region_titulacion) VALUES (7, 17443478, '0', 'Íngrid', 'Hurtado', 'Iniesta', TO_DATE('1988-11-20','YYYY-MM-DD'), 'oguijarro@yahoo.com', '+34 707 997 749', 'Chilena', '', 2, 2, 2, 2);
INSERT INTO postulante (id_postulante, rut_numero, rut_dv, nombres, ap_paterno, ap_materno, fecha_nacimiento, correo_electronico, telefono_contacto, nacionalidad, discapacidad, id_genero, id_estado_civil, id_region_residencia, id_region_titulacion) VALUES (8, 13501709, 'K', 'Sandra', 'Araujo', 'Bauzà', TO_DATE('2001-07-21','YYYY-MM-DD'), 'bzamora@gracia.com', '+34 894 45 24 77', 'Chilena', '', 1, 2, 2, 3);
INSERT INTO postulante (id_postulante, rut_numero, rut_dv, nombres, ap_paterno, ap_materno, fecha_nacimiento, correo_electronico, telefono_contacto, nacionalidad, discapacidad, id_genero, id_estado_civil, id_region_residencia, id_region_titulacion) VALUES (9, 15607658, '0', 'Narciso', 'Palomares', 'Torre', TO_DATE('1991-04-03','YYYY-MM-DD'), 'amadorriquelme@gmail.com', '+34709240112', 'Chilena', 'Auditiva', 2, 1, 1, 3);
INSERT INTO postulante (id_postulante, rut_numero, rut_dv, nombres, ap_paterno, ap_materno, fecha_nacimiento, correo_electronico, telefono_contacto, nacionalidad, discapacidad, id_genero, id_estado_civil, id_region_residencia, id_region_titulacion) VALUES (10, 24109551, '0', 'Amelia', 'Alberto', 'Robledo', TO_DATE('1994-01-03','YYYY-MM-DD'), 'lurena@solano-peralta.com', '+34743 71 61 88', 'Chilena', '', 1, 2, 3, 3);

INSERT INTO programa_becas (id_programa, nombre_programa, fecha_inicio, fecha_fin, id_area, id_tipo_programa) VALUES (1, 'Programa Beca 1', TO_DATE('2024-03-01','YYYY-MM-DD'), TO_DATE('2024-08-28','YYYY-MM-DD'), 3, 3);
INSERT INTO programa_becas (id_programa, nombre_programa, fecha_inicio, fecha_fin, id_area, id_tipo_programa) VALUES (2, 'Programa Beca 2', TO_DATE('2024-03-01','YYYY-MM-DD'), TO_DATE('2024-08-28','YYYY-MM-DD'), 1, 1);
INSERT INTO programa_becas (id_programa, nombre_programa, fecha_inicio, fecha_fin, id_area, id_tipo_programa) VALUES (3, 'Programa Beca 3', TO_DATE('2024-03-01','YYYY-MM-DD'), TO_DATE('2024-08-28','YYYY-MM-DD'), 5, 2);

INSERT INTO documento (id_documento, nombre, id_tipo_documento, id_tipo_sistema) VALUES (1, 'Formulario de postulación y currículum vitae', 2, 2);
INSERT INTO documento (id_documento, nombre, id_tipo_documento, id_tipo_sistema) VALUES (2, 'Copia Cédula de Identidad', 1, 1);
INSERT INTO documento (id_documento, nombre, id_tipo_documento, id_tipo_sistema) VALUES (3, 'Carta de aceptación al programa', 2, 2);
INSERT INTO documento (id_documento, nombre, id_tipo_documento, id_tipo_sistema) VALUES (4, 'Certificado de Alumno regular', 2, 1);
INSERT INTO documento (id_documento, nombre, id_tipo_documento, id_tipo_sistema) VALUES (5, 'Copia de Título Profesional', 3, 2);
INSERT INTO documento (id_documento, nombre, id_tipo_documento, id_tipo_sistema) VALUES (6, 'Certificado de ranking de egreso', 1, 1);
INSERT INTO documento (id_documento, nombre, id_tipo_documento, id_tipo_sistema) VALUES (7, 'Certificado de notas final', 2, 1);
INSERT INTO documento (id_documento, nombre, id_tipo_documento, id_tipo_sistema) VALUES (8, 'Certificado de vigencia de permanencia definitiva', 3, 1);
INSERT INTO documento (id_documento, nombre, id_tipo_documento, id_tipo_sistema) VALUES (9, 'Sección Socioeconómica', 1, 2);
INSERT INTO documento (id_documento, nombre, id_tipo_documento, id_tipo_sistema) VALUES (10, 'Certificados de idioma', 3, 2);
INSERT INTO documento (id_documento, nombre, id_tipo_documento, id_tipo_sistema) VALUES (11, '2 Cartas de Recomendación', 2, 2);
INSERT INTO documento (id_documento, nombre, id_tipo_documento, id_tipo_sistema) VALUES (12, 'Certificado de Veracidad', 3, 1);
INSERT INTO documento (id_documento, nombre, id_tipo_documento, id_tipo_sistema) VALUES (13, 'Copia de otros postgrados', 2, 2);
INSERT INTO documento (id_documento, nombre, id_tipo_documento, id_tipo_sistema) VALUES (14, 'Concentración de notas otros postgrados', 1, 2);
INSERT INTO documento (id_documento, nombre, id_tipo_documento, id_tipo_sistema) VALUES (15, 'Certificado de CONADI', 3, 1);

INSERT INTO postulacion (id_postulacion, id_postulante, id_programa, id_institucion, id_estado, fecha_postulacion) VALUES (1, 1, 1, 3, 1, TO_DATE('2024-04-03','YYYY-MM-DD'));
INSERT INTO postulacion (id_postulacion, id_postulante, id_programa, id_institucion, id_estado, fecha_postulacion) VALUES (2, 2, 1, 1, 3, TO_DATE('2024-04-11','YYYY-MM-DD'));
INSERT INTO postulacion (id_postulacion, id_postulante, id_programa, id_institucion, id_estado, fecha_postulacion) VALUES (3, 3, 1, 1, 2, TO_DATE('2024-04-19','YYYY-MM-DD'));
INSERT INTO postulacion (id_postulacion, id_postulante, id_programa, id_institucion, id_estado, fecha_postulacion) VALUES (4, 4, 1, 3, 1, TO_DATE('2024-04-14','YYYY-MM-DD'));
INSERT INTO postulacion (id_postulacion, id_postulante, id_programa, id_institucion, id_estado, fecha_postulacion) VALUES (5, 5, 1, 3, 1, TO_DATE('2024-04-05','YYYY-MM-DD'));
INSERT INTO postulacion (id_postulacion, id_postulante, id_programa, id_institucion, id_estado, fecha_postulacion) VALUES (6, 6, 2, 2, 3, TO_DATE('2024-04-21','YYYY-MM-DD'));
INSERT INTO postulacion (id_postulacion, id_postulante, id_programa, id_institucion, id_estado, fecha_postulacion) VALUES (7, 7, 1, 3, 1, TO_DATE('2024-04-27','YYYY-MM-DD'));
INSERT INTO postulacion (id_postulacion, id_postulante, id_programa, id_institucion, id_estado, fecha_postulacion) VALUES (8, 8, 1, 3, 2, TO_DATE('2024-04-10','YYYY-MM-DD'));
INSERT INTO postulacion (id_postulacion, id_postulante, id_programa, id_institucion, id_estado, fecha_postulacion) VALUES (9, 9, 2, 1, 1, TO_DATE('2024-04-24','YYYY-MM-DD'));
INSERT INTO postulacion (id_postulacion, id_postulante, id_programa, id_institucion, id_estado, fecha_postulacion) VALUES (10, 10, 2, 1, 1, TO_DATE('2024-04-12','YYYY-MM-DD'));

INSERT INTO documento_presentado (id_documento_presentado, id_postulante, id_postulacion, id_documento, url_archivo, fecha_entrega) VALUES (1, 1, 1, 2, 'https://archivo.com/doc_1.pdf', TO_DATE('2024-04-25', 'YYYY-MM-DD'));
INSERT INTO documento_presentado (id_documento_presentado, id_postulante, id_postulacion, id_documento, url_archivo, fecha_entrega) VALUES (2, 1, 1, 15, 'https://archivo.com/doc_2.pdf', TO_DATE('2024-04-14', 'YYYY-MM-DD'));
INSERT INTO documento_presentado (id_documento_presentado, id_postulante, id_postulacion, id_documento, url_archivo, fecha_entrega) VALUES (3, 2, 2, 3, 'https://archivo.com/doc_3.pdf', TO_DATE('2024-04-13', 'YYYY-MM-DD'));
INSERT INTO documento_presentado (id_documento_presentado, id_postulante, id_postulacion, id_documento, url_archivo, fecha_entrega) VALUES (4, 2, 2, 12, 'https://archivo.com/doc_4.pdf', TO_DATE('2024-04-18', 'YYYY-MM-DD'));
INSERT INTO documento_presentado (id_documento_presentado, id_postulante, id_postulacion, id_documento, url_archivo, fecha_entrega) VALUES (5, 3, 3, 5, 'https://archivo.com/doc_5.pdf', TO_DATE('2024-04-21', 'YYYY-MM-DD'));
INSERT INTO documento_presentado (id_documento_presentado, id_postulante, id_postulacion, id_documento, url_archivo, fecha_entrega) VALUES (6, 3, 3, 14, 'https://archivo.com/doc_6.pdf', TO_DATE('2024-04-05', 'YYYY-MM-DD'));
INSERT INTO documento_presentado (id_documento_presentado, id_postulante, id_postulacion, id_documento, url_archivo, fecha_entrega) VALUES (7, 4, 4, 7, 'https://archivo.com/doc_7.pdf', TO_DATE('2024-04-12', 'YYYY-MM-DD'));
INSERT INTO documento_presentado (id_documento_presentado, id_postulante, id_postulacion, id_documento, url_archivo, fecha_entrega) VALUES (8, 4, 4, 1, 'https://archivo.com/doc_8.pdf', TO_DATE('2024-04-22', 'YYYY-MM-DD'));
INSERT INTO documento_presentado (id_documento_presentado, id_postulante, id_postulacion, id_documento, url_archivo, fecha_entrega) VALUES (9, 5, 5, 5, 'https://archivo.com/doc_9.pdf', TO_DATE('2024-04-02', 'YYYY-MM-DD'));
INSERT INTO documento_presentado (id_documento_presentado, id_postulante, id_postulacion, id_documento, url_archivo, fecha_entrega) VALUES (10, 5, 5, 1, 'https://archivo.com/doc_10.pdf', TO_DATE('2024-04-28', 'YYYY-MM-DD'));
INSERT INTO documento_presentado (id_documento_presentado, id_postulante, id_postulacion, id_documento, url_archivo, fecha_entrega) VALUES (11, 6, 6, 11, 'https://archivo.com/doc_11.pdf', TO_DATE('2024-04-05', 'YYYY-MM-DD'));
INSERT INTO documento_presentado (id_documento_presentado, id_postulante, id_postulacion, id_documento, url_archivo, fecha_entrega) VALUES (12, 6, 6, 13, 'https://archivo.com/doc_12.pdf', TO_DATE('2024-04-11', 'YYYY-MM-DD'));
INSERT INTO documento_presentado (id_documento_presentado, id_postulante, id_postulacion, id_documento, url_archivo, fecha_entrega) VALUES (13, 7, 7, 3, 'https://archivo.com/doc_13.pdf', TO_DATE('2024-04-01', 'YYYY-MM-DD'));
INSERT INTO documento_presentado (id_documento_presentado, id_postulante, id_postulacion, id_documento, url_archivo, fecha_entrega) VALUES (14, 7, 7, 7, 'https://archivo.com/doc_14.pdf', TO_DATE('2024-04-11', 'YYYY-MM-DD'));
INSERT INTO documento_presentado (id_documento_presentado, id_postulante, id_postulacion, id_documento, url_archivo, fecha_entrega) VALUES (15, 8, 8, 3, 'https://archivo.com/doc_15.pdf', TO_DATE('2024-04-07', 'YYYY-MM-DD'));
INSERT INTO documento_presentado (id_documento_presentado, id_postulante, id_postulacion, id_documento, url_archivo, fecha_entrega) VALUES (16, 8, 8, 15, 'https://archivo.com/doc_16.pdf', TO_DATE('2024-04-21', 'YYYY-MM-DD'));
INSERT INTO documento_presentado (id_documento_presentado, id_postulante, id_postulacion, id_documento, url_archivo, fecha_entrega) VALUES (17, 9, 9, 12, 'https://archivo.com/doc_17.pdf', TO_DATE('2024-04-08', 'YYYY-MM-DD'));
INSERT INTO documento_presentado (id_documento_presentado, id_postulante, id_postulacion, id_documento, url_archivo, fecha_entrega) VALUES (18, 9, 9, 14, 'https://archivo.com/doc_18.pdf', TO_DATE('2024-04-06', 'YYYY-MM-DD'));
INSERT INTO documento_presentado (id_documento_presentado, id_postulante, id_postulacion, id_documento, url_archivo, fecha_entrega) VALUES (19, 10, 10, 10, 'https://archivo.com/doc_19.pdf', TO_DATE('2024-04-27', 'YYYY-MM-DD'));
INSERT INTO documento_presentado (id_documento_presentado, id_postulante, id_postulacion, id_documento, url_archivo, fecha_entrega) VALUES (20, 10, 10, 12, 'https://archivo.com/doc_20.pdf', TO_DATE('2024-04-20', 'YYYY-MM-DD'));
INSERT INTO evaluacion_documento (id_evaluacion_documento, id_documento_presentado, id_subcriterio, id_ponderacion, id_evaluador, comentario) VALUES (1, 1, 5, 1, 6564, 'Evaluación automática 1');
INSERT INTO evaluacion_documento (id_evaluacion_documento, id_documento_presentado, id_subcriterio, id_ponderacion, id_evaluador, comentario) VALUES (2, 2, 6, 2, 9934, 'Evaluación automática 2');
INSERT INTO evaluacion_documento (id_evaluacion_documento, id_documento_presentado, id_subcriterio, id_ponderacion, id_evaluador, comentario) VALUES (3, 3, 3, 3, 8303, 'Evaluación automática 3');
INSERT INTO evaluacion_documento (id_evaluacion_documento, id_documento_presentado, id_subcriterio, id_ponderacion, id_evaluador, comentario) VALUES (4, 4, 6, 4, 2338, 'Evaluación automática 4');
INSERT INTO evaluacion_documento (id_evaluacion_documento, id_documento_presentado, id_subcriterio, id_ponderacion, id_evaluador, comentario) VALUES (5, 5, 4, 5, 3403, 'Evaluación automática 5');
INSERT INTO evaluacion_documento (id_evaluacion_documento, id_documento_presentado, id_subcriterio, id_ponderacion, id_evaluador, comentario) VALUES (6, 6, 6, 6, 7324, 'Evaluación automática 6');
INSERT INTO evaluacion_documento (id_evaluacion_documento, id_documento_presentado, id_subcriterio, id_ponderacion, id_evaluador, comentario) VALUES (7, 7, 2, 7, 5931, 'Evaluación automática 7');
INSERT INTO evaluacion_documento (id_evaluacion_documento, id_documento_presentado, id_subcriterio, id_ponderacion, id_evaluador, comentario) VALUES (8, 8, 1, 8, 1336, 'Evaluación automática 8');
INSERT INTO evaluacion_documento (id_evaluacion_documento, id_documento_presentado, id_subcriterio, id_ponderacion, id_evaluador, comentario) VALUES (9, 9, 6, 9, 3817, 'Evaluación automática 9');
INSERT INTO evaluacion_documento (id_evaluacion_documento, id_documento_presentado, id_subcriterio, id_ponderacion, id_evaluador, comentario) VALUES (10, 10, 3, 10, 4314, 'Evaluación automática 10');
INSERT INTO evaluacion_documento (id_evaluacion_documento, id_documento_presentado, id_subcriterio, id_ponderacion, id_evaluador, comentario) VALUES (11, 11, 5, 11, 3971, 'Evaluación automática 11');
INSERT INTO evaluacion_documento (id_evaluacion_documento, id_documento_presentado, id_subcriterio, id_ponderacion, id_evaluador, comentario) VALUES (12, 12, 1, 12, 7038, 'Evaluación automática 12');
INSERT INTO evaluacion_documento (id_evaluacion_documento, id_documento_presentado, id_subcriterio, id_ponderacion, id_evaluador, comentario) VALUES (13, 13, 3, 13, 9053, 'Evaluación automática 13');
INSERT INTO evaluacion_documento (id_evaluacion_documento, id_documento_presentado, id_subcriterio, id_ponderacion, id_evaluador, comentario) VALUES (14, 14, 3, 14, 1170, 'Evaluación automática 14');
INSERT INTO evaluacion_documento (id_evaluacion_documento, id_documento_presentado, id_subcriterio, id_ponderacion, id_evaluador, comentario) VALUES (15, 15, 2, 15, 3114, 'Evaluación automática 15');
INSERT INTO evaluacion_documento (id_evaluacion_documento, id_documento_presentado, id_subcriterio, id_ponderacion, id_evaluador, comentario) VALUES (16, 16, 5, 16, 4711, 'Evaluación automática 16');
INSERT INTO evaluacion_documento (id_evaluacion_documento, id_documento_presentado, id_subcriterio, id_ponderacion, id_evaluador, comentario) VALUES (17, 17, 2, 17, 1126, 'Evaluación automática 17');
INSERT INTO evaluacion_documento (id_evaluacion_documento, id_documento_presentado, id_subcriterio, id_ponderacion, id_evaluador, comentario) VALUES (18, 18, 4, 18, 6952, 'Evaluación automática 18');
INSERT INTO evaluacion_documento (id_evaluacion_documento, id_documento_presentado, id_subcriterio, id_ponderacion, id_evaluador, comentario) VALUES (19, 19, 1, 19, 4222, 'Evaluación automática 19');
INSERT INTO evaluacion_documento (id_evaluacion_documento, id_documento_presentado, id_subcriterio, id_ponderacion, id_evaluador, comentario) VALUES (20, 20, 6, 20, 6783, 'Evaluación automática 20');