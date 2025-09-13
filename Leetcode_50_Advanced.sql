--1.find customer with positive revenue this year
SELECT customer_id
from Customers
where year=2021 and revenue>0;


--2.customers who never order
 SELECT c.id,c.name
 from Customers c 
 JOIN Orders o on c.id=o.customer_id
 where o.customer_id IS NULL


 --3.calculate special bonus
 SELECT employee_id,salary as bonus
 FROM employee
 where employee_id%2!=0 and lower(name) not like '%m%'
 order by employee_id;

 select 
 employee_id,
 if(employee_id%2!=0 AND lower(name) not like '%m%') as bonus
 from employees
 order by employee_id;

 select employee_id,case when employee_id%2!=0 AND lower(name) not like '%m%' then salary else 0 end as bonus
 from employees
 order by employee_id;


 --4.customers who bought products A and B but not C 
SELECT o.customer_id,c.customer_name
from Customers c 
left join Orders o c.customer_id=o.customer_id
order by customer_id
group by o.customer_id
having 
GROUP_CONCAT(distinct product_name order by product_name) like 'A,B%' 
AND 
GROUP_CONCAT(distinct product_name order by product_name) NOT LIKE '%C%';   


--5.highest grade for each student
SELECT tab.student_id,tab.course_id,tab.grade
(SELECT student_id,row_number() over(partition by student_id order by course_id,grade desc)
from Enrollments
order by student_id) tab 
where tab.rank=1
order by tab.studet_id;


with cte as(
select *,row_number() over(partition by student_id order by grade desc,course_id) as rnk 
from Enrollments
)
select student_id,course_id,grade 
from cte 
where rnk=1
order by student_id;


--6.combine two tables
SELECT p.first_name,p.last_name,a.city,a.state
from Persons p 
left join Address on a p.person_id=a.person_id 


--7.sellers with no sales   
from Orders o 
left join customers c on c.customer_id=o.customer_id
left join sellers s on o.seller_id=s.seller_id
where year(state_date)=2020
order by seller_name


select s.seller_name
from sellers s 
left join(select * from Orders where year(sale_date)=2020) as o  
on s.seller_id=o.seller_id
where o.order_id is NULL
order by s.seller_name;


--8.top travellers
SELECT u.name,IFNULL(sum(r.distance),0) as total_distance
from Users u
left join Rides r on u.id=r.user_id
group by u.id,u.name
order by total_distance desc,u.name


--9.sales person
SELECT s.sales_id,s.name
 from Salespersons s 
 left join Orders o on s.sales_id=o.sales_id
 left join Company c on o.com_id=c.com_id
group by s.sales_id,s.name 
having sum(if(c.name='RED',1,0))=0;


--10.evaluate boolean expression
select e.*,
case 
when operator='>' then if(v1.value>v2.value,'True','False')   
when operator='<' then if(v1.value<v2.value,'True','False')
when operator='=' then if(v1.value=v2.value,'True','False')
else NULL
end as value 
from Expressions e 
left join Variables v1 on e.left_operand=v1.name
left join Variables v2 on  e.right_operand=v2.name


--11.team scores in football tournament
with cte as(select t.team_id,t.team_name,
CASE 
    WHEN t.team_id=m.host_team and m.host_goals>m.guest_goals THEN 3  
     WHEN t.team_id=m.guest_team and m.host_goals<m.guest_goals THEN 3 
      WHEN ((t.team_id=m.host_team) or (t.team_id=m.guest_team)) and m.host_goals=m.guest_goals THEN 1  
    ELSE  0
END as points
from Teams t 
left join Matches m on t.team_id=m.host_team or t.team_id=m.guest_team)

select team_id,team_name,sum(points) as total_points
from cte
group by t.team_id,t.team_name
order by sum(points) desc,t.team_id;


--12.the latest login in 2020
select user_id,max(timestamp) as last_stamp
from Logins
where year(time_stamp)=2020
group by user_id;


--13.game play analysis
SELECT player_id,min(event_date) as first_sign
from Activity
group by player_id;


--14.warehouse manager
select w.name as warehouse_name,sum(w.units*p.width*p.length*p.height) as volume
from Wrehouse w
left join Products p
on w.product_id=p.product_id
group by w.name;


--15.customer placing the largest number of orders 
with counts as(SELECT *,count(order_number) over(partition by customer_number) as cnt
from Orders ),
ranking as(SELECT *,dense_rank() over(order by cnt desc) as rnk
from counts)
select distinct customer_number from ranking; 


--16.find total time spent by each employee
SELECT event_day as day,emp_id,sum(out_time-in_time) as total_time
from employee
group by event_day,emp_id


