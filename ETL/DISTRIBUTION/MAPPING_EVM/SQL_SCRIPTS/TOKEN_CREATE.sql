CREATE TABLE IF NOT EXISTS mapping_evm.TOKEN(
    ID_TOKEN char(40) not null,
    TICKER varchar(60) not null,
    DECIMALS DECIMAL(2, 0) not null,
    LOGO varchar(100),
    constraint PK_TOKEN primary key (ID_TOKEN)
);