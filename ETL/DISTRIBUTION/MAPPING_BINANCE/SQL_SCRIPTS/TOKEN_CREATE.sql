CREATE TABLE IF NOT EXISTS mapping_binance.TOKEN(
    ID_TOKEN char(40) not null,
    TOKEN char(6) not null,
    constraint PK_TOKEN primary key (ID_TOKEN)
);