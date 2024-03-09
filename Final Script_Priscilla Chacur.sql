#Selecting the databse
USE bos_fmban_sql_analysis;

#Creating CTE for normalizing product categories
	#Keeping in mind this is usually because the data has mistakes
WITH prod_categ AS (
SELECT
    (CASE
			WHEN category LIKE ('%beauty%') THEN 'Beauty'
            WHEN category LIKE ('%beverage%') THEN 'Beverages'
            WHEN category LIKE ('%body%') THEN 'Body Care'
            WHEN category LIKE ('%Bakery%') THEN 'Bread, Rolls & Bakery'
            WHEN category LIKE ('%Dairy%') THEN 'Dairy and Eggs'
            WHEN category LIKE ('%Dessert%') THEN 'Desserts'
            WHEN category LIKE ('%Floral%') THEN 'Floral'
            WHEN category LIKE ('%Frozen%') THEN 'Frozen Foods'
			WHEN category LIKE ('%lifestyle%') THEN 'Lifestyle'
            WHEN category LIKE ('%meat%') THEN 'Meat'
            WHEN category LIKE ('%Pantry%') THEN 'Pantry Essentials'
            WHEN category LIKE ('%prepared%') THEN 'Prepared Foods'
            WHEN category LIKE ('%produce%') THEN 'Produce'
            WHEN category LIKE ('%seafood%') THEN 'seafood'
            WHEN category LIKE ('%snacks%') THEN 'Snacks, Chips, Salsa & Dips'
            WHEN category LIKE ('%supplements%') THEN 'Supplements'
            WHEN category LIKE ('%wine%') THEN 'Wine, Beer & Spirits'
            ELSE '!!!'
            END) AS categories,
            data_entry_order,
            count(data_entry_order) as id_data_entry
			FROM bfmban_data
			group by categories, data_entry_order
            )
            
#Selecting the CTE to categorize based on whole food product and other brands 
SELECT 
    prod_categ.categories,
	#using sum function so that it collects the number of data points that fits the requirements
    SUM(CASE WHEN brand LIKE ('%whole%') 
			OR brand LIKE ('%365%') 	
			THEN '1'
            ELSE '0'
            END) as whole_foods_brands,
	sum(CASE WHEN brand not LIKE ('%whole%') 
			AND brand not LIKE ('%365%') 	
			THEN '1'
            ELSE '0'
            END) as other_brands,
	#finding the % of whole_foods_brands from total 
		#keeping in mind that aggregate functions does not work with alias, so rewriting the formula to get the % in 2 decimal places
    ROUND(((SUM(CASE WHEN brand LIKE ('%whole%') OR brand LIKE ('%365%') 	THEN '1' ELSE '0' END))/((SUM(CASE WHEN brand LIKE ('%whole%') OR brand LIKE ('%365%') THEN '1' ELSE '0' END))+ 
			(sum(CASE WHEN brand not LIKE ('%whole%') AND brand not LIKE ('%365%') THEN '1'ELSE '0'
            END)))*100.0),2) as '% of whole_foods_brands',
	#Percentage of non whole foods brands products by each category
    Round(100.0- (ROUND(((SUM(CASE WHEN brand LIKE ('%whole%') OR brand LIKE ('%365%') 	THEN '1' ELSE '0' END))/((SUM(CASE WHEN brand LIKE ('%whole%') OR brand LIKE ('%365%') THEN '1' ELSE '0' END))+ 
			(sum(CASE WHEN brand not LIKE ('%whole%') AND brand not LIKE ('%365%') THEN '1' ELSE '0'
			END)))*100.0),2)),2) as '% of other_brands'
    from bfmban_data as d
#inner joining the CTE with the main data set
INNER JOIN prod_categ
	ON prod_categ.data_entry_order = d.data_entry_order
GROUP BY prod_categ.categories
#ordering in alphabetical order similarly to excel
order by prod_categ.categories

#This results provides the % of WF brands compared to other brands in each category, providing that it is underrepresented.
    ;
    
-- Actional Insight 1-- 

#Selecting the databse
USE bos_fmban_sql_analysis;

#Creating CTE for normalizing product categories
	#Keeping in mind this is usually because the data has mistakes
WITH prod_categ AS (
SELECT
    (CASE
			WHEN category LIKE ('%beauty%') THEN 'Beauty'
            WHEN category LIKE ('%beverage%') THEN 'Beverages'
            WHEN category LIKE ('%body%') THEN 'Body Care'
            WHEN category LIKE ('%Bakery%') THEN 'Bread, Rolls & Bakery'
            WHEN category LIKE ('%Dairy%') THEN 'Dairy and Eggs'
            WHEN category LIKE ('%Dessert%') THEN 'Desserts'
            WHEN category LIKE ('%Floral%') THEN 'Floral'
            WHEN category LIKE ('%Frozen%') THEN 'Frozen Foods'
			WHEN category LIKE ('%lifestyle%') THEN 'Lifestyle'
            WHEN category LIKE ('%meat%') THEN 'Meat'
            WHEN category LIKE ('%Pantry%') THEN 'Pantry Essentials'
            WHEN category LIKE ('%prepared%') THEN 'Prepared Foods'
            WHEN category LIKE ('%produce%') THEN 'Produce'
            WHEN category LIKE ('%seafood%') THEN 'seafood'
            WHEN category LIKE ('%snacks%') THEN 'Snacks, Chips, Salsa & Dips'
            WHEN category LIKE ('%supplements%') THEN 'Supplements'
            WHEN category LIKE ('%wine%') THEN 'Wine, Beer & Spirits'
            ELSE '!!!'
            END) AS categories,
            data_entry_order,
            count(data_entry_order) as id_data_entry
			FROM bfmban_data
			group by categories, data_entry_order
            )

