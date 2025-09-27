create table clients (
    id_client INT not null,
    dt_start DATE not null,
    dt_end DATE null,
    name_client VARCHAR(255) not null,
    type_client VARCHAR(20) null,
    department VARCHAR(20) null,

    primary key (id_client, dt_start) 
);

create table loans (
    id_loan INT not null,
    dt_start DATE not null,
    dt_end DATE not null,
    id_client INT,
    num_loan VARCHAR(20) not null,
    dt_open_loan DATE null,
    code_curr VARCHAR(3),
    int_rate decimal(4, 2) not null,
    risk_group VARCHAR(20) null,
    
    primary key (id_loan, dt_start)
);

create table loans_fact (
    id_loan INT primary key,
    dt DATE not null,
   	rest_od decimal(10, 2) null,
   	rest_od_eq decimal(10, 2) null,
   	rest_pd decimal(10, 2) null,
   	rest_pd_eq decimal(10, 2) null
);
 
