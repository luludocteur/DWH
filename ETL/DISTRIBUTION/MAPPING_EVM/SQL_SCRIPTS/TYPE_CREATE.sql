create table if not exists mapping_evm.TYPE(
	ID_TYPE char(40) not null,
    LIBELLE varchar(40) not null,
    constraint PK_TYPE primary key (ID_TYPE)
);