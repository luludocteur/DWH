-- MySQL dump 10.13  Distrib 5.7.24, for osx10.9 (x86_64)
--
-- Host: localhost    Database: BINANCE
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
-- Table structure for table `COINS_DEPOSIT_WITHDRAW`
--

DROP TABLE IF EXISTS `COINS_DEPOSIT_WITHDRAW`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `COINS_DEPOSIT_WITHDRAW` (
  `ID` char(32) NOT NULL,
  `TX_ID` char(88) NOT NULL,
  `TIMESTAMP` timestamp NOT NULL,
  `TYPE` varchar(40) NOT NULL,
  `IS_DEPOSIT` tinyint(1) NOT NULL,
  `NETWORK` char(8) NOT NULL,
  `COIN` char(6) NOT NULL,
  `AMOUNT` decimal(7,3) NOT NULL,
  `TRANSACTION_FEE` decimal(8,7) DEFAULT NULL,
  `ADDRESS` varchar(55) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `FIAT_DEPOSIT_WITHDRAW`
--

DROP TABLE IF EXISTS `FIAT_DEPOSIT_WITHDRAW`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `FIAT_DEPOSIT_WITHDRAW` (
  `ORDER_ID` char(26) NOT NULL,
  `TIMESTAMP` timestamp NOT NULL,
  `TYPE` varchar(40) NOT NULL,
  `IS_SUCCESS` tinyint(1) NOT NULL,
  `FIAT` char(6) NOT NULL,
  `AMOUNT` decimal(6,2) NOT NULL,
  `IS_DEPOSIT` tinyint(1) NOT NULL,
  `TRANSACTION_FEE` decimal(2,1) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `TOKEN`
--

DROP TABLE IF EXISTS `TOKEN`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `TOKEN` (
  `TOKEN` char(6) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `TRANSACTIONS`
--

DROP TABLE IF EXISTS `TRANSACTIONS`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `TRANSACTIONS` (
  `ORDER_ID` varchar(40) NOT NULL,
  `TIMESTAMP` timestamp NOT NULL,
  `TYPE` varchar(40) NOT NULL,
  `FROM_ASSET` char(6) NOT NULL,
  `FROM_QUANTITY` decimal(7,3) NOT NULL,
  `FROM_PRICE` decimal(10,3) NOT NULL,
  `TO_ASSET` char(6) NOT NULL,
  `TO_QUANTITY` decimal(7,3) NOT NULL,
  `TO_PRICE` decimal(10,3) NOT NULL,
  `TRANSACTION_FEE` decimal(10,9) DEFAULT NULL,
  `FEE_ASSET` char(6) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping events for database 'BINANCE'
--

--
-- Dumping routines for database 'BINANCE'
--
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2024-10-15 21:52:22
