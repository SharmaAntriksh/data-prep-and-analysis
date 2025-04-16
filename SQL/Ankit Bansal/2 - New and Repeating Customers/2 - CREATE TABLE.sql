-- https://www.youtube.com/watch?v=MpAMjtvarrc&list=PLBTZqjSKn0IeKBQDjLmzisazhqQy4iGkb&index=2&t=262s&ab_channel=AnkitBansal

CREATE TABLE customer_orders (
     order_id INT,
	 customer_id INT,
	 order_date DATE,
	 order_amount INT
  );


INSERT INTO customer_orders
VALUES     
	(1,100,CAST('2022-01-01' AS DATE),2000),
	(2,200,CAST('2022-01-01' AS DATE),2500),
	(3,300,CAST('2022-01-01' AS DATE),2100),
	(4,100,CAST('2022-01-02' AS DATE),2000),
	(5,400,CAST('2022-01-02' AS DATE),2200),
	(6,500,CAST('2022-01-02' AS DATE),2700),
	(7,100,CAST('2022-01-03' AS DATE),3000),
	(8,400,CAST('2022-01-03' AS DATE),1000),
	(9,600,CAST('2022-01-03' AS DATE),3000); 