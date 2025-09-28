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
inner join loans l on l.dt_start < day_of_month::date
inner join clients c on l.id_client = c.id_client 
where
		l.dt_end = '3001-01-01' and c.type_client  = 'ЮЛ'
group by day_of_month
order by day_of_month