SELECT 
    d.subcategory,
    d.name_of_product,
    #Query that distinguish between WF and other brands
    (CASE WHEN brand LIKE ('%whole%') 
			OR brand LIKE ('%365%') 
			THEN 'In-House Brand'
			ELSE 'Other_Brands'
		END) AS brand,
	d.regular_price,
    d.sale_price,
    #Calculating the difference in 2 decimal places
    ROUND(sum(d.regular_price-d.sale_price),2) as diff_price
FROM bfmban_data as d
INNER JOIN prod_categ
	ON prod_categ.data_entry_order = d.data_entry_order
#Selecting only the category with snacks and using the %snacks% to ensure that the data is there for word variations
Where prod_categ.categories LIKE ('%snacks%')
GROUP BY d.subcategory, brand, d.name_of_product,d.regular_price, d.sale_price
#ordering to see the highest sale products
ORDER by diff_price DESC
limit 15;
#There is no whole foods brands sale prices in "snacks, chips" category, but other brands does it. Good opportunity to explore.

-- Actionable Insight 2 -- 

#Calculating proportion of vegan products in snacks category

#Selecting the databse
USE bos_fmban_sql_analysis;

#Creating CTE for normalizing product categories
	#Keeping in mind this is usually because the data has mistakes
WITH prod_categ AS (
SELECT
    (CASE
			WHEN category LIKE ('%beauty%') THEN 'Beauty'
            WHEN category LIKE ('%beverage%') THEN 'Beverages'
            WHEN category LIKE ('%body%') THEN 'Body Care'
            WHEN category LIKE ('%Bakery%') THEN 'Bread, Rolls & Bakery'
            WHEN category LIKE ('%Dairy%') THEN 'Dairy and Eggs'
            WHEN category LIKE ('%Dessert%') THEN 'Desserts'
            WHEN category LIKE ('%Floral%') THEN 'Floral'
            WHEN category LIKE ('%Frozen%') THEN 'Frozen Foods'
			WHEN category LIKE ('%lifestyle%') THEN 'Lifestyle'
            WHEN category LIKE ('%meat%') THEN 'Meat'
            WHEN category LIKE ('%Pantry%') THEN 'Pantry Essentials'
            WHEN category LIKE ('%prepared%') THEN 'Prepared Foods'
            WHEN category LIKE ('%produce%') THEN 'Produce'
            WHEN category LIKE ('%seafood%') THEN 'seafood'
            WHEN category LIKE ('%snacks%') THEN 'Snacks, Chips, Salsa & Dips'
            WHEN category LIKE ('%supplements%') THEN 'Supplements'
            WHEN category LIKE ('%wine%') THEN 'Wine, Beer & Spirits'
            ELSE '!!!'
            END) AS categories,
            data_entry_order,
            count(data_entry_order) as id_data_entry
			FROM bfmban_data
			group by categories, data_entry_order
            )

SELECT 
   d.subcategory,
   #Subquery to filter only for vegan products in the snacks category
   (SELECT
		count(data_entry_order)
               FROM bfmban_data 
               WHERE vegan= '1' 
               AND category LIKE ('%snacks%')) 
               AS number_vegan_options_for_snacks_category,
    SUM(CASE WHEN brand LIKE ('%whole%') 
			OR brand LIKE ('%365%') 	
			THEN '1'
            ELSE '0'
            END) as whole_foods_brands,
	sum(CASE WHEN brand not LIKE ('%whole%') 
			AND brand not LIKE ('%365%') 	
			THEN '1'
            ELSE '0'
            END) as other_brands,
	#Calculating the % of Whole foods brands vs total by 2 decimals 
    ROUND(((SUM(CASE WHEN brand LIKE ('%whole%') OR brand LIKE ('%365%') 	THEN '1' ELSE '0' END))/((SUM(CASE WHEN brand LIKE ('%whole%') OR brand LIKE ('%365%') THEN '1' ELSE '0' END))+ 
			(sum(CASE WHEN brand not LIKE ('%whole%') AND brand not LIKE ('%365%') THEN '1'ELSE '0'
            END)))*100.0),2) as '% of whole_foods_brands'
FROM bfmban_data as d
INNER JOIN prod_categ
	ON prod_categ.data_entry_order = d.data_entry_order
WHERE prod_categ.categories LIKE ('%snacks%')
GROUP BY d.subcategory
order by (ROUND(((SUM(CASE WHEN brand LIKE ('%whole%') OR brand LIKE ('%365%') 	THEN '1' ELSE '0' END))/((SUM(CASE WHEN brand LIKE ('%whole%') OR brand LIKE ('%365%') THEN '1' ELSE '0' END))+ 
			(sum(CASE WHEN brand not LIKE ('%whole%') AND brand not LIKE ('%365%') THEN '1'ELSE '0'
            END)))*100.0),2))
            ;

#Opportunity to invest in vegan products for snacks category
	