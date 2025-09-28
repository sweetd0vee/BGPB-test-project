create table clients (
    id_client int not null,
    dt_start date not null,
    dt_end date null,
    name_client varchar(255) not null,
    type_client varchar(20) null,
    department varchar(20) null,

    primary key (id_client, dt_start) 
);

create table loans (
    id_loan int not null,
    dt_start date not null,
    dt_end date not null,
    id_client int,
    num_loan varchar(20) not null,
    dt_open_loan date null,
    code_curr varchar(3),
    int_rate decimal(4, 2) not null,
    risk_group varchar(20) null,
    
    primary key (id_loan, dt_start)
);

create table loans_fact (
    id_loan int primary key,
    dt date not null,
   	rest_od decimal(10, 2) null,
   	rest_od_eq decimal(10, 2) null,
   	rest_pd decimal(10, 2) null,
   	rest_pd_eq decimal(10, 2) null
);
 
