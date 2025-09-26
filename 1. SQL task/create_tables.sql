CREATE TABLE clients (
	client_key SERIAL PRIMARY KEY,
    id_client INT NOT null,
    dt_start DATE NOT NULL,
    dt_end DATE NULL,
    name_client VARCHAR(255) NOT NULL,
    type_client VARCHAR(20) NULL,
    department VARCHAR(20) null
);

CREATE TABLE loans (
	loan_key SERIAL PRIMARY KEY ,
    id_loan INT NOT null,
    dt_start DATE NOT NULL,
    dt_end DATE NOT NULL,
    id_client INT,
    num_loan VARCHAR(20) NOT NULL,
    dt_open_loan DATE NULL,
    code_curr VARCHAR(3),
    int_rate DECIMAL(4, 2) NOT NULL,
    risk_group VARCHAR(20) null
);

CREATE TABLE loans_fact (
    id_loan SERIAL PRIMARY KEY,
    dt DATE NOT NULL,
   	rest_od DECIMAL(10, 2) NULL,
   	rest_od_eq DECIMAL(10, 2) NULL,
   	rest_pd DECIMAL(10, 2) NULL,
   	rest_pd_eq DECIMAL(10, 2) NULL
);
 