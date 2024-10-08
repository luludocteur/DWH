-- MySQL dump 10.13  Distrib 9.0.0, for macos14 (arm64)
--
-- Host: localhost    Database: MAPPING_BINANCE
-- ------------------------------------------------------
-- Server version	9.0.0

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
-- Table structure for table `R_TRANSACTION`
--

DROP TABLE IF EXISTS `R_TRANSACTION`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `R_TRANSACTION` (
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
-- Table structure for table `SOURCE`
--

DROP TABLE IF EXISTS `SOURCE`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `SOURCE` (
  `ID_SOURCE` char(40) NOT NULL,
  `SOURCE` char(10) NOT NULL,
  PRIMARY KEY (`ID_SOURCE`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `TOKEN`
--

DROP TABLE IF EXISTS `TOKEN`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `TOKEN` (
  `ID_TOKEN` char(40) NOT NULL,
  `TOKEN` char(6) NOT NULL,
  PRIMARY KEY (`ID_TOKEN`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `TRANSACTION`
--

DROP TABLE IF EXISTS `TRANSACTION`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `TRANSACTION` (
  `ID_TRANSACTION` char(40) NOT NULL,
  `TIMESTAMP` timestamp NOT NULL,
  `ID_TYPE` char(40) NOT NULL,
  `ID_SOURCE` char(40) NOT NULL,
  `ID_TOKEN` char(40) DEFAULT NULL,
  `AMOUNT` decimal(12,6) DEFAULT NULL,
  `FEE` decimal(12,10) DEFAULT NULL,
  `TOKEN_FEE` char(40) DEFAULT NULL,
  PRIMARY KEY (`ID_TRANSACTION`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `TYPE`
--

DROP TABLE IF EXISTS `TYPE`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `TYPE` (
  `ID_TYPE` char(40) NOT NULL,
  `TYPE` varchar(40) NOT NULL,
  PRIMARY KEY (`ID_TYPE`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping events for database 'MAPPING_BINANCE'
--

--
-- Dumping routines for database 'MAPPING_BINANCE'
--
/*!50003 DROP PROCEDURE IF EXISTS `INSERT_COIN_DEPOSIT_WITHDRAW` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `INSERT_COIN_DEPOSIT_WITHDRAW`()
begin
    SET SQL_SAFE_UPDATES = 0;
    
    insert into mapping_binance.transaction
    select 
	sha1(concat(tx_id, 'binance')) as ID_TRANSACTION,
    timestamp as TIMESTAMP,
    typ.id_type as ID_TYPE,
    sha1('Binance') as ID_SOURCE,
    tok.ID_TOKEN as ID_TOKEN,
    case
		when is_deposit=1
        then amount
        when is_deposit=0
        then -amount
	end as AMOUNT,
    transaction_fee as FEE,
    tok.ID_TOKEN as TOKEN_FEE
from binance.coins_deposit_withdraw cdw
inner join mapping_binance.token tok
on tok.token = cdw.coin
inner join mapping_binance.type typ
on typ.type = cdw.type;

    SET SQL_SAFE_UPDATES = 1;
end ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `INSERT_FIAT_DEPOSIT_WITHDRAW` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `INSERT_FIAT_DEPOSIT_WITHDRAW`()
begin
    SET SQL_SAFE_UPDATES = 0;
    
    insert into mapping_binance.transaction
    select 
	sha1(order_id) as ID_TRANSACTION,
    timestamp as TIMESTAMP,
    typ.id_type as ID_TYPE,
    sha1('Binance') as ID_SOURCE,
    tok.ID_TOKEN as ID_TOKEN,
    case
		when is_deposit=1
        then amount
        when is_deposit=0
        then -amount
	end as AMOUNT,
    transaction_fee as FEE,
    tok.ID_TOKEN as ID_TOKEN
from binance.fiat_deposit_withdraw fdw
inner join mapping_binance.token tok
on tok.token = fdw.fiat
inner join mapping_binance.type typ
on typ.type = fdw.type;

    SET SQL_SAFE_UPDATES = 1;
end ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `INSERT_R_TRANSACTION` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `INSERT_R_TRANSACTION`()
begin
    SET SQL_SAFE_UPDATES = 0;
    
    delete from mapping_binance.r_transaction;
    
    insert into mapping_binance.r_transaction
    select * from binance.transactions
where order_id in (
select grp.order_id from (
select order_id, fee_asset from binance.transactions
group by order_id, fee_asset) grp
group by grp.order_id
having count(1)>1);

    SET SQL_SAFE_UPDATES = 1;
end ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `INSERT_SOURCE` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `INSERT_SOURCE`()
begin
    SET SQL_SAFE_UPDATES = 0;
    
    delete from mapping_binance.source;
    
    insert into mapping_binance.source
    values (sha1('Binance'), 'Binance');

    SET SQL_SAFE_UPDATES = 1;
end ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `INSERT_TOKEN` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `INSERT_TOKEN`()
begin
    SET SQL_SAFE_UPDATES = 0;
    
    delete from mapping_binance.token;
    
    insert into mapping_binance.token
    select sha1(token) as ID_TOKEN, token as TOKEN from binance.token;

    SET SQL_SAFE_UPDATES = 1;
end ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `INSERT_TRANSACTION` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `INSERT_TRANSACTION`()
begin
    SET SQL_SAFE_UPDATES = 0;
    
    insert into mapping_binance.transaction
	select
	sha1(concat(order_id, '1')) as ID_TRANSACTION,
    timestamp as TIMESTAMP,
    typ.id_type as ID_TYPE,
    sha1('Binance') as ID_SOURCE,
    tok.id_token as ID_TOKEN,
    -from_quantity as AMOUNT,
    null as FEE,
    null as TOKEN_FEE
from (
select order_id, timestamp, type, from_asset, sum(from_quantity) as from_quantity, avg(from_price), to_asset, sum(to_quantity) as to_quantity, avg(to_price) from binance.transactions txs
group by order_id, timestamp, type, from_asset, to_asset
) txs
inner join mapping_binance.token tok
on tok.token=txs.from_asset
inner join mapping_binance.type typ
on typ.type=txs.type

union

select
	sha1(concat(order_id, '2')) as ID_TRANSACTION,
    timestamp as TIMESTAMP,
    typ.id_type as ID_TYPE,
    sha1('Binance') as ID_SOURCE,
    tok.id_token as ID_TOKEN,
    to_quantity as AMOUNT,
    null as FEE,
    null as TOKEN_FEE
from (
select order_id, timestamp, type, from_asset, sum(from_quantity) as from_quantity, avg(from_price), to_asset, sum(to_quantity) as to_quantity, avg(to_price) from binance.transactions txs
group by order_id, timestamp, type, from_asset, to_asset
) txs
inner join mapping_binance.token tok
on tok.token=txs.to_asset
inner join mapping_binance.type typ
on typ.type=txs.type

union

select
	sha1(concat(order_id, 'fee')) as ID_TRANSACTION,
    timestamp as TIMESTAMP,
    typ.id_type as ID_TYPE,
    sha1('Binance') as ID_SOURCE,
    null as ID_TOKEN,
    null as AMOUNT,
    transaction_fee as FEE,
    tok.id_token as TOKEN_FEE
from (
select order_id, timestamp, type, from_asset to_asset,sum(transaction_fee) as transaction_fee, fee_asset from binance.transactions txs
where txs.order_id not in (select order_id from mapping_binance.r_transaction)
and txs.transaction_fee is not null
and txs.fee_asset is not null
group by order_id, timestamp, type, from_asset, to_asset, fee_asset
) txs
inner join mapping_binance.token tok
on tok.token=txs.fee_asset
inner join mapping_binance.type typ
on typ.type=txs.type;

    SET SQL_SAFE_UPDATES = 1;
end ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `INSERT_TYPE` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `INSERT_TYPE`()
begin
    SET SQL_SAFE_UPDATES = 0;
    
    delete from mapping_binance.type;
    
    insert into mapping_binance.type
    select sha1(TYPE), TYPE from binance.transactions
group by TYPE
union
select sha1(TYPE), TYPE from binance.coins_deposit_withdraw
group by TYPE
union
select sha1(TYPE), TYPE from binance.fiat_deposit_withdraw
group by TYPE;

    SET SQL_SAFE_UPDATES = 1;
end ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2024-10-08 23:43:25
