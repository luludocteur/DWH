DROP TABLE IF EXISTS BINANCE.COINS_DEPOSIT_WITHDRAW;

CREATE TABLE IF NOT EXISTS BINANCE.COINS_DEPOSIT_WITHDRAW(
    ID CHAR(32) NOT NULL,
    TX_ID CHAR(88) NOT NULL,
    TIMESTAMP TIMESTAMP NOT NULL,
    IS_DEPOSIT BOOLEAN NOT NULL,
    NETWORK CHAR(8) NOT NULL,
    COIN CHAR(6) NOT NULL,
    AMOUNT DECIMAL(7,3) NOT NULL,
    TRANSACTION_FEE DECIMAL(8,7),
    ADDRESS VARCHAR(55) not null
);