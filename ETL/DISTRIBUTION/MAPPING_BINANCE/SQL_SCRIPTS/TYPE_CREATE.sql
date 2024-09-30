create table if not exists mapping_binance.TYPE(
	ID_TYPE char(40) not null,
    TYPE varchar(40) not null,
    constraint PK_TYPE primary key (ID_TYPE)
);