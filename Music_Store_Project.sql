---------------------Set1-------------------
   
--Q1: Who is the senior most employee based on job title?

select *from employee
order by levels desc limit 1; 


--Q2: Which countries have the most invoices?
select count(invoice)as c,billing_country
from invoice
group by billing_country
order by c desc;


--Q3: What are top 3 values of total invoice?
select total from invoice
order by total desc
limit 3;


--Q4: Which city has the best customers? 
select sum(total) as invoice_total,billing_city
from invoice
group by billing_city
order by invoice_total desc;


--Q5: Which is the best customer? customer who spent the more money
select c.customer_id,c.first_name,c.last_name ,sum(i.total) as Total from customer as c
join invoice as i on
c.customer_id = i.customer_id
group by c.customer_id
order by total desc
limit 1;



------------------------Set 2-------------------------

--Q1: Write query to return the email,first name,last name and genre of all rock music listeners.
--return your list ordered alphabatically by email starting with A
select distinct email,first_name,last_name
from customer as c 
join invoice as i on c.customer_id=i.customer_id
join invoice_line as il on i.invoice_id = il.invoice_id
where track_id in(
	select track_id from track
	join genre on track.genre_id = genre.genre_id
	where genre.name like 'Rock'
) order by email;



--Q2: write a query that returns the artist name and total track 
--count of the top 10 rock bands?
select a.artist_id , a.name,count(a.artist_id) as Number_of_Songs
from track as t
join album as al on al.album_id=t.album_id
join artist as a on a.artist_id = a.artist_id
join genre as g on g.genre_id = t.genre_id
where g.name like 'Rock'
group by a.artist_id
order by Number_of_Songs desc
limit 10;


--Q3: return all the tracks name that have a song length longer than the average song
--length return the name and millisecond for each track order by the song length with
--the longest song listed first?
select name, milliseconds
from track
where milliseconds > (
	select avg(milliseconds) as Avg_Track_Length
	from track)
order by milliseconds desc; 



------------------------Set 3-------------------------

--Q1: Find how much amount spent by each customer on artist write a query to return customer name ,
--artist name and total spent..?
with best_selling_artist as (
    select a.artist_id as artist_id, a.name as artist_name,
    sum(il.unit_price * il.quantity) as total_sales
    from invoice_line as il
    join track as t on t.track_id = il.track_id
    join album as ab on ab.album_id = t.album_id
    join artist as a on a.artist_id = ab.artist_id
    group by 1
    order by 3 desc
    limit 1 
)
select c.customer_id, c.first_name, c.last_name,
sum(il.unit_price * il.quantity) as Amount_Spent
from invoice as i
join customer as c on c.customer_id = i.customer_id
join invoice_line as il on il.invoice_id = i.invoice_id
join track as t on t.track_id = il.track_id
join album as ab on ab.album_id = t.album_id
join best_selling_artist as bsa on bsa.artist_id = ab.artist_id
group by c.customer_id, c.first_name, c.last_name
order by Amount_Spent desc;


--Q2: Write a query that returns each country along with the top genre 
--for countries where the maximum number of purchases is shared return all genres..?

with popular_genre as
(
    select 
        count(il.quantity) as Purchases, 
        c.country, 
        g.name as genre_name, 
        g.genre_id,
        row_number() over(partition by c.country order by count(il.quantity) desc) as RowNo
    from invoice_line as il
    join invoice as i on i.invoice_id = il.invoice_id
    join customer as c on c.customer_id = i.customer_id
    join track as t on t.track_id = il.track_id
    join genre as g on g.genre_id = t.genre_id
    group by c.country, g.name, g.genre_id
)
select *
from popular_genre
where RowNo = 1
order by country asc, Purchases desc;


--Q3: write a query that determines the customer that has spent the most on 
--music for each country write a query that returns the country along with the 
--top customer and how much they spent for countries where the top amount spent 
--is shared provide all customer who spend this amount

WITH Customer_with_country AS (
    SELECT 
        c.customer_id, 
        c.first_name, 
        c.last_name, 
        c.country AS billing_country, 
        SUM(i.total) AS total_spending, 
        ROW_NUMBER() OVER(PARTITION BY c.country ORDER BY SUM(i.total) DESC) AS RowNo
    FROM 
        invoice AS i
    JOIN 
        customer AS c ON c.customer_id = i.customer_id
    GROUP BY 
        c.customer_id, c.first_name, c.last_name, c.country
)
SELECT 
    customer_id, 
    first_name, 
    last_name, 
    billing_country, 
    total_spending,
    RowNo
FROM 
    Customer_with_country
WHERE 
    RowNo = 1
ORDER BY 
    billing_country ASC, 
    total_spending DESC;






















