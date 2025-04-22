-- NIVEL 1

-- EXERCICI 1 | La teva tasca és dissenyar i crear una taula anomenada "credit_card" que emmagatzemi detalls crucials sobre les targetes de crèdit. La nova taula ha de ser capaç d'identificar de manera única cada targeta i establir una relació adequada amb les altres dues taules ("transaction" i "company"). Després de crear la taula serà necessari que ingressis la informació del document denominat "dades_introduir_credit". Recorda mostrar el diagrama i realitzar una breu descripció d'aquest.
	-- Creamos el database si no existe y operamos sobre ella
create database if not exists transactions;
use transactions;
	-- Creamos la tabla "credit_card"
create table if not exists credit_card (
	id varchar(20) primary key,
    iban varchar(50),
    pan varchar(100),
    pin varchar(4),
    cvv int,
    expiring_date varchar(20) -- No se puede usar date ya que el formato de los datos es incorrecto. Habría que formatear las fechas
);

	-- Añadimos la relación de transaction con credit_card
alter table transactions.transaction
add constraint fk_credit_card foreign key (credit_card_id) references credit_card(id);
	-- Datos insertados desde el archivo pertinente

-- EXERCICI 2 | El departament de Recursos Humans ha identificat un error en el número de compte de l'usuari amb ID CcU-2938. La informació que ha de mostrar-se per a aquest registre és: R323456312213576817699999. Recorda mostrar que el canvi es va realitzar.
	-- Request
update transactions.credit_card 
set iban = "R323456312213576817699999"
where transactions.credit_card.id = "CcU-2938";
	-- Comprobación
select transactions.credit_card.id,
transactions.credit_card.iban
from transactions.credit_card
where transactions.credit_card.id = "CcU-2938";

-- EXERCICI 3 | En la taula "transaction" ingressa un nou usuari amb la següent informació:
	-- Los datos a introducir contienenen referencias de una empresa que no existe, así que hay que crearla primero
insert into transactions.company (id)
values ("b-9999");
	-- Los datos a introducir contienenen referencias de una tarjeta que no existe, así que hay que crearla primero
insert into transactions.credit_card(id)
values('CcU-9999');

	-- Ahora podemos introducir los datos
insert into transactions.transaction (id, credit_card_id, company_id, user_id, lat, longitude, amount, declined) 
values ("108B1D1D-5B23-A76C-55EF-C568E49A99DD", "CcU-9999", "b-9999", "9999", "829.999", "-117.999", "111.11", "0");

	-- Chechk
select *
from transactions.transaction
where transactions.transaction.id = "108B1D1D-5B23-A76C-55EF-C568E49A99DD";

-- EXERCICI 4 | Des de recursos humans et sol·liciten eliminar la columna "pan" de la taula credit_*card. Recorda mostrar el canvi realitzat.
alter table transactions.credit_card
drop column pan;


-- NIVEL 2

-- EXERCICI 1 | Elimina de la taula transaction el registre amb ID 02C6201E-D90A-1859-B4EE-88D2986D3B02 de la base de dades.
	-- Request
delete transactions.transaction
from transactions.transaction
where transactions.transaction.id = "02C6201E-D90A-1859-B4EE-88D2986D3B02";
	-- Comprobación
select *
from transactions.transaction
where transactions.transaction.id = "02C6201E-D90A-1859-B4EE-88D2986D3B02";

-- EXERCICI 2 | La secció de màrqueting desitja tenir accés a informació específica per a realitzar anàlisi i estratègies efectives. S'ha sol·licitat crear una vista que proporcioni detalls clau sobre les companyies i les seves transaccions. Serà necessària que creïs una vista anomenada VistaMarketing que contingui la següent informació: Nom de la companyia. Telèfon de contacte. País de residència. Mitjana de compra realitzat per cada companyia. Presenta la vista creada, ordenant les dades de major a menor mitjana de compra.
	-- Request
