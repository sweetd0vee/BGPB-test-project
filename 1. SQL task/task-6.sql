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