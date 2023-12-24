DROP DATABASE IF EXISTS `gameProject`;
CREATE DATABASE `gameProject`;

USE `gameProject`; 

CREATE TABLE `users` (
`id` INT PRIMARY KEY AUTO_INCREMENT,
`userName` VARCHAR(200) UNIQUE NOT NULL,
`password` VARCHAR(200) NOT NULL,
`dateOfRegistration` DATETIME NOT NULL,
CONSTRAINT CHECK (char_length(`password`) >= 8)
);

CREATE TABLE `heroes` (
`id` INT PRIMARY KEY AUTO_INCREMENT,
`user_id` INT NOT NULL,
`type` ENUM('Fighter','Magician') NOT NULL,
`blood` INT DEFAULT 100,
`attack` INT NOT NULL,
`defence` INT NOT NULL,
`killedMonsters` INT DEFAULT 0,
`isAlive` BOOLEAN NOT NULL DEFAULT 1,
`points` INT NOT NULL DEFAULT 0,
CONSTRAINT FOREIGN KEY`user_key` (`user_id`) REFERENCES `users`(`id`)
ON DELETE RESTRICT ON UPDATE CASCADE,
CONSTRAINT CHECK (`attack` <= 10),
CONSTRAINT CHECK (`defence` <= 10)
);

CREATE TABLE `missions` (
`id` INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(255) NOT NULL UNIQUE,
`description` TEXT(500) DEFAULT NULL,
`awardPoints` INT NOT NULL,
`countOfZombies` TINYINT NOT NULL DEFAULT 0,
`countOfTrolls` TINYINT NOT NULL DEFAULT 0,
`countOfGnomes` TINYINT NOT NULL DEFAULT 0
);

