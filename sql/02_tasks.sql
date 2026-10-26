-- Часть 2. SQL-задачи (PostgreSQL)

-- 1. Клиенты из Новосибирска, зарегистрированные в 2025 году, по дате регистрации.
--    Диапазон дат вместо extract(year ...), чтобы мог работать индекс по registered_at.
select client_id, full_name, registered_at
from clients
where city = 'Новосибирск'
  and registered_at >= date '2025-01-01'
  and registered_at <  date '2026-01-01'
order by registered_at;

-- 2. Количество открытых счетов в каждой валюте.
--    Открытый счет это счет без даты закрытия (или с датой закрытия в будущем).
select currency, count(*) as open_accounts
from accounts
where closed_at is null or closed_at > current_date
group by currency
order by open_accounts desc, currency;

-- 3. Имя клиента и общая сумма входящих транзакций.
--    Условие на tx_type стоит в ON, поэтому клиенты без входящих попадают в выборку с нулем.
select c.client_id, c.full_name, coalesce(sum(t.amount), 0) as total_in
from clients c
left join accounts a     on a.client_id = c.client_id
left join transactions t on t.account_id = a.account_id and t.tx_type = 'in'
group by c.client_id, c.full_name
order by total_in desc;

-- 4. Клиенты без единого счета (анти-джойн).
select c.client_id, c.full_name
from clients c
where not exists (select 1 from accounts a where a.client_id = c.client_id);

-- 4а. То же через left join.
select c.client_id, c.full_name
from clients c
left join accounts a on a.client_id = c.client_id
where a.account_id is null;

-- 5. Клиенты, у которых больше двух счетов.
select c.client_id, c.full_name, count(*) as accounts_cnt
from clients c
join accounts a on a.client_id = c.client_id
group by c.client_id, c.full_name
having count(*) > 2;

-- 6. Задвоенные транзакции (одинаковые account_id, tx_date, amount).
-- 6а. Группы дублей.
select account_id, tx_date, amount, count(*) as cnt, array_agg(tx_id order by tx_id) as tx_ids
from transactions
group by account_id, tx_date, amount
having count(*) > 1;

-- 6б. Сами лишние строки, первая в группе считается оригиналом.
select tx_id, account_id, tx_date, amount
from (
    select t.*,
           row_number() over (partition by account_id, tx_date, amount order by tx_id) as rn
    from transactions t
) d
where rn > 1;

-- 7. Топ-3 клиентов по сумме исходящих транзакций в каждом месяце.
--    dense_rank оставляет всех, кто делит место; для строго трех строк заменить на row_number.
with monthly as (
    select date_trunc('month', t.tx_date)::date as month,
           a.client_id,
           sum(t.amount) as total_out
    from transactions t
    join accounts a on a.account_id = t.account_id
    where t.tx_type = 'out'
    group by 1, 2
), ranked as (
    select m.*, dense_rank() over (partition by month order by total_out desc) as rnk
    from monthly m
)
select r.month, r.rnk, c.full_name, r.total_out
from ranked r
join clients c on c.client_id = r.client_id
where r.rnk <= 3
order by r.month, r.rnk;
