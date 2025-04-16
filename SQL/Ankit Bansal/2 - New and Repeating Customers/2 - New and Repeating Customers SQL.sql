-- Solution 1:

;WITH A AS ( 
	SELECT T1.*, 
		CustomerType = CASE WHEN T2.order_id IS NULL THEN 1 ELSE 0 END
	FROM customer_orders AS T1
			LEFT JOIN customer_orders AS T2
				ON T1.customer_id = T2.customer_id
					AND T2.order_date < T1.order_date
)
SELECT  OrderDate = order_date, 
		NewCustomer = SUM(CustomerType), 
		RepeatCustomer = (
			SELECT COUNT(DISTINCT customer_id) 
			FROM A AS T2 
			WHERE T1.order_date = T2.order_date 
				AND T2.CustomerType = 0 
		) 
FROM A AS T1
GROUP BY order_date


-- Solution 2:

WITH CustomerFirstPurchaseDate AS ( 
	SELECT  Customer_ID, 
			FirstVisitDate = MIN(Order_Date) 
	FROM Customer_Orders
	GROUP BY Customer_ID
),
CustomerStatus AS (
	SELECT  T1.*, 
			Flag = CASE 
				WHEN T2.FirstVisitDate < T1.Order_Date 
				THEN 'Repeat' 
				ELSE 'New' 
			END 
	FROM Customer_Orders AS T1
			LEFT JOIN CustomerFirstPurchaseDate AS T2
				ON T1.Customer_ID = T2.Customer_ID
)

SELECT  OrderDate = Order_Date, 
		NewCustomer = SUM(CASE WHEN Flag = 'New' THEN 1 ELSE 0 END),
		RepeatCustomer = SUM(CASE WHEN Flag = 'Repeat' THEN 1 ELSE 0 END)
FROM CustomerStatus
GROUP BY Order_Date