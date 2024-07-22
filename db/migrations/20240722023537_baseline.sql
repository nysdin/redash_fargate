-- Add new schema named "nikki"
CREATE DATABASE `nikki` COLLATE utf8mb4_unicode_ci;
-- Create "users" table
CREATE TABLE `nikki`.`users` (`id` bigint NOT NULL AUTO_INCREMENT, `name` varchar(255) NOT NULL, `age` int NOT NULL, `sex` varchar(255) NOT NULL, PRIMARY KEY (`id`)) CHARSET utf8mb4 COLLATE utf8mb4_unicode_ci;
