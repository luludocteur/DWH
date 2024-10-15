-- MySQL dump 10.13  Distrib 5.7.24, for osx10.9 (x86_64)
--
-- Host: localhost    Database: MAPPING_EVM
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
-- Table structure for table `SOURCE`
--

DROP TABLE IF EXISTS `SOURCE`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `SOURCE` (
  `ID_SOURCE` char(40) NOT NULL,
  `LIBELLE` varchar(35) NOT NULL,
  PRIMARY KEY (`ID_SOURCE`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `TOKEN`
--

DROP TABLE IF EXISTS `TOKEN`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `TOKEN` (
  `ID_TOKEN` char(40) NOT NULL,
  `TICKER` varchar(60) NOT NULL,
  `DECIMALS` decimal(2,0) NOT NULL,
  `LOGO` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`ID_TOKEN`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `TRANSACTIONS`
--

DROP TABLE IF EXISTS `TRANSACTIONS`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `TRANSACTIONS` (
  `TRANSACTION_ID` char(40) NOT NULL,
  `TX_HASH` char(66) NOT NULL,
  `TIMESTAMP` timestamp NOT NULL,
  `ID_TYPE` char(40) NOT NULL,
  `ID_SOURCE` char(40) NOT NULL,
  `ID_TOKEN` char(40) NOT NULL,
  `AMOUNT` decimal(20,8) NOT NULL,
  `FEE` decimal(12,5) DEFAULT NULL,
  `TOKEN_FEE` char(40) DEFAULT NULL,
  PRIMARY KEY (`TRANSACTION_ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `TYPE`
--

DROP TABLE IF EXISTS `TYPE`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `TYPE` (
  `ID_TYPE` char(40) NOT NULL,
  `LIBELLE` varchar(40) NOT NULL,
  PRIMARY KEY (`ID_TYPE`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping events for database 'MAPPING_EVM'
--

--
-- Dumping routines for database 'MAPPING_EVM'
--
/*!50003 DROP PROCEDURE IF EXISTS `INSERT_LOG_APPROVAL` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `INSERT_LOG_APPROVAL`()
begin
	
    SET SQL_SAFE_UPDATES = 0;
    
    insert into mapping_evm.transactions
    select
	sha1(concat(concat(log.tx_hash,log.tx_offset),log.log_offset)) as TRANSACTION_ID,
	log.tx_hash as TX_HASH,
    txs.block_timestamp as TIMESTAMP,
    typ.ID_TYPE as ID_TYPE,
    sou.ID_SOURCE as ID_SOURCE,
    mtok.ID_TOKEN as ID_TOKEN,
    val.value/power(10, tok.token_contract_decimals) as AMOUNT,
    null as FEE,
    null as TOKEN_FEE
	from evm.transactions txs
	right join evm.logs log
	on log.tx_hash=txs.tx_hash
	inner join evm.params_values val
	on log.tx_hash=val.tx_hash
	and log.tx_offset=val.tx_offset
	and log.log_offset=val.log_offset
	inner join evm.tokens tok
	on log.token_address=tok.token_address
	inner join mapping_evm.type typ
	on log.logs_function_name=typ.libelle
	inner join mapping_evm.token mtok
	on tok.token_ticker=mtok.ticker
	inner join mapping_evm.source sou
	on txs.blockchain=sou.libelle
	where log.logs_function_name = 'Approval'
	and (log.tx_hash, log.tx_offset, log.log_offset) in (
	select log.tx_hash, log.tx_offset, log.log_offset from evm.logs log
	inner join evm.params_address adr
	on log.tx_hash=adr.tx_hash
	and log.tx_offset=adr.tx_offset
	and log.log_offset=adr.log_offset
	where adr.address = '0x121df711eda64694b36c4d3f0fc38454f6ea3792')
	group by log.tx_hash,log.tx_offset,log.log_offset,txs.block_timestamp,val.value,typ.ID_TYPE,sou.ID_SOURCE,mtok.ID_TOKEN,tok.token_contract_decimals;
    
    SET SQL_SAFE_UPDATES = 1;
end ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `INSERT_LOG_MINT` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `INSERT_LOG_MINT`()
begin
	
    SET SQL_SAFE_UPDATES = 0;
    
    insert into mapping_evm.transactions
    /*Mint(indexed address sender, uint256 amount0, uint256 amount1)*/
select * from
(select
	sha1(concat(concat(log.tx_hash,log.tx_offset),log.log_offset)) as TRANSACTION_ID,
	log.tx_hash as TX_HASH,
    txs.block_timestamp as TIMESTAMP,
    typ.ID_TYPE as ID_TYPE,
    sou.ID_SOURCE as ID_SOURCE,
    mtok.ID_TOKEN as ID_TOKEN,
    max(case when val.param_name = 'amount0' then val.value/power(10, tok.token_contract_decimals) end) as AMOUNT,
    null as FEE,
    null as TOKEN_FEE
from evm.transactions txs
right join evm.logs log
on log.tx_hash=txs.tx_hash
inner join evm.gas_metadata gas
on gas.gas_id=txs.gas_id
inner join evm.params_values val
on log.tx_hash=val.tx_hash
and log.tx_offset=val.tx_offset
and log.log_offset=val.log_offset
inner join evm.params_address adr
on log.tx_hash=adr.tx_hash
and log.tx_offset=adr.tx_offset
and log.log_offset=adr.log_offset
inner join evm.tokens tok
on log.token_address=tok.token_address
inner join mapping_evm.type typ
on log.logs_function_name=typ.libelle
inner join mapping_evm.token mtok
on tok.token_ticker=mtok.ticker
inner join mapping_evm.source sou
on txs.blockchain=sou.libelle
where log.logs_function_signature = 'Mint(indexed address sender, uint256 amount0, uint256 amount1)'
and (log.tx_hash, log.tx_offset, log.log_offset) in (
select log.tx_hash, log.tx_offset, log.log_offset from evm.logs log
inner join evm.params_address adr
on log.tx_hash=adr.tx_hash
and log.tx_offset=adr.tx_offset
and log.log_offset=adr.log_offset
where adr.address = '0x121df711eda64694b36c4d3f0fc38454f6ea3792')
group by log.tx_hash,log.tx_offset,log.log_offset,log.logs_function_signature,txs.block_timestamp,adr.address,typ.ID_TYPE,sou.ID_SOURCE,mtok.ID_TOKEN) base

/*Mint(indexed address from, indexed address onBehalfOf, uint256 value, uint256 index)*/
union
select * from
(select
	sha1(concat(concat(log.tx_hash,log.tx_offset),log.log_offset)) as TRANSACTION_ID,
	log.tx_hash as TX_HASH,
    txs.block_timestamp as TIMESTAMP,
    typ.ID_TYPE as ID_TYPE,
    sou.ID_SOURCE as ID_SOURCE,
    mtok.ID_TOKEN as ID_TOKEN,
    max(case when val.param_name = 'value' then val.value/power(10, tok.token_contract_decimals) end) as AMOUNT,
    null as FEE,
    null as TOKEN_FEE
from evm.transactions txs
right join evm.logs log
on log.tx_hash=txs.tx_hash
inner join evm.params_values val
on log.tx_hash=val.tx_hash
and log.tx_offset=val.tx_offset
and log.log_offset=val.log_offset
inner join evm.tokens tok
on log.token_address=tok.token_address
inner join mapping_evm.type typ
on log.logs_function_name=typ.libelle
inner join mapping_evm.token mtok
on tok.token_ticker=mtok.ticker
inner join mapping_evm.source sou
on txs.blockchain=sou.libelle
where log.logs_function_signature = 'Mint(indexed address from, indexed address onBehalfOf, uint256 value, uint256 index)'
and (log.tx_hash, log.tx_offset, log.log_offset) in (
select log.tx_hash, log.tx_offset, log.log_offset from evm.logs log
inner join evm.params_address adr
on log.tx_hash=adr.tx_hash
and log.tx_offset=adr.tx_offset
and log.log_offset=adr.log_offset
where adr.address = '0x121df711eda64694b36c4d3f0fc38454f6ea3792')
group by log.tx_hash,log.tx_offset,log.log_offset,log.logs_function_signature,txs.block_timestamp,typ.ID_TYPE,sou.ID_SOURCE,mtok.ID_TOKEN) base

/*Mint(indexed address minter, indexed address depositAddress, uint256 depositAmount, uint256 tokenAmount, uint256 price)*/
union
select * from
(select
	sha1(concat(concat(log.tx_hash,log.tx_offset),log.log_offset)) as TRANSACTION_ID,
	log.tx_hash as TX_HASH,
    txs.block_timestamp as TIMESTAMP,
    typ.ID_TYPE as ID_TYPE,
    sou.ID_SOURCE as ID_SOURCE,
    mtok.ID_TOKEN as ID_TOKEN,
    max(case when val.param_name = 'depositAmount' then val.value/power(10, tok.token_contract_decimals) end) as AMOUNT,
    null as FEE,
    null as TOKEN_FEE
from evm.transactions txs
right join evm.logs log
on log.tx_hash=txs.tx_hash
inner join evm.params_values val
on log.tx_hash=val.tx_hash
and log.tx_offset=val.tx_offset
and log.log_offset=val.log_offset
inner join evm.tokens tok
on log.token_address=tok.token_address
inner join mapping_evm.type typ
on log.logs_function_name=typ.libelle
inner join mapping_evm.token mtok
on tok.token_ticker=mtok.ticker
inner join mapping_evm.source sou
on txs.blockchain=sou.libelle
where log.logs_function_signature = 'Mint(indexed address minter, indexed address depositAddress, uint256 depositAmount, uint256 tokenAmount, uint256 price)'
and (log.tx_hash, log.tx_offset, log.log_offset) in (
select log.tx_hash, log.tx_offset, log.log_offset from evm.logs log
inner join evm.params_address adr
on log.tx_hash=adr.tx_hash
and log.tx_offset=adr.tx_offset
and log.log_offset=adr.log_offset
where adr.address = '0x121df711eda64694b36c4d3f0fc38454f6ea3792')
group by log.tx_hash,log.tx_offset,log.log_offset,log.logs_function_signature,txs.block_timestamp,typ.ID_TYPE,sou.ID_SOURCE,mtok.ID_TOKEN) base

/*Mint(indexed address from, indexed address to, uint256 value)*/
union
select * from
(select
	sha1(concat(concat(log.tx_hash,log.tx_offset),log.log_offset)) as TRANSACTION_ID,
	log.tx_hash as TX_HASH,
    txs.block_timestamp as TIMESTAMP,
    typ.ID_TYPE as ID_TYPE,
    sou.ID_SOURCE as ID_SOURCE,
    mtok.ID_TOKEN as ID_TOKEN,
    max(case when val.param_name = 'value' then val.value/power(10, tok.token_contract_decimals) end) as AMOUNT,
    null as FEE,
    null as TOKEN_FEE
from evm.transactions txs
right join evm.logs log
on log.tx_hash=txs.tx_hash
inner join evm.params_values val
on log.tx_hash=val.tx_hash
and log.tx_offset=val.tx_offset
and log.log_offset=val.log_offset
inner join evm.tokens tok
on log.token_address=tok.token_address
inner join mapping_evm.type typ
on log.logs_function_name=typ.libelle
inner join mapping_evm.token mtok
on tok.token_ticker=mtok.ticker
inner join mapping_evm.source sou
on txs.blockchain=sou.libelle
where log.logs_function_signature = 'Mint(indexed address from, indexed address to, uint256 value)'
and (log.tx_hash, log.tx_offset, log.log_offset) in (
select log.tx_hash, log.tx_offset, log.log_offset from evm.logs log
inner join evm.params_address adr
on log.tx_hash=adr.tx_hash
and log.tx_offset=adr.tx_offset
and log.log_offset=adr.log_offset
where adr.address = '0x121df711eda64694b36c4d3f0fc38454f6ea3792')
group by log.tx_hash,log.tx_offset,log.log_offset,log.logs_function_signature,txs.block_timestamp,typ.ID_TYPE,sou.ID_SOURCE,mtok.ID_TOKEN) base;
    
    SET SQL_SAFE_UPDATES = 1;
end ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `INSERT_LOG_TRANSFER` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `INSERT_LOG_TRANSFER`()
begin
	
    SET SQL_SAFE_UPDATES = 0;
    
	insert into mapping_evm.transactions
	select 
	sha1(concat(concat(base.tx_hash,base.tx_offset),base.log_offset)) as TRANSACTION_ID,
    base.tx_hash as TX_HASH,
    base.block_timestamp as TIME,
    base.ID_TYPE,
    base.ID_SOURCE,
    base.ID_TOKEN,
    case when base.address_from = '0x121df711eda64694b36c4d3f0fc38454f6ea3792'
    then -1*(base.value/power(10, base.token_contract_decimals))
    when base.address_to= '0x121df711eda64694b36c4d3f0fc38454f6ea3792'
    then base.value/power(10, base.token_contract_decimals)
    end as AMOUNT,
    null as FEE,
    null as ID_TOKEN_FEE from (
select
	log.tx_hash,
    log.tx_offset,
    log.log_offset,
    txs.block_timestamp,
    sou.ID_SOURCE as ID_SOURCE,
    typ.ID_TYPE as ID_TYPE,
    max(case when adr.param_name = 'from' then adr.address end) as address_from,
    max(case when adr.param_name = 'to' then adr.address end) as address_to,
    val.value,
    mtok.ID_TOKEN as ID_TOKEN,
    tok.token_contract_decimals
	from evm.transactions txs
	right join evm.logs log
	on log.tx_hash=txs.tx_hash
	inner join evm.params_address adr
	on log.tx_hash=adr.tx_hash
	and log.tx_offset=adr.tx_offset
	and log.log_offset=adr.log_offset
	inner join evm.params_values val
	on log.tx_hash=val.tx_hash
	and log.tx_offset=val.tx_offset
	and log.log_offset=val.log_offset
	inner join evm.tokens tok
	on log.token_address=tok.token_address
	inner join mapping_evm.type typ
	on log.logs_function_name=typ.libelle
	inner join mapping_evm.token mtok
	on tok.token_ticker=mtok.ticker
	inner join mapping_evm.source sou
	on txs.blockchain=sou.libelle
	where log.logs_function_name = 'Transfer'
	and (log.tx_hash, log.tx_offset, log.log_offset) in (
	select log.tx_hash, log.tx_offset, log.log_offset from evm.logs log
	inner join evm.params_address adr
	on log.tx_hash=adr.tx_hash
	and log.tx_offset=adr.tx_offset
	and log.log_offset=adr.log_offset
	where adr.address = '0x121df711eda64694b36c4d3f0fc38454f6ea3792')
	group by log.tx_hash,log.tx_offset,log.log_offset,txs.block_timestamp,val.value,typ.ID_TYPE,sou.ID_SOURCE,mtok.ID_TOKEN,tok.token_contract_decimals) base;
    
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
    
    delete from mapping_evm.source;
    
	insert into mapping_evm.source
	select sha1(blockchain), blockchain from evm.transactions
    group by blockchain;
    
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
    
    delete from mapping_evm.token;
    
    insert into mapping_evm.token
    
    select sha1(token_ticker), token_ticker, max(cast(token_contract_decimals as unsigned)), max(token_logo_url) from evm.tokens
group by token_ticker

union

	select sha1(contrat_ticker), contrat_ticker, max(cast(contract_decimals as unsigned)), null from evm.gas_metadata
where contrat_ticker not in (
select gas.contrat_ticker from evm.gas_metadata gas
inner join (select sha1(token_ticker), token_ticker, max(cast(token_contract_decimals as unsigned)), max(token_logo_url) from evm.tokens
group by token_ticker) tok
on gas.contrat_ticker=tok.token_ticker)
group by contrat_ticker;

    SET SQL_SAFE_UPDATES = 1;
end ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `INSERT_TRANSACTIONS` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `INSERT_TRANSACTIONS`()
begin
	
    SET SQL_SAFE_UPDATES = 0;
    
    insert into mapping_evm.transactions
    select
sha1(txs.tx_hash) as TRANSACTION_ID,
txs.tx_hash as TX_HASH,
txs.block_timestamp as TIMESTAMP,
'1a7b7c1b33d161f45804730c70b75175dccd9883' as ID_TYPE,
sou.ID_SOURCE as ID_SOURCE,
tok.ID_TOKEN as ID_TOKEN,
case when txs.from_address='0x121df711eda64694b36c4d3f0fc38454f6ea3792'
then -txs.TX_VALUE/power(10, tok.DECIMALS)
when txs.to_address='0x121df711eda64694b36c4d3f0fc38454f6ea3792'
then txs.TX_VALUE/power(10, tok.DECIMALS)
end as AMOUNT,
case when txs.from_address='0x121df711eda64694b36c4d3f0fc38454f6ea3792'
then txs.fees_paid/power(10, gas.contract_decimals)
when txs.from_address<>'0x121df711eda64694b36c4d3f0fc38454f6ea3792'
then 0
end as FEE,
tok.ID_TOKEN as FEE_TOKEN
from evm.transactions txs
inner join evm.gas_metadata gas
on gas.gas_id=txs.gas_id
inner join mapping_evm.token tok
on gas.contrat_ticker=tok.ticker
inner join mapping_evm.source sou
on txs.blockchain=sou.libelle
where txs.from_address='0x121df711eda64694b36c4d3f0fc38454f6ea3792'
or txs.to_address='0x121df711eda64694b36c4d3f0fc38454f6ea3792';


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
    
    delete from mapping_evm.type;
    
	insert into mapping_evm.type
	select sha1(logs_function_name), logs_function_name from evm.logs
    where logs_function_name is not null
    group by logs_function_name;
    
    insert into mapping_evm.type
    values (sha1('Transaction'), 'Transaction');
    
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

-- Dump completed on 2024-10-15 21:52:23
