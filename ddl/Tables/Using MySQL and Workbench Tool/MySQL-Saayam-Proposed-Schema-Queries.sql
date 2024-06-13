-- MySQL Script generated by MySQL Workbench
-- Fri May 31 09:42:46 2024
-- Model: New Model    Version: 1.0
-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema mydb
-- -----------------------------------------------------
-- -----------------------------------------------------
-- Schema proposed-saayam
-- -----------------------------------------------------

-- -----------------------------------------------------
-- Schema proposed-saayam
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `proposed-saayam` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci ;
USE `proposed-saayam` ;

-- -----------------------------------------------------
-- Table `proposed-saayam-test`.`action`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `proposed-saayam`.`action` (
  `action_id` INT NOT NULL AUTO_INCREMENT COMMENT 'Auto generated unique identifier',
  `action_desc` VARCHAR(30) NOT NULL,
  `created_dt` DATE NULL,
  `created_by` VARCHAR(30) NULL,
  `last_upd_by` VARCHAR(30) NULL,
  `last_upd_dt` DATE NULL,
  UNIQUE INDEX `uk_action_actn_id` (`action_id` ASC),
  PRIMARY KEY (`action_id`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `proposed-saayam-test`.`country`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `proposed-saayam`.`country` (
  `country_id` INT NOT NULL AUTO_INCREMENT COMMENT 'Auto generated unique identifier',
  `country_name` VARCHAR(255) NOT NULL COMMENT 'Represents names of the countries.',
  `phone_country_code` INT NOT NULL COMMENT 'Represents International Subscriber Dialing (ISD) code or telephone country code. These codes are used as prefixes for reaching telephone subscribers in different countries and are defined by the International Telecommunication Union (ITU). They enable international direct dialing (IDD) and are an essential part of the international telephone numbering plan.\n\nhttps://www.countrycode.org/',
  `last_update_date` DATETIME NULL COMMENT 'Represents last date time the record is updated in the database.',
  UNIQUE INDEX `uk_cntry_cntry_id` (`country_id` ASC),
  PRIMARY KEY (`country_id`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `proposed-saayam-test`.`identity_type`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `proposed-saayam`.`identity_type` (
  `identity_type_id` INT NOT NULL AUTO_INCREMENT COMMENT 'Auto generated unique identifier',
  `identity_value` VARCHAR(255) NOT NULL,
  `identity_type_dsc` VARCHAR(255) NULL COMMENT 'Represents explanation of each identity type',
  `last_updated_date` DATETIME NULL COMMENT 'Represents last date time the record is updated in the database.',
  UNIQUE INDEX `uk_user_idnty_id` (`identity_type_id` ASC),
  PRIMARY KEY (`identity_type_id`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `proposed-saayam-test`.`request_priority`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `proposed-saayam`.`request_priority` (
  `priority_id` INT NOT NULL AUTO_INCREMENT COMMENT 'Auto generated unique identifier',
  `priority_value` VARCHAR(255) NOT NULL COMMENT 'Represents values a help request\'s urgency/importance level can have.\n\nLow\nMedium\nHigh',
  `priority_description` VARCHAR(255) NULL COMMENT 'Represents explanation of each priority.',
  `last_updated_date` DATETIME NULL COMMENT 'Represents last date time the record is updated in the database.',
  UNIQUE INDEX `uk_priority_prty_id` (`priority_id` ASC),
  PRIMARY KEY (`priority_id`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `proposed-saayam`.`state`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `proposed-saayam`.`state` (
  `state_id` INT NOT NULL AUTO_INCREMENT COMMENT 'Auto generated unique identifier',
  `country_id` INT NOT NULL COMMENT 'Represents country using ID from \'Country\' table.',
  `state_name` VARCHAR(255) NOT NULL COMMENT 'Represents states in a country.',
  `last_update_date` DATETIME NULL DEFAULT NULL COMMENT 'Represents last date time the record is updated in the database.',
  PRIMARY KEY (`state_id`),
  UNIQUE INDEX `uk_state_lkp` (`country_id` ASC, `state_id` ASC),
  UNIQUE INDEX `state_id_UNIQUE` (`state_id` ASC) VISIBLE,
  CONSTRAINT `fk_country_id`
    FOREIGN KEY (`country_id`)
    REFERENCES `proposed-saayam`.`country` (`country_id`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `proposed-saayam`.`city`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `proposed-saayam`.`city` (
  `city_id` INT NOT NULL AUTO_INCREMENT COMMENT 'Auto generated unique identifier',
  `state_id` INT NOT NULL COMMENT 'Represents state ID. Associated with state ID from \'State\' table. This helps to identify same city name but different state name.',
  `city_name` VARCHAR(30) NOT NULL COMMENT 'Represents city name.',
  `lattitude` DECIMAL(9) NULL COMMENT 'Represents lattitude of the city.',
  `longitude` DECIMAL(9) NULL COMMENT 'Represents longitude of the city.',
  `last_update_date` DATETIME NULL DEFAULT NULL,
  UNIQUE INDEX `uk_region_regn_id` (`city_id` ASC),
  PRIMARY KEY (`city_id`),
  INDEX `fk_state_id_idx` (`state_id` ASC),
  CONSTRAINT `fk_state_id`
    FOREIGN KEY (`state_id`)
    REFERENCES `proposed-saayam`.`state` (`state_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `proposed-saayam`.`user_status`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `proposed-saayam`.`user_status` (
  `user_status_id` INT NOT NULL AUTO_INCREMENT COMMENT 'Auto generated unique identifier',
  `user_status` VARCHAR(255) NOT NULL COMMENT 'Represents status of each user.\n\nActive - the volunteer is currently engaged and actively participating in volunteering activities.\nInactive - The volunteer is not currently participating in any volunteering activities.\nPending - The volunteer has expressed interest but has not yet started volunteering or is awaiting assignment.\nOnHold - The volunteer’s activities are temporarily suspended, possibly due to personal reasons, vacations etc.',
  `user_status_desc` VARCHAR(255) NULL COMMENT 'Represents explanation of each status value',
  `last_update` DATE NULL COMMENT 'Represents last date time the record is updated in the database.',
  UNIQUE INDEX `uk_user_status_id` (`user_status_id` ASC),
  PRIMARY KEY (`user_status_id`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `proposed-saayam`.`user_category`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `proposed-saayam`.`user_category` (
  `user_category_id` INT NOT NULL AUTO_INCREMENT COMMENT 'Auto generated unique identifier',
  `user_category` VARCHAR(255) NOT NULL COMMENT 'Represents cateogry of the user.\n\nMember\nDonor\nVolunteer',
  `user_category_desc` VARCHAR(255) NOT NULL COMMENT 'Represents explanation of each category.',
  `last_update_date` DATETIME NULL,
  UNIQUE INDEX `uk_ut_utypid` (`user_category_id` ASC),
  PRIMARY KEY (`user_category_id`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `proposed-saayam`.`users`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `proposed-saayam`.`users` (
  `user_id` INT NOT NULL AUTO_INCREMENT COMMENT 'Auto generated unique identifier',
  `city_id` INT NOT NULL COMMENT 'Represents city where user resides',
  `state_id` INT NOT NULL COMMENT 'Represents state where user resides',
  `country_id` INT NOT NULL COMMENT 'Represents country where user resides',
  `user_status_id` INT NOT NULL COMMENT 'Represents status of each user. Associated with ID from \'user_status\' table\n\nActive - the volunteer is currently engaged and actively participating in volunteering activities.\nInactive - The volunteer is not currently participating in any volunteering activities.\nPending - The volunteer has expressed interest but has not yet started volunteering or is awaiting assignment.\nOnHold - The volunteer’s activities are temporarily suspended, possibly due to personal reasons, vacations etc.',
  `user_category_id` INT NOT NULL,
  `full_name` VARCHAR(255) NOT NULL COMMENT 'Represents the name of the user (provided while signing up)',
  `first_name` VARCHAR(255) NOT NULL COMMENT 'Represents first name of the user',
  `middle_name` VARCHAR(255) NULL COMMENT 'Represents middle name of the user optional)',
  `last_name` VARCHAR(255) NOT NULL COMMENT 'Represents last name of the user',
  `email_address` VARCHAR(255) NULL COMMENT 'Represents email address of the user. This is optional field.',
  `phone_number` VARCHAR(255) NULL COMMENT 'Represents phone numberof the user',
  `addr_ln1` VARCHAR(255) NULL COMMENT 'Represents address of the user',
  `addr_ln2` VARCHAR(255) NULL COMMENT 'Represents address of the user',
  `addr_ln3` VARCHAR(255) NULL COMMENT 'Represents address of the user',
  `zip_code` INT NOT NULL COMMENT 'Represents zip code where user resides',
  `last_update_date` DATETIME NULL,
  `time_zone` VARCHAR(255) NOT NULL COMMENT 'Represents the time zone of the user',
  `profile_picture_path` VARCHAR(255) NULL COMMENT 'Prepresents the path to the profile picture in S3',
  PRIMARY KEY (`user_id`),
  UNIQUE INDEX `uk_user_user_id` (`user_id` ASC),
  INDEX `fk_user_state_id` (`country_id` ASC, `state_id` ASC),
  INDEX `fk_user_status_id` (`user_status_id` ASC),
  INDEX `fk_city_id_idx` (`city_id` ASC),
  INDEX `fk_user_category_id_idx` (`user_category_id` ASC),
  CONSTRAINT `fk_user_country_id`
    FOREIGN KEY (`country_id`)
    REFERENCES `proposed-saayam`.`country` (`country_id`),
  CONSTRAINT `fk_user_state_id`
    FOREIGN KEY (`country_id` , `state_id`)
    REFERENCES `proposed-saayam`.`state` (`country_id` , `state_id`),
  CONSTRAINT `fk_user_status_id`
    FOREIGN KEY (`user_status_id`)
    REFERENCES `proposed-saayam`.`user_status` (`user_status_id`),
  CONSTRAINT `fk_city_id`
    FOREIGN KEY (`city_id`)
    REFERENCES `proposed-saayam`.`city` (`city_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_user_category_id`
    FOREIGN KEY (`user_category_id`)
    REFERENCES `proposed-saayam`.`user_category` (`user_category_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `proposed-saayam`.`request_status`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `proposed-saayam`.`request_status` (
  `request_status_id` INT NOT NULL COMMENT 'Auto generated unique identifier',
  `request_status` VARCHAR(255) NOT NULL COMMENT 'Represents various states a help request can transition through.\n\nCreated\nPending\nIn_progress\nCompleted\nCancelled',
  `request_status_desc` VARCHAR(255) NULL COMMENT 'Represents explanation of each request status.',
  `last_updated_date` DATETIME NULL COMMENT 'Represents last date time the record is updated in the database.',
  PRIMARY KEY (`request_status_id`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `proposed-saayam`.`request_type`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `proposed-saayam`.`request_type` (
  `request_type_id` INT NOT NULL AUTO_INCREMENT COMMENT 'Auto generated unique identifier',
  `request_type` VARCHAR(255) NULL COMMENT 'Represents values type of help request. This is helpful for service providers in understanding the nature of the request and how best to assist the user.\n\nIn-Person\nDigitial',
  `request_type_desc` VARCHAR(255) NULL COMMENT 'Represents explanation of each request type.',
  `last_updated_date` DATETIME NULL COMMENT 'Represents last date time the record is updated in the database.',
  PRIMARY KEY (`request_type_id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `proposed-saayam`.`request_category`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `proposed-saayam`.`request_category` (
  `request_category_id` INT NOT NULL AUTO_INCREMENT COMMENT 'Auto generated unique identifier',
  `request_category` VARCHAR(255) NOT NULL COMMENT 'Represents values for type of help request can have.\n\nTechnical Support\nFinancial Support\nLegal Support',
  `request_category_desc` VARCHAR(255) NULL COMMENT 'Represents explanation of each category.',
  `last_updated_date` DATETIME NULL COMMENT 'Represents last date time the record is updated in the database.',
  PRIMARY KEY (`request_category_id`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `proposed-saayam`.`request`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `proposed-saayam`.`request` (
  `request_id` INT NOT NULL AUTO_INCREMENT COMMENT 'Auto generated unique identifier',
  `request_user_id` INT NOT NULL COMMENT 'Identifies the user making the request. Associated with user ID from \'User\' table',
  `request_status_id` INT NOT NULL COMMENT 'Represents the current status of the request. Represents various states a help request can transition through.\n\n-- Created\n-- Pending\n-- In_progress\n-- Completed\n-- Cancelled',
  `request_priority_id` INT NOT NULL COMMENT 'Represents values a help request\'s urgency/importance level can have.\n\nLow\nMedium\nHigh',
  `request_type_id` INT NOT NULL COMMENT 'Represents values type of help request. This is helpful for service providers in understanding the nature of the request and how best to assist the user.\n\nIn-Person\nDigitial',
  `request_category_id` INT NOT NULL COMMENT 'Represents values for type of help request can have.\n\nTechnical Support\nFinancial Support\nLegal Support',
  `request_city_id` INT NOT NULL,
  `request_desc` VARCHAR(255) NOT NULL COMMENT 'Describes details of the help request.',
  `request_for` VARCHAR(255) NOT NULL COMMENT 'Specifies whether request is for self or someone else.',
  `submission_date` DATETIME NULL COMMENT 'Indicates when the request was first created/submitted',
  `lead_volunteer_user_id` INT NULL COMMENT 'Represents the volunteer assigned to the request. Volunteer ID would be user from \'User\' table.\n\nQue: Should this be here OR request ID should be in User table?? Need to avoid cyclic foreign keys association.',
  `serviced_date` DATETIME NULL COMMENT 'Represents when volunteer completed the request.',
  `last_update_date` DATETIME NULL COMMENT 'Represents last date time the record is updated in the database.',
  PRIMARY KEY (`request_id`), 
  UNIQUE INDEX `request_id_UNIQUE` (`request_id` ASC),
  INDEX `user_id_idx` (`request_user_id` ASC),
  INDEX `request_status_id_idx` (`request_status_id` ASC),
  INDEX `request_priority_id_idx` (`request_priority_id` ASC),
  INDEX `request_type_id_idx` (`request_type_id` ASC),
  INDEX `request_category_id_idx` (`request_category_id` ASC),
  INDEX `request_region_id_idx` (`request_city_id` ASC),
  CONSTRAINT `fk_user_id`
    FOREIGN KEY (`request_user_id`)
    REFERENCES `proposed-saayam`.`users` (`user_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_request_status_id`
    FOREIGN KEY (`request_status_id`)
    REFERENCES `proposed-saayam`.`request_status` (`request_status_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_request_priority_id`
    FOREIGN KEY (`request_priority_id`)
    REFERENCES `proposed-saayam`.`request_priority` (`priority_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_request_type_id`
    FOREIGN KEY (`request_type_id`)
    REFERENCES `proposed-saayam`.`request_type` (`request_type_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_request_category_id`
    FOREIGN KEY (`request_category_id`)
    REFERENCES `proposed-saayam`.`request_category` (`request_category_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_request_city_id`
    FOREIGN KEY (`request_city_id`)
    REFERENCES `proposed-saayam`.`city` (`city_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `proposed-saayam`.`skill_lst`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `proposed-saayam`.`skill_lst` (
  `skill_lst_id` INT NOT NULL AUTO_INCREMENT,
  `skill_level` INT NOT NULL,
  `level_desc` VARCHAR(100) NOT NULL,
  `skill_last_used` DATE NULL,
  `is_actv` VARCHAR(1) NULL,
  `created_by` VARCHAR(30) NULL,
  `created_dt` DATE NULL,
  `last_update_by` VARCHAR(30) NULL,
  `last_update` DATE NULL,
  UNIQUE INDEX `uk_skill_lst_id` (`skill_lst_id` ASC))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `proposed-saayam`.`sla`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `proposed-saayam`.`sla` (
  `sla_id` INT NOT NULL AUTO_INCREMENT COMMENT 'Auto generated unique identifier',
  `sla_hours` INT NOT NULL COMMENT 'Represents total SLA for a request to get volunteer assigned',
  `sla_description` VARCHAR(255) NOT NULL COMMENT 'Represents explanation of each SLA',
  `no_of_cust_impct` INT NULL,
  `last_updated_date` DATETIME NULL COMMENT 'Represents last date time the record is updated in the database.',
  UNIQUE INDEX `uk_sla_sla_id` (`sla_id` ASC),
  PRIMARY KEY (`sla_id`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `proposed-saayam`.`user_skills`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `proposed-saayam`.`user_skills` (
  `user_id` INT NULL,
  `skill_id` INT NULL,
  `created_by` VARCHAR(30) NULL,
  `created_dt` DATE NULL,
  `last_update_by` VARCHAR(30) NULL,
  `last_update` DATE NULL,
  INDEX `fk_user_skills_user_id` (`user_id` ASC),
  INDEX `fk_user_skills_skill_id` (`skill_id` ASC),
  CONSTRAINT `fk_user_skills_skill_id`
    FOREIGN KEY (`skill_id`)
    REFERENCES `proposed-saayam`.`skill_lst` (`skill_lst_id`),
  CONSTRAINT `fk_user_skills_user_id`
    FOREIGN KEY (`user_id`)
    REFERENCES `proposed-saayam`.`users` (`user_id`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;