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
        having count(l.id_loan) > 1 -- Фильтрация по количеству договоров
    ) as filtered_clients;
