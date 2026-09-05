-- ============================================================
-- Base de datos del módulo MAPA DE CONOCIMIENTO — MariaDB
--
-- Este script SE DERIVA del que entrega el curso
-- (ProyectosDeAula/db_scripts/mysql/mapa_conocimiento.sql). No es una copia: le aplica
-- CINCO cambios, y aquí están todos, para que quien lo abra sepa
-- exactamente qué se tocó y por qué.
--
--   1. area_conocimiento.id pasa de INT a VARCHAR(6). Los datos del
--      Excel son códigos alfanuméricos ('1A01'), no enteros: como
--      estaba, el script no podía cargar su propio catálogo. Arrastra
--      a la tabla que lo referencia.                            [C1]
--   2. area_conocimiento.disciplina pasa a VARCHAR(150): el valor más
--      largo del catálogo tiene 124 caracteres y no cabía en 60.  [C2]
--   3. area_aplicacion.nombre pasa a VARCHAR(150): el suyo tiene 129.                                                     [C3]
--   4. Las 18 tablas del módulo ganan 'activo BOOLEAN NOT NULL
--      DEFAULT TRUE': el borrado es LÓGICO. En MariaDB BOOLEAN es un
--      alias de TINYINT(1) y TRUE vale 1 — se escribe BOOLEAN porque
--      dice lo que la columna significa, no cómo se guarda.      [C4]
--   5. Se corrige 'Cienias Naturales' -> 'Ciencias Naturales' en 48
--      filas. Es un error de digitación de la fuente: cargarlo tal
--      cual lo dejaría a la vista en cada listado.               [C5]
--
-- Y una diferencia con el script dado que no es un cambio sino una
-- omisión deliberada: aquí NO va el `CREATE DATABASE` ni el `USE`. La
-- base la crea el contenedor con MARIADB_DATABASE, y este archivo se
-- ejecuta ya dentro de ella. Dejar el `USE` haría que el script
-- dependiera de un nombre de base escrito dos veces.
--
-- Las 21 tablas se crean COMPLETAS aunque la v1 solo use una: la
-- base es infraestructura dada. Lo que crece por versiones es la API.
--
-- El GEMELO EN PYTHON de este módulo (proyecto_paradigmas_mapa_conocimiento1)
-- monta este mismo módulo sobre PostgreSQL, con los mismos cinco
-- cambios y las mismas filas. Los dos se pueden levantar a la vez y
-- comparar: la tabla es la misma, el motor y el lenguaje no.
--
-- MariaDB ejecuta este archivo SOLO en el primer arranque, cuando el
-- volumen está vacío. Para volver a correrlo: docker compose down -v
-- ============================================================

SET FOREIGN_KEY_CHECKS = 0;

-- =============================================
-- TABLAS DEL MÓDULO: MAPA DE CONOCIMIENTO
-- =============================================

