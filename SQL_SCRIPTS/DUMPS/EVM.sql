-- MySQL dump 10.13  Distrib 5.7.24, for osx10.9 (x86_64)
--
-- Host: localhost    Database: EVM
-- ------------------------------------------------------
-- Server version	9.0.0

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `GAS_METADATA`
--

DROP TABLE IF EXISTS `GAS_METADATA`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `GAS_METADATA` (
  `GAS_ID` int NOT NULL,
  `CONTRACT_DECIMALS` char(2) NOT NULL,
  `CONTRACT_NAME` char(30) NOT NULL,
  `CONTRAT_TICKER` char(5) NOT NULL,
  `CONTRACT_ADDRESS` char(42) NOT NULL,
  `LOGO_URL` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `LOGS`
--

DROP TABLE IF EXISTS `LOGS`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `LOGS` (
  `TX_OFFSET` int NOT NULL,
  `LOG_OFFSET` int NOT NULL,
  `TX_HASH` char(66) NOT NULL,
  `TOKEN_ADDRESS` char(42) NOT NULL,
  `LOGS_FUNCTION_NAME` varchar(30) DEFAULT NULL,
  `LOGS_FUNCTION_SIGNATURE` varchar(200) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `PARAMS_ADDRESS`
--

DROP TABLE IF EXISTS `PARAMS_ADDRESS`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `PARAMS_ADDRESS` (
  `PARAM_ID` int NOT NULL,
  `TX_OFFSET` int NOT NULL,
  `LOG_OFFSET` int NOT NULL,
  `TX_HASH` char(66) NOT NULL,
  `PARAM_NAME` varchar(30) NOT NULL,
  `PARAM_TYPE` varchar(10) NOT NULL,
  `INDEXED` tinyint(1) NOT NULL,
  `ADDRESS` varchar(150) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `PARAMS_VALUES`
--

DROP TABLE IF EXISTS `PARAMS_VALUES`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `PARAMS_VALUES` (
  `PARAM_ID` int NOT NULL,
  `TX_OFFSET` int NOT NULL,
  `LOG_OFFSET` int NOT NULL,
  `TX_HASH` char(66) NOT NULL,
  `PARAM_NAME` varchar(30) NOT NULL,
  `PARAM_TYPE` varchar(10) NOT NULL,
  `INDEXED` tinyint(1) NOT NULL,
  `VALUE` varchar(90) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `TOKENS`
--

DROP TABLE IF EXISTS `TOKENS`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `TOKENS` (
  `TOKEN_CONTRACT_DECIMALS` char(2) NOT NULL,
  `TOKEN_NAME` varchar(100) NOT NULL,
  `TOKEN_TICKER` varchar(100) NOT NULL,
  `TOKEN_ADDRESS` char(42) NOT NULL,
  `TOKEN_LABEL` varchar(50) DEFAULT NULL,
  `TOKEN_LOGO_URL` varchar(120) DEFAULT NULL,
  `TOKEN_FACTORY_ADDRESS` char(42) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `TRANSACTIONS`
--

DROP TABLE IF EXISTS `TRANSACTIONS`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `TRANSACTIONS` (
  `BLOCKCHAIN` varchar(30) NOT NULL,
  `BLOCK_TIMESTAMP` timestamp NOT NULL,
  `BLOCK_HEIGHT` char(10) NOT NULL,
  `BLOCK_HASH` char(66) NOT NULL,
  `TX_HASH` char(66) NOT NULL,
  `TX_OFFSET` int NOT NULL,
  `SUCCESSFUL` tinyint(1) NOT NULL,
  `MINER_ADDRESS` char(42) NOT NULL,
  `FROM_ADDRESS` char(42) NOT NULL,
  `TO_ADDRESS` char(42) NOT NULL,
  `TX_VALUE` varchar(30) NOT NULL,
  `TX_VALUE_QUOTE` decimal(7,2) DEFAULT NULL,
  `PRETTY_VALUE_QUOTE` char(10) DEFAULT NULL,
  `GAS_ID` int NOT NULL,
  `GAS_OFFERED` int NOT NULL,
  `GAS_SPENT` int NOT NULL,
  `GAS_PRICE` varchar(30) DEFAULT NULL,
  `FEES_PAID` varchar(30) NOT NULL,
  `GAS_QUOTE` decimal(9,4) DEFAULT NULL,
  `PRETTY_GAS_QUOTE` char(10) DEFAULT NULL,
  `GAS_QUOTE_RATE` decimal(7,2) DEFAULT NULL,
  `EXPLORER_URL` varchar(150) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping events for database 'EVM'
--

--
-- Dumping routines for database 'EVM'
--
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2024-10-06 13:01:27
