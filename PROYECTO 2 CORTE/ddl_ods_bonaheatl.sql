CREATE DATABASE `ods_bona_health` /*!40100 DEFAULT CHARACTER SET utf8 */;

USE `Bona_Health_DW` ;

CREATE TABLE `enfermedad` (
  `nombre` varchar(45) NOT NULL,
  `observacion` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`nombre`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


CREATE TABLE `persona` (
  `id_persona` varchar(45) NOT NULL,
  `fecha_nam` date NOT NULL,
  `edad` int(2) NOT NULL,
  `sexo` varchar(45) NOT NULL,
  `seg_social` varchar(45) NOT NULL,
  PRIMARY KEY (`id_persona`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `fecha` (
  `fecha_completa` date NOT NULL,
  `año` int(4) NOT NULL,
  `mes` varchar(45) NOT NULL,
  `dia` int(2) NOT NULL,
  PRIMARY KEY (`fecha_completa`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `departamento` (
  `cod_departamento` int(11) NOT NULL,
  `nombre` varchar(45) NOT NULL,
  PRIMARY KEY (`cod_departamento`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `institucion` (
  `cod_institucion` varchar(45) NOT NULL,
  `nombre` varchar(60) NOT NULL,
  PRIMARY KEY (`cod_institucion`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


CREATE TABLE `municipio` (
  `cod_municipio` int(11) NOT NULL,
  `cod_departamento` int(11) NOT NULL,
  `nombre` varchar(45) NOT NULL,
  PRIMARY KEY (`cod_municipio`,`cod_departamento`),
  KEY `fk_municipio_departamento_idx` (`cod_departamento`),
  CONSTRAINT `fk_municipio_departamento` FOREIGN KEY (`cod_departamento`) REFERENCES `departamento` (`cod_departamento`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


CREATE TABLE `lugar` (
  `id_lugar` varchar(45) NOT NULL,
  `tipo_lugar` varchar(45) NOT NULL,
  `departamento` int(11) NOT NULL,
  `municipio` int(11) NOT NULL,
  `institucion` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`id_lugar`),
  KEY `fk_lugar_institucion1_idx` (`institucion`),
  KEY `fk_lugar_municipio1_idx` (`municipio`,`departamento`),
  CONSTRAINT `fk_lugar_institucion1` FOREIGN KEY (`institucion`) REFERENCES `institucion` (`cod_institucion`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_lugar_municipio1` FOREIGN KEY (`municipio`, `departamento`) REFERENCES `municipio` (`cod_municipio`, `cod_departamento`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


CREATE TABLE `fallecimiento` (
  `lugar` varchar(45) NOT NULL,
  `fecha` date NOT NULL,
  `persona` varchar(45) NOT NULL,
  `enfermedad` varchar(45) NOT NULL,
  `asistencia_medica` varchar(2) NOT NULL,
  PRIMARY KEY (`lugar`,`fecha`,`persona`,`enfermedad`),
  KEY `fk_fallecimiento_lugar1_idx` (`lugar`),
  KEY `fk_fallecimiento_fecha1_idx` (`fecha`),
  KEY `fk_fallecimiento_persona1_idx` (`persona`),
  KEY `fk_fallecimiento_enfermedad1_idx` (`enfermedad`),
  CONSTRAINT `fk_fallecimiento_enfermedad1` FOREIGN KEY (`enfermedad`) REFERENCES `enfermedad` (`nombre`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_fallecimiento_fecha1` FOREIGN KEY (`fecha`) REFERENCES `fecha` (`fecha_completa`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_fallecimiento_lugar1` FOREIGN KEY (`lugar`) REFERENCES `lugar` (`id_lugar`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_fallecimiento_persona1` FOREIGN KEY (`persona`) REFERENCES `persona` (`id_persona`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
