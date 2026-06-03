-- Total products
SELECT COUNT(*) as total FROM food_facts_db.parquet;

-- Nutriscore distribution
SELECT nutriscore_grade, COUNT(*) as total
FROM food_facts_db.parquet
GROUP BY nutriscore_grade
ORDER BY total DESC;

-- Top brands by nutriscore A
SELECT brands, COUNT(*) as total
FROM food_facts_db.parquet
WHERE nutriscore_grade = 'A'
GROUP BY brands
ORDER BY total DESC
LIMIT 10;

-- Average nutrients by grade
SELECT nutriscore_grade,
       AVG(sugars) as avg_sugars,
       AVG(fat)    as avg_fat,
       AVG(salt)   as avg_salt
FROM food_facts_db.parquet
GROUP BY nutriscore_grade
ORDER BY nutriscore_grade;

-- Healthiest products (grade A, low sugar)
SELECT product_name, brands, sugars, fat, salt
FROM food_facts_db.parquet
WHERE nutriscore_grade = 'A'
AND sugars < 5
ORDER BY sugars ASC
LIMIT 10;