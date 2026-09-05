-- =============================================================================
-- Base de datos: knowledge_map_db
-- Base de datos completa del Sistema de Gestion de Informacion
-- del Conocimiento Universitario
-- Total de tablas del modelo: 57
-- Tablas de gestion de usuarios: 3
-- Total de tablas: 60
-- =============================================================================

CREATE DATABASE IF NOT EXISTS `knowledge_map_db`;
USE `knowledge_map_db`;

-- =============================================
-- MODULO: CARACTERIZACION
-- =============================================

-- Tabla: area_aplicacion
CREATE TABLE IF NOT EXISTS `area_aplicacion` (
    `id` INT NOT NULL,
    `nombre` VARCHAR(60) NOT NULL,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB;

-- Tabla: area_conocimiento
CREATE TABLE IF NOT EXISTS `area_conocimiento` (
    `id` INT NOT NULL,
    `gran_area` VARCHAR(60) NOT NULL,
    `area` VARCHAR(60) NOT NULL,
    `disciplina` VARCHAR(60) NOT NULL,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB;

-- Tabla: objetivo_desarrollo_sostenible
CREATE TABLE IF NOT EXISTS `objetivo_desarrollo_sostenible` (
    `id` INT NOT NULL,
    `nombre` VARCHAR(60) NOT NULL,
    `categoria` VARCHAR(45) NOT NULL,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB;

-- =============================================
-- MODULO: COMUN
-- =============================================

-- Tabla: linea_investigacion
CREATE TABLE IF NOT EXISTS `linea_investigacion` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `nombre` VARCHAR(45) NOT NULL,
    `descripcion` VARCHAR(256) NOT NULL,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB;

-- Tabla: termino_clave
CREATE TABLE IF NOT EXISTS `termino_clave` (
    `termino` VARCHAR(30) NOT NULL,
    `termino_ingles` VARCHAR(30),
    PRIMARY KEY (`termino`)
) ENGINE=InnoDB;

-- Tabla: docente
CREATE TABLE IF NOT EXISTS `docente` (
    `cedula` INT NOT NULL,
    `nombres` VARCHAR(60) NOT NULL,
    `apellidos` VARCHAR(60) NOT NULL,
    `genero` VARCHAR(12) NOT NULL,
    `cargo` VARCHAR(30) NOT NULL,
    `fecha_nacimiento` DATE NOT NULL,
    `correo` VARCHAR(70) NOT NULL,
    `telefono` VARCHAR(20) NOT NULL,
    `url_cvlac` VARCHAR(128) NOT NULL,
    `fecha_actualizacion` DATE NOT NULL,
    `escalafon` VARCHAR(45) NOT NULL,
    `perfil` LONGTEXT NOT NULL,
    `cat_minciencia` VARCHAR(45),
    `conv_minciencia` VARCHAR(45) NOT NULL,
    `nacionalidaad` VARCHAR(45) NOT NULL,
    `linea_investigacion_principal` INT,
    PRIMARY KEY (`cedula`),
    FOREIGN KEY (`linea_investigacion_principal`) REFERENCES `linea_investigacion`(`id`)
) ENGINE=InnoDB;

-- =============================================
-- MODULO: MAPA DE CONOCIMIENTO
-- =============================================

-- Tabla: aliado
CREATE TABLE IF NOT EXISTS `aliado` (
    `nit` INT NOT NULL,
    `razon_social` VARCHAR(60) NOT NULL,
    `nombre_contacto` VARCHAR(60) NOT NULL,
    `correo` VARCHAR(70) NOT NULL,
    `telefono` VARCHAR(45) NOT NULL,
    `ciudad` VARCHAR(45) NOT NULL,
    PRIMARY KEY (`nit`)
) ENGINE=InnoDB;

-- Tabla: proyecto
CREATE TABLE IF NOT EXISTS `proyecto` (
    `id` INT NOT NULL,
    `titulo` VARCHAR(70) NOT NULL,
    `resumen` VARCHAR(256) NOT NULL,
    `presupuesto` DOUBLE NOT NULL,
    `tipo_financiacion` VARCHAR(45) NOT NULL,
    `tipo_fondos` VARCHAR(45) NOT NULL,
    `fecha_inicio` DATE NOT NULL,
    `fecha_fin` DATE,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB;

-- Tabla: tipo_producto
CREATE TABLE IF NOT EXISTS `tipo_producto` (
    `id` INT NOT NULL,
    `categoria` VARCHAR(45) NOT NULL,
    `clase` VARCHAR(45) NOT NULL,
    `nombre` VARCHAR(45) NOT NULL,
    `tipologia` VARCHAR(45) NOT NULL,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB;

-- Tabla: aa_proyecto
CREATE TABLE IF NOT EXISTS `aa_proyecto` (
    `proyecto` INT NOT NULL,
    `area_aplicacion` INT NOT NULL,
    PRIMARY KEY (`proyecto`, `area_aplicacion`),
    FOREIGN KEY (`proyecto`) REFERENCES `proyecto`(`id`),
    FOREIGN KEY (`area_aplicacion`) REFERENCES `area_aplicacion`(`id`)
) ENGINE=InnoDB;

-- Tabla: ac_proyecto
CREATE TABLE IF NOT EXISTS `ac_proyecto` (
    `proyecto` INT NOT NULL,
    `area_conocimiento` INT NOT NULL,
    PRIMARY KEY (`proyecto`, `area_conocimiento`),
    FOREIGN KEY (`proyecto`) REFERENCES `proyecto`(`id`),
    FOREIGN KEY (`area_conocimiento`) REFERENCES `area_conocimiento`(`id`)
) ENGINE=InnoDB;

-- Tabla: aliado_proyecto
CREATE TABLE IF NOT EXISTS `aliado_proyecto` (
    `aliado` INT NOT NULL,
    `proyecto` INT NOT NULL,
    PRIMARY KEY (`aliado`, `proyecto`),
    FOREIGN KEY (`aliado`) REFERENCES `aliado`(`nit`),
    FOREIGN KEY (`proyecto`) REFERENCES `proyecto`(`id`)
) ENGINE=InnoDB;

-- Tabla: desarrolla
CREATE TABLE IF NOT EXISTS `desarrolla` (
    `docente` INT NOT NULL,
    `proyecto` INT NOT NULL,
    `rol` VARCHAR(45) NOT NULL,
    `descripcion` VARCHAR(256) NOT NULL,
    PRIMARY KEY (`docente`, `proyecto`),
    FOREIGN KEY (`docente`) REFERENCES `docente`(`cedula`),
    FOREIGN KEY (`proyecto`) REFERENCES `proyecto`(`id`)
) ENGINE=InnoDB;

-- Tabla: ods_proyecto
CREATE TABLE IF NOT EXISTS `ods_proyecto` (
    `proyecto` INT NOT NULL,
    `ods` INT NOT NULL,
    PRIMARY KEY (`proyecto`, `ods`),
    FOREIGN KEY (`proyecto`) REFERENCES `proyecto`(`id`),
    FOREIGN KEY (`ods`) REFERENCES `objetivo_desarrollo_sostenible`(`id`)
) ENGINE=InnoDB;

-- Tabla: palabras_clave
CREATE TABLE IF NOT EXISTS `palabras_clave` (
    `proyecto` INT NOT NULL,
    `termino_clave` VARCHAR(30) NOT NULL,
    PRIMARY KEY (`proyecto`, `termino_clave`),
    FOREIGN KEY (`proyecto`) REFERENCES `proyecto`(`id`),
    FOREIGN KEY (`termino_clave`) REFERENCES `termino_clave`(`termino`)
) ENGINE=InnoDB;

-- Tabla: proyecto_linea
CREATE TABLE IF NOT EXISTS `proyecto_linea` (
    `proyecto` INT NOT NULL,
    `linea_investigacion` INT NOT NULL,
    PRIMARY KEY (`proyecto`, `linea_investigacion`),
    FOREIGN KEY (`proyecto`) REFERENCES `proyecto`(`id`),
    FOREIGN KEY (`linea_investigacion`) REFERENCES `linea_investigacion`(`id`)
) ENGINE=InnoDB;

-- Tabla: producto
CREATE TABLE IF NOT EXISTS `producto` (
    `id` INT NOT NULL,
    `nombre` VARCHAR(45) NOT NULL,
    `categoria` VARCHAR(45) NOT NULL,
    `fecha_entrega` DATE NOT NULL,
    `proyecto` INT,
    `tipo_producto` INT NOT NULL,
    PRIMARY KEY (`id`),
    FOREIGN KEY (`proyecto`) REFERENCES `proyecto`(`id`),
    FOREIGN KEY (`tipo_producto`) REFERENCES `tipo_producto`(`id`)
) ENGINE=InnoDB;

-- Tabla: docente_producto
CREATE TABLE IF NOT EXISTS `docente_producto` (
    `docente` INT NOT NULL,
    `producto` INT NOT NULL,
    PRIMARY KEY (`docente`, `producto`),
    FOREIGN KEY (`docente`) REFERENCES `docente`(`cedula`),
    FOREIGN KEY (`producto`) REFERENCES `producto`(`id`)
) ENGINE=InnoDB;

-- =============================================
-- MODULO: GESTION PROFESORAL
-- =============================================

-- Tabla: estudios_realizados
CREATE TABLE IF NOT EXISTS `estudios_realizados` (
    `id` INT NOT NULL,
    `titulo` VARCHAR(45) NOT NULL,
    `universidad` VARCHAR(50) NOT NULL,
    `fecha` DATE NOT NULL,
    `tipo` VARCHAR(45) NOT NULL,
    `ciudad` VARCHAR(45) NOT NULL,
    `docente` INT NOT NULL,
    `ins_acreditada` TINYINT NOT NULL,
    `metodologia` VARCHAR(45) NOT NULL,
    `perfil_egresado` LONGTEXT NOT NULL,
    `pais` VARCHAR(45) NOT NULL,
    PRIMARY KEY (`id`),
    FOREIGN KEY (`docente`) REFERENCES `docente`(`cedula`)
) ENGINE=InnoDB;

-- Tabla: evaluacion_docente
CREATE TABLE IF NOT EXISTS `evaluacion_docente` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `calificacion` FLOAT NOT NULL,
    `semestre` VARCHAR(45) NOT NULL,
    `docente` INT NOT NULL,
    PRIMARY KEY (`id`),
    FOREIGN KEY (`docente`) REFERENCES `docente`(`cedula`)
) ENGINE=InnoDB;

-- Tabla: experiecia
CREATE TABLE IF NOT EXISTS `experiecia` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `nombre_cargo` VARCHAR(45) NOT NULL,
    `institucion` VARCHAR(45) NOT NULL,
    `tipo` VARCHAR(45) NOT NULL,
    `fecha_inicio` DATE NOT NULL,
    `fecha_fin` DATE,
    `docente` INT NOT NULL,
    PRIMARY KEY (`id`),
    FOREIGN KEY (`docente`) REFERENCES `docente`(`cedula`)
) ENGINE=InnoDB;

-- Tabla: intereses_futuros
CREATE TABLE IF NOT EXISTS `intereses_futuros` (
    `docente` INT NOT NULL,
    `termino_clave` VARCHAR(30) NOT NULL,
    PRIMARY KEY (`docente`, `termino_clave`),
    FOREIGN KEY (`docente`) REFERENCES `docente`(`cedula`),
    FOREIGN KEY (`termino_clave`) REFERENCES `termino_clave`(`termino`)
) ENGINE=InnoDB;

-- Tabla: reconocimiento
CREATE TABLE IF NOT EXISTS `reconocimiento` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `tipo` VARCHAR(45) NOT NULL,
    `fecha` DATE NOT NULL,
    `institucion` VARCHAR(45) NOT NULL,
    `nombre` VARCHAR(45) NOT NULL,
    `ambito` VARCHAR(45) NOT NULL,
    `docente` INT NOT NULL,
    PRIMARY KEY (`id`),
    FOREIGN KEY (`docente`) REFERENCES `docente`(`cedula`)
) ENGINE=InnoDB;

-- Tabla: red
CREATE TABLE IF NOT EXISTS `red` (
    `idr` INT NOT NULL,
    `nombre` VARCHAR(45) NOT NULL,
    `url` VARCHAR(45) NOT NULL,
    `pais` VARCHAR(45) NOT NULL,
    PRIMARY KEY (`idr`)
) ENGINE=InnoDB;

-- Tabla: apoyo_profesoral
CREATE TABLE IF NOT EXISTS `apoyo_profesoral` (
    `estudios` INT NOT NULL,
    `con_apoyo` TINYINT NOT NULL,
    `institucion` VARCHAR(45) NOT NULL,
    `tipo` VARCHAR(45) NOT NULL,
    PRIMARY KEY (`estudios`),
    FOREIGN KEY (`estudios`) REFERENCES `estudios_realizados`(`id`)
) ENGINE=InnoDB;

-- Tabla: beca
CREATE TABLE IF NOT EXISTS `beca` (
    `estudios` INT NOT NULL,
    `tipo` VARCHAR(45) NOT NULL,
    `institucion` VARCHAR(80) NOT NULL,
    `fecha_inicio` DATE NOT NULL,
    `fecha_fin` DATE,
    PRIMARY KEY (`estudios`),
    FOREIGN KEY (`estudios`) REFERENCES `estudios_realizados`(`id`)
) ENGINE=InnoDB;

-- Tabla: estudio_ac
CREATE TABLE IF NOT EXISTS `estudio_ac` (
    `estudio` INT NOT NULL,
    `area_conocimiento` INT NOT NULL,
    PRIMARY KEY (`estudio`, `area_conocimiento`),
    FOREIGN KEY (`estudio`) REFERENCES `estudios_realizados`(`id`),
    FOREIGN KEY (`area_conocimiento`) REFERENCES `area_conocimiento`(`id`)
) ENGINE=InnoDB;

-- Tabla: red_docente
CREATE TABLE IF NOT EXISTS `red_docente` (
    `red` INT NOT NULL,
    `docente` INT NOT NULL,
    `fecha_inicio` DATE NOT NULL,
    `fecha_fin` VARCHAR(45),
    `act_destacadas` LONGTEXT NOT NULL,
    PRIMARY KEY (`red`, `docente`),
    FOREIGN KEY (`red`) REFERENCES `red`(`idr`),
    FOREIGN KEY (`docente`) REFERENCES `docente`(`cedula`)
) ENGINE=InnoDB;

-- =============================================
-- MODULO: INNOVACION CURRICULAR
-- =============================================

-- Tabla: aspecto_normativo
CREATE TABLE IF NOT EXISTS `aspecto_normativo` (
    `id` INT NOT NULL,
    `tipo` VARCHAR(45) NOT NULL,
    `descripcion` VARCHAR(45) NOT NULL,
    `fuente` VARCHAR(45) NOT NULL,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB;

-- Tabla: car_innovacion
CREATE TABLE IF NOT EXISTS `car_innovacion` (
    `id` INT NOT NULL,
    `nombre` VARCHAR(45) NOT NULL,
    `descripcion` LONGTEXT NOT NULL,
    `tipo` VARCHAR(45) NOT NULL,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB;

-- Tabla: enfoque
CREATE TABLE IF NOT EXISTS `enfoque` (
    `id` INT NOT NULL,
    `nombre` VARCHAR(45) NOT NULL,
    `descripcion` VARCHAR(45) NOT NULL,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB;

-- Tabla: practica_estrategia
CREATE TABLE IF NOT EXISTS `practica_estrategia` (
    `id` INT NOT NULL,
    `tipo` VARCHAR(45) NOT NULL,
    `nombre` VARCHAR(45) NOT NULL,
    `descripcion` VARCHAR(45) NOT NULL,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB;

-- Tabla: universidad
CREATE TABLE IF NOT EXISTS `universidad` (
    `id` INT NOT NULL,
    `nombre` VARCHAR(60) NOT NULL,
    `tipo` VARCHAR(45) NOT NULL,
    `ciudad` VARCHAR(45) NOT NULL,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB;

-- Tabla: facultad
CREATE TABLE IF NOT EXISTS `facultad` (
    `id` INT NOT NULL,
    `nombre` VARCHAR(60) NOT NULL,
    `tipo` VARCHAR(45) NOT NULL,
    `fecha_fun` DATE NOT NULL,
    `universidad` INT NOT NULL,
    PRIMARY KEY (`id`),
    FOREIGN KEY (`universidad`) REFERENCES `universidad`(`id`)
) ENGINE=InnoDB;

-- Tabla: programa
CREATE TABLE IF NOT EXISTS `programa` (
    `id` INT NOT NULL,
    `nombre` VARCHAR(60) NOT NULL,
    `tipo` VARCHAR(45) NOT NULL,
    `nivel` VARCHAR(45) NOT NULL,
    `fecha_creacion` VARCHAR(45) NOT NULL,
    `fecha_cierre` VARCHAR(45),
    `numero_cohortes` VARCHAR(45) NOT NULL,
    `cant_graduados` VARCHAR(45) NOT NULL,
    `fecha_actualizacion` VARCHAR(45) NOT NULL,
    `ciudad` VARCHAR(45) NOT NULL,
    `facultad` INT NOT NULL,
    PRIMARY KEY (`id`),
    FOREIGN KEY (`facultad`) REFERENCES `facultad`(`id`)
) ENGINE=InnoDB;

-- Tabla: acreditacion
CREATE TABLE IF NOT EXISTS `acreditacion` (
    `resolucion` INT NOT NULL,
    `tipo` VARCHAR(45) NOT NULL,
    `calificacion` VARCHAR(45) NOT NULL,
    `fecha_inicio` VARCHAR(45) NOT NULL,
    `fecha_fin` VARCHAR(45) NOT NULL,
    `programa` INT NOT NULL,
    PRIMARY KEY (`resolucion`),
    FOREIGN KEY (`programa`) REFERENCES `programa`(`id`)
) ENGINE=InnoDB;

-- Tabla: activ_academica
CREATE TABLE IF NOT EXISTS `activ_academica` (
    `id` INT NOT NULL,
    `nombre` VARCHAR(45) NOT NULL,
    `num_creditos` INT NOT NULL,
    `tipo` VARCHAR(20) NOT NULL,
    `area_formacion` VARCHAR(45) NOT NULL,
    `h_acom` INT NOT NULL,
    `h_indep` INT NOT NULL,
    `idioma` VARCHAR(45) NOT NULL,
    `espejo` TINYINT NOT NULL,
    `entidad_espejo` VARCHAR(45) NOT NULL,
    `pais_espejo` VARCHAR(45) NOT NULL,
    `disenio` INT,
    PRIMARY KEY (`id`),
    FOREIGN KEY (`disenio`) REFERENCES `programa`(`id`)
) ENGINE=InnoDB;

-- Tabla: alianza
CREATE TABLE IF NOT EXISTS `alianza` (
    `aliado` INT NOT NULL,
    `departamento` INT NOT NULL,
    `fecha_inicio` DATE NOT NULL,
    `fecha_fin` DATE,
    `docente` INT,
    PRIMARY KEY (`aliado`, `departamento`),
    FOREIGN KEY (`aliado`) REFERENCES `aliado`(`nit`),
    FOREIGN KEY (`departamento`) REFERENCES `programa`(`id`),
    FOREIGN KEY (`docente`) REFERENCES `docente`(`cedula`)
) ENGINE=InnoDB;

-- Tabla: an_programa
CREATE TABLE IF NOT EXISTS `an_programa` (
    `aspecto_normativo` INT NOT NULL,
    `programa` INT NOT NULL,
    PRIMARY KEY (`aspecto_normativo`, `programa`),
    FOREIGN KEY (`aspecto_normativo`) REFERENCES `aspecto_normativo`(`id`),
    FOREIGN KEY (`programa`) REFERENCES `programa`(`id`)
) ENGINE=InnoDB;

-- Tabla: docente_departamento
CREATE TABLE IF NOT EXISTS `docente_departamento` (
    `docente` INT NOT NULL,
    `departamento` INT NOT NULL,
    `dedicacion` VARCHAR(15) NOT NULL,
    `modalidad` VARCHAR(45) NOT NULL,
    `fecha_ingreso` DATE NOT NULL,
    `fecha_salida` DATE,
    PRIMARY KEY (`docente`, `departamento`),
    FOREIGN KEY (`docente`) REFERENCES `docente`(`cedula`),
    FOREIGN KEY (`departamento`) REFERENCES `programa`(`id`)
) ENGINE=InnoDB;

-- Tabla: pasantia
CREATE TABLE IF NOT EXISTS `pasantia` (
    `id` INT NOT NULL,
    `nombre` VARCHAR(45) NOT NULL,
    `pais` VARCHAR(45) NOT NULL,
    `empresa` VARCHAR(45) NOT NULL,
    `descripcion` VARCHAR(45) NOT NULL,
    `programa` INT NOT NULL,
    PRIMARY KEY (`id`),
    FOREIGN KEY (`programa`) REFERENCES `programa`(`id`)
) ENGINE=InnoDB;

-- Tabla: premio
CREATE TABLE IF NOT EXISTS `premio` (
    `id` INT NOT NULL,
    `nombre` VARCHAR(45) NOT NULL,
    `descripcion` VARCHAR(45) NOT NULL,
    `fecha` DATE NOT NULL,
    `entidad_otorgante` VARCHAR(45) NOT NULL,
    `pais` VARCHAR(45) NOT NULL,
    `programa` INT NOT NULL,
    PRIMARY KEY (`id`),
    FOREIGN KEY (`programa`) REFERENCES `programa`(`id`)
) ENGINE=InnoDB;

-- Tabla: programa_ac
CREATE TABLE IF NOT EXISTS `programa_ac` (
    `programa` INT NOT NULL,
    `area_conocimiento` INT NOT NULL,
    PRIMARY KEY (`programa`, `area_conocimiento`),
    FOREIGN KEY (`programa`) REFERENCES `programa`(`id`),
    FOREIGN KEY (`area_conocimiento`) REFERENCES `area_conocimiento`(`id`)
) ENGINE=InnoDB;

-- Tabla: programa_ci
CREATE TABLE IF NOT EXISTS `programa_ci` (
    `programa` INT NOT NULL,
    `car_innovacion` INT NOT NULL,
    PRIMARY KEY (`programa`, `car_innovacion`),
    FOREIGN KEY (`programa`) REFERENCES `programa`(`id`),
    FOREIGN KEY (`car_innovacion`) REFERENCES `car_innovacion`(`id`)
) ENGINE=InnoDB;

-- Tabla: programa_pe
CREATE TABLE IF NOT EXISTS `programa_pe` (
    `programa` INT NOT NULL,
    `practica_estrategia` INT NOT NULL,
    PRIMARY KEY (`programa`, `practica_estrategia`),
    FOREIGN KEY (`programa`) REFERENCES `programa`(`id`),
    FOREIGN KEY (`practica_estrategia`) REFERENCES `practica_estrategia`(`id`)
) ENGINE=InnoDB;

-- Tabla: registro_calificado
CREATE TABLE IF NOT EXISTS `registro_calificado` (
    `codigo` INT NOT NULL,
    `cant_creditos` VARCHAR(45) NOT NULL,
    `hora_acom` VARCHAR(45) NOT NULL,
    `hora_ind` VARCHAR(45) NOT NULL,
    `metodologia` VARCHAR(45) NOT NULL,
    `fecha_inicio` DATE NOT NULL,
    `fecha_fin` DATE NOT NULL,
    `duracion_anios` VARCHAR(45) NOT NULL,
    `duracion_semestres` VARCHAR(45) NOT NULL,
    `tipo_titulacion` VARCHAR(45) NOT NULL,
    `programa` INT NOT NULL,
    PRIMARY KEY (`codigo`),
    FOREIGN KEY (`programa`) REFERENCES `programa`(`id`)
) ENGINE=InnoDB;

-- Tabla: aa_rc
CREATE TABLE IF NOT EXISTS `aa_rc` (
    `activ_academicas_idcurso` INT NOT NULL,
    `registro_calificado_codigo` INT NOT NULL,
    `componente` VARCHAR(45) NOT NULL,
    `semestre` VARCHAR(45) NOT NULL,
    PRIMARY KEY (`activ_academicas_idcurso`, `registro_calificado_codigo`),
    FOREIGN KEY (`activ_academicas_idcurso`) REFERENCES `activ_academica`(`id`),
    FOREIGN KEY (`registro_calificado_codigo`) REFERENCES `registro_calificado`(`codigo`)
) ENGINE=InnoDB;

-- Tabla: enfoque_rc
CREATE TABLE IF NOT EXISTS `enfoque_rc` (
    `enfoque` INT NOT NULL,
    `registro_calificado` INT NOT NULL,
    PRIMARY KEY (`enfoque`, `registro_calificado`),
    FOREIGN KEY (`enfoque`) REFERENCES `enfoque`(`id`),
    FOREIGN KEY (`registro_calificado`) REFERENCES `registro_calificado`(`codigo`)
) ENGINE=InnoDB;

-- =============================================
-- MODULO: INVESTIGACION
-- =============================================

-- Tabla: aa_linea
CREATE TABLE IF NOT EXISTS `aa_linea` (
    `area_aplicacion` INT NOT NULL,
    `linea_investigacion` INT NOT NULL,
    PRIMARY KEY (`area_aplicacion`, `linea_investigacion`),
    FOREIGN KEY (`area_aplicacion`) REFERENCES `area_aplicacion`(`id`),
    FOREIGN KEY (`linea_investigacion`) REFERENCES `linea_investigacion`(`id`)
) ENGINE=InnoDB;

-- Tabla: ac_linea
CREATE TABLE IF NOT EXISTS `ac_linea` (
    `linea_investigacion` INT NOT NULL,
    `area_conocimiento` INT NOT NULL,
    PRIMARY KEY (`linea_investigacion`, `area_conocimiento`),
    FOREIGN KEY (`linea_investigacion`) REFERENCES `linea_investigacion`(`id`),
    FOREIGN KEY (`area_conocimiento`) REFERENCES `area_conocimiento`(`id`)
) ENGINE=InnoDB;

-- Tabla: grupo_investigacion
CREATE TABLE IF NOT EXISTS `grupo_investigacion` (
    `id` INT NOT NULL,
    `nombre` VARCHAR(60) NOT NULL,
    `url_gruplac` VARCHAR(128),
    `categoria` VARCHAR(10),
    `convocatoria` VARCHAR(10),
    `fecha_fundacion` DATE NOT NULL,
    `universidsad` INT,
    `interno` TINYINT NOT NULL,
    `ambito` VARCHAR(45) NOT NULL,
    PRIMARY KEY (`id`),
    FOREIGN KEY (`universidsad`) REFERENCES `universidad`(`id`)
) ENGINE=InnoDB;

-- Tabla: ods_linea
CREATE TABLE IF NOT EXISTS `ods_linea` (
    `linea_investigacion` INT NOT NULL,
    `ods` INT NOT NULL,
    PRIMARY KEY (`linea_investigacion`, `ods`),
    FOREIGN KEY (`linea_investigacion`) REFERENCES `linea_investigacion`(`id`),
    FOREIGN KEY (`ods`) REFERENCES `objetivo_desarrollo_sostenible`(`id`)
) ENGINE=InnoDB;

-- Tabla: grupo_linea
CREATE TABLE IF NOT EXISTS `grupo_linea` (
    `grupo_investigacion` INT NOT NULL,
    `linea_investigacion` INT NOT NULL,
    PRIMARY KEY (`grupo_investigacion`, `linea_investigacion`),
    FOREIGN KEY (`grupo_investigacion`) REFERENCES `grupo_investigacion`(`id`),
    FOREIGN KEY (`linea_investigacion`) REFERENCES `linea_investigacion`(`id`)
) ENGINE=InnoDB;

-- Tabla: participa_grupo
CREATE TABLE IF NOT EXISTS `participa_grupo` (
    `docente_cedula` INT NOT NULL,
    `grupo_investigacion_id` INT NOT NULL,
    `rol` VARCHAR(15) NOT NULL,
    `fecha_inicio` DATE NOT NULL,
    `fecha_fin` DATE,
    PRIMARY KEY (`docente_cedula`, `grupo_investigacion_id`),
    FOREIGN KEY (`docente_cedula`) REFERENCES `docente`(`cedula`),
    FOREIGN KEY (`grupo_investigacion_id`) REFERENCES `grupo_investigacion`(`id`)
) ENGINE=InnoDB;

-- Tabla: semillero
CREATE TABLE IF NOT EXISTS `semillero` (
    `id` INT NOT NULL,
    `nombre` VARCHAR(60) NOT NULL,
    `fecha_fundacion` DATE NOT NULL,
    `grupo_investigacion` INT NOT NULL,
    PRIMARY KEY (`id`),
    FOREIGN KEY (`grupo_investigacion`) REFERENCES `grupo_investigacion`(`id`)
) ENGINE=InnoDB;

-- Tabla: participa_semillero
CREATE TABLE IF NOT EXISTS `participa_semillero` (
    `docente` INT NOT NULL,
    `semillero` INT NOT NULL,
    `rol` VARCHAR(15) NOT NULL,
    `fecha_inicio` DATE NOT NULL,
    `fecha_fin` DATE,
    PRIMARY KEY (`docente`, `semillero`),
    FOREIGN KEY (`docente`) REFERENCES `docente`(`cedula`),
    FOREIGN KEY (`semillero`) REFERENCES `semillero`(`id`)
) ENGINE=InnoDB;

-- Tabla: semillero_linea
CREATE TABLE IF NOT EXISTS `semillero_linea` (
    `semillero` INT NOT NULL,
    `linea_investigacion` INT NOT NULL,
    PRIMARY KEY (`semillero`, `linea_investigacion`),
    FOREIGN KEY (`semillero`) REFERENCES `semillero`(`id`),
    FOREIGN KEY (`linea_investigacion`) REFERENCES `linea_investigacion`(`id`)
) ENGINE=InnoDB;


-- =============================================
-- MODULO DE GESTION DE USUARIOS
-- =============================================

-- Tabla: rol
CREATE TABLE IF NOT EXISTS `rol` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `nombre` VARCHAR(100) NOT NULL UNIQUE,
    `descripcion` TEXT,
    `activo` TINYINT(1) DEFAULT 1,
    `fecha_creacion` DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- Tabla: usuario
CREATE TABLE IF NOT EXISTS `usuario` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `username` VARCHAR(100) NOT NULL UNIQUE,
    `password` VARCHAR(255) NOT NULL,
    `email` VARCHAR(150) NOT NULL UNIQUE,
    `nombre_completo` VARCHAR(200),
    `activo` TINYINT(1) DEFAULT 1,
    `fecha_creacion` DATETIME DEFAULT CURRENT_TIMESTAMP,
    `fecha_actualizacion` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- Tabla: rol_usuario
CREATE TABLE IF NOT EXISTS `rol_usuario` (
    `usuario_id` INT NOT NULL,
    `rol_id` INT NOT NULL,
    PRIMARY KEY (`usuario_id`, `rol_id`),
    FOREIGN KEY (`usuario_id`) REFERENCES `usuario`(`id`) ON DELETE CASCADE,
    FOREIGN KEY (`rol_id`) REFERENCES `rol`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB;
