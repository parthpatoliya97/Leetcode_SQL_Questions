--1.combine tables
SELECT p.first_name,p.last_name,a.city,a.state
from Person p
left join Address a 
on p.person_id=a.person_id


--2.employees earning more than their managers
SELECT e.name as Employee
from Employee e 
left join Employee m 
on e.manager_id=m.id
where e.salary>m.salary


--3.duplicate emails
SELECT email
from Person
group by email
having count(*)>1;


--4.customers who never order
SELECT c.name as customer
from Customers c 
left join Orders o   
on c.id=o.customer_id
where o.id IS NULL;

SELECT c.name as customers
from Custoemrs c  
where c.id NOT IN( 
    select c.id from Custoemrs c join Orders o on c.id=o.customer_id
)


--5.employee bonus
SELECT e.name,b.bonus
from employee e
left join bonus b 
on e.emp_id=b.emp_id
where b.bonus<1000 or b.bonus is NULL;


--6.find customer referee
select name
from customer
where referee_id!+2 or referee_id IS NULL;


--7.customer placing the largest number od Orders
with cte as(SELECT customer_number,count(order_number) as orders_count
from orders 
group by customer_number
order by orders_count )
SELECT customer_number
from cte
where orders_count=(SELECT max(orders_count) from cte)


--8.big countries
SELECT name,population,area
from world
where area>=3000000 or population>=25000000


--9.
SELECT class
group by class 
having count(student)>=5


--10.triangle judgement
select *,CASE 
    WHEN x+y>z and y+z>x and x+z>y THEN "Yes"
    ELSE "No" 
END as Triangle
from data;


--11.shortest distance in a line
SELECT MIN(ABS(p1.x-p2.x)) as shortest
from point p1 
cross join point p2 
where p1.x!=p2.x

-- good for larger size datasets
SELECT MIN(ABS(p1.x-p2.x)) as shortest
from point p1 
cross join point p2 
where p1.x<p2.x


--12.biggest single number
with cte as(SELECT num
from mynumbers
group by num 
having count(num)=1)
SELECT CASE 
    WHEN count(*)>0 THEN  max(num)
    ELSE NULL
END AS num
from cte


--13.
SELECT *
FROM cinema
WHERE id%2!=0 and description!="boring"
order by rating desc;


--14.swap salary
UPDATE salary  
SET sex = 
case when sex='f' THEN 'm'
when sex='m' THEN 'f'
END


--15.actors and directors who cooperated at least threee times
SELECT actor_id,director_id
from actor_director
GROUP BY actor_id,director_id
HAVING count(*)>=3;


--16.reported posts
SELECT extra as report_reason,count(distinct post_id) as report_count
from actions  
where action_date='2019-07-04' AND action='report' AND extra IS NOT NULL
group by extra


--17.queries quality and percentage 
with cte as(SELECT query_name, rating/position as ratio,case when raing<3 then 1 else 0 end as quality_binary
from queries)
SELECT 
query_name,
round(avg(ratio),2) as quality
round(quality,(sum(quality_binary)/count(*))*100,2) as poor_query_index
from cte
GROUP BY query_name


--18.number of comments per post
with posts as(SELECT distinct sub_id
from submissions  
where parent_id IS NULL),
com as(SELECT parent_id,count(distinct sub_id) as num
from submissions
where parent_id IS NOT NULL
group by parent_id)

SELECT sub_id as post_id,
case when num IS NOT NULL THEN num  else 0 END as number_of_comments
from posts
left join com
on posts.sub_id=com.parent_id
order by post_id;


--19.average selling price
SELECT p.product_id,round(sum(p.price*u.units)/sum(u.units),2) as average_price
from prices p  
join unitssold u 
on p.product_id=u.product_id
where u.purchase_date between p.start_date and p.end_date
group by p.product_id 


