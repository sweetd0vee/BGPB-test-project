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