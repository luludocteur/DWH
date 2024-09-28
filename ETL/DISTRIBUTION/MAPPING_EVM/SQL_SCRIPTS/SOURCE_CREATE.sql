CREATE TABLE IF NOT EXISTS mapping_evm.SOURCE(
    ID_SOURCE char(40) not null,
    LIBELLE varchar(35) not null,
    constraint PK_SOURCE primary key (ID_SOURCE) 
);