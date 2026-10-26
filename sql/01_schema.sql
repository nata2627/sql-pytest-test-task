-- Схема из задания (PostgreSQL) и небольшой набор данных для проверки запросов
drop table if exists transactions;
drop table if exists accounts;
drop table if exists clients;

create table clients (
    client_id     integer primary key,
    full_name     text not null,
    city          text,
    registered_at date not null
);

create table accounts (
    account_id integer primary key,
    client_id  integer not null references clients (client_id),
    currency   char(3) not null,
    opened_at  date not null,
    closed_at  date null
);

create table transactions (
    tx_id      integer primary key,
    account_id integer not null references accounts (account_id),
    tx_date    timestamp not null,
    amount     numeric(14, 2) not null,
    tx_type    text not null check (tx_type in ('in', 'out'))
);

create index on accounts (client_id);
create index on transactions (account_id, tx_date);

insert into clients values
    (1, 'Иванов Иван',      'Новосибирск', '2025-02-10'),
    (2, 'Петрова Анна',     'Новосибирск', '2024-11-05'),
    (3, 'Сидоров Олег',     'Москва',      '2025-03-15'),
    (4, 'Козлова Мария',    'Новосибирск', '2025-07-01'),
    (5, 'Смирнов Павел',    'Казань',      '2025-01-20'),
    (6, 'Орлова Елена',     'Казань',      '2025-05-12'),
    (7, 'Волков Денис',     null,          '2025-06-30');

insert into accounts values
    (101, 1, 'RUB', '2025-02-10', null),
    (102, 1, 'USD', '2025-03-01', null),
    (103, 1, 'EUR', '2025-04-01', '2025-09-01'),
    (104, 2, 'RUB', '2024-11-05', null),
    (105, 3, 'RUB', '2025-03-15', null),
    (106, 3, 'USD', '2025-03-20', '2025-06-01'),
    (107, 3, 'RUB', '2025-05-01', null),
    (108, 4, 'RUB', '2025-07-01', null),
    (109, 6, 'CNY', '2025-05-12', null);

insert into transactions values
    (1,  101, '2025-03-05 10:00', 50000.00, 'in'),
    (2,  101, '2025-03-07 12:30', 12000.00, 'out'),
    (3,  101, '2025-03-07 12:30', 12000.00, 'out'),   -- дубль tx 2
    (4,  102, '2025-04-02 09:15',  1500.00, 'in'),
    (5,  104, '2025-03-10 18:00', 30000.00, 'in'),
    (6,  104, '2025-03-11 11:00', 25000.00, 'out'),
    (7,  105, '2025-03-20 14:00', 80000.00, 'in'),
    (8,  105, '2025-03-25 16:45',  9000.00, 'out'),
    (9,  107, '2025-04-03 10:10', 40000.00, 'out'),
    (10, 108, '2025-04-15 13:00',  7000.00, 'out'),
    (11, 109, '2025-04-20 08:00',  3000.00, 'out'),
    (12, 104, '2025-04-21 19:20',  5000.00, 'out'),
    (13, 101, '2025-04-28 17:00', 40000.00, 'out'),
    (14, 108, '2025-04-29 10:00', 20000.00, 'in'),
    (15, 108, '2025-04-29 10:00', 20000.00, 'in'),    -- дубль tx 14
    (16, 108, '2025-04-29 10:00', 20000.00, 'in');    -- и еще один
