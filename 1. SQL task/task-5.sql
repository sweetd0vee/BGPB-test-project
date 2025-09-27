select
	name_client,
	num_loan,
	lf.rest_od_eq + lf.rest_pd_eq as rest_eq_loan,
	rest_eq_client

from
	(
        select
            c.id_client
        from
            clients c
        join
            loans l ON c.id_client = l.id_client
        where
            type_client = 'ЮЛ' -- Фильтрация по типу клиента
            and dt_open_loan between '2023-09-01' and '2023-09-30' -- Фильтрация по дате договора
        group by
            c.id_client
        having count (distinct l.id_loan) > 1 -- Фильтрация по количеству договоров
    ) as filtered_clients; -- все client_id которые нам нужны

where lf.dt = '2023-09-30'
group by c.id_client
order by name_client