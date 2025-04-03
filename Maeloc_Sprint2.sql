-- NIVEL 1

-- ExercExercici 2 | Utilitzant JOIN realitzaràs les següents consultes:
-- Llistat dels països que estan fent compres.
select transactions.company.country,
count(transactions.transaction.id) as pedidos_por_pais
from transactions.company
join transactions.transaction
on transactions.company.id = transactions.transaction.company_id
where transactions.transaction.declined = 0 -- Quitamos de la ecuación las compras anuladas
group by transactions.company.country
having pedidos_por_pais > 0
order by pedidos_por_pais desc; -- Cuenta de ID de transaccion por pais donde dicha cuenta sea mayor que 0

-- Des de quants països es realitzen les compres.
select count(distinct transactions.company.country) as cuenta_de_paises
from transactions.company
join transactions.transaction
on transactions.company.id = transactions.transaction.company_id
where transactions.transaction.declined = 0; -- Quitamos de la ecuación las compras anuladas

-- Identifica la companyia amb la mitjana més gran de vendes.
select transactions.company.company_name,
round(avg(transactions.transaction.amount), 2)as avg_cantidad_vendida
from transactions.company
join transactions.transaction
on transactions.company.id = transactions.transaction.company_id
where transactions.transaction.declined = 0 -- Quitamos de la ecuación las compras anuladas
group by transactions.company.company_name
having avg_cantidad_vendida = (
	select round(avg(transactions.transaction.amount),2) as media_cantidad_por_pedido
	from transactions.transaction
    where transactions.transaction.declined = 0 -- Quitamos de la ecuación las compras anuladas
	group by transactions.transaction.company_id
	order by media_cantidad_por_pedido desc
	limit 1); -- Subquery para que, en caso de que haya empate, aparezcan todas las empresas con dicho número. Se puede hacer sin ella ordenando desc y limit 1

-- Exercici 3 | Utilitzant només subconsultes (sense utilitzar JOIN):
-- Mostra totes les transaccions realitzades per empreses d'Alemanya.
select transactions.transaction.id
from transactions.transaction
where transactions.transaction.company_id IN (
	select transactions.company.id
	from transactions.company
	where transactions.company.country = "Germany");

-- Llista les empreses que han realitzat transaccions per un amount superior a la mitjana de totes les transaccions.
select transactions.company.company_name
from transactions.company
where transactions.company.id IN 
	(
	select media_transaccion_por_company_tabla.company_id
	from
		(
        select transactions.transaction.company_id,
		avg(transactions.transaction.amount) as media_transaccion_por_company
		from transactions.transaction
		where transactions.transaction.declined = 0 -- Quitamos de la ecuación las compras anuladas
		group by transactions.transaction.company_id
		having media_transaccion_por_company > 
			(
			select avg(transactions.transaction.amount) as media_total_transacciones
			from transactions.transaction
			where transactions.transaction.declined = 0 -- Quitamos de la ecuación las compras anuladas
            ) -- media total de transacciones válidas
		)as media_transaccion_por_company_tabla -- id compañía + media de amount (superior a la media)
	); -- extraemos solo el id para filtrar por el
    
-- Eliminaran del sistema les empreses que no tenen transaccions registrades, entrega el llistat d'aquestes empreses.
select transactions.company.company_name
from transactions.company
where not exists 
	(
	select * 
	from transaction 
    where transactions.company.id = transactions.transaction.company_id
    and transactions.transaction.declined = 0
    );

-- NIVEL 2
-- Exercici 1 | Identifica els cinc dies que es va generar la quantitat més gran d'ingressos a l'empresa per vendes. Mostra la data de cada transacció juntament amb el total de les vendes.

select transactions.transaction.*,
ingresos_por_fecha.ingresos_totales_dia
from transactions.transaction
join
	(select date(transactions.transaction.timestamp) as fecha,
	sum(transactions.transaction.amount) as ingresos_totales_dia
	from transactions.transaction
	where transactions.transaction.declined = 0 -- Quitamos de la ecuación las compras anuladas
	group by fecha
	order by ingresos_totales_dia desc
	limit 5) as ingresos_por_fecha -- muestra los 5 dias con mas ingresos por ventas y la cantidad
