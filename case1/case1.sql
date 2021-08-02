create database sql_challenge;
use  sql_challenge;

/* creating tables */

CREATE TABLE sales(
  customer_id VARCHAR(1),
  order_date DATE,
  product_id INTEGER
);

INSERT INTO sales
  (customer_id, order_date, product_id)
VALUES
  ('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');
 

CREATE TABLE menu (
  product_id INTEGER,
  product_name VARCHAR(5),
  price INTEGER
);

INSERT INTO menu
  (product_id, product_name, price)
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');
  

CREATE TABLE members (
  customer_id VARCHAR(1),
  join_date DATE
);

INSERT INTO members
  (customer_id, join_date)
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');
  
  show tables;
  select * from members;
  select * from sales;
  
  /* ------------------------QUESTIONS--------------------------*/
  
  /* Ques1
  What is the total amount each customer spent at the restaurant?
  */
  
  select s.customer_id, sum(menu.price) from sales as s
  join menu on s.product_id=menu.product_id
  group by s.customer_id;
  
  
  /* Ques2
  How many days has each customer visited the restaurant?
  */
  
 
select customer_id, count(distinct(order_date)) from sales
group by customer_id
order by customer_id;





/* Ques3
What was the first item from the menu purchased by each customer?
*/
        
 select s.customer_id,s.product_id,m.product_name,t.first_visit as order_date from sales as s
 join (select customer_id, min(order_date) as first_visit from sales
 group by customer_id) t 
 on s.order_date=t.first_visit
 join menu as m on s.product_id=m.product_id;
 
 -- check this query, getting duplicate rows
 
 
 
 
 
 /* Ques4
 What is the most purchased item on the menu and how many times was it purchased by all customers?
 */
 
 select s.product_id,m.product_name,count(s.product_id) as times_bought from sales s 
 join menu m on s.product_id=m.product_id
 group by s.product_id
 having count(s.product_id)=(select max(count) from  (select product_id,count(product_id) as count from sales
group by product_id) a);


 
 /* Ques5
 Which item was the most popular for each customer?
*/

select t1.customer_id,t1.product_id,m.product_name from(select customer_id,product_id,count(product_id),dense_rank() over(
									partition by customer_id
                                    order by count(product_id) desc) rank_count
							from sales
                            group by customer_id,product_id
                            order by customer_id) t1
	join menu as m
    on t1.product_id=m.product_id
    where rank_count=1
    order by customer_id;
    
    


/*Ques 6
Which item was purchased first by the customer after they became a member?
*/

select s.customer_id,s.product_id,menu.product_name from sales s
join menu on s.product_id=menu.product_id
join members mem on s.customer_id=mem.customer_id
where s.order_date<=mem.join_date
order by customer_id;




/*Ques7
Which item was purchased just before the customer became a member?
*/
 
 -- use dense ranking
 
 select t2.customer_id,t2.product_id,menu.product_name,t2.order_date from (select s.customer_id,s.product_id,s.order_date,members.join_date, dense_rank() over (
													partition by s.customer_id
                                                    order by s.order_date desc) t1
										from sales s 
                                        join members  on s.customer_id=members.customer_id
                                        group by s.customer_id,s.order_date
										having s.order_date < members.join_date
                                        order by s.customer_id) t2
                                        join menu on t2.product_id=menu.product_id
                                        where t1=1
                                        order by t2.customer_id;
                                        
	
	
  
/* Ques8
What is the total items and amount spent for each member before they became a member?
*/


select t.customer_id,count(t.product_id) as total_products,sum(t.price) as total_amount from (select s.customer_id,s.product_id,menu.price,s.order_date from sales s
join menu on s.product_id=menu.product_id
join members m on s.customer_id=m.customer_id
where s.order_date<m.join_date
order by s.customer_id) t
group by t.customer_id;




/* Ques9
If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
*/


select customer_id, sum(points) from (select s.customer_id, case
					when s.product_id=1 then menu.price*20
                    else menu.price*10
                    end as points
from sales s join menu on s.product_id=menu.product_id
order by s.customer_id) ptable	
group by customer_id;




/*ques10
In the first week after a customer joins the program (including their join date) they
earn 2x points on all items, not just sushi - how many points do customer A and B
have at the end of January?
*/

select customer_id,sum(points) from (select mem.customer_id, case
						when (s.order_date<mem.join_date and s.product_id=1) then menu.price*20
                        when (s.order_date<mem.join_date) then price*10
                        else price*20
                        end as points
from members mem join sales s on mem.customer_id=s.customer_id
join menu on s.product_id=menu.product_id
where s.order_date<= '2021-01-31') ptable 
group by customer_id
order by customer_id
            
            
                    

        
 
									
                                        
                                                    
										
                              
									
                                   
