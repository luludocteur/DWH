CREATE TABLE IF NOT EXISTS distribution.USD_PRICE(
    TIMESTAMP TIMESTAMP not null,
    TOKEN varchar(70) not null,
    USD_PRICE DECIMAL(20,10),
    constraint PK_USD_PRICE primary key (TIMESTAMP, TOKEN) 
);