select 
	l.num_loan,
	l.risk_group,
	case 
		when l.code_curr = '840' then 'Доллары США'
		when l.code_curr = '978' then 'Евро'
	end as currency,
	coalesce(lf.rest_od_eq, 0) + coalesce(lf.rest_pd_eq, 0) as rest_eq
from
	loans as l
left join loans_fact as lf on
	l.id_loan = lf.id_loan
where
	lf.dt <= '2023-09-30'
	and (l.code_curr = '840' or l.code_curr = '978')
	and coalesce(lf.rest_od_eq, 0) + coalesce(lf.rest_pd_eq, 0) != 0
