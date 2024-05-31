-- MySQL dump 10.13  Distrib 8.0.27, for macos11 (arm64)
--
-- Host: 127.0.0.1    Database: memos
-- ------------------------------------------------------
-- Server version	8.0.37

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `delegate`
--

DROP TABLE IF EXISTS `delegate`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `delegate` (
  `id` int NOT NULL AUTO_INCREMENT,
  `owner_id` varchar(120) NOT NULL,
  `delegate_id` varchar(120) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `owner_id` (`owner_id`),
  KEY `delegate_id` (`delegate_id`),
  CONSTRAINT `delegate_ibfk_1` FOREIGN KEY (`owner_id`) REFERENCES `user` (`username`),
  CONSTRAINT `delegate_ibfk_2` FOREIGN KEY (`delegate_id`) REFERENCES `user` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `delegate`
--

LOCK TABLES `delegate` WRITE;
/*!40000 ALTER TABLE `delegate` DISABLE KEYS */;
/*!40000 ALTER TABLE `delegate` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `memo`
--

DROP TABLE IF EXISTS `memo`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `memo` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` varchar(120) NOT NULL,
  `number` int DEFAULT NULL,
  `version` varchar(2) DEFAULT NULL,
  `confidential` tinyint(1) DEFAULT NULL,
  `pinned` tinyint(1) DEFAULT NULL,
  `template` tinyint(1) DEFAULT NULL,
  `distribution` text,
  `keywords` text,
  `title` text NOT NULL,
  `action_date` datetime NOT NULL,
  `create_date` datetime DEFAULT NULL,
  `submit_date` datetime DEFAULT NULL,
  `active_date` datetime DEFAULT NULL,
  `obsolete_date` datetime DEFAULT NULL,
  `_signers` text,
  `_references` text,
  `memo_state` enum('Draft','Signoff','Active','Obsolete') DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `memo_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`username`)
) ENGINE=InnoDB AUTO_INCREMENT=160 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `memo`
--

LOCK TABLES `memo` WRITE;
/*!40000 ALTER TABLE `memo` DISABLE KEYS */;
/*!40000 ALTER TABLE `memo` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `memo_file`
--

DROP TABLE IF EXISTS `memo_file`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `memo_file` (
  `id` int NOT NULL AUTO_INCREMENT,
  `_filename` varchar(4000) DEFAULT NULL,
  `_uuid` varchar(48) DEFAULT NULL,
  `memo_id` int NOT NULL,
  PRIMARY KEY (`id`),
  KEY `memo_id` (`memo_id`),
  CONSTRAINT `memo_file_ibfk_1` FOREIGN KEY (`memo_id`) REFERENCES `memo` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=73 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `memo_file`
--

LOCK TABLES `memo_file` WRITE;
/*!40000 ALTER TABLE `memo_file` DISABLE KEYS */;
/*!40000 ALTER TABLE `memo_file` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `memo_history`
--

DROP TABLE IF EXISTS `memo_history`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `memo_history` (
  `id` int NOT NULL AUTO_INCREMENT,
  `memo_id` int DEFAULT NULL,
  `memo_ref` varchar(48) DEFAULT NULL,
  `date` datetime NOT NULL,
  `memo_activity` enum('Create','Signoff','Sign','Unsign','Activate','Obsolete','Cancel','Reject','IllegalFile') DEFAULT NULL,
  `ref_user_id` varchar(120) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `memo_id` (`memo_id`),
  KEY `ref_user_id` (`ref_user_id`),
  CONSTRAINT `memo_history_ibfk_1` FOREIGN KEY (`memo_id`) REFERENCES `memo` (`id`),
  CONSTRAINT `memo_history_ibfk_2` FOREIGN KEY (`ref_user_id`) REFERENCES `user` (`username`)
) ENGINE=InnoDB AUTO_INCREMENT=300 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `memo_history`
--

LOCK TABLES `memo_history` WRITE;
/*!40000 ALTER TABLE `memo_history` DISABLE KEYS */;
/*!40000 ALTER TABLE `memo_history` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `memo_reference`
--

DROP TABLE IF EXISTS `memo_reference`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `memo_reference` (
  `id` int NOT NULL AUTO_INCREMENT,
  `source_id` int NOT NULL,
  `ref_user_id` varchar(120) NOT NULL,
  `ref_memo_number` int NOT NULL,
  `ref_memo_version` varchar(2) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `source_id` (`source_id`),
  KEY `ref_user_id` (`ref_user_id`),
  CONSTRAINT `memo_reference_ibfk_1` FOREIGN KEY (`source_id`) REFERENCES `memo` (`id`),
  CONSTRAINT `memo_reference_ibfk_2` FOREIGN KEY (`ref_user_id`) REFERENCES `user` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `memo_reference`
--

LOCK TABLES `memo_reference` WRITE;
/*!40000 ALTER TABLE `memo_reference` DISABLE KEYS */;
/*!40000 ALTER TABLE `memo_reference` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `memo_signature`
--

DROP TABLE IF EXISTS `memo_signature`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `memo_signature` (
  `id` int NOT NULL AUTO_INCREMENT,
  `memo_id` int NOT NULL,
  `signer_id` varchar(120) NOT NULL,
  `delegate_id` varchar(120) DEFAULT NULL,
  `signed` tinyint(1) DEFAULT NULL,
  `date_signed` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `memo_id` (`memo_id`),
  KEY `signer_id` (`signer_id`),
  KEY `delegate_id` (`delegate_id`),
  CONSTRAINT `memo_signature_ibfk_1` FOREIGN KEY (`memo_id`) REFERENCES `memo` (`id`),
  CONSTRAINT `memo_signature_ibfk_2` FOREIGN KEY (`signer_id`) REFERENCES `user` (`username`),
  CONSTRAINT `memo_signature_ibfk_3` FOREIGN KEY (`delegate_id`) REFERENCES `user` (`username`)
) ENGINE=InnoDB AUTO_INCREMENT=129 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `memo_signature`
--

LOCK TABLES `memo_signature` WRITE;
/*!40000 ALTER TABLE `memo_signature` DISABLE KEYS */;
/*!40000 ALTER TABLE `memo_signature` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `memo_subscription`
--

DROP TABLE IF EXISTS `memo_subscription`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `memo_subscription` (
  `id` int NOT NULL AUTO_INCREMENT,
  `subscriber_id` varchar(120) NOT NULL,
  `subscription_id` varchar(120) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `subscriber_id` (`subscriber_id`),
  KEY `subscription_id` (`subscription_id`),
  CONSTRAINT `memo_subscription_ibfk_1` FOREIGN KEY (`subscriber_id`) REFERENCES `user` (`username`),
  CONSTRAINT `memo_subscription_ibfk_2` FOREIGN KEY (`subscription_id`) REFERENCES `user` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `memo_subscription`
--

LOCK TABLES `memo_subscription` WRITE;
/*!40000 ALTER TABLE `memo_subscription` DISABLE KEYS */;
/*!40000 ALTER TABLE `memo_subscription` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user`
--

DROP TABLE IF EXISTS `user`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user` (
  `username` varchar(120) NOT NULL,
  `email` varchar(120) DEFAULT NULL,
  `image_file` varchar(20) NOT NULL,
  `password` varchar(120) NOT NULL,
  `admin` tinyint(1) DEFAULT NULL,
  `readAll` tinyint(1) DEFAULT NULL,
  `pagesize` int NOT NULL,
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user`
--

LOCK TABLES `user` WRITE;
/*!40000 ALTER TABLE `user` DISABLE KEYS */;
/*!40000 ALTER TABLE `user` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2024-05-24 11:57:39
