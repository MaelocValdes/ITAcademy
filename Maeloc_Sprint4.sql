-- Creamos la database
create database if not exists business_db default character set utf8mb4;
use business_db;

-- Tabla companies
	-- creamos una tabla "temporal" para los datos raw de companies
create table if not exists companies_raw (
	companies_raw_data text
);

	-- introducimos los datos raw de companies
load data
infile "C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\companies.csv"
into table companies_raw;

select * from companies_raw; -- Check

	-- Creamos la tabla final de companies
create table if not exists companies (
	company_id varchar(15) primary key,
    company_name varchar(255),
    phone varchar(15),
    email varchar(100),
    country varchar(100),
    website varchar(255)
    );

	-- Separamos la raw data en las columnas de la tabla definitiva
insert into companies (company_id, company_name, phone, email, country, website)
select
	substring_index(companies_raw_data, ",", 1) as company_id,
    substring_index(substring_index(companies_raw_data, ",", 2), ",", -1) as company_name,
    substring_index(substring_index(companies_raw_data, ",", 3), ",", -1) as phone,
    substring_index(substring_index(companies_raw_data, ",", 4), ",", -1) as email,
	substring_index(substring_index(companies_raw_data, ",", 5), ",", -1) as country,
    substring_index(substring_index(companies_raw_data, ",", 6), ",", -1) as website
from companies_raw;

	-- Limpiamos data
delete from companies
where company_id = "company_id"; -- Eliminamos cabeceras

select * from companies; -- Check

	-- Eliminamos la tabla temporal
drop table companies_raw;



-- Tabla credit_cards
	-- creamos una tabla "temporal" para los datos raw de credit_card
create table if not exists credit_card_raw (
	cc_raw_data text
);

	-- Introducimos los datos raw de credit_cards
load data
infile "C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\credit_cards.csv"
into table credit_card_raw;

select * from credit_card_raw; -- check

	-- Creamos la tabla credit_cards
create table if not exists credit_cards (
	id varchar(15) primary key,
    user_id varchar(15),
    iban varchar(50),
    pan varchar(100),
    pin varchar(4),
    cvv varchar(4),
    track1 varchar(255),
    track2 varchar(255),
    expiring_date varchar(20)
    );

-- Separamos la raw data en las columnas de la tabla definitiva
insert into credit_cards (id, user_id, iban, pan, pin, cvv, track1, track2, expiring_date)
select
	substring_index(cc_raw_data, ",", 1) as id,
	substring_index(substring_index(cc_raw_data, ",", 2), ",", -1) as user_id,
	substring_index(substring_index(cc_raw_data, ",", 3), ",", -1) as iban,
	substring_index(substring_index(cc_raw_data, ",", 4), ",", -1) as pan,
	substring_index(substring_index(cc_raw_data, ",", 5), ",", -1) as pin,
	substring_index(substring_index(cc_raw_data, ",", 6), ",", -1) as cvv,
	substring_index(substring_index(cc_raw_data, ",", 7), ",", -1) as track1,
	substring_index(substring_index(cc_raw_data, ",", 8), ",", -1) as track2,
	substring_index(substring_index(cc_raw_data, ",", 9), ",", -1) as expiring_date
from credit_card_raw;

	-- Limpiamos la data
delete from credit_cards
where id = "id"; -- Eliminamos cabeceras

alter table credit_cards
modify user_id smallint; -- Cambiamos el tipo de user id para poder ordenar por el

alter table credit_cards
add column expiring_date_format date;
update credit_cards
set expiring_date_format = str_to_date(expiring_date, "%m/%d/%y");
alter table credit_cards
drop column expiring_date;
alter table credit_cards
change expiring_date_format expiring_date date; -- formateamos fechas en una nueva columna y eliminamos la vieja
    
select * from credit_cards; -- Check

	-- Eliminamos la tabla temporal
drop table credit_card_raw;




-- Tabla users

	-- creamos una tabla "temporal" para los datos raw de users
create table if not exists users_raw (
	users_raw_data text
);

	-- Introducimos los datos raw de users
load data
infile "C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\users_usa.csv"
into table users_raw;

load data
infile "C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\users_uk.csv"
into table users_raw;

load data
infile "C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\users_ca.csv"
into table users_raw;

select * from users_raw; -- Check

	-- Creamos la tabla users
create table if not exists users (
	id varchar(50),
	name varchar(100),
	surname varchar(100),
	phone varchar(20),
	email varchar(150),
	birth_date varchar(100),
	country varchar(100),
	city varchar(150),
	postal_code varchar(100),
	address varchar(255)        
    );

	-- Separamos la raw data en las columnas de la tabla definitiva
