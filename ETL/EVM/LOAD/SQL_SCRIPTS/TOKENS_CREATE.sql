DROP TABLE IF EXISTS EVM.TOKENS;

CREATE TABLE IF NOT EXISTS EVM.TOKENS(
    TOKEN_CONTRACT_DECIMALS CHAR(2) NOT NULL,
    TOKEN_NAME VARCHAR(100) NOT NULL,
    TOKEN_TICKER VARCHAR(100) NOT NULL,
    TOKEN_ADDRESS CHAR(42) NOT NULL,
    TOKEN_LABEL VARCHAR(50) NULL,
    TOKEN_LOGO_URL VARCHAR(120) NULL,
    TOKEN_FACTORY_ADDRESS CHAR(42) NULL
);
