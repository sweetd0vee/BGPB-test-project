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
