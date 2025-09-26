select
	l.num_loan,
	l.risk_group,
	case 
		when l.code_curr = '840' then 'Доллары США'
		when l.code_curr = '978' then 'Евро'
	end as currency,
	lf.rest_od_eq + lf.rest_pd_eq as rest_eq
from
	LOANS as l
join LOANS_FACT as lf on
	l.id_loan = lf.id_loan
where
	lf.dt = '2023-09-30'
	and (l.code_curr = '840'
		or l.code_curr = '978')