insert into users (id, name, surname, phone, email, birth_date, country, city, postal_code, address)
select
	substring_index(users_raw_data, ",", 1) as id,
    substring_index(substring_index(users_raw_data, ",", 2), ",", -1) as name,
    substring_index(substring_index(users_raw_data, ",", 3), ",", -1) as surname,
    substring_index(substring_index(users_raw_data, ",", 4), ",", -1) as phone,
    substring_index(substring_index(users_raw_data, ",", 5), ",", -1) as email,
	substring_index(substring_index(users_raw_data, '"', 2), '"', -1) as birth_date,
    substring_index(substring_index(users_raw_data, ",", 8), ",", -1) as country,
    substring_index(substring_index(users_raw_data, ",", 9), ",", -1) as city,
    substring_index(substring_index(users_raw_data, ",", 10), ",", -1) as postal_code,
    substring_index(substring_index(users_raw_data, ",", 11), ",", -1) as address
from users_raw;

	-- Limpiamos la data

delete from users 
where name = "name"; -- Eliminamos cabeceras

alter table users
modify id smallint primary key; -- Seteamos el tipo correcto para el id

alter table users
add column birth_date_format date;
update users
set birth_date_format = str_to_date(birth_date, "%b %d, %Y");
alter table users
drop column birth_date;
alter table users
change birth_date_format birth_date date; -- Formateamos las fechas en una nueva columna y borramos las otras

select * from users; -- Check

	-- Eliminamos la tabla temporal
drop table users_raw;



-- Tabla transactions

	-- Creamos la tabla transactions
  create table if not exists transactions (
	id varchar(255),
	card_id varchar(15),
	business_id varchar(15),
	timestamp varchar(255),
    amount varchar(100),
    declined varchar(15),
    product_ids varchar(255),
	user_id varchar(50),
	lat varchar(100),
	longitude varchar(100) null
    );

	-- Insetamos la data
load data
infile "C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\transactions.csv"
into table transactions
fields terminated by ";"; -- por defecto lee ","

	-- Limpiamos la data
delete from transactions
where id = "id"; -- Eliminamos cabeceras

	-- Formateamos campos
alter table transactions
modify id varchar(255) primary key; -- Seteamos la PK

alter table transactions
modify timestamp timestamp; -- Formateamos fechas

alter table transactions
modify amount decimal(10, 2); -- Formateamos amounts

alter table transactions
modify declined boolean; -- Formateamos declined

alter table transactions
modify user_id smallint; -- Formateamos user_id para que coincida con la tabla users

alter table transactions
modify lat float; -- Formateamos lat

alter table transactions
modify longitude float; -- Formateamos longitude

	-- Agregamos constraints
alter table transactions
add constraint cards_constraint 
foreign key (card_id) references credit_cards(id); -- Unimos con credit_cards

alter table transactions
add constraint companies_constraint 
foreign key (business_id) references companies(company_id); -- Unimos con companies

alter table transactions
add constraint users_constraint 
foreign key (user_id) references users(id); -- Unimos con users

select * from transactions; -- Check

-- ---------------------------------------------------------------------------------------------------------------------

-- NIVEL 1

-- Exercici 1 | Realitza una subconsulta que mostri tots els usuaris amb més de 30 transaccions utilitzant almenys 2 taules.
use business_db;
select users.id,
users.name,
users.surname
from users
where exists(
	select transactions.user_id,
	count(transactions.id) as transacciones_realizadas
	from transactions
	where users.id = transactions.user_id and transactions.declined = 0
	group by transactions.user_id
	having transacciones_realizadas > 30);

-- Exercici 2 | Mostra la mitjana d'amount per IBAN de les targetes de crèdit a la companyia Donec Ltd, utilitza almenys 2 taules.
use business_db;
select credit_cards.iban,
round(avg(transactions.amount), 2) as media_de_amount
from credit_cards
join transactions
on credit_cards.id = transactions.card_id
join companies
on transactions.business_id = companies.company_id
where companies.company_name = "Donec Ltd" and transactions.declined = 0 -- Eliminamos transacciones rechazadas
group by credit_cards.id;


-- NIVEL 2

-- Exercici 1 | Crea una nova taula que reflecteixi l'estat de les targetes de crèdit basat en si les últimes tres transaccions van ser declinades i genera la següent consulta: Quantes targetes estan actives?

-- Creamos la tabla
use business_db;
create table if not exists cards_status (
	card_id varchar(15) primary key,
    tarjeta_estado varchar(15),
    foreign key (card_id) references credit_cards(id)
    );

-- Insertamos los datos (query probada por separado)
use business_db;
insert into cards_status (card_id, tarjeta_estado)
select 
	data_estado_tarjeta.card_id,
	data_estado_tarjeta.tarjeta_estado
	from
		(with recent_transactions as (
			select credit_cards.id,
			transactions.declined,
			row_number() over (partition by credit_cards.id order by transactions.timestamp desc) as recent_transaction_order
			from credit_cards
			join transactions
			on credit_cards.id = transactions.card_id
			),
		three_latest_transactions as (
			select recent_transactions.id,
			recent_transactions.declined
			from recent_transactions
			where recent_transactions.recent_transaction_order < 4
			),
		valid_check as (
			select three_latest_transactions.id,
			count(case when three_latest_transactions.declined = 0 then 1 end) as transacciones_validas,
			count(case when three_latest_transactions.declined = 1 then 1 end) as transacciones_no_validas
			from three_latest_transactions
			group by three_latest_transactions.id
			)
		select valid_check.id as card_id,
		case when valid_check.transacciones_no_validas = 3 then "CANCELADA" else "OPERATIVA" end as tarjeta_estado
		from valid_check
		) as data_estado_tarjeta;
 