-- Tabla: area_conocimiento
CREATE TABLE IF NOT EXISTS `area_conocimiento` (
    `id` VARCHAR(6) NOT NULL,
    `gran_area` VARCHAR(60) NOT NULL,
    `area` VARCHAR(60) NOT NULL,
    `disciplina` VARCHAR(150) NOT NULL,
    `activo` BOOLEAN NOT NULL DEFAULT TRUE,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB;

-- Tabla: objetivo_desarrollo_sostenible
CREATE TABLE IF NOT EXISTS `objetivo_desarrollo_sostenible` (
    `id` INT NOT NULL,
    `nombre` VARCHAR(60) NOT NULL,
    `categoria` VARCHAR(45) NOT NULL,
    `activo` BOOLEAN NOT NULL DEFAULT TRUE,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB;

-- Tabla: area_aplicacion
CREATE TABLE IF NOT EXISTS `area_aplicacion` (
    `id` INT NOT NULL,
    `nombre` VARCHAR(150) NOT NULL,
    `activo` BOOLEAN NOT NULL DEFAULT TRUE,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB;

-- Tabla: termino_clave
CREATE TABLE IF NOT EXISTS `termino_clave` (
    `termino` VARCHAR(30) NOT NULL,
    `termino_ingles` VARCHAR(30),
    `activo` BOOLEAN NOT NULL DEFAULT TRUE,
    PRIMARY KEY (`termino`)
) ENGINE=InnoDB;

-- Tabla: linea_investigacion
CREATE TABLE IF NOT EXISTS `linea_investigacion` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `nombre` VARCHAR(45) NOT NULL,
    `descripcion` VARCHAR(256) NOT NULL,
    `activo` BOOLEAN NOT NULL DEFAULT TRUE,
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
    `activo` BOOLEAN NOT NULL DEFAULT TRUE,
    PRIMARY KEY (`nit`)
) ENGINE=InnoDB;

-- Tabla: tipo_producto
CREATE TABLE IF NOT EXISTS `tipo_producto` (
    `id` INT NOT NULL,
    `categoria` VARCHAR(45) NOT NULL,
    `clase` VARCHAR(45) NOT NULL,
    `nombre` VARCHAR(45) NOT NULL,
    `tipologia` VARCHAR(45) NOT NULL,
    `activo` BOOLEAN NOT NULL DEFAULT TRUE,
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
    `activo` BOOLEAN NOT NULL DEFAULT TRUE,
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
    `activo` BOOLEAN NOT NULL DEFAULT TRUE,
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
    `activo` BOOLEAN NOT NULL DEFAULT TRUE,
    PRIMARY KEY (`id`),
    FOREIGN KEY (`proyecto`) REFERENCES `proyecto`(`id`),
    FOREIGN KEY (`tipo_producto`) REFERENCES `tipo_producto`(`id`)
) ENGINE=InnoDB;

-- Tabla: aliado_proyecto
CREATE TABLE IF NOT EXISTS `aliado_proyecto` (
    `aliado` INT NOT NULL,
    `proyecto` INT NOT NULL,
    `activo` BOOLEAN NOT NULL DEFAULT TRUE,
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
    `activo` BOOLEAN NOT NULL DEFAULT TRUE,
    PRIMARY KEY (`docente`, `proyecto`),
    FOREIGN KEY (`docente`) REFERENCES `docente`(`cedula`),
    FOREIGN KEY (`proyecto`) REFERENCES `proyecto`(`id`)
) ENGINE=InnoDB;

-- Tabla: palabras_clave
CREATE TABLE IF NOT EXISTS `palabras_clave` (
    `proyecto` INT NOT NULL,
    `termino_clave` VARCHAR(30) NOT NULL,
    `activo` BOOLEAN NOT NULL DEFAULT TRUE,
    PRIMARY KEY (`proyecto`, `termino_clave`),
    FOREIGN KEY (`proyecto`) REFERENCES `proyecto`(`id`),
    FOREIGN KEY (`termino_clave`) REFERENCES `termino_clave`(`termino`)
) ENGINE=InnoDB;

-- Tabla: ac_proyecto
CREATE TABLE IF NOT EXISTS `ac_proyecto` (
    `proyecto` INT NOT NULL,
    `area_conocimiento` VARCHAR(6) NOT NULL,
    `activo` BOOLEAN NOT NULL DEFAULT TRUE,
    PRIMARY KEY (`proyecto`, `area_conocimiento`),
    FOREIGN KEY (`proyecto`) REFERENCES `proyecto`(`id`),
    FOREIGN KEY (`area_conocimiento`) REFERENCES `area_conocimiento`(`id`)
) ENGINE=InnoDB;

-- Tabla: proyecto_linea
CREATE TABLE IF NOT EXISTS `proyecto_linea` (
    `proyecto` INT NOT NULL,
    `linea_investigacion` INT NOT NULL,
    `activo` BOOLEAN NOT NULL DEFAULT TRUE,
    PRIMARY KEY (`proyecto`, `linea_investigacion`),
    FOREIGN KEY (`proyecto`) REFERENCES `proyecto`(`id`),
    FOREIGN KEY (`linea_investigacion`) REFERENCES `linea_investigacion`(`id`)
) ENGINE=InnoDB;

-- Tabla: ods_proyecto
CREATE TABLE IF NOT EXISTS `ods_proyecto` (
    `proyecto` INT NOT NULL,
    `ods` INT NOT NULL,
    `activo` BOOLEAN NOT NULL DEFAULT TRUE,
    PRIMARY KEY (`proyecto`, `ods`),
    FOREIGN KEY (`proyecto`) REFERENCES `proyecto`(`id`),
    FOREIGN KEY (`ods`) REFERENCES `objetivo_desarrollo_sostenible`(`id`)
) ENGINE=InnoDB;

-- Tabla: aa_proyecto
CREATE TABLE IF NOT EXISTS `aa_proyecto` (
    `proyecto` INT NOT NULL,
    `area_aplicacion` INT NOT NULL,
    `activo` BOOLEAN NOT NULL DEFAULT TRUE,
    PRIMARY KEY (`proyecto`, `area_aplicacion`),
    FOREIGN KEY (`proyecto`) REFERENCES `proyecto`(`id`),
    FOREIGN KEY (`area_aplicacion`) REFERENCES `area_aplicacion`(`id`)
) ENGINE=InnoDB;

-- Tabla: docente_producto
CREATE TABLE IF NOT EXISTS `docente_producto` (
    `docente` INT NOT NULL,
    `producto` INT NOT NULL,
    `activo` BOOLEAN NOT NULL DEFAULT TRUE,
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


-- DATOS DE REFERENCIA (del Excel del módulo)
-- ============================================================

-- area_conocimiento: 218 filas
INSERT INTO area_conocimiento (id, gran_area, area, disciplina) VALUES
    ('1A01', 'Ciencias Naturales', 'Matemáticas', 'Matemáticas puras'),
    ('1A02', 'Ciencias Naturales', 'Matemáticas', 'Matemáticas aplicadas'),
    ('1A03', 'Ciencias Naturales', 'Matemáticas', 'Estadística y probabilidades (investigación en metodologías)'),
    ('1B01', 'Ciencias Naturales', 'Coputación y ciencias de la información', 'Ciencias de la Computación'),
    ('1B02', 'Ciencias Naturales', 'Coputación y ciencias de la información', 'Ciencias de la Información y bioinformática (hardware en 2.B y aspectos sociales en 5.8)'),
    ('1C01', 'Ciencias Naturales', 'Ciencias físicas', 'Física Atómica, molecular y química'),
    ('1C02', 'Ciencias Naturales', 'Ciencias físicas', 'Física de la materia'),
    ('1C03', 'Ciencias Naturales', 'Ciencias físicas', 'Física de partículas y campos'),
    ('1C04', 'Ciencias Naturales', 'Ciencias físicas', 'Física nuclear'),
    ('1C05', 'Ciencias Naturales', 'Ciencias físicas', 'Física de plasmas y fluidos'),
    ('1C06', 'Ciencias Naturales', 'Ciencias físicas', 'Óptica'),
    ('1C07', 'Ciencias Naturales', 'Ciencias físicas', 'Acústica'),
    ('1C08', 'Ciencias Naturales', 'Ciencias físicas', 'Astronomía'),
    ('1D01', 'Ciencias Naturales', 'Ciencias químicas', 'Química orgánica'),
    ('1D02', 'Ciencias Naturales', 'Ciencias químicas', 'Química inorgánica y nuclear'),
    ('1D03', 'Ciencias Naturales', 'Ciencias químicas', 'Química física'),
    ('1D04', 'Ciencias Naturales', 'Ciencias químicas', 'Ciencia de los polímeros'),
    ('1D05', 'Ciencias Naturales', 'Ciencias químicas', 'Electroquímica'),
    ('1D06', 'Ciencias Naturales', 'Ciencias químicas', 'Química de los coloides'),
    ('1D07', 'Ciencias Naturales', 'Ciencias químicas', 'Química analítica'),
    ('1E01', 'Ciencias Naturales', 'Ciencias de la tierra y medioambientales', 'Geociencias (multidisciplinario)'),
    ('1E02', 'Ciencias Naturales', 'Ciencias de la tierra y medioambientales', 'Mineralogía'),
    ('1E03', 'Ciencias Naturales', 'Ciencias de la tierra y medioambientales', 'Paleontología'),
    ('1E04', 'Ciencias Naturales', 'Ciencias de la tierra y medioambientales', 'Geoquímica y geofísica'),
    ('1E05', 'Ciencias Naturales', 'Ciencias de la tierra y medioambientales', 'Geografía Física'),
    ('1E06', 'Ciencias Naturales', 'Ciencias de la tierra y medioambientales', 'Geología'),
    ('1E07', 'Ciencias Naturales', 'Ciencias de la tierra y medioambientales', 'Vulcanología'),
    ('1E08', 'Ciencias Naturales', 'Ciencias de la tierra y medioambientales', 'Ciencias del medio ambiente (aspectos sociales en 5.G)'),
    ('1E09', 'Ciencias Naturales', 'Ciencias de la tierra y medioambientales', 'Meteorología y ciencias atmosféricas'),
    ('1E10', 'Ciencias Naturales', 'Ciencias de la tierra y medioambientales', 'Investicación del clima.'),
    ('1E11', 'Ciencias Naturales', 'Ciencias de la tierra y medioambientales', 'Oceanografía, hidrología y recursos del agua'),
    ('1F01', 'Ciencias Naturales', 'Ciencias biológicas', 'Biología celular y microbiología'),
    ('1F02', 'Ciencias Naturales', 'Ciencias biológicas', 'Virología'),
    ('1F03', 'Ciencias Naturales', 'Ciencias biológicas', 'Bioquímica y biología molecular'),
    ('1F04', 'Ciencias Naturales', 'Ciencias biológicas', 'Métodos de investigación en bioquímica'),
    ('1F05', 'Ciencias Naturales', 'Ciencias biológicas', 'Micología'),
    ('1F06', 'Ciencias Naturales', 'Ciencias biológicas', 'Biofísica'),
    ('1F07', 'Ciencias Naturales', 'Ciencias biológicas', 'Genética y herencia (aspectos médicos en 3)'),
    ('1F08', 'Ciencias Naturales', 'Ciencias biológicas', 'Biología reproductiva (aspectos médicos en 3)'),
    ('1F09', 'Ciencias Naturales', 'Ciencias biológicas', 'Biología del desarrollo'),
    ('1F10', 'Ciencias Naturales', 'Ciencias biológicas', 'Botánica y ciencias de las plantas'),
    ('1F11', 'Ciencias Naturales', 'Ciencias biológicas', 'Zoología, Ornitología, Entomología, ciencias biológicas del comportamiento'),
    ('1F12', 'Ciencias Naturales', 'Ciencias biológicas', 'Biología marina del agua'),
    ('1F13', 'Ciencias Naturales', 'Ciencias biológicas', 'Ecología'),
    ('1F14', 'Ciencias Naturales', 'Ciencias biológicas', 'Conservación de la biodiversidad'),
    ('1F15', 'Ciencias Naturales', 'Ciencias biológicas', 'Biología (Teórica, matemática, criobiología, evolutiva…)'),
    ('1F16', 'Ciencias Naturales', 'Ciencias biológicas', 'Otras Biologías'),
    ('1G01', 'Ciencias Naturales', 'Otras ciencias naturales', 'Otras ciencias naturales'),
    ('2A01', 'Ingeniería y Tecnología', 'Ingeniería civil', 'Ingeniería civil'),
    ('2A02', 'Ingeniería y Tecnología', 'Ingeniería civil', 'Ingeniería arquitectónica'),
    ('2A03', 'Ingeniería y Tecnología', 'Ingeniería civil', 'Ingeniería de la construcción'),
    ('2A04', 'Ingeniería y Tecnología', 'Ingeniería civil', 'Ingeniería estructural y municipal'),
    ('2A05', 'Ingeniería y Tecnología', 'Ingeniería civil', 'Ingeniería del transporte'),
    ('2B01', 'Ingeniería y Tecnología', 'Ingenierías Eléctrica, Electrónica e Informática', 'Ingeniería eléctrica y electrónica'),
    ('2B02', 'Ingeniería y Tecnología', 'Ingenierías Eléctrica, Electrónica e Informática', 'Robótica y control automático'),
    ('2B03', 'Ingeniería y Tecnología', 'Ingenierías Eléctrica, Electrónica e Informática', 'Automatización y sistemas de control'),
    ('2B04', 'Ingeniería y Tecnología', 'Ingenierías Eléctrica, Electrónica e Informática', 'Ingeniería de sistemas y comunicaciones'),
    ('2B05', 'Ingeniería y Tecnología', 'Ingenierías Eléctrica, Electrónica e Informática', 'Telecomunicaciones'),
    ('2B06', 'Ingeniería y Tecnología', 'Ingenierías Eléctrica, Electrónica e Informática', 'Hardware y arquitectura de computadores'),
    ('2C01', 'Ingeniería y Tecnología', 'Ingeniería Mecánica', 'Ingeniería mecánica'),
    ('2C02', 'Ingeniería y Tecnología', 'Ingeniería Mecánica', 'Mecánica aplicada'),
    ('2C03', 'Ingeniería y Tecnología', 'Ingeniería Mecánica', 'Termodinámica'),
    ('2C04', 'Ingeniería y Tecnología', 'Ingeniería Mecánica', 'Ingeniería aeroespacial'),
    ('2C05', 'Ingeniería y Tecnología', 'Ingeniería Mecánica', 'Ingeniería nuclear (física nuclear en 1.C)'),
    ('2C06', 'Ingeniería y Tecnología', 'Ingeniería Mecánica', 'Ingeniería de audio'),
    ('2D01', 'Ingeniería y Tecnología', 'Ingeniería Química', 'Ingeniería química (plantas y productos)'),
    ('2D02', 'Ingeniería y Tecnología', 'Ingeniería Química', 'Ingeniería de procesos'),
    ('2E01', 'Ingeniería y Tecnología', 'Ingeniería de los Materiales', 'Ingeniería mecánica'),
    ('2E02', 'Ingeniería y Tecnología', 'Ingeniería de los Materiales', 'Cerámicos'),
    ('2E03', 'Ingeniería y Tecnología', 'Ingeniería de los Materiales', 'Recubrimientos y películas'),
    ('2E04', 'Ingeniería y Tecnología', 'Ingeniería de los Materiales', 'Compuestos (laminados, plásticos reforzados, fira sintéticas y naturales, e ECA.)'),
    ('2E05', 'Ingeniería y Tecnología', 'Ingeniería de los Materiales', 'Papel y madera'),
    ('2E06', 'Ingeniería y Tecnología', 'Ingeniería de los Materiales', 'Textiles (Nanomateriales en 2.J y biomateriales en 2.I)'),
    ('2F01', 'Ingeniería y Tecnología', 'Ingeniería Médica', 'Ingeniería médica'),
    ('2F02', 'Ingeniería y Tecnología', 'Ingeniería Médica', 'Tecnología médica de laboratorio (análisis de muestras, tecnologías para el diagnóstico)'),
    ('2G01', 'Ingeniería y Tecnología', 'Ingeniería Ambiental', 'Ingeniería ambiental y geológica'),
    ('2G02', 'Ingeniería y Tecnología', 'Ingeniería Ambiental', 'Geotécnicas'),
    ('2G03', 'Ingeniería y Tecnología', 'Ingeniería Ambiental', 'Ingeniería del petróleo (combustibles, aceites), energía y combustibles'),
    ('2G04', 'Ingeniería y Tecnología', 'Ingeniería Ambiental', 'Sensores remotos'),
    ('2G05', 'Ingeniería y Tecnología', 'Ingeniería Ambiental', 'Mineria y procesamiento de minerales'),
    ('2G06', 'Ingeniería y Tecnología', 'Ingeniería Ambiental', 'Ingeniería marina, naves'),
    ('2G07', 'Ingeniería y Tecnología', 'Ingeniería Ambiental', 'Ingeniería oceanográfica'),
    ('2H01', 'Ingeniería y Tecnología', 'Biotecnología Ambiental', 'Biotecnología industrial'),
    ('2H02', 'Ingeniería y Tecnología', 'Biotecnología Ambiental', 'Bioremediación, biotecnología para el diagnóstico (Chips ADN y biosensores) en manejo ambiental'),
    ('2H03', 'Ingeniería y Tecnología', 'Biotecnología Ambiental', 'Ética relacionada con biotecnología ambiental'),
    ('2I01', 'Ingeniería y Tecnología', 'Biotecnología Industrial', 'Biotecnología industrial'),
    ('2I02', 'Ingeniería y Tecnología', 'Biotecnología Industrial', 'Tecnologías de bioprocesamiento, biocatálisis, fermentación'),
    ('2I03', 'Ingeniería y Tecnología', 'Biotecnología Industrial', 'Bioproductos (productos que se manufacturan usando biotecnología)'),
    ('2J01', 'Ingeniería y Tecnología', 'Nanotecnología', 'Nanomateriales (producción y propiedades)'),
    ('2J02', 'Ingeniería y Tecnología', 'Nanotecnología', 'Nanoprocesos (aplicaciones a nanoescala) (biomateriales en 2.I)'),
    ('2K01', 'Ingeniería y Tecnología', 'Otras Ingenierías y tecnologías', 'Alimentos y bebidas'),
    ('2K02', 'Ingeniería y Tecnología', 'Otras Ingenierías y tecnologías', 'Otras ingenierías y tecnologías'),
    ('2K03', 'Ingeniería y Tecnología', 'Otras Ingenierías y tecnologías', 'Ingeniería de producción'),
    ('2K04', 'Ingeniería y Tecnología', 'Otras Ingenierías y tecnologías', 'Ingeniería Industrial'),
    ('3A01', 'Ciencias Médicas y de la Salud', 'Medicina básica', 'Anatomía y morfología (ciencias vegetales en 1.F)'),
    ('3A02', 'Ciencias Médicas y de la Salud', 'Medicina básica', 'Genética humana'),
    ('3A03', 'Ciencias Médicas y de la Salud', 'Medicina básica', 'Inmunología'),
    ('3A04', 'Ciencias Médicas y de la Salud', 'Medicina básica', 'Neurociencias'),
    ('3A05', 'Ciencias Médicas y de la Salud', 'Medicina básica', 'Farmacología y farmacia'),
    ('3A06', 'Ciencias Médicas y de la Salud', 'Medicina básica', 'Medicina química'),
    ('3A07', 'Ciencias Médicas y de la Salud', 'Medicina básica', 'Toxicología'),
    ('3A08', 'Ciencias Médicas y de la Salud', 'Medicina básica', 'Fisiología (incluye citología)'),
    ('3A09', 'Ciencias Médicas y de la Salud', 'Medicina básica', 'Patología'),
    ('3B01', 'Ciencias Médicas y de la Salud', 'Medicina Clínica', 'Andrología'),
    ('3B02', 'Ciencias Médicas y de la Salud', 'Medicina Clínica', 'Obstetricia y ginecología'),
    ('3B03', 'Ciencias Médicas y de la Salud', 'Medicina Clínica', 'Pediatría'),
    ('3B04', 'Ciencias Médicas y de la Salud', 'Medicina Clínica', 'Cardiovascular'),
    ('3B05', 'Ciencias Médicas y de la Salud', 'Medicina Clínica', 'Vascular periférico'),
    ('3B06', 'Ciencias Médicas y de la Salud', 'Medicina Clínica', 'Hematología'),
    ('3B07', 'Ciencias Médicas y de la Salud', 'Medicina Clínica', 'Respiratoria'),
    ('3B08', 'Ciencias Médicas y de la Salud', 'Medicina Clínica', 'Cuidado crítico y de emergencia'),
    ('3B09', 'Ciencias Médicas y de la Salud', 'Medicina Clínica', 'Anestesiología'),
    ('3B10', 'Ciencias Médicas y de la Salud', 'Medicina Clínica', 'Ortopédica'),
    ('3B11', 'Ciencias Médicas y de la Salud', 'Medicina Clínica', 'Cirugía'),
    ('3B12', 'Ciencias Médicas y de la Salud', 'Medicina Clínica', 'Radiología, medicina nuclear y de imágenes'),
    ('3B13', 'Ciencias Médicas y de la Salud', 'Medicina Clínica', 'Trasplantes'),
    ('3B14', 'Ciencias Médicas y de la Salud', 'Medicina Clínica', 'Odontología, cirugía oral y medicina oral'),
    ('3B15', 'Ciencias Médicas y de la Salud', 'Medicina Clínica', 'Dermatología y enfermedades venéreas'),
    ('3B16', 'Ciencias Médicas y de la Salud', 'Medicina Clínica', 'Alergias'),
    ('3B17', 'Ciencias Médicas y de la Salud', 'Medicina Clínica', 'Reumatología'),
    ('3B18', 'Ciencias Médicas y de la Salud', 'Medicina Clínica', 'Endocrinología y metabolismo (incluye diabetes y trastornos hormonales)'),
    ('3B19', 'Ciencias Médicas y de la Salud', 'Medicina Clínica', 'Gastroenterología y hepatología'),
    ('3B20', 'Ciencias Médicas y de la Salud', 'Medicina Clínica', 'Urología y nefrología'),
    ('3B21', 'Ciencias Médicas y de la Salud', 'Medicina Clínica', 'Oncología'),
    ('3B22', 'Ciencias Médicas y de la Salud', 'Medicina Clínica', 'Oftalmología'),
    ('3B23', 'Ciencias Médicas y de la Salud', 'Medicina Clínica', 'Otorrinolaringología'),
    ('3B24', 'Ciencias Médicas y de la Salud', 'Medicina Clínica', 'Psiquiatría'),
    ('3B25', 'Ciencias Médicas y de la Salud', 'Medicina Clínica', 'Neurología clínica'),
    ('3B26', 'Ciencias Médicas y de la Salud', 'Medicina Clínica', 'Geriatría'),
    ('3B27', 'Ciencias Médicas y de la Salud', 'Medicina Clínica', 'Medicina general e interna'),
    ('3B28', 'Ciencias Médicas y de la Salud', 'Medicina Clínica', 'Otros temas de medicina clínica'),
    ('3B29', 'Ciencias Médicas y de la Salud', 'Medicina Clínica', 'Medicina complementaria (sistemas alternativos)'),
    ('3C01', 'Ciencias Médicas y de la Salud', 'Ciencias de la Salud', 'Ciencias del cuidado de la salud y servicios (administración de hospitales y financiamiento)'),
    ('3C02', 'Ciencias Médicas y de la Salud', 'Ciencias de la Salud', 'Políticas de salud y servicios'),
    ('3C03', 'Ciencias Médicas y de la Salud', 'Ciencias de la Salud', 'Enfermería'),
    ('3C04', 'Ciencias Médicas y de la Salud', 'Ciencias de la Salud', 'Nutrición y dietas'),
    ('3C05', 'Ciencias Médicas y de la Salud', 'Ciencias de la Salud', 'Salud pública'),
    ('3C06', 'Ciencias Médicas y de la Salud', 'Ciencias de la Salud', 'Medicina tropical'),
    ('3C07', 'Ciencias Médicas y de la Salud', 'Ciencias de la Salud', 'Parasitología'),
    ('3C08', 'Ciencias Médicas y de la Salud', 'Ciencias de la Salud', 'enfermedades infecciosas'),
    ('3C09', 'Ciencias Médicas y de la Salud', 'Ciencias de la Salud', 'Epidemiología'),
    ('3C10', 'Ciencias Médicas y de la Salud', 'Ciencias de la Salud', 'Salud ocupacional'),
    ('3C11', 'Ciencias Médicas y de la Salud', 'Ciencias de la Salud', 'Ciencias del deporte'),
    ('3C12', 'Ciencias Médicas y de la Salud', 'Ciencias de la Salud', 'Ciencias socio biomédicas (planificación familiar, salud sexual, efectos políticos y sociales de la investigación biomédica)'),
    ('3C13', 'Ciencias Médicas y de la Salud', 'Ciencias de la Salud', 'Ética'),
    ('3C14', 'Ciencias Médicas y de la Salud', 'Ciencias de la Salud', 'Abuso de sustancias'),
    ('3D01', 'Ciencias Médicas y de la Salud', 'Biotecnología en Salud', 'Biotecnología relacionada con la salud'),
    ('3D02', 'Ciencias Médicas y de la Salud', 'Biotecnología en Salud', 'Tecnologías para la manipulación de células, tejidos, órganos o el organismo (reporducción asistida)'),
    ('3D03', 'Ciencias Médicas y de la Salud', 'Biotecnología en Salud', 'Tecnología para la identificación y funcionamiento del ADN, proteinas y encimas y como influencian la enfermedad'),
    ('3D04', 'Ciencias Médicas y de la Salud', 'Biotecnología en Salud', 'Biomateriales (relacionados con implantes, dispositivos, sensores)'),
    ('3D05', 'Ciencias Médicas y de la Salud', 'Biotecnología en Salud', 'Ética relacionada con la biomedicina.'),
    ('3E01', 'Ciencias Médicas y de la Salud', 'Otras Ciencias Médicas', 'Forénsicas'),
    ('3E02', 'Ciencias Médicas y de la Salud', 'Otras Ciencias Médicas', 'Otras ciencias médicas'),
    ('3E03', 'Ciencias Médicas y de la Salud', 'Otras Ciencias Médicas', 'Fonoaudiología'),
    ('4A01', 'Ciencias Agrícolas', 'Agricultura, Silvicultura y Pesca', 'Agricultura'),
    ('4A02', 'Ciencias Agrícolas', 'Agricultura, Silvicultura y Pesca', 'Forestal'),
    ('4A03', 'Ciencias Agrícolas', 'Agricultura, Silvicultura y Pesca', 'Pesca'),
    ('4A04', 'Ciencias Agrícolas', 'Agricultura, Silvicultura y Pesca', 'Ciencias del suelo'),
    ('4A05', 'Ciencias Agrícolas', 'Agricultura, Silvicultura y Pesca', 'Horticultura y viticultura'),
    ('4A06', 'Ciencias Agrícolas', 'Agricultura, Silvicultura y Pesca', 'Agronomía'),
    ('4A07', 'Ciencias Agrícolas', 'Agricultura, Silvicultura y Pesca', 'Protección y nutrición de las plantas'),
    ('4B01', 'Ciencias Agrícolas', 'Ciencias animales y lechería', 'Ciencias animales y lechería'),
    ('4B02', 'Ciencias Agrícolas', 'Ciencias animales y lechería', 'Crías y mascotas'),
    ('4C01', 'Ciencias Agrícolas', 'Ciencias Veterinarias', 'Ciencias Veterinarias'),
    ('4D01', 'Ciencias Agrícolas', 'Biotecnología Agrícola', 'Biotecnología agrícola y de alimentos'),
    ('4D02', 'Ciencias Agrícolas', 'Biotecnología Agrícola', 'Tecnología MG, clonamiento de ganado, selección asistida, diagnóstico'),
    ('4D03', 'Ciencias Agrícolas', 'Biotecnología Agrícola', 'Ética relacionada a la biotecnología agrícola'),
    ('4E01', 'Ciencias Agrícolas', 'Otras Ciencias Agrícolas', 'Otras ciencias Agrícolas'),
    ('5A01', 'Ciencias Sociales', 'Psicología', 'Psicología (incluye relaciones hombre-máquina)'),
    ('5A02', 'Ciencias Sociales', 'Psicología', 'Psicología (incluye terapias de aprendizaje, habla, visual y otras discapacidades físicas y mentales'),
    ('5B01', 'Ciencias Sociales', 'Economía y Negocios', 'Economía'),
    ('5B02', 'Ciencias Sociales', 'Economía y Negocios', 'Econometría'),
    ('5B03', 'Ciencias Sociales', 'Economía y Negocios', 'Relaciones Industriales'),
    ('5B04', 'Ciencias Sociales', 'Economía y Negocios', 'Negocios y Management'),
    ('5C01', 'Ciencias Sociales', 'Ciencias de la Educación', 'Educación general (incluye capacitación, pedagogía)'),
    ('5C02', 'Ciencias Sociales', 'Ciencias de la Educación', 'Educación especial (para estudios dotados y aquellos con dificultades del aprendizaje)'),
    ('5D01', 'Ciencias Sociales', 'Sociología', 'Sociología'),
    ('5D02', 'Ciencias Sociales', 'Sociología', 'Demografía'),
    ('5D03', 'Ciencias Sociales', 'Sociología', 'Antropología'),
    ('5D04', 'Ciencias Sociales', 'Sociología', 'Etnografía'),
    ('5D05', 'Ciencias Sociales', 'Sociología', 'Temas especiales (Estudios de género, Temas sociales, Estudios de la familia, Trabajo social)'),
    ('5E01', 'Ciencias Sociales', 'Derecho', 'Derecho'),
    ('5E02', 'Ciencias Sociales', 'Derecho', 'Penal'),
    ('5F01', 'Ciencias Sociales', 'Ciencias Políticas', 'Ciencias Políticas'),
    ('5F02', 'Ciencias Sociales', 'Ciencias Políticas', 'Administración Pública'),
    ('5F03', 'Ciencias Sociales', 'Ciencias Políticas', 'teoría organizacional'),
    ('5G01', 'Ciencias Sociales', 'Geografía Social y Económica', 'Ciencias ambientales'),
    ('5G02', 'Ciencias Sociales', 'Geografía Social y Económica', 'Geografía económica y cultural'),
    ('5G03', 'Ciencias Sociales', 'Geografía Social y Económica', 'Estudios urbanos (planificación y desarrollo)'),
    ('5G04', 'Ciencias Sociales', 'Geografía Social y Económica', 'Planificación del transporte y aspectos sociales del transporte'),
    ('5H01', 'Ciencias Sociales', 'Periodismo y Comunicaciones', 'Periodismo'),
    ('5H02', 'Ciencias Sociales', 'Periodismo y Comunicaciones', 'Ciencias de la Información (aspectos sociales)'),
    ('5H03', 'Ciencias Sociales', 'Periodismo y Comunicaciones', 'Bibliotecología'),
    ('5H04', 'Ciencias Sociales', 'Periodismo y Comunicaciones', 'Medios y comunicación social'),
    ('5I01', 'Ciencias Sociales', 'Otras Ciencias Sociales', 'Ciencias Sociales, interdisciplinaria'),
    ('5I02', 'Ciencias Sociales', 'Otras Ciencias Sociales', 'Otras Ciencias Sociales'),
    ('6A01', 'Humanidades', 'Historia y Arqueología', 'Historia (historia de la ciencia y tecnología en 6C)'),
    ('6A02', 'Humanidades', 'Historia y Arqueología', 'Arqueología'),
    ('6A03', 'Humanidades', 'Historia y Arqueología', 'Historia de Colombia'),
    ('6B01', 'Humanidades', 'Idiomas y Literatura', 'Estudios generales del lenguaje'),
    ('6B02', 'Humanidades', 'Idiomas y Literatura', 'Idiomas específicos'),
    ('6B03', 'Humanidades', 'Idiomas y Literatura', 'Estudios literarios'),
    ('6B04', 'Humanidades', 'Idiomas y Literatura', 'Teoría literaria'),
    ('6B05', 'Humanidades', 'Idiomas y Literatura', 'Literatura específica'),
    ('6B06', 'Humanidades', 'Idiomas y Literatura', 'Lingüística'),
    ('6C01', 'Humanidades', 'Otras historias', 'Historia de la Ciencia y la Tecnología'),
    ('6C02', 'Humanidades', 'Otras historias', 'Otras historias especializadas (Se incluye Histora del Arte)'),
    ('6D01', 'Humanidades', 'Arte', 'Artes plásticas y visules'),
    ('6D02', 'Humanidades', 'Arte', 'Música y musicología'),
    ('6D03', 'Humanidades', 'Arte', 'Danza o Artes danzarías'),
    ('6D04', 'Humanidades', 'Arte', 'Teatro, dramaturgia o Artes escénicas'),
    ('6D05', 'Humanidades', 'Arte', 'Otras artes'),
    ('6D06', 'Humanidades', 'Arte', 'Artes audiovisuales'),
    ('6D07', 'Humanidades', 'Arte', 'Arquitectura y urbanismo'),
    ('6D08', 'Humanidades', 'Arte', 'Diseño'),
    ('6E01', 'Humanidades', 'Otras Humanidades', 'Otras humanidades (Se incluye Estudios del folclor)'),
    ('6E02', 'Humanidades', 'Otras Humanidades', 'Filosofía'),
    ('6E03', 'Humanidades', 'Otras Humanidades', 'Teología');

-- objetivo_desarrollo_sostenible: 17 filas
INSERT INTO objetivo_desarrollo_sostenible (id, nombre, categoria) VALUES
    (1, 'Fin de la Pobreza', 'Social'),
    (2, 'Hambre cero', 'Social'),
    (3, 'Salud y bienestar', 'Social'),
    (4, 'Educación de calidad', 'Social'),
    (5, 'Igualdad de género', 'Social'),
    (6, 'Agua limpia y saneamiento', 'Ambientales'),
    (7, 'Energía asequible y no contaminante', 'Económicos'),
    (8, 'Trabajo decente y crecimiento económico', 'Económicos'),
    (9, 'Industria, Innovación e Infraestructura', 'Económicos'),
    (10, 'Reducción de las desigualdades', 'Económicos'),
    (11, 'Ciudades y Comunidades Sostenibles', 'Económicos'),
    (12, 'Producción y consumo Responsables', 'Ambientales'),
    (13, 'Acción por el clima', 'Ambientales'),
    (14, 'Vida Submarina', 'Ambientales'),
    (15, 'Vide de ecosistemas terrestres', 'Ambientales'),
    (16, 'Paz, Justicia e instituciones sólidas', 'Estrategicos'),
    (17, 'Alianzas para lograr los objetivos', 'Estrategicos');

-- area_aplicacion: 21 filas
INSERT INTO area_aplicacion (id, nombre) VALUES
    (1, 'Agricultura, ganadería, caza, silvicultura y pesca'),
    (2, 'Explotación de minas y canteras'),
    (3, 'Industriasmanufactureras'),
    (4, 'Suministro de electricidad, gas, vapor y aire acondicionado'),
    (5, 'Distribución de agua; evacuación y tratamiento de aguas residuales, gestión de desechos y actividades de saneamiento ambiental'),
    (6, 'Construcción'),
    (7, 'Comercio al por mayor y al por menor; reparación de vehículos automotores y motocicletas'),
    (8, 'Transporte y almacenamiento'),
    (9, 'Alojamiento y servicios de comida'),
    (10, 'Información y comunicaciones'),
    (11, 'Actividades financieras y de seguros'),
    (12, 'Actividades inmobiliarias'),
    (13, 'Actividades profesionales, científicas y técnicas'),
    (14, 'Actividades de servicios administrativos y de apoyo'),
    (15, 'Administración pública y defensa; planes de seguridad social de afiliación obligatoria'),
    (16, 'Educación'),
    (17, 'Actividades de atención de la salud humana y de asistencia social'),
    (18, 'Actividades artísticas, de entretenimiento y recreación'),
    (19, 'Otras actividades de servicios'),
    (20, 'Actividades de los hogares en calidad de empleadores'),
    (21, 'Actividades de organizaciones y entidades extraterritoriales');

-- proyecto: 14 filas DE EJEMPLO. Ojo con esto.
--
-- Los tres catálogos de arriba salieron del Excel del módulo. Esta tabla NO:
-- la hoja `proyecto` del Excel no trae ni un proyecto. Lo único que aporta
-- son los valores admitidos de dos columnas —`tipo_financiacion` con
-- 'interna', 'externa' y 'cofinanciado', y `tipo_fondos` con 'Público',
-- 'Privado' y 'Mixto'—, y ESO SÍ se respeta al pie de la letra: las catorce
-- filas usan solo esos seis valores.
--
-- El resto —títulos, resúmenes, presupuestos y fechas— está inventado, y se
-- dice aquí porque un dato inventado que no se anuncia termina citado en un
-- informe como si fuera del módulo. Ninguno de estos proyectos existe.
--
-- Cinco filas van con `fecha_fin` en NULL a propósito: son las que están en
-- curso, y son las que hacen visible en pantalla que esa columna es LA ÚNICA
-- opcional de la tabla. Con las catorce terminadas, nadie notaría la
-- diferencia entre una columna opcional y una obligatoria.
INSERT INTO proyecto (id, titulo, resumen, presupuesto, tipo_financiacion,
                      tipo_fondos, fecha_inicio, fecha_fin) VALUES
    (1001, 'Mapa de saberes locales en el oriente antioqueño', 'Levantamiento participativo del conocimiento tradicional de cuatro municipios, con miras a integrarlo a los currículos de pregrado.', 48000000, 'interna', 'Público', '2024-02-01', '2025-01-31'),
    (1002, 'Analítica de datos para la deserción estudiantil', 'Modelo descriptivo que cruza matrícula, notas y apoyos económicos para identificar en qué semestre se pierde a los estudiantes y por qué.', 72500000, 'cofinanciado', 'Mixto', '2024-03-15', '2025-09-30'),
    (1003, 'Energías limpias para sedes rurales', 'Diseño de un sistema solar de respaldo para tres sedes rurales y medición de su costo real frente al de la red convencional.', 130000000, 'externa', 'Privado', '2024-05-02', NULL),
    (1004, 'Lectura crítica en la formación de maestros', 'Estudio de aula sobre cómo cambian las prácticas de lectura de los futuros licenciados cuando la evaluación deja de ser un cuestionario.', 21000000, 'interna', 'Público', '2023-08-01', '2024-12-15'),
    (1005, 'Prototipo de riego inteligente para pequeños cultivos', 'Sensores de humedad y control por microcontrolador, pensado para predios de menos de dos hectáreas y presupuesto de familia campesina.', 56800000, 'cofinanciado', 'Mixto', '2024-07-01', NULL),
    (1006, 'Memoria histórica del conflicto en el Caribe', 'Archivo oral con sobrevivientes y organizaciones sociales, y una guía para que otras universidades repitan el método sin revictimizar.', 94000000, 'externa', 'Público', '2023-11-06', '2025-05-30'),
    (1007, 'Salud mental de estudiantes en primer semestre', 'Tamizaje y acompañamiento durante el primer año, con seguimiento de qué tanto el acompañamiento cambia la permanencia.', 38400000, 'interna', 'Público', '2024-01-22', '2024-11-29'),
    (1008, 'Materiales de construcción a partir de residuos', 'Ensayos de resistencia de bloques fabricados con residuos de demolición, buscando una mezcla que cumpla la norma sismo resistente.', 112300000, 'externa', 'Privado', '2024-04-08', NULL),
    (1009, 'Observatorio de innovación curricular', 'Seguimiento a las reformas de plan de estudios de los últimos diez años y a lo que efectivamente cambió en el aula después de firmarlas.', 29750000, 'interna', 'Público', '2024-09-02', NULL),
    (1010, 'Turismo comunitario y patrimonio en el Quindío', 'Inventario del patrimonio material de seis veredas y formación de guías locales, con las comunidades como dueñas de los productos.', 67200000, 'cofinanciado', 'Mixto', '2023-06-12', '2024-10-31'),
    (1011, 'Accesibilidad web en los servicios universitarios', 'Auditoría de los trámites en línea contra la norma de accesibilidad y corrección de los tres más usados por estudiantes con discapacidad.', 18900000, 'interna', 'Público', '2024-08-19', '2025-03-14'),
    (1012, 'Cadena de valor del café de alta montaña', 'Costeo de la cadena desde el predio hasta la exportación, para establecer dónde se queda el margen que no llega al productor.', 85000000, 'externa', 'Privado', '2024-02-26', '2025-08-29'),
    (1013, 'Formación docente en pensamiento computacional', 'Programa para maestros de básica que no vienen de áreas técnicas, con medición de lo que aprenden sus estudiantes al año siguiente.', 43600000, 'cofinanciado', 'Mixto', '2024-10-07', NULL),
    (1014, 'Movilidad sostenible en el campus', 'Conteo de viajes, encuesta de origen y destino, y propuesta de rutas seguras para bicicleta entre las sedes y el sistema de transporte.', 25400000, 'interna', 'Público', '2023-09-04', '2024-08-30');

SET FOREIGN_KEY_CHECKS = 1;

-- ============================================================
-- Conteos esperados:
--   area_conocimiento                 218 filas
--   objetivo_desarrollo_sostenible     17 filas
--   area_aplicacion                    21 filas
--   proyecto                           14 filas (DE EJEMPLO: el Excel no las trae)
-- ============================================================
