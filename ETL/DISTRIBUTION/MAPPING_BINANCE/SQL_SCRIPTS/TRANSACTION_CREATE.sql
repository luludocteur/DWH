CREATE TABLE IF NOT EXISTS mapping_binance.TRANSACTION(
    ID_TRANSACTION char(40) not null,
    TIMESTAMP TIMESTAMP not null,
    ID_TYPE char(40) not null,
    ID_SOURCE char(40) not null,
    ID_TOKEN char(40),
    AMOUNT DECIMAL(12, 6),
    FEE DECIMAL(12, 10),
    TOKEN_FEE char(40),
    CONSTRAINT PK_TRANSACTION primary key (ID_TRANSACTION)
);