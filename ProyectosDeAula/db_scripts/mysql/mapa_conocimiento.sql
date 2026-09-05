-- =============================================================================
-- Base de datos: mapa_conocimiento
-- Módulo: Mapa de Conocimiento
-- Tablas del módulo: 18
-- Tablas de gestión de usuarios: 3
-- Total de tablas: 21
-- =============================================================================

CREATE DATABASE IF NOT EXISTS `mapa_conocimiento`;
USE `mapa_conocimiento`;

-- =============================================
-- TABLAS DEL MÓDULO: MAPA DE CONOCIMIENTO
-- =============================================

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

-- Tabla: area_aplicacion
CREATE TABLE IF NOT EXISTS `area_aplicacion` (
    `id` INT NOT NULL,
    `nombre` VARCHAR(60) NOT NULL,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB;

-- Tabla: termino_clave
CREATE TABLE IF NOT EXISTS `termino_clave` (
    `termino` VARCHAR(30) NOT NULL,
    `termino_ingles` VARCHAR(30),
    PRIMARY KEY (`termino`)
) ENGINE=InnoDB;

-- Tabla: linea_investigacion
CREATE TABLE IF NOT EXISTS `linea_investigacion` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `nombre` VARCHAR(45) NOT NULL,
    `descripcion` VARCHAR(256) NOT NULL,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB;

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

-- Tabla: tipo_producto
CREATE TABLE IF NOT EXISTS `tipo_producto` (
    `id` INT NOT NULL,
    `categoria` VARCHAR(45) NOT NULL,
    `clase` VARCHAR(45) NOT NULL,
    `nombre` VARCHAR(45) NOT NULL,
    `tipologia` VARCHAR(45) NOT NULL,
    PRIMARY KEY (`id`)
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

-- Tabla: palabras_clave
CREATE TABLE IF NOT EXISTS `palabras_clave` (
    `proyecto` INT NOT NULL,
    `termino_clave` VARCHAR(30) NOT NULL,
    PRIMARY KEY (`proyecto`, `termino_clave`),
    FOREIGN KEY (`proyecto`) REFERENCES `proyecto`(`id`),
    FOREIGN KEY (`termino_clave`) REFERENCES `termino_clave`(`termino`)
) ENGINE=InnoDB;

-- Tabla: ac_proyecto
CREATE TABLE IF NOT EXISTS `ac_proyecto` (
    `proyecto` INT NOT NULL,
    `area_conocimiento` INT NOT NULL,
    PRIMARY KEY (`proyecto`, `area_conocimiento`),
    FOREIGN KEY (`proyecto`) REFERENCES `proyecto`(`id`),
    FOREIGN KEY (`area_conocimiento`) REFERENCES `area_conocimiento`(`id`)
) ENGINE=InnoDB;

-- Tabla: proyecto_linea
CREATE TABLE IF NOT EXISTS `proyecto_linea` (
    `proyecto` INT NOT NULL,
    `linea_investigacion` INT NOT NULL,
    PRIMARY KEY (`proyecto`, `linea_investigacion`),
    FOREIGN KEY (`proyecto`) REFERENCES `proyecto`(`id`),
    FOREIGN KEY (`linea_investigacion`) REFERENCES `linea_investigacion`(`id`)
) ENGINE=InnoDB;

-- Tabla: ods_proyecto
CREATE TABLE IF NOT EXISTS `ods_proyecto` (
    `proyecto` INT NOT NULL,
    `ods` INT NOT NULL,
    PRIMARY KEY (`proyecto`, `ods`),
    FOREIGN KEY (`proyecto`) REFERENCES `proyecto`(`id`),
    FOREIGN KEY (`ods`) REFERENCES `objetivo_desarrollo_sostenible`(`id`)
) ENGINE=InnoDB;

-- Tabla: aa_proyecto
CREATE TABLE IF NOT EXISTS `aa_proyecto` (
    `proyecto` INT NOT NULL,
    `area_aplicacion` INT NOT NULL,
    PRIMARY KEY (`proyecto`, `area_aplicacion`),
    FOREIGN KEY (`proyecto`) REFERENCES `proyecto`(`id`),
    FOREIGN KEY (`area_aplicacion`) REFERENCES `area_aplicacion`(`id`)
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
-- MÓDULO DE GESTIÓN DE USUARIOS
-- =============================================

-- Tabla de roles
CREATE TABLE IF NOT EXISTS `rol` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `nombre` VARCHAR(100) NOT NULL UNIQUE,
    `descripcion` TEXT,
    `activo` TINYINT(1) DEFAULT 1,
    `fecha_creacion` DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- Tabla de usuarios
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

-- Tabla de relación usuario-rol
CREATE TABLE IF NOT EXISTS `rol_usuario` (
    `usuario_id` INT NOT NULL,
    `rol_id` INT NOT NULL,
    PRIMARY KEY (`usuario_id`, `rol_id`),
    FOREIGN KEY (`usuario_id`) REFERENCES `usuario`(`id`) ON DELETE CASCADE,
    FOREIGN KEY (`rol_id`) REFERENCES `rol`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB;
