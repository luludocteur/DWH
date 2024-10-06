CREATE TABLE IF NOT EXISTS distribution.TOKEN(
    ID_TOKEN char(40) not null,
    TOKEN varchar(60) not null,
    LOGO varchar(100),
    constraint PK_TOKEN primary key (ID_TOKEN)
);