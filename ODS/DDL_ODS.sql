-- MySQL Workbench Forward Engineering
-- -----------------------------------------------------
-- Schemaods_bona_health
-- -----------------------------------------------------

-- -----------------------------------------------------
-- Schemaods_bona_health
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `ods_bona_health` DEFAULT CHARACTER SET utf8 ;
USE `ods_bona_health` ;

-- -----------------------------------------------------
-- Table `ods_bona_health`.`institucion`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `ods_bona_health`.`institucion` (
  `cod_institucion` VARCHAR(45) NOT NULL,
  `nombre` VARCHAR(60) NOT NULL,
  PRIMARY KEY (`cod_institucion`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `ods_bona_health`.`departamento`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `ods_bona_health`.`departamento` (
  `cod_departamento` INT NOT NULL,
  `nombre` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`cod_departamento`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `ods_bona_health`.`municipio`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `ods_bona_health`.`municipio` (
  `cod_municipio` INT NOT NULL,
  `cod_departamento` INT NOT NULL,
  `nombre` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`cod_municipio`, `cod_departamento`),
  INDEX `fk_municipio_departamento_idx` (`cod_departamento` ASC) ,
  CONSTRAINT `fk_municipio_departamento`
    FOREIGN KEY (`cod_departamento`)
    REFERENCES `ods_bona_health`.`departamento` (`cod_departamento`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `ods_bona_health`.`lugar`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `ods_bona_health`.`lugar` (
  `id_lugar` VARCHAR(45) NOT NULL,
  `tipo_lugar` VARCHAR(45) NOT NULL,
  `departamento` INT NOT NULL,
  `municipio` INT NOT NULL,
  `institucion` VARCHAR(45) NULL,
  PRIMARY KEY (`id_lugar`),
  INDEX `fk_lugar_institucion1_idx` (`institucion` ASC) ,
  INDEX `fk_lugar_municipio1_idx` (`municipio` ASC, `departamento` ASC) ,
  CONSTRAINT `fk_lugar_institucion1`
    FOREIGN KEY (`institucion`)
    REFERENCES `ods_bona_health`.`institucion` (`cod_institucion`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_lugar_municipio1`
    FOREIGN KEY (`municipio` , `departamento`)
    REFERENCES `ods_bona_health`.`municipio` (`cod_municipio` , `cod_departamento`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `ods_bona_health`.`fecha`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `ods_bona_health`.`fecha` (
  `fecha_completa` DATE NOT NULL,
  `año` INT(4) NOT NULL,
  `mes` VARCHAR(45) NOT NULL,
  `dia` INT(2) NOT NULL,
  PRIMARY KEY (`fecha_completa`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `ods_bona_health`.`persona`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `ods_bona_health`.`persona` (
  `id_persona` VARCHAR(45) NOT NULL,
  `fecha_nam` DATE NOT NULL,
  `edad` INT(2) NOT NULL,
  `sexo` VARCHAR(45) NOT NULL,
  `seg_social` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`id_persona`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `ods_bona_health`.`enfermedad`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `ods_bona_health`.`enfermedad` (
  `nombre` VARCHAR(45) NOT NULL,
  `observacon` VARCHAR(45) NULL,
  PRIMARY KEY (`nombre`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `ods_bona_health`.`fallecimiento`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `ods_bona_health`.`fallecimiento` (
  `lugar` VARCHAR(45) NOT NULL,
  `fecha` DATE NOT NULL,
  `persona` VARCHAR(45) NOT NULL,
  `enfermedad` VARCHAR(45) NOT NULL,
  `asistencia_medica` VARCHAR(2) NOT NULL,
  INDEX `fk_fallecimiento_lugar1_idx` (`lugar` ASC) ,
  INDEX `fk_fallecimiento_fecha1_idx` (`fecha` ASC) ,
  INDEX `fk_fallecimiento_persona1_idx` (`persona` ASC) ,
  INDEX `fk_fallecimiento_enfermedad1_idx` (`enfermedad` ASC) ,
  CONSTRAINT `fk_fallecimiento_lugar1`
    FOREIGN KEY (`lugar`)
    REFERENCES `ods_bona_health`.`lugar` (`id_lugar`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_fallecimiento_fecha1`
    FOREIGN KEY (`fecha`)
    REFERENCES `ods_bona_health`.`fecha` (`fecha_completa`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_fallecimiento_persona1`
    FOREIGN KEY (`persona`)
    REFERENCES `ods_bona_health`.`persona` (`id_persona`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_fallecimiento_enfermedad1`
    FOREIGN KEY (`enfermedad`)
    REFERENCES `ods_bona_health`.`enfermedad` (`nombre`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

delete from  `ods_bona_health`.`lugar`;
delete from `ods_bona_health`.`institucion`;