--17.immediate food delivery
SELECT round(sum(if(order_date=customer_pref_delivery_date,1,0))/count(*)*100,2) as immediate_percentage
from Delivery;


--18. apples & oranges
SELECT sale_date,
sum(if(fruit='apples',sold_num,0) as apples
-
if(fruit='oranges',sold_num,0) as oranges) as diff
from Sales
group by sale_date
order by sale_date;


--19.number of calls between two Persons
SELECT least(from_id,to_id) as person1,greatest(from_id,to_id) as person_2,count(*) as call_count,
sum(duration) as total_duration
from calls
group by least(from_id,to_id),greatest(from_id,to_id);


--20.bank account summary
SELECT
from Transactions t 
LEFT JOIN Users u
on t.account=u.account
group by t.account,t.name
having sum(t.account)>10000;


--when column name is same we can use using keyword
SELECT u.name
from Transactions t 
LEFT JOIN Users u
using(account)
group by t.account,t.name
having sum(t.account)>10000;


--21. duplicate emails
SELECT lower(email)
from Persons
group by lower(email)
having count(*)>1


--22.actors and directors who cooperated at least three times
SELECT actor_id,director_id
from ActorDirector
group by actor_id,director_id
having count(*)>=3;


--23.customer order frequency
SELECT o.customer_id,c.name,month(o.order_date),sum(o.quantity*p.price) as spend
from Orders o 
left join customers c on o.customer_id=c.customer_id
left join products p on o.product_id=p.product_id
where year(o.order_date)=2020 and month(o.order_date) in (6,7);
group by o.customer_id,c.name,month(o.order_date)
having sum(o.quantity*p.price)>=100;


--24.daily leads and partners
SELECT
 date_id,
lower(make_name),
count(distinct lead_id) as unique_leads,
count(distinct partner_id) as unique_partners
from DailySales
group by date_id,lower(make_name)


--25.friendly movies streamed last month
SELECT distinct c.title
from TVprogram t  
left join Content c  
on t.content_id=c.content_id
where date_format(t.program_date,'%Y-%m')='2020-06' AND c.kids_content='Y' AND c.content_type='Movies';


--26.countries you can safely invest in 
select co.name as country
Person as p
LEFT JOIN Calls AS c  
on p.id in (c.caller_id,c.callee_id)
left join Country co 
on LEFT(p.phone_number,3)=co.country_code
group by co.name
HAVING avg(c.duration)>(SELECT avg(duration) from Calls);


--27.consecutive available seats
SELECT seat_id
from(SELECT *,lag(free) over(order by seat_id) as befor,lead(free) over(order by seat_id) as after
from Cinema) t
where (free=1 AND befor=1) OR
(free=1 AND after=1)
order by seat_id;


--28.rearrange product tables
SELECT product_id, 'store1' as store,store1 as price
from Products
where store1 is NOT NULL
UNION
SELECT product_id, 'store2' as store,store2 as price
from Products
where store2 is NOT NULL
UNION
SELECT product_id, 'store3' as store,store3 as price
from Products
where store3 is NOT NULL


--29.shortest diatance in a line
SELECT min(abs(p1.x-p2.x)) as shortest 
from Points p1
LEFT join Points p2
onp1.x!=p2.X


--30.employee with missing information
SELECT coalesce(e.employee_id,s.employee_id) as employee_id
from Employee e 
left join Salaries s  
on e.employee_id=s.employee_id
where s.salary is NULL
UNION
SELECT coalesce(e.employee_id,s.employee_id) as employee_id
from Employee e 
right join Salaries s  
on e.employee_id=s.employee_id
where s.salary is NULL
order by employee_id


--31.Page recommendations


--32.tree node
SELECT
id,
case 
when p_id IS NULL THEN 'Root'
when p_id is NOT NULL AND id in (select DISTINCT p_id from Tree) then 'Inner'
else 'Leaf'
END as node_type
from Tree
order by id;


--33. game play analysis 3
SELECT player_id,event_date,sum(games_played) over(partition by player_id order by event_date)
from Activity;


--34.grand slam titles
SELECT p.player_id,p.player_name,
sum(c.wimbledon=p.player_id)+
sum(c.fr_open=p.player_id)+
sum(c.au_open=p.player_id)
as grand_slams_count
from Players as p 
cross join Championships as c 
group p.player_id,p.player_name
having grand_slams_count>0;


--35.leetflex banned accounts
SELECT DISTINCT l1.account_id
from loginfo as l1
join loginfo as l2 
on l1.account_id=l2.account_id
AND
l1.ip_address!=l2.ip_address
where (l1.login BETWEEN l2.login and l2.logout) OR
(l1.logout BETWEEN l2.login and l2.logout)


