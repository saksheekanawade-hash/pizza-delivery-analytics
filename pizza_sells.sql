SELECT * FROM pizza_orders;

-- 1.Which restaurant has the highest delay rate, and how does it compare to the company-wide average?
SELECT
    "Restaurant Name",
	COUNT(*) AS total_orders,
	SUM(CASE WHEN "Is Delayed" = true THEN 1 ELSE 0 END) AS delayed_orders,
	ROUND(100.0 * SUM(CASE WHEN "Is Delayed" = true THEN 1 ELSE 0 END) / COUNT(*), 2) AS delay_rate_pct
FROM pizza_orders
GROUP BY "Restaurant Name"
ORDER BY delay_rate_pct DESC;

-- 2.What is the average delay (in minutes) broken down by traffic level (Low/Medium/High)?
SELECT
    "Traffic Level",
	COUNT(*) AS total_orders,
	ROUND(AVG("Delay (min)")::numeric, 2) AS avg_delay_min,
	ROUND(100.0 * SUM(CASE WHEN "Is Delayed" = true THEN 1 ELSE 0 END) / COUNT(*), 2) AS delay_rate_pct
FROM pizza_orders
GROUP BY "Traffic Level"
ORDER BY avg_delay_min DESC;

-- Does Domino's operate in higher-traffic conditions more often than other restaurants?
SELECT
    "Restaurant Name",
    "Traffic Level",
	COUNT(*) AS orders,
	ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (PARTITION BY "Restaurant Name"), 2) AS pct_of_restaurant_orders
FROM pizza_orders
GROUP BY "Restaurant Name", "Traffic Level"
ORDER BY "Restaurant Name", "Traffic Level";

--: Within the same traffic conditions, does Domino's still delay more than other restaurants?
SELECT
    "Traffic Level",
    "Restaurant Name",
	COUNT(*) AS orders,
	ROUND(100.0 * SUM(CASE WHEN "Is Delayed" = true THEN 1 ELSE 0 END)/ COUNT(*), 2) AS delay_rate_pct
FROM pizza_orders
GROUP BY "Traffic Level", "Restaurant Name"
ORDER BY "Traffic Level", delay_rate_pct DESC;

-- During Medium traffic, does Domino's handle longer-distance orders than other restaurants — or is the estimated delivery time itself miscalibrated?
SELECT
    "Restaurant Name",
	COUNT(*) AS orders,
	ROUND(AVG("Distance (km)")::numeric, 2) AS avg_distance,
	ROUND(AVG("Estimated Duration (min)")::numeric, 2) AS avg_estimated_duration,
	ROUND(AVG("Delivery Duration (min)")::numeric, 2) AS avg_actual_duration,
	ROUND(avg("Delay (min)")::numeric, 2) AS avg_delay
FROM pizza_orders
WHERE "Traffic Level" = 'Medium'
GROUP BY "Restaurant Name"
ORDER BY avg_delay DESC;

-- How much does delivery delay vary within each restaurant — is Domino's inconsistent, or just consistently a bit slower?
SELECT
    "Restaurant Name",
	COUNT(*) AS orders,
	ROUND(AVG("Delay (min)")::numeric, 2) AS avg_delay,
	ROUND(STDDEV("Delay (min)")::numeric, 2) AS stddev_delay,
	ROUND(MIN("Delay (min)")::numeric, 2) AS min_delay,
	ROUND(MAX("Delay (min)")::numeric, 2) AS max_delay
FROM pizza_orders
WHERE "Traffic Level" ='Medium'
GROUP BY "Restaurant Name"
ORDER BY stddev_delay DESC;

-- Q3.Which locations (cities) have the worst average delivery delay, and how many orders come from each?
SELECT
    "Location",
	COUNT(*) AS orders,
	ROUND(AVG("Delay (min)")::numeric, 2) AS avg_delay,
	ROUND(100.0 * SUM(CASE WHEN "Is Delayed" = true THEN 1 ELSE 0 END) / COUNT(*), 2) AS delay_rate_pct
