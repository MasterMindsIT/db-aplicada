
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
    nota_media_pregrado NUMBER(3, 2) DEFAULT null CHECK (nota_media_pregrado IS NULL OR (nota_media_pregrado >= 0 AND nota_media_pregrado <= 7)),--usuario verificador_notas
    posicion_ranking NUMBER DEFAULT null CHECK (posicion_ranking IS NULL OR posicion_ranking > 0), --Usuario verificador_notas
    total_egresados NUMBER DEFAULT null CHECK (total_egresados IS NULL OR total_egresados > 0),--Usuario verificador_notas
    puntaje_aa NUMBER(5, 3) DEFAULT null CHECK (puntaje_aa IS NULL OR (puntaje_aa >= 0 AND puntaje_aa <= 5)), --Usuario administrador_system
    CONSTRAINT chk_telefono_contacto CHECK (telefono_contacto IS NULL OR LENGTH(telefono_contacto) <= 20),
    CONSTRAINT chk_rut CHECK (rut_numero > 0 AND LENGTH(rut_numero) <= 8),
    FOREIGN KEY (id_genero) REFERENCES genero(id_genero),
    FOREIGN KEY (id_estado_civil) REFERENCES estado_civil(id_estado_civil),
    FOREIGN KEY (id_region_residencia) REFERENCES region(id_region),
    FOREIGN KEY (id_region_titulacion) REFERENCES region(id_region),
    CONSTRAINT uq_postulante_rut UNIQUE (rut_numero, rut_dv)
);


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