select transactions.company.company_name,
transactions.company.phone,
transactions.company.country,
round(avg(transactions.transaction.amount),2) as media_de_compra
from transactions.company
join transactions.transaction
on transactions.company.id = transactions.transaction.company_id
where transactions.transaction.declined = 0 -- Eliminamos los registros rechazados
group by transactions.transaction.company_id -- Agrupamos por ID en caso de compañías con el mismo nombre
order by media_de_compra desc;
	-- Comprobación
select *
from transactions.vistamarketing;

-- EXERCICI 3 | Filtra la vista VistaMarketing per a mostrar només les companyies que tenen el seu país de residència en "Germany"
select *
from transactions.vistamarketing
where transactions.vistamarketing.country = "Germany";


-- NIVEL 3

-- EXERCICI 1 | La setmana vinent tindràs una nova reunió amb els gerents de màrqueting. Un company del teu equip va realitzar modificacions en la base de dades, però no recorda com les va realitzar. Et demana que l'ajudis a deixar els comandos executats per a obtenir el següent diagrama:
	-- Cambios en "user"
		-- Creamos la tabla user
use transactions;
CREATE INDEX idx_user_id ON transaction(user_id);
CREATE TABLE IF NOT EXISTS user (
        id INT PRIMARY KEY,
        name VARCHAR(100),
        surname VARCHAR(100),
        phone VARCHAR(150),
        email VARCHAR(150),
        birth_date VARCHAR(100),
        country VARCHAR(150),
        city VARCHAR(150),
        postal_code VARCHAR(100),
        address VARCHAR(255)        
    );
		-- Añadimos los datos a la tabla user desde su script "datos_introducir_user"
		-- Introducimos también el usuario extra del "Nivel 1 | Ejercicio 3" para evitar errores al crear constraints en "transaction"
insert into transactions.user(id)
values('9999');
		-- Renombramos la columna "email" a "personal_email"
alter table transactions.user
rename column email to personal_email;

	-- Cambios en "company"
		-- Eliminamos la columna company.website
alter table transactions.company
drop column website;

	-- Cambios en "credit_card"
		-- Creamos la columna "fecha_actual"
alter table transactions.credit_card
add column fecha_actual date;

	-- Cambios en "transaction"
		-- Añadimos la relación de transaction con user
alter table transactions.transaction
add constraint fk_user foreign key (user_id) references user(id);

	-- EXTRA: Renombramos la tabla user para dejarla como en el diagrama 
rename table transactions.user to data_user; -- NO activar en este doc. Hará fallar las query previas. Si se activa volver a renombrar usnado: rename table transactions.data_user to user;

-- EXERCICI 2 | L'empresa també et sol·licita crear una vista anomenada "InformeTecnico" que contingui la següent informació:
	-- Request
with media_gasto_usuario_tabla as
	(
        select round(avg(transactions.transaction.amount),2) as media_gasto_usuario,
    transactions.transaction.user_id
    from transactions.transaction
    where transactions.transaction.declined = 0
    group by transactions.transaction.user_id
    )
select transactions.transaction.id as id_transacción,
date(transactions.transaction.timestamp) as fecha_transacción,
transactions.company.company_name as compañía,
transactions.user.id as user_id,
transactions.user.name as nombre_usuario,
transactions.user.surname as apellido_usuario,
transactions.credit_card.iban,
transactions.transaction.amount as ingresos_de_la_transacción,
media_gasto_usuario_tabla.media_gasto_usuario,
case 
	when transactions.transaction.declined = 0 then "NO"
	when transactions.transaction.declined = 1 then "SÍ"
end as transacción_rechazada
from transactions.transaction
join transactions.user
on transactions.transaction.user_id = transactions.user.id
join transactions.credit_card
on transactions.transaction.credit_card_id = transactions.credit_card.id
join transactions.company
on transactions.transaction.company_id = transactions.company.id
join
media_gasto_usuario_tabla
on transactions.transaction.user_id = media_gasto_usuario_tabla.user_id;
	-- Comprobación
select *
from transactions.informetecnico
order by id_transacción desc;

-- wildcard BORRAR!!!!!!!!!
describe transactions.credit_card;
select * from transactions.credit_card;
select * from transactions.user;
select * from transactions.transaction;
select * from transactions.company;
    