FROM pizza_orders
GROUP BY "Location"
HAVING COUNT(*) >=10
ORDER BY avg_delay DESC;

-- Q4.Is there a measurable difference in delay rate between peak-hour and non-peak-hour orders?
SELECT
    "Is Peak Hour",
	COUNT(*) AS orders,
	ROUND(AVG("Delay (min)")::numeric, 2) AS avg_delay,
	ROUND(100.0 * SUM(CASE WHEN "Is Delayed" = true THEN 1 ELSE 0 END) / COUNT(*), 2) AS delay_rate_pct
FROM pizza_orders
GROUP BY "Is Peak Hour"
ORDER BY delay_rate_pct DESC;

--let's check if peak hours and traffic levels overlap:
SELECT
    "Is Peak Hour",
	"Traffic Level",
	COUNT(*) AS orders,
	ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (PARTITION BY "Is Peak Hour"), 2) AS pct_within_peak_group
FROM pizza_orders
GROUP BY "Is Peak Hour", "Traffic Level"
ORDER BY "Is Peak Hour", "Traffic Level";

--Q5.What percentage of orders exceed their estimated delivery duration by more than 10 minutes?
SELECT
    COUNT(*) AS total_orders,
	SUM(CASE WHEN "Delay (min)" > 10 THEN 1 ELSE 0 END) AS orders_over_10min_delay,
	ROUND(100.0 * SUM(CASE WHEN "Delay (min)" > 10 THEN 1 ELSE 0 END) / COUNT(*),2) AS pct_over_10min_delay
FROM pizza_orders;

--This is worth verifying before we conclude too strongly — let's check the actual distribution:
SELECT 
    ROUND(AVG("Estimated Duration (min)")::numeric, 2) AS avg_estimated,
    ROUND(AVG("Delivery Duration (min)")::numeric, 2) AS avg_actual,
    ROUND(AVG("Delay (min)")::numeric, 2) AS avg_delay,
    ROUND(MIN("Delay (min)")::numeric, 2) AS min_delay,
    ROUND(MAX("Delay (min)")::numeric, 2) AS max_delay
FROM pizza_orders;

--Q6Which pizza type and size combination is ordered most frequently, and does it vary by restaurant?
SELECT
    "Pizza Type",
	"Pizza Size",
	COUNT(*) AS orders,
	ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS pct_of_all_orders
FROM pizza_orders
GROUP BY "Pizza Type", "Pizza Size"
ORDER BY orders DESC
LIMIT 10;

SELECT * FROM (
    SELECT
	    "Restaurant Name",
		"Pizza Type",
		"Pizza Size",
		COUNT(*) AS orders,
		RANK() OVER (PARTITION BY "Restaurant Name" ORDER BY COUNT(*) DESC) AS rnk
	FROM pizza_orders
	GROUP BY "Restaurant Name", "Pizza Type", "Pizza Size"
) sub
WHERE rnk =1
ORDER BY "Restaurant Name";

--Q7. Do orders with more toppings take significantly longer to deliver, controlling for distance?
SELECT
    "Toppings Count",
	COUNT(*) AS orders,
	ROUND(AVG("Distance (km)")::numeric, 2) AS avg_distance,
	ROUND(AVG("Delivery Duration (min)")::numeric, 2) AS avg_delivery_duration,
	ROUND(AVG("Delivery Efficiency (min/km)")::numeric, 2) AS avg_efficincy
FROM pizza_orders
GROUP BY "Toppings Count"
ORDER BY "Toppings Count";

--Q8. Which restaurant maintains the most consistent (lowest variance) delivery time, regardless of distance?
SELECT 
    "Restaurant Name",
    COUNT(*) AS orders,
    ROUND(AVG("Delivery Duration (min)")::numeric, 2) AS avg_duration,
    ROUND(STDDEV("Delivery Duration (min)")::numeric, 2) AS stddev_duration,
    ROUND(AVG("Delivery Efficiency (min/km)")::numeric, 2) AS avg_efficiency,
    ROUND(STDDEV("Delivery Efficiency (min/km)")::numeric, 2) AS stddev_efficiency
