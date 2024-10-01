-- BINANCE

select * from binance.coins_deposit_withdraw;
select * from binance.fiat_deposit_withdraw;
select * from binance.token;
select * from binance.transactions;
/*
delete from binance.coins_deposit_withdraw;
delete from binance.fiat_deposit_withdraw;
delete from binance.token;
delete from binance.transactions;

drop table binance.coins_deposit_withdraw;
drop table binance.fiat_deposit_withdraw;
drop table binance.token;
drop table binance.transactions;
*/

-- MAPPING_BINANCE

select * from mapping_binance.type;
select * from mapping_binance.source;
select * from mapping_binance.token;
select * from mapping_binance.transaction;
select * from mapping_binance.r_transaction;
/*
delete from mapping_binance.type;
delete from mapping_binance.source;
delete from mapping_binance.token;
delete from mapping_binance.transaction;
delete from mapping_binance.r_transaction;

drop table mapping_binance.type;
drop table mapping_binance.source;
drop table mapping_binance.token;
drop table mapping_binance.transaction;
drop table mapping_binance.r_transaction;
*/