--36.students with invalid departments
SELECT s.id.s.name
from Students s  
left join Departments d 
on s.id=d.id 
where d.department_id IS NULL;

select id,name
from students 
where department_id NOT IN (select id from departments);


--37.find the team size
SELECT e.employee_id,t.team_size
from Employee as e 
left join
(select 
team_id,count(employee_id) as team_size
from Employee e 
group by team_id) t 
on e.team_id=t.team_id


--38.game play analysis 2
SELECT t.player_id,t.device_id
FROM
(SELECT *,dense_rank() over(partition by player_id order by event_date) as rnk
from Activity ) t 
where t.rnk=1;


--39.department highest salary
SELECT t.department,t.employee,t.salary
FROM 
(SELECT d.name as Department,e.name as Employee,e.salary as Salary,dense_rank() over(partition by d.name order by e.salary desc) as rnk
from Employee e 
left join Departments d  
on e.department_id=d.id) t  
where t.rnk=1


--40.the most recent orders for each product  
SELECT p.product_name,t.product_id,t.order_id,t.order_date
from (SELECT *,dense_rank() over(partition by product_id order by order_Date desc) as rnk
from Orders) t 
left join Products p 
on t.product_id=p.product_id
where t.rnk=1
order by p.product_name,t.product_id,t.order_id;


--41.the most recent orders
SELECT c.name as customer_name,t.customer_id,t.order_id,t.order_date
from(select order_id,order_date,customer_id,
dense_rank() over(partition by customer_id order by order_date desc) as rnk
from Orders) t 
left join Customers c 
on t.customer_id=c.customer_id
where t.rnk<=3
order by customer_name,t.customer_id,t.order_date desc;


--42.maximum transaction each day
SELECT t.transaction_id
FROM
(SELECT *,dense_rank() over(partition by date_format(day,'%y-%m-%d') order by amount desc) as rnk
from Transactions ) t
where t.rnk=1
order by t.transaction_id desc;


--43.project employees 3
with cte as(SELECT p.*,e.experience_years,max(e.experience_years) over(partition by p.project_id) as max_exp
from Project p 
left join Employee e  
on p.employee_id=e.employee_id)

SELECT project_id,employee_id
from cte 
where experience_years=max_exp


--44.find the start and end number of continous ranges
with cte as
(select log_id,log_id-row_number() over(order by log_id) as diff
from Logs)
select min(log_id) start_id,max(log_id) end_id
from cte
group by diff;


--45.the most frequently ordered products for each customer
with cte1 as(SELECT o.*,p.product_name,count(o.order_id) over(partition by o.customer_id,o.product_id) as freq
from Orders o
left join Products p
on o.product_id=p.roduct_id),
cte2 as(
SELECT *,dense_rank() over(partition by customer_id order by freq desc) as rnk
from cte1)
SELECT distinct customer_id,product_id,product_name
from cte2
where rnk=1;


--46.biggest window between visits
with cte as(SELECT *,lead(visit_date,'2021-01-01') over(partition by user_id order by visit_date) as next_visit
from UserVisits)
SELECT user_id,max(datediff(next_visit,visit_date)) as biggest_window
from cte
group by user_id
order by user_id;


--47.all people report to the given manager
with recursive cte as(

)
select * from cte;


--48.find the quiet students in all exams
with min_max as(select *,max(score) over(partition by exam_id) as maxim ,min(score) over(partition by exam_id)
from Exam ),

scored_min_max as(
select *
from min_max
where score=maxim or score=minim)

select *
from Student
where student_id in(select distinct student_id from Exam) AND
student_id not in (select student_id from scored_min_max)
order by student_id
;


--49.find the subtasks that did not execute
with recursive cte as(
  SELECT task_id,subtasks_count from tasks
  UNION
  select task_id,subtasks_count-1 from cte
  where subtasks_count>1
)
select task_id,subtasks_count as subtask_id
from cte 
where (task_id,subtasks_count) not in (
  select * from Ececuted
)


--50.report contiguous dates
with cte as
(SELECT
fail_date as date,'failed' as state from Failed
UNION
SELECT
success_date as date,'succeeded' as state from succeeded),

cte2 as(
select *,row_number() over(partition by state order by date) as rnk
from cte),

cte3 as(
select *,date_sub(date,interval rnk DAY) as group_date
from cte2)

select state as period_state,min(date) as start_date,max(date) as end_date
from cte3
where date between '2019-01-01' AND '2019-12-31'
group by group_date,state
order by start_date;













 
