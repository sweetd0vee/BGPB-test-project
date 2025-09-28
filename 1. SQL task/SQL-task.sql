-------------- Для решения задач используется диалект postgresql -------------------

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
 

INSERT INTO clients values 
(101, '2025-01-01', null, 'client name 1', 'ФЛ', '1'),
(102, '2025-01-01', null, 'client name 2', 'ЮЛ', '2'),
(103, '2025-01-01', null, 'client name 3', 'ЮЛ', '3'),
(104, '2025-01-01', null, 'client name 4', 'ЮЛ', '3'),
(105, '2025-01-01', null, 'client name 5', 'ЮЛ', '3'),
(106, '2025-01-01', null, 'client name 6', 'ЮЛ', '4');


INSERT INTO loans values 
(1, '1980-01-01', '3001-01-01', 101, 'DEAL_A', '2023-01-05', '933', 10.00, '1'),
(2, '1980-01-01', '2023-09-30', 102, 'DEAL_B', '2023-04-11', '840', 5.50, '1'),
(2, '1923-10-01', '3001-01-01', 102, 'DEAL_B', '2023-04-11', '840', 5.50, '2'),
(3, '1980-10-01', '2022-12-31', 102, 'DEAL_C', '2022-09-15', '978', 4.75, '1'),
(3, '1923-01-01', '2023-02-15', 102, 'DEAL_C', '2022-09-15', '978', 4.75, '2'),
(3, '1923-02-16', '3001-01-01', 102, 'DEAL_C', '2022-09-15', '978', 5.00, '3'),
(4, '1923-02-16', '3001-01-01', 102, 'DEAL_D', '2023-09-11', '978', 5.00, '3'),
(5, '1923-02-16', '3001-01-01', 102, 'DEAL_E', '2023-09-12', '978', 5.00, '3');


INSERT INTO loans_fact values
(1, '2023-09-29', 11, 33, 3, 9),
(2, '2023-09-29', 101, 303, 3, 9),
(3, '2023-09-30', 100, 300, 5, 15),
(4, '2023-09-29', 10, 30, 3, 9),
(5, '2023-09-30', 9, 27, 5, 15),
(6, '2023-09-30', 8, 24, 4, 12),
(7, '2023-09-30', 7, 21, 3, 9);

------- task 1 ------------------------------------------------------------------

select
	l.num_loan,
	l.risk_group,
	case 
		when l.code_curr = '840' then 'Доллары США'
		when l.code_curr = '978' then 'Евро'
	end as currency,
	lf.rest_od_eq + lf.rest_pd_eq as rest_eq -- not null
from
	LOANS as l
join LOANS_FACT as lf on
	l.id_loan = lf.id_loan
where
	lf.dt = '2023-09-30'
	and (l.code_curr = '840'
		or l.code_curr = '978')

------- task 2 ------------------------------------------------------------------

select day_of_month, count(*) as cnt_loan
from
		generate_series(
		'2023-09-01'::date, 
		'2023-09-30'::date, 
		'1 day'::interval
		) as day_of_month
left join loans l on l.dt_start < day_of_month::date
left join clients c on l.id_client = c.id_client 
where
		l.dt_end = '3001-01-01' and c.type_client  = 'ФЛ'
group by day_of_month 
order by day_of_month

------- task 3 ------------------------------------------------------------------

select day_of_month, 
	count(*) as cnt_loan, 
	count(case when l.code_curr = '933' then 1 end) as cnt_BYN,
	count(case when l.code_curr = '840' then 1 end) as cnt_USD,
	count(case when l.code_curr = '978' then 1 end) as cnt_EUR
from
		generate_series(
		'2023-09-01'::date, 
		'2023-09-30'::date, 
		'1 day'::interval
		) as day_of_month
left join loans l on l.dt_start < day_of_month::date
left join clients c on l.id_client = c.id_client 
where
		l.dt_end = '3001-01-01' and c.type_client  = 'ЮЛ'
group by day_of_month
order by day_of_month
   
------- task 4 ------------------------------------------------------------------

select
    name_client
from
    (
        select
            name_client,
            count(l.id_loan) as num_loans
        from
            clients c
        join
            loans l ON c.id_client = l.id_client
        where
            type_client = 'ЮЛ' and lower(name_client) like 'ооо%' -- Фильтрация по типу и наименованию клиента
            and dt_open_loan between '2022-01-01' and '2022-12-31' -- Фильтрация по дате договора
        group by
            c.name_client
        having count (distinct l.id_loan) > 1 -- Фильтрация по количеству договоров
    ) as filtered_clients;


------- task 5 ---------------------------------------------------------------------

with 
loans_rest_rs as (
	select	
		c.name_client,
		l2.num_loan, 
		lf.rest_od_eq + lf.rest_pd_eq as rest_eq_deal
	from loans l2
	join loans_fact lf on lf.id_loan = l2.id_loan 
	join clients c  on l2.id_client = c.id_client 
	where
		l2.id_client in (
			-- все client_id которые нам нужны
			select c.id_client
			from clients c
			join loans l on c.id_client = l.id_client
			where
				-- Фильтрация по типу клиента
		 		type_client = 'ЮЛ'
				-- Фильтрация по дате договора
				and dt_open_loan between '2023-09-01' and '2023-09-30'
			group by c.id_client
			having
				-- Фильтрация по количеству договоров
		 		count (distinct l.id_loan) > 1 
	 	) 
		and lf.dt = '2023-09-30' 
		and l2.dt_open_loan between '2023-09-01' and '2023-09-30'
	order by c.name_client
),
client_total as (
	select loans_rest_rs.name_client, sum(loans_rest_rs.rest_eq_deal) as rest_eq_client from loans_rest_rs
	group by loans_rest_rs.name_client
)

select rs.name_client, rs.num_loan, rs.rest_eq_deal, t.rest_eq_client
from loans_rest_rs rs
left join client_total t on rs.name_client = t.name_client
order by rs.name_client

 
------- task 6 -------------------------------------------------------------------

select
		c.id_client,
		round(sum(l.int_rate * lf.rest_od_eq)/sum(lf.rest_od_eq), 2) as avg_rate,
		sum(lf.rest_od_eq)
from clients as c
join loans as l on c.id_client = l.id_client
join loans_fact as lf on lf.id_loan = l.id_loan
where lf.dt = '2022-12-31' and c.type_client = 'ЮЛ'
group by c.id_client
having sum(lf.rest_od_eq) > 0
order by avg_rate
	
------- task 7 --------------------------------------------------------------------

select
	count(id_client) as cnt_clients_without_loans, department 
from
	clients c2
where
	id_client not in (
	select
		c.id_client
	from
		clients c
	inner join loans l on
		l.id_client = c.id_client
	where
		l.dt_end = '3001-01-01'
	group by
		c.id_client )
group by department
order by department

