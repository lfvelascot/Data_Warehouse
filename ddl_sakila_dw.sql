-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema sakila_dw
-- -----------------------------------------------------

-- -----------------------------------------------------
-- Schema sakila_dw
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `sakila_dw` DEFAULT CHARACTER SET utf8 ;
-- -----------------------------------------------------
-- Schema sakila_dw
-- -----------------------------------------------------
USE `sakila_dw` ;

-- -----------------------------------------------------
-- Table `sakila_dw`.`dim_film`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `sakila_dw`.`dim_film` (
  `id_film` INT NOT NULL,
  `title` VARCHAR(45) NULL,
  `language` VARCHAR(45) NULL,
  PRIMARY KEY (`id_dim_film`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `sakila_dw`.`dim_time`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `sakila_dw`.`dim_time` (
  `complete_date` DATE NOT NULL,
  `year` INT NULL,
  `month` VARCHAR(45) NULL,
  `day` INT NULL,
  `week_day` VARCHAR(45) NULL,
  PRIMARY KEY (`complete_date`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `sakila_dw`.`dim_store`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `sakila_dw`.`dim_store` (
  `id_store` INT NOT NULL,
  `country` VARCHAR(45) NULL,
  `city` VARCHAR(45) NULL,
  `address` VARCHAR(45) NULL,
  PRIMARY KEY (`id_dim_store`),
  UNIQUE INDEX `address_UNIQUE` (`address` ASC) )
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `sakila_dw`.`fact_inventory`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `sakila_dw`.`fact_inventory` (
  `dim_film` INT NOT NULL,
  `dim_time` DATE NOT NULL,
  `dim_store` INT NOT NULL,
  `quantity_film` INT(6) NOT NULL DEFAULT 1,
  INDEX `fk_fact_inventory_dim_film_idx` (`dim_film` ASC) ,
  INDEX `fk_fact_inventory_dim_time_idx` (`dim_time` ASC) ,
  INDEX `fk_fact_inventory_dim_store_idx` (`dim_store` ASC) ,
  PRIMARY KEY (`dim_store`, `dim_time`, `dim_film`),
  CONSTRAINT `fk_fact_inventory_dim_film`
    FOREIGN KEY (`dim_film`)
    REFERENCES `sakila_dw`.`dim_film` (`id_film`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_fact_inventory_dim_time1`
    FOREIGN KEY (`dim_time`)
    REFERENCES `sakila_dw`.`dim_time` (`complete_date`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_fact_inventory_dim_store1`
    FOREIGN KEY (`dim_store`)
    REFERENCES `sakila_dw`.`dim_store` (`id_store`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

-- drop table `sakila_dw`.`fact_inventory`;

-- -----------------------------------------------------
-- Table `sakila_dw`.`dim_customer`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `sakila_dw`.`dim_customer` (
  `id_dim_customer` INT NOT NULL,
  `name` VARCHAR(45) NULL,
  `status` TINYINT NULL,
  `address` VARCHAR(45) NULL,
  `city` VARCHAR(45) NULL,
  `country` VARCHAR(45) NULL,
  PRIMARY KEY (`id_dim_customer`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `sakila_dw`.`dim_staff`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `sakila_dw`.`dim_staff` (
  `id_dim_staff` INT NOT NULL,
  `name` VARCHAR(45) NULL,
  `id_store` INT NULL,
  PRIMARY KEY (`id_dim_staff`),
  INDEX `fk_dim_staff_dim_store1_idx` (`id_store` ASC) ,
  CONSTRAINT `fk_dim_staff_dim_store1`
    FOREIGN KEY (`id_store`)
    REFERENCES `sakila_dw`.`dim_store` (`id_dim_store`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `sakila_dw`.`fact_rentals`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `sakila_dw`.`fact_rentals` (
  `dim_customer` INT NOT NULL,
  `dim_film` INT NOT NULL,
  `dim_store` INT NOT NULL,
  `dim_time` DATE NOT NULL,
  `dim_staff` INT NOT NULL,
  `quantity_rentals` INT(6) NOT NULL DEFAULT 1,
  INDEX `fk_fact_rentals_dim_customer1_idx` (`dim_customer` ASC) ,
  INDEX `fk_fact_rentals_dim_film1_idx` (`dim_film` ASC) ,
  INDEX `fk_fact_rentals_dim_store1_idx` (`dim_store` ASC) ,
  INDEX `fk_fact_rentals_dim_time1_idx` (`dim_time` ASC) ,
  INDEX `fk_fact_rentals_dim_staff1_idx` (`dim_staff` ASC) ,
  PRIMARY KEY (`dim_staff`, `dim_time`, `dim_store`, `dim_film`, `dim_customer`),
  CONSTRAINT `fk_fact_rentals_dim_customer1`
    FOREIGN KEY (`dim_customer`)
    REFERENCES `sakila_dw`.`dim_customer` (`id_customer`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_fact_rentals_dim_film1`
    FOREIGN KEY (`dim_film`)
    REFERENCES `sakila_dw`.`dim_film` (`id_film`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_fact_rentals_dim_store1`
    FOREIGN KEY (`dim_store`)
    REFERENCES `sakila_dw`.`dim_store` (`id_store`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_fact_rentals_dim_time1`
    FOREIGN KEY (`dim_time`)
    REFERENCES `sakila_dw`.`dim_time` (`complete_date`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_fact_rentals_dim_staff1`
    FOREIGN KEY (`dim_staff`)
    REFERENCES `sakila_dw`.`dim_staff` (`id_staff`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `sakila_dw`.`fact_sales`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `sakila_dw`.`fact_sales` (
  `dim_customer` INT NOT NULL,
  `dim_time` DATE NOT NULL,
  `dim_store` INT NOT NULL,
  `dim_staff` INT NOT NULL,
  `quantity_sales` INT(6) NOT NULL DEFAULT 1,
  INDEX `fk_fact_sales_dim_customer1_idx` (`dim_customer` ASC) ,
  INDEX `fk_fact_sales_dim_time1_idx` (`dim_time` ASC) ,
  INDEX `fk_fact_sales_dim_store1_idx` (`dim_store` ASC) ,
  INDEX `fk_fact_sales_dim_staff1_idx` (`dim_staff` ASC) ,
  PRIMARY KEY (`dim_customer`, `dim_time`, `dim_store`, `dim_staff`),
  CONSTRAINT `fk_fact_sales_dim_customer1`
    FOREIGN KEY (`dim_customer`)
    REFERENCES `sakila_dw`.`dim_customer` (`id_dim_customer`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_fact_sales_dim_time1`
    FOREIGN KEY (`dim_time`)
    REFERENCES `sakila_dw`.`dim_time` (`complete_date`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_fact_sales_dim_store1`
    FOREIGN KEY (`dim_store`)
    REFERENCES `sakila_dw`.`dim_store` (`id_dim_store`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_fact_sales_dim_staff1`
    FOREIGN KEY (`dim_staff`)
    REFERENCES `sakila_dw`.`dim_staff` (`id_dim_staff`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `sakila_dw`.`dim_category`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `sakila_dw`.`dim_categorydim_film` (
  `id_category` TINYINT NOT NULL,
  `name` VARCHAR(45) NULL,
  PRIMARY KEY (`id_category`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `sakila_dw`.`bridge_film_category`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `sakila_dw`.`bridge_film_category` (
  `id_category` TINYINT NOT NULL,
  `id_dim` INT NOT NULL,
  INDEX `fk_bridge_film_category_dim_category1_idx` (`id_category` ASC) ,
  INDEX `fk_bridge_film_category_dim_film1_idx` (`id_dim` ASC) ,
  CONSTRAINT `fk_bridge_film_category_dim_category1`
    FOREIGN KEY (`id_category`)
    REFERENCES `sakila_dw`.`dim_category` (`id_category`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_bridge_film_category_dim_film1`
    FOREIGN KEY (`id_dim`)
    REFERENCES `sakila_dw`.`dim_film` (`id_dim_film`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `sakila_dw`.`dim_actor`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `sakila_dw`.`dim_actor` (
  `id_actor` TINYINT NOT NULL,
  `name` VARCHAR(45) NULL,
  PRIMARY KEY (`id_actor`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `sakila_dw`.`bridge_film_customer`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `sakila_dw`.`bridge_film_actor` (
  `id_actor` TINYINT NOT NULL,
  `id_film` INT NOT NULL,
  INDEX `fk_bridge_film_customer_dim_actor1_idx` (`id_actor` ASC) ,
  INDEX `fk_bridge_film_customer_dim_film1_idx` (`id_film` ASC) ,
  CONSTRAINT `fk_bridge_film_customer_dim_actor1`
    FOREIGN KEY (`id_actor`)
    REFERENCES `sakila_dw`.`dim_actor` (`id_actor`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_bridge_film_customer_dim_film1`
    FOREIGN KEY (`id_film`)
    REFERENCES `sakila_dw`.`dim_film` (`id_film`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