--20.weather type in each country
SELECT c.country_name,CASE 
    WHEN avg(w.weatehr_state)<=15 THEN  "Cold"
    WHEN avg(w.weather_state>=25) THEN "Hot"
    ELSE  "Worm"
END as weatehr_type
from weather w
left join countries c
on w.country_id=c.country_id
where month(day)=11 AND year(day)=2019
group by c.country_name;


--21.find the team size
SELECT employee_id,count() over(partition by team_id order by team_id) as team_size
from employee


--22.students and examinations
with cte as(select *
from students
cross join subjects),
cte2 as(select student_id,subject_name,count(subject_name) as count
from examinations
group by subject_name,student_id)

select c1.student_id,c1.student_name,c1.subject_name,case when count is not null then count else 0 end as attending_exams
from cte c1
left join cte2 cte2
on c1.student_id=c2.student_id and c1.subject_name=c2.subject_name
order by c1.student_id,c1.subject_name;


--23.studetns wiht invalid departments
select s.id,s.name
from students s 
left join departments d 
on s.dept_id=d.id
where d.name is null


--24.replace employee id with the unique identifier
select eu.unique_id,e.name
from employees e 
left join employeeuni eu  
on e.id=eu.id


--25.top travellers
select distinct u.name,case when r.distance is not null then sum() over(partition by r.user_id order by r.user_id) else 0 end as travel_distance
from users u  
left join rides r  
on u.id=r.user_id
order by travel_distance desc,u.name;


--26.npv queries
select q.id,q.year,case when npv.nv is not null then npv.nv else 0 end as npv
from queries q 
left join npv 
on q.id=npv.id and q.year=npv.year


--27.create a session bar chart
with cte as(select *,
case when duration between 0 and 299 then '[0-5>'
when duration between 300 and 599 then '[5-10>'
when duration between 600 and 899 then '[10-15>'
else '15 more'
end as bin  
from sessions)
cte2 as(
select '[0-5>' as bin  
union
select '[5-10>'
union
select '[10-15>'
union
select '15 more')

select cte2.bin,
case when w.c is not null then w.c else 0 end as total
from cte2 
left join
(select bin,count(*) as c
from cte 
group by bin) w 
on cte2.bin=w.bin;


--28.group sold product by the date  
select 
sell_date,count(distinct product) as num_sold,
group_concat(product order by product) as products
from activities
group by sell_date
order by sell_date;


--29.unique orders and customers per month
select substring(order_date,1,7) as month,count(order_id) as order_count, count(distinct customer_id) as customer_count 
from orders
where invoice>20
group by substring(order_date,1,7);


--30.warehouse manager
select w.name as warehouse_name,SUM(w.units*p.height*p.width*p.length) as volume
from warehouse w  
join products p on w.product_id=p.product_id
group by w.name;


--31.customers who visited but did not make any transactions
select v.customer_id,count(v.visit_id) as count_no_trans
from visits v 
left join transactions t  
on v.visit_id=t.visit_id
where t.transaction_id is NULL
group by v.customer_id


--32.bank account summary
select u.name,sum(amount) as balance
from transactions t 
join users u  on t.account=u.account
group by u.name  
having sum(amount)>10000;


--33.invalid tweets
select tweet_id
from tweets
where len(content)>15;


--34.daily leads and partners
select date_id,make_name,count(distinct lead_id) as lead_count,count(distinct partner_id) as partner_count
from dailysales
group by date_id,make_name;


--35.find total time spen by each employee
select event_day as day,emp_id as id,sum(out_time-in_time) as total_time
from employees
group by event_day,emp_id;


--36.find customers with positive revenue this year
select customer_id
from customers 
where year="2021" and revenue>0;


--37.calculate special bonus
select employee_id,case when mod(emp_id,2)!=0 and lower(left(name,1))!="m" then salary else 0 end as bonus
from employees


--38.the latest login in 2020
select distinct user_id,first_value(time_stamp) over(partition by user_id order by time_stamp desc) as last_stamp
from logins
where year(timestamp)="2020";