on date(transactions.transaction.timestamp) = ingresos_por_fecha.fecha
order by ingresos_por_fecha.ingresos_totales_dia desc;

-- Top 5 días y sus ingresos (solo de transacciones válidas)
select date(transactions.transaction.timestamp) as fecha,
sum(transactions.transaction.amount) as ingresos_totales_dia
from transactions.transaction
where transactions.transaction.declined = 0 -- Quitamos de la ecuación las compras anuladas
group by fecha
order by ingresos_totales_dia desc
limit 5;

-- Exercici 2 |Quina és la mitjana de vendes per país? Presenta els resultats ordenats de major a menor mitjà.
select transactions.company.country,
round(avg(transactions.transaction.amount),2) as avg_venta_por_pais
from transactions.company
join transactions.transaction
on transactions.company.id = transactions.transaction.company_id
where transactions.transaction.declined = 0 -- Quitamos de la ecuación las compras anuladas
group by transactions.company.country
order by avg_venta_por_pais desc;

-- Exercici 3 | En la teva empresa, es planteja un nou projecte per a llançar algunes campanyes publicitàries per a fer competència a la companyia "Non Institute". Per a això, et demanen la llista de totes les transaccions realitzades per empreses que estan situades en el mateix país que aquesta companyia.
-- Join + SubQ Ver
select transactions.transaction.*
from transactions.transaction
join transactions.company
on transactions.company.id = transactions.transaction.company_id
where transactions.transaction.declined = 0 and transactions.company.country = 
	(
    select transactions.company.country as pais_referencia
	from transactions.company
	where transactions.company.company_name = "Non Institute"
    ); -- 93 resultados

-- Solo SubQ Ver    
select *
from transactions.transaction as t
where exists
	(
    select *
	from transactions.company as c
	where t.company_id = c.id and t.declined = 0 and c.country = 
		(
        select transactions.company.country as pais_referencia
		from transactions.company
		where transactions.company.company_name = "Non Institute" 
        ) -- UK
	); -- 93 resultados

-- Nivel 3
-- Exercici 1 | Presenta el nom, telèfon, país, data i amount, d'aquelles empreses que van realitzar transaccions amb un valor comprès entre 100 i 200 euros i en alguna d'aquestes dates: 29 d'abril del 2021, 20 de juliol del 2021 i 13 de març del 2022. Ordena els resultats de major a menor quantitat.
select transactions.company.company_name,
transactions.company.phone,
transactions.company.country,
date(transactions.transaction.timestamp) as fecha,
transactions.transaction.amount
from transactions.company
join transactions.transaction
on transactions.company.id = transactions.transaction.company_id
where (amount > 100 and amount < 200) and (date(transactions.transaction.timestamp) IN ("2021-04-29", "2021-07-20", "2022-03-13")) and transactions.transaction.declined = 0
order by amount desc;

-- Exercici 2 | Necessitem optimitzar l'assignació dels recursos i dependrà de la capacitat operativa que es requereixi, per la qual cosa et demanen la informació sobre la quantitat de transaccions que realitzen les empreses, però el departament de recursos humans és exigent i vol un llistat de les empreses on especifiquis si tenen més de 4 transaccions o menys.
select transactions.company.company_name,
cantidad_transacciones_tabla.cantidad_transacciones,
	case when cantidad_transacciones_tabla.cantidad_transacciones < 4 then "Sí"
	else "No"
	END as "menos_de_4_transacciones"
from transactions.company
join
	(select count(*) as cantidad_transacciones,
	transactions.transaction.company_id
	from transactions.transaction
    where transactions.transaction.declined = 0 -- Quitamos de la ecuación las compras anuladas
	group by transactions.transaction.company_id) as cantidad_transacciones_tabla
on transactions.company.id = cantidad_transacciones_tabla.company_id;

-- Wildcard
select * from transactions.company;
select * from transactionstransaction;