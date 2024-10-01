-- EVM

select * from evm.tokens;
select * from evm.transactions;
select * from evm.gas_metadata;
select * from evm.logs;
select * from evm.params_values;
select * from evm.params_address;
/*
delete from evm.tokens;
delete from evm.transactions;
delete from evm.gas_metadata;
delete from evm.logs;
delete from evm.params_values;
delete from evm.params_address;

drop table evm.tokens;
drop table evm.transactions;
drop table evm.gas_metadata;
drop table evm.logs;
drop table evm.params_values;
drop table evm.params_address;
*/
-- Mapping_EVM

select * from mapping_evm.token;
select * from mapping_evm.type;
select * from mapping_evm.source;
select * from mapping_evm.transactions;
/*
delete from mapping_evm.token;
delete from mapping_evm.type;
delete from mapping_evm.source;
delete from mapping_evm.transactions;

drop table mapping_evm.token;
drop table mapping_evm.type;
drop table mapping_evm.source;
drop table mapping_evm.transactions;
/*