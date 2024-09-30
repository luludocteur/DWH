DROP TABLE IF EXISTS BINANCE.FIAT_DEPOSIT_WITHDRAW;

CREATE TABLE IF NOT EXISTS BINANCE.FIAT_DEPOSIT_WITHDRAW(
    ORDER_ID CHAR(26) NOT NULL,
    TIMESTAMP TIMESTAMP NOT NULL,
    IS_SUCCESS BOOLEAN NOT NULL,
    FIAT CHAR(6) NOT NULL,
    AMOUNT DECIMAL(6,2) NOT NULL,
    IS_DEPOSIT BOOLEAN NOT NULL,
    TRANSACTION_FEE DECIMAL(2,1)
);