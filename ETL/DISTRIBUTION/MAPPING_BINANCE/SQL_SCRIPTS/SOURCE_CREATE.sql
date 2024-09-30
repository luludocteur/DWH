CREATE TABLE IF NOT EXISTS mapping_binance.SOURCE(
    ID_SOURCE char(40) not null,
    SOURCE char(10) not null,
    constraint PK_SOURCE primary key (ID_SOURCE) 
);