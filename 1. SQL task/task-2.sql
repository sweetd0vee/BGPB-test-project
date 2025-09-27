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