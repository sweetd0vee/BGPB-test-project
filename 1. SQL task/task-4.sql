select name_client
from clients
where type_client = 'ЮЛ' and LOWER(name_client) like 'ооо%'
-- в 2022 году было открыто более 1 договора