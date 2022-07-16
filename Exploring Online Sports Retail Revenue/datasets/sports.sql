-- Count all columns as total_rows
-- Count the number of non-missing entries for description, 
-- listing_price, and last_visited
-- Join info, finance, and traffic
SELECT COUNT(*) AS total_rows,
    COUNT(i.description) AS count_description, 
    COUNT(f.listing_price) AS count_listing_price, 
    COUNT(t.last_visited) AS count_last_visited

FROM info AS i
INNER JOIN finance AS f
    ON i.product_id = f.product_id
INNER JOIN traffic AS t
    ON t.product_id = f.product_id;
    
    
-- Select the brand, listing_price as an integer, 
-- and a count of all products in finance 
-- Join brands to finance on product_id
-- Filter for products with a listing_price more than zero
-- Aggregate results by brand and listing_price, and sort the results
-- by listing_price in descending order
SELECT b.brand, f.listing_price::integer , COUNT(f.product_id)

FROM brands AS b
INNER JOIN finance AS f
ON b.product_id = f.product_id

WHERE listing_price > 0
GROUP BY brand, listing_price
ORDER BY f.listing_price DESC; 


-- Select brand and average_discount as a percentage
-- Join brands to finance on product_id
-- Aggregate by brand
-- Filter for products without missing values for brand
SELECT brand, AVG(discount)*100 AS average_discount

FROM brands AS b
INNER JOIN finance AS f
ON b.product_id = f.product_id

GROUP BY brand
HAVING brand IS NOT NULL;


-- Calculate the correlation between reviews and revenue as review_revenue_corr
-- Join the reviews and finance tables on product_id
SELECT CORR(reviews, revenue) AS review_revenue_corr

FROM reviews AS r
INNER JOIN finance AS f
USING(product_id);


-- Calculate description_length
-- Convert rating to a numeric data type and calculate average_rating
-- Join info to reviews on product_id and group the results by description_length
-- Filter for products without missing values for description, and sort results by description_length
SELECT TRUNC(LENGTH(description), -2) AS description_length, ROUND(AVG(r.rating::numeric),2) AS average_rating

FROM info AS i
INNER JOIN reviews AS r
    ON i.product_id = r.product_id

WHERE description IS NOT NULL
GROUP BY description_length
ORDER BY description_length;



-- Select brand, month from last_visited, and a count of all products in reviews aliased as num_reviews
-- Join traffic with reviews and brands on product_id
-- Group by brand and month, filtering out missing values for brand and month
-- Order the results by brand and month
SELECT b.brand,
EXTRACT(MONTH FROM t.last_visited) AS month,
COUNT(r.product_id) AS num_reviews

FROM traffic AS t
INNER JOIN reviews AS r
 ON t.product_id = r.product_id
INNER JOIN brands AS b
ON r.product_id = b.product_id

GROUP BY b.brand, month
HAVING b.brand IS NOT NULL 
    AND EXTRACT(MONTH FROM t.last_visited) IS NOT NULL
ORDER BY b.brand, month;





-- Create the footwear CTE, containing description and revenue
-- Filter footwear for products with a description containing %shoe%, %trainer, 
-- or %foot%
-- Also filter for products that are not missing values for description
-- Calculate the number of products and median revenue for footwear products
WITH footwear AS
(
    SELECT i.description, f.revenue
    FROM info AS i
    INNER JOIN finance AS f
        ON i.product_id = f.product_id
    WHERE i.description ILIKE '%shoe%'
        OR i.description ILIKE'%trainer%'
        OR i.description ILIKE '%foot%'
        AND i.description IS NOT NULL
    
)

SELECT COUNT(*) AS num_footwear_products,
    percentile_disc(0.5) WITHIN GROUP (ORDER BY revenue) AS median_footwear_revenue
FROM footwear;