CREATE TABLE `hero_mission` (
`id` INT PRIMARY KEY AUTO_INCREMENT,
`hero_id` INT NOT NULL,
`mission_id` INT NOT NULL,
`result` ENUM('Success','Fail','Ongoing') NOT NULL DEFAULT 'Ongoing',
CONSTRAINT FOREIGN KEY`hero_key` (`hero_id`) REFERENCES `heroes`(`id`)
ON DELETE RESTRICT ON UPDATE CASCADE,
CONSTRAINT FOREIGN KEY`mission_key` (`mission_id`) REFERENCES `missions`(`id`)
ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE `monsters` (
`id` INT PRIMARY KEY AUTO_INCREMENT,
`mission_id` INT NOT NULL,
`type` ENUM('Zombie','Troll','Gnom') NOT NULL,
`blood` INT NOT NULL DEFAULT 100,
`attack` INT NOT NULL,
`magicslPoints` INT NOT NULL,
CONSTRAINT FOREIGN KEY`mission_monster_key` (`mission_id`) REFERENCES `missions`(`id`)
ON DELETE CASCADE ON UPDATE CASCADE,
CONSTRAINT CHECK (`blood` <= 100),
CONSTRAINT CHECK (`attack` <= 10)
);

INSERT INTO `users` (`userName`, `password`, `dateOfRegistration`)
VALUES ('mHadzhimurad','melih501221065', now()),
('gIvanov','ivanov0405', now()),
('aGeorgiev','georgiev69', now()),
('pNikolov','nikolov009', now()),
('iBayramali','ilyas5012', now()),
('jDurmaz','ji12335689', now());

INSERT INTO `missions` (`name`, `description`, `awardPoints`)
VALUES ('Zombie Swamp', 'Zombies hell', 4),
('Troll Field', NULL, 6),
('Erebor - The Gnome Shell','The Lonely Mountain, known in Sindarin as Erebor, 
referred to both a mountain in northern Rhovanion and the subterranean Dwarven city contained within it.', 10),
('Zombieland','Zombieland uses the undead as a metaphor for growing up, the war is inevitable.' , 9),
('Isengard', 'Beneath the mountains arm within the Wizards Vale through years uncounted had stood that ancient
 place that Men called Isengard.', 15),
('Mordor', 'The Shadowland, where the Dark Lord Sauron rules.', 30);
--
/* 8 */
DROP TRIGGER IF EXISTS `gameProject`.`create_newHero`;
delimiter |
CREATE TRIGGER`create_newHero` BEFORE INSERT ON `heroes`
FOR EACH ROW
BEGIN
IF(NEW.`type`='Fighter')
THEN
	SET NEW.`attack`=4; 
    SET NEW.`defence`=10;
ELSE
	SET NEW.`attack`=10; 
	SET NEW.`defence`=2;
END IF;
END;
|
delimiter ;

delimiter |
CREATE PROCEDURE createHero(IN paramUserId INT, IN paramFighterCount INT, IN paramMagicianCount INT)
BEGIN

	DECLARE iterator INT;
	SET iterator = 0;

	IF (paramFighterCount > 0)
		THEN
            WHILE (iterator < paramFighterCount)
            DO
				INSERT INTO `heroes` (`user_id`, `type`)
                VALUES (paramUserId, 'Fighter');
                SET iterator = iterator + 1;
			END WHILE;
	END IF;
    SET iterator = 0;
    IF (paramMagicianCount > 0)
		THEN
			WHILE (iterator < paramMagicianCount)
            DO
				INSERT INTO `heroes` (`user_id`, `type`)
                VALUES (paramUserId, 'Magician');
                SET iterator = iterator + 1;
			END WHILE;
	END IF;
	
    SELECT 'Success';
    
END;
|
delimiter ;

DROP PROCEDURE IF EXISTS `generateMonsterForMission`;
delimiter |
CREATE PROCEDURE generateMonsterForMission(IN paramMissionID INT)
BEGIN

	SET @countOfZombies = (select `countOfZombies`
							FROM `missions`
							WHERE `id` = paramMissionID);

	SET @countOfTrolls = (select `countOfTrolls`
							FROM `missions`
							WHERE `id` = paramMissionID);
                       
	SET @countOfGnomes = (select `countOfGnomes`
							FROM `missions`
							WHERE `id` = paramMissionID);

	WHILE (@countOfZombies > 0)
		DO
			INSERT INTO `monsters` (`mission_id`, `type`, `blood`, `attack`, `magicslPoints`)
            VALUES (paramMissionID, 'Zombie', 80, 7, 4);
            SET @countOfZombies = @countOfZombies - 1;
		END WHILE;
            
	WHILE (@countOfTrolls > 0)
		DO
			INSERT INTO `monsters` (`mission_id`, `type`, `blood`, `attack`, `magicslPoints`)
            VALUES (paramMissionID, 'Troll', 100, 9, 7);
            SET @countOfTrolls = @countOfTrolls - 1;
		END WHILE;
            
	WHILE (@countOfGnomes > 0)
		DO
			INSERT INTO `monsters` (`mission_id`, `type`, `blood`, `attack`, `magicslPoints`)
            VALUES (paramMissionID, 'Gnom', 60, 9, 7);
            SET @countOfGnomes = @countOfGnomes - 1;
		END WHILE;
        
	SELECT 'Successfull insertion';
    
END;
delimiter;

UPDATE `gameproject`.`missions` SET `countOfZombies` = '4' WHERE (`id` = '1');
UPDATE `gameproject`.`missions` SET `countOfTrolls` = '6' WHERE (`id` = '2');
UPDATE `gameproject`.`missions` SET `countOfGnomes` = '7' WHERE (`id` = '3');
UPDATE `gameproject`.`missions` SET `countOfZombies` = '10' WHERE (`id` = '4');
UPDATE `gameproject`.`missions` SET `countOfZombies` = '6', `countOfTrolls` = '3', `countOfGnomes` = '8' 
WHERE (`id` = '5');
UPDATE `gameproject`.`missions` SET `countOfZombies` = '4', `countOfTrolls` = '6', `countOfGnomes` = '10' 
WHERE (`id` = '6');

CALL generateMonsterForMission (1);
CALL generateMonsterForMission (2);
CALL generateMonsterForMission (3);
CALL generateMonsterForMission (4);
CALL generateMonsterForMission (5);
CALL generateMonsterForMission (6);

ALTER TABLE `users`
ADD COLUMN `isActive` BOOLEAN NOT NULL DEFAULT 1;
--
CALL createHero(1,3,3);
CALL createHero(2,2,2);
CALL createHero(3,3,2);
CALL createHero(4,2,1);
CALL createHero(5,3,4);

INSERT INTO `hero_mission` (`hero_id`,`mission_id`)
VALUES (1,1),
(2,3),
(5,2),
(7,1),
(8,2),
(7,4),
(10,1),
(11,2),
(12,3),
(14,3),
(16,1),
(17,2),
(22,4),
(23,4),
(25,1),
(25,2),
(25,3);

/* 8 */
DROP TRIGGER IF EXISTS `gameProject`.`after_completing_a_mission`;
delimiter |
CREATE TRIGGER `after_completing_a_mission` AFTER UPDATE ON `hero_mission`
FOR EACH ROW
BEGIN

	IF (NEW.`result` = 'Success')
		THEN
			SET @pointsEarned = (SELECT `awardPoints`
									FROM `missions`
									WHERE `id` = NEW.`mission_id`);

			UPDATE `heroes`
			SET `points` = `points` + @pointsEarned
			WHERE `id` = NEW.`hero_id`;
        
        ELSE
			UPDATE `heroes`
			SET `isAlive` = 0
			WHERE `id` = NEW.`hero_id`;
            
		END IF;
END;
|
delimiter ;

/* 9 */
DROP PROCEDURE IF EXISTS `logIn`;
delimiter |
CREATE PROCEDURE logIn(IN paramUsername VARCHAR(255), IN paramPassword VARCHAR(255))
BEGIN
	
    DECLARE `tempId` INT;
    DECLARE `tempName` VARCHAR(255);
    DECLARE `tempPassword` VARCHAR(255);
    
    DECLARE `authenticationCursor` CURSOR FOR SELECT `id`, `userName`, `password` FROM `users`;
    DECLARE EXIT HANDLER FOR NOT FOUND SELECT 'User not found! Please, check for registration or enter correct datas!';
    
    OPEN `authenticationCursor`;
    
    check_loop: LOOP
		FETCH `authenticationCursor` INTO `tempId`, `tempName`, `tempPassword`;
        
        IF (paramUsername = `tempName` AND paramPassword = `tempPassword`)
			THEN
				SELECT `type`, `blood`, `attack`, `defence`, `killedMonsters`, `isAlive`, `points`
                FROM `heroes` WHERE `heroes`.`user_id` = `tempId`;
                LEAVE check_loop;
		END IF;
        END LOOP;
        CLOSE `authenticationCursor`;
END;
|
delimiter ;

/* 2 */
SELECT `name` AS `Name`, `description` AS `Description`
FROM `missions`
WHERE `missions`.`description` IS NOT NULL;

/* 3 */
SELECT `user_id` AS `User`, sum(`points`) AS Points
FROM `heroes`
GROUP BY `user_id`
ORDER BY Points DESC;

/* 4 */
SELECT `users`.`userName`, `heroes`.`type`, `heroes`.`blood`, `heroes`.`killedMonsters`, `heroes`.`isAlive`, `heroes`.`points`
FROM `users` INNER JOIN `heroes`
ON `users`.`id` = `heroes`.`user_id`
WHERE `heroes`.`points` <> 0
ORDER BY `users`.`userName` ASC;

/* 5 */
SELECT `heroes`.`id`, `heroes`.`user_id`, `heroes`.`type`, `heroes`.`blood`, `heroes`.`killedMonsters`, `heroes`.`isAlive`, `heroes`.`points`,
`missions`.`name`, `missions`.`description`
FROM `heroes` LEFT OUTER JOIN `hero_mission`
ON `heroes`.`id` = `hero_mission`.`hero_id`
LEFT OUTER JOIN `missions`
ON `hero_mission`.`mission_id` = `missions`.`id`;

/* 6 */
SELECT * 
FROM `heroes`
WHERE `heroes`.`id` IN (SELECT `hero_id` 
						FROM `hero_mission`
                        WHERE `result` = 'Fail');
 
/* 7 */
SELECT `users`.`id`, `users`.`userName`, count(`heroes`.`id`) AS `HeroCount`
FROM `users` JOIN `heroes`
ON `users`.`id` = `heroes`.`user_id`
GROUP BY `user_id`; 

/* 8 */
DROP TRIGGER IF EXISTS `gameProject`.`before_insert_in_hero_mission`;
delimiter |
CREATE TRIGGER `before_insert_in_hero_mission` BEFORE INSERT ON `hero_mission`
FOR EACH ROW
BEGIN
        
    SET @heroState = (SELECT `isAlive`
						FROM `heroes`
                        WHERE `id` = NEW.`hero_id`);
        
	IF (@heroState = 0)
		THEN
			SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Character is dead, please select another living character';
	END IF;
END;
|
delimiter ;

UPDATE `gameproject`.`hero_mission` SET `result` = 'Success' WHERE (`id` = '1');
UPDATE `gameproject`.`hero_mission` SET `result` = 'Fail' WHERE (`id` = '2');
UPDATE `gameproject`.`hero_mission` SET `result` = 'Success' WHERE (`id` = '3');
UPDATE `gameproject`.`hero_mission` SET `result` = 'Success' WHERE (`id` = '4');
UPDATE `gameproject`.`hero_mission` SET `result` = 'Success' WHERE (`id` = '5');
UPDATE `gameproject`.`hero_mission` SET `result` = 'Fail' WHERE (`id` = '6');
UPDATE `gameproject`.`hero_mission` SET `result` = 'Success' WHERE (`id` = '7');
UPDATE `gameproject`.`hero_mission` SET `result` = 'Success' WHERE (`id` = '8');
UPDATE `gameproject`.`hero_mission` SET `result` = 'Success' WHERE (`id` = '9');
UPDATE `gameproject`.`hero_mission` SET `result` = 'Success' WHERE (`id` = '10');
UPDATE `gameproject`.`hero_mission` SET `result` = 'Success' WHERE (`id` = '11');
UPDATE `gameproject`.`hero_mission` SET `result` = 'Fail' WHERE (`id` = '12');
UPDATE `gameproject`.`hero_mission` SET `result` = 'Success' WHERE (`id` = '13');
UPDATE `gameproject`.`hero_mission` SET `result` = 'Success' WHERE (`id` = '14');
UPDATE `gameproject`.`hero_mission` SET `result` = 'Success' WHERE (`id` = '15');
UPDATE `gameproject`.`hero_mission` SET `result` = 'Success' WHERE (`id` = '16');
UPDATE `gameproject`.`hero_mission` SET `result` = 'Fail' WHERE (`id` = '17');

INSERT INTO`hero_mission` (`hero_id`, `mission_id`)
VALUES (2,3);

CALL logIn('mHadzhimurad','melih5021065');