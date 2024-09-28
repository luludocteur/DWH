CREATE TABLE IF NOT EXISTS mapping_evm.TRANSACTIONS(
    TRANSACTION_ID char(40) not null,
    TX_HASH char(66) not null,
    TIMESTAMP TIMESTAMP not null,
    ID_TYPE char(40) not null,
    ID_SOURCE char(40) not null,
    ID_TOKEN char(40) not null,
    AMOUNT DECIMAL(20, 8) not null,
    FEE DECIMAL(12, 5),
    TOKEN_FEE char(40),
    CONSTRAINT PK_TRANSACTIONS primary key (TRANSACTION_ID)
);