select * from cards_status; -- Check

-- respuesta a la pregunta
use business_db;
select cards_status.tarjeta_estado,
count(cards_status.card_id) as cantidad
from cards_status
group by cards_status.tarjeta_estado;


-- NIVEL 3

-- Exercici 1 | Crea una taula amb la qual puguem unir les dades del nou arxiu products.csv amb la base de dades creada, tenint en compte que des de transaction tens product_ids. Genera la següent consulta: Necessitem conèixer el nombre de vegades que s'ha venut cada producte.ç

-- Creamos una tabla de productos raw
use business_db;
create table if not exists products_raw(
products_raw_data text
);

-- Introducimos la data raw
load data
infile "C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\products.csv"
into table products_raw;

-- Creamos la tabla productos
use business_db;
create table if not exists products(
	id varchar(5),
    product_name varchar(255),
    price varchar(20),
    colour varchar(50),
    weight varchar(50),
    warehouse_id varchar(100)
	);

-- introducimos la data raw en la tabla definitva
insert into products (id, product_name, price, colour, weight, warehouse_id)
select
	substring_index(products_raw_data, ",", 1) as id,
    substring_index(substring_index(products_raw_data, ",", 2), ",", -1) as product_name,
    substring_index(substring_index(products_raw_data, ",", 3), ",", -1) as price,
    substring_index(substring_index(products_raw_data, ",", 4), ",", -1) as colour,
    substring_index(substring_index(products_raw_data, ",", 5), ",", -1) as weight,
    substring_index(substring_index(products_raw_data, ",", 6), ",", -1) as warehouse_id
from products_raw;

-- Limpiamos la data
	-- Eliminamos cabeceras
delete from products where id = "id";
	-- Eliminamos moneda en price para poder operar con ella
		-- Creamos una columna nueva
alter table products
add column price_dollars decimal(10, 2);
		-- Filtramos e introducimos en ella el contenido de price
update products
set price_dollars = replace(price, "$", "");
		-- Eliminamos la columna original con símbolos
alter table products
drop column price;
	-- Cambiamos el tipo de data de las columnas
		-- ID (seteamos pk)
alter table products
modify id smallint primary key;
		-- Weight
alter table products
modify weight float;

select * from products; -- Check

-- Eliminamos la tabla temporal
drop table products_raw;       

-- Creamos una tabla separada para mediar con los id de los pedidos por separados en columnas
use business_db;
create table if not exists productos_comprados(
	transaction_id varchar(100) primary key,
    p1 varchar(5),
    p2 varchar(5),
    p3 varchar(5),
    p4 varchar(5)
    );

-- Insertamos la data separada de la columna transactions.product_id
use business_db;
insert into productos_comprados (transaction_id, p1, p2, p3, p4)
	select id,
	substring_index(product_ids, ",", 1) as p1,
	if (
		length(product_ids) - length(replace(product_ids, ",", "")) + 1 >= 2,
		substring_index(substring_index(product_ids, ",", 2), ",", -1),
		null
		) as p2,
	if (
		length(product_ids) - length(replace(product_ids, ",", "")) + 1 >= 3,
		substring_index(substring_index(product_ids, ",", 3), ",", -1),
		null
		) as p3,
	if (
		length(product_ids) - length(replace(product_ids, ",", "")) + 1 >= 4,
		substring_index(substring_index(product_ids, ",", 4), ",", -1),
		null
		) as p4
	from transactions;

select * from productos_comprados; -- Check

-- Creamos una tabla definitiva con los resultados de productos_comprados agrupados en dos columnas
use business_db;
create table if not exists bought_products (
	transactions_id varchar(255),
    product_id smallint
    );
    
-- Insertamos los datos de productos_comprados en la tabla de bought_products
insert into bought_products (transactions_id, product_id)
	select transaction_id, p1 from productos_comprados
	union
	select transaction_id, p2 from productos_comprados
	union
	select transaction_id, p3 from productos_comprados
	union
	select transaction_id, p4 from productos_comprados;

-- Limpiamos los nulls
delete from bought_products
where product_id is null;

select * from bought_products; -- Check

-- Unimos las tablas a traves de sus keys
	-- Union bought_products con transactions
alter table bought_products
add constraint transaction_product_fk foreign key (transactions_id) references transactions(id);

	-- Union con bought_products productos
alter table bought_products
add constraint bought_product_id_fk foreign key (product_id) references products(id);

-- Requested query
use business_db;
select products.id,
products.product_name,
count(bought_products.product_id) as cantidad_comprada
from products
join bought_products
on products.id = bought_products.product_id
join transactions
on bought_products.transactions_id = transactions.id
where transactions.declined = 0
group by products.id
order by cantidad_comprada desc;

-- Wildcard
show variables like 'secure_file_priv'; -- Ver carpetas habilitadas
set sql_safe_updates = 1; -- activar y desactivar safe mode
select * from transactions;