--39.employees with missing information
select e.employee_id
from employees e 
left join salaries s 
on e.employee_id=s.employee_id
where s.salary is NULL;
union
select s.employee_id
from salaries s 
left join employees e 
on s.employee_id=e.employee_id
where e.name is null
order by employee_id


--40.low-quality problem
select problem_id
from Problems
where (likes/likes+dislikes)<0.6
order by problem_id;


--41.the number of rich customers
select count(distinct customer_id)
from store
where amount>500;


--42.rearrange product details
select product_id,'store1' as store,store1 as price
from products
where store1 is not null

union

select product_id,'store2' as store,store2 as price
from products
where store2 is not null

union 

select product_id,'store3' as store,store3 as price
from products
where store3 is not null 


--43.convert date format
select date_format(day,'%W,$M,%e,%Y')


--44.immediate food delivery
select round((sum(case when order_date=customer_pref_delivery_date then 1 else 0 end)/(select count(*) from delivery))*100,2) as immediate_percentage
from delivery


--45.product sales analysis 2
select product_id,sum(quantity) as total_quantity 
from sales 
group by product_id;


--46.product sales analysis 1
select p.product_name,s.year,s.price
from sales s 
left join product p on s.product_id=p.product_id


--47.game play analysis 1
select player_id,min(event_date) as first_login
from activity 
group by player_id


--48.primary department for each employee
select employee_id ,case when count(department_id=1) then department_id
when count(department_id)>1 then sum((primary_flag='Y') *department_id) END AS department_id
from employees 
group by employee_id


-- 49.LIST THE PRODUCTS ORDERED IN person_id
with cte as(select product_id,sum(units) units_sold
from orders 
where year(order_date)=2020 and month(order_date)=2
group by product_id)

select p.product_name,c.units_sold as units 
from cte c 
left join products p 
on c.product_id=p.problem_id
where c.units_sold>=100;


-- 50.article views 1
select distinct author_id as id
from views 
where author_id=viewer_id
order by id;


-- 51.sales analysis 1
select seller_id
from sales 
group by seller_id
having sum(price)=
(select sum(price) from sales group seller_id order by sum(price) desc limit 1)

-- 52.customer order frequency
with cte as(
select o.customer_id,year(o.order_date) as year,month(o.order_date) as month,(o.quantity*p.price) as amount
from orders o 
left join products p  on o.product_id=p.product_id
where year(o.order_date)=2020 and month(o.order_date) in (6,7)
group by o.customer_id,year(o.order_date),month(o.order_date)),

cte2 as(
select customer_id
from cte 
where amount>=100
group by customer_id 
having count(month)=2)

select cu.customer_id,cu.name
from cte2 c 
join customers cu on c.customer_id=cu.customer_id



-- 53.find followers count 
select user_id,count(distinct follower_id) as follower_count
from followers 
group by user_id 
order by user_id;


-- 54.percentage of users attend the event 
select contest_id,round(count(distinct user_id)/(select count(user_id) from users),2) as user_percentage
from register
group by contest_id
order by user_percentage desc,contest_id;


-- 55.sales person
with cte as(
select
from orders o 
left join company c on o.com_id=c.com_id
where c.name like 'RED')

select name
from sales_person 
where sales_id not in (select distinct sales_id from cte)


-- 56.the winner university
WITH newyork_city AS (
    SELECT COUNT(student_id) AS nsc
    FROM newyork
    WHERE score >= 90
),
california_city AS (
    SELECT COUNT(student_id) AS csc
    FROM california
    WHERE score >= 90
)

SELECT 
    CASE 
        WHEN ny.nsc > ca.csc THEN 'New York University' 
        WHEN ny.nsc < ca.csc THEN 'California University'
        ELSE 'No Winner' 
    END AS winner
FROM newyork_city ny
CROSS JOIN california_city ca; 



