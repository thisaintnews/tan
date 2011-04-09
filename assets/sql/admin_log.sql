CREATE  TABLE IF NOT EXISTS `tan`.`admin_log` (
  `log_id` BIGINT(20) NOT NULL AUTO_INCREMENT ,
  `admin_id` BIGINT(20) NOT NULL ,
  `action` ENUM('edit_comment', 'edit_object', 'delete_object', 'delete_comment', 'delete_user', 'mass_delete_objects', 'mass_delete_comments') NOT NULL ,
  `reason` VARCHAR(255) NOT NULL ,
  `bulk` TEXT NULL DEFAULT NULL ,
  `user_id` BIGINT(20) NOT NULL ,
  `comment_id` BIGINT(20) NULL DEFAULT NULL ,
  `object_id` BIGINT(20) NULL DEFAULT NULL ,
  `created` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ,
  PRIMARY KEY (`log_id`) ,
  INDEX `fk_admin_id` (`admin_id` ASC) ,
  INDEX `fk_user_id` (`user_id` ASC) ,
  INDEX `fk_object_id` (`object_id` ASC) ,
  INDEX `fk_comment_id` (`comment_id` ASC) ,
  CONSTRAINT `fk_admin_id`
    FOREIGN KEY (`admin_id` )
    REFERENCES `tan`.`user` (`user_id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_user_id`
    FOREIGN KEY (`user_id` )
    REFERENCES `tan`.`user` (`user_id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_object_id`
    FOREIGN KEY (`object_id` )
    REFERENCES `tan`.`object` (`object_id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_comment_id`
    FOREIGN KEY (`comment_id` )
    REFERENCES `tan`.`comments` (`comment_id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_general_ci;

ALTER TABLE `tan`.`poll_vote` DROP FOREIGN KEY `fk_poll_vote_1` ;
ALTER TABLE `tan`.`poll_vote` 
  ADD CONSTRAINT `fk_poll_vote_1`
  FOREIGN KEY (`answer_id` )
  REFERENCES `tan`.`poll_answer` (`answer_id` )
  ON DELETE CASCADE
  ON UPDATE NO ACTION;

ALTER TABLE `tan`.`admin_log` ADD COLUMN `other` TEXT NULL DEFAULT NULL  AFTER `created` , CHANGE COLUMN `action` `action` ENUM('edit_comment', 'edit_object', 'delete_object', 'delete_comment', 'delete_user', 'delete_avatar', 'mass_delete_objects', 'mass_delete_comments') NOT NULL  , CHANGE COLUMN `reason` `reason` VARCHAR(512) NOT NULL  , CHANGE COLUMN `bulk` `bulk` LONGTEXT NULL DEFAULT NULL  ;