FROM pizza_orders
GROUP BY "Restaurant Name"
ORDER BY stddev_efficiency ASC;

--Q9. Does delay increase linearly with distance, or is there a threshold where it spikes?
SELECT
    CASE
	    WHEN "Distance (km)" < 3 THEN '0-3 km'
		WHEN "Distance (km)" < 6 THEN '3-6 km'
		WHEN "Distance (km)" < 9 THEN '6-9 km'
		WHEN "Distance (km)" < 12 THEN '9-12 km'
		ELSE '12+ km'
	END AS distance_bucket,
    COUNT(*) AS orders,
    ROUND(AVG("Delay (min)")::numeric, 2) AS avg_delay,
    ROUND(100.0 * SUM(CASE WHEN "Is Delayed" = true THEN 1 ELSE 0 END) / COUNT(*), 2) AS delay_rate_pct
FROM pizza_orders
GROUP BY distance_bucket
ORDER BY MIN("Distance (km)");

--Q10 Which top 5 locations generate the highest order volume, and what's their average delay in each?
SELECT
    "Location",
	COUNT(*) AS orders,
	ROUND(AVG("Delay (min)")::numeric, 2) AS avg_delay,
	ROUND(100.0 *SUM(CASE WHEN "Is Delayed" = true THEN 1 ELSE 0 END) / COUNT(*),2) AS delay_rate_pct
FROM pizza_orders
GROUP BY "Location"
ORDER BY orders DESC
LIMIT 5;

--Q11. How does order volume vary by month — is there a clear seasonal pattern across 2024–2025?
SELECT 
    "Order Month",
    COUNT(*) AS orders,
    ROUND(AVG("Delay (min)")::numeric, 2) AS avg_delay,
    ROUND(100.0 * SUM(CASE WHEN "Is Delayed" = true THEN 1 ELSE 0 END) / COUNT(*), 2) AS delay_rate_pct
FROM pizza_orders
GROUP BY "Order Month"
ORDER BY 
    CASE "Order Month"
        WHEN 'January' THEN 1 WHEN 'February' THEN 2 WHEN 'March' THEN 3
        WHEN 'April' THEN 4 WHEN 'May' THEN 5 WHEN 'June' THEN 6
        WHEN 'July' THEN 7 WHEN 'August' THEN 8 WHEN 'September' THEN 9
        WHEN 'October' THEN 10 WHEN 'November' THEN 11 WHEN 'December' THEN 12
    END;

--Q12. What are the busiest hours of the day for orders, and do delay rates spike during those hours?
SELECT 
    "Order Hour",
    COUNT(*) AS orders,
    ROUND(AVG("Delay (min)")::numeric, 2) AS avg_delay,
    ROUND(100.0 * SUM(CASE WHEN "Is Delayed" = true THEN 1 ELSE 0 END) / COUNT(*), 2) AS delay_rate_pct
FROM pizza_orders
GROUP BY "Order Hour"
ORDER BY "Order Hour";

--Q13. Are weekend orders delayed more often than weekday orders?
SELECT 
    "Is Weekend",
    COUNT(*) AS orders,
    ROUND(AVG("Delay (min)")::numeric, 2) AS avg_delay,
    ROUND(100.0 * SUM(CASE WHEN "Is Delayed" = true THEN 1 ELSE 0 END) / COUNT(*), 2) AS delay_rate_pct
FROM pizza_orders
GROUP BY "Is Weekend"
ORDER BY delay_rate_pct DESC;

-- Payment Behavior
--Q14. Which payment method is most commonly used for orders that get delayed — is there a link between
SELECT 
    "Payment Method",
    COUNT(*) AS orders,
    SUM(CASE WHEN "Is Delayed" = true THEN 1 ELSE 0 END) AS delayed_orders,
    ROUND(100.0 * SUM(CASE WHEN "Is Delayed" = true THEN 1 ELSE 0 END) / COUNT(*), 2) AS delay_rate_pct
FROM pizza_orders
GROUP BY "Payment Method"
ORDER BY delay_rate_pct DESC;


