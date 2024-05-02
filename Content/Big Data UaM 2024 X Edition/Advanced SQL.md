I'll link to Microsoft SQL Server, as this is the one I'm working with, but many databases share some concepts so they should be possible to apply in other SQL technologies too.

# Operations order
- [Logical Processing Order of the SELECT statement](https://learn.microsoft.com/en-us/sql/t-sql/queries/select-transact-sql?view=sql-server-ver16#logical-processing-order-of-the-select-statement)
Specific parts of the basic SQL query are executed in order as below, more detailed in link above.

| Operation   | Order |
| ----------- | ----- |
| SELECT      | 5     |
| FROM / JOIN | 1     |
| WHERE       | 2     |
| GROUP BY    | 3     |
| HAVING      | 4     |
| ORDER  BY   | 6     |
Due to this for example you can't use column aliases from select in group by / having because those actions are executed **before** aliases are defined.

# Set operators
I've many times used **UNION ALL**, but had no idea there are other operators which work on sets.
* [EXCEPT & INTERSECT](https://learn.microsoft.com/en-us/sql/t-sql/language-elements/set-operators-except-and-intersect-transact-sql?view=sql-server-ver16)
* [UNION & UNION ALL](https://learn.microsoft.com/en-us/sql/t-sql/language-elements/set-operators-union-transact-sql?view=sql-server-ver16)
## UNION / UNION ALL

UNION ALL works like appending rows from second select to the first one, resulting in single table with all the rows.
```sql
SELECT 1 As ID, 'Bob' As Name
UNION ALL
SELECT 2 As ID, 'Claire' As Name
UNION ALL
SELECT 1 As ID, 'Bob' As Name
```

| ID  | Name   |
| --- | ------ |
| 1   | Bob    |
| 2   | Claire |
| 1   | Bob    |
UNION without ALL works similar, but it removes duplicates after the operation so there will be only one record for Bob.

```sql
SELECT 1 As ID, 'Bob' As Name
UNION
SELECT 2 As ID, 'Claire' As Name
UNION
SELECT 1 As ID, 'Bob' As Name
```

| ID  | Name   |
| --- | ------ |
| 1   | Bob    |
| 2   | Claire |
## INTERSECT
INTERSECT will pick rows which exist in both datasets - first, and next query. In example below - Deborah will be missing, as it doesn't intersect.
```sql
WITH first_query (id, name) AS (
    SELECT 1 As ID, 'Bob' As Name
    UNION ALL
    SELECT 2 As ID, 'Claire' As Name
), second_query (id, name) AS (
    SELECT 1 As ID, 'Bob' As Name
    UNION ALL
    SELECT 2 As ID, 'Claire' As Name
    UNION ALL
    SELECT 3 As ID, 'Deborah' As Name
)
  
SELECT * FROM first_query
INTERSECT
SELECT * FROM second_query
```

| ID  | Name   |
| --- | ------ |
| 1   | Bob    |
| 2   | Claire |
## MINUS / EXCEPT
EXCEPT is opposite of [[#INTERSECT]] instead of picking those existing in both sets we are removing from first set values existing in second set - order does matter here.
```sql
WITH first_query (id, name) AS (
    SELECT 1 As ID, 'Bob' As Name
    UNION ALL
    SELECT 2 As ID, 'Claire' As Name
), second_query (id, name) AS (
    SELECT 1 As ID, 'Bob' As Name
    UNION ALL
    SELECT 2 As ID, 'Claire' As Name
    UNION ALL
    SELECT 3 As ID, 'Deborah' As Name

)

SELECT * FROM second_query
EXCEPT
SELECT * FROM first_query
```

| ID  | Name    |
| --- | ------- |
| 3   | Deborah |

```sql
SELECT * FROM first_query
EXCEPT
SELECT * FROM second_query
```
Will return 0 rows.
# Grouping
- [ROLLUP](https://learn.microsoft.com/en-us/sql/t-sql/queries/select-group-by-transact-sql?view=sql-server-ver16#group-by-rollup)
- [CUBE](https://learn.microsoft.com/en-us/sql/t-sql/queries/select-group-by-transact-sql?view=sql-server-ver16#group-by-cube--)
- [GROUPING SETS](https://learn.microsoft.com/en-us/sql/t-sql/queries/select-group-by-transact-sql?view=sql-server-ver16#group-by-grouping-sets--)
## Rollup
This is an extension of group by - additionally to aggregated values for specified level, there will be calculated values that summarises on previous scopes.

```sql
WITH example_sales (region, country, salesman, sale_value) AS (
    SELECT 'Europe', 'Poland', 'Katarzyna Nowak', 980 UNION ALL
    SELECT 'Europe', 'Romania', 'István Kovács', 1350 UNION ALL
    SELECT 'Europe', 'Romania', 'Andrei Popescu', 1100 UNION ALL
    SELECT 'North America', 'United States', 'John Smith', 2200 UNION ALL
    SELECT 'North America', 'Canada', 'Emily Johnson', 1800 UNION ALL
    SELECT 'North America', 'Canada', 'Michael Brown', 1750 UNION ALL
    SELECT 'North America', 'United States', 'Jessica Williams', 2050 UNION ALL
    SELECT 'Asia', 'China', 'Li Wei', 2500 UNION ALL
    SELECT 'Asia', 'Japan', 'Yuki Tanaka', 2100 UNION ALL
    SELECT 'Asia', 'China', 'Wei Chen', 2300
)

SELECT
    region,
    country,
    SUM(sale_value)
FROM
    example_sales
GROUP BY ROLLUP
    (region, country)
```

This will aggregate on 3 levels:
* Region + Country
* Region
* Total

| region            | country       | sales     | level  |
| ----------------- | ------------- | --------- | ------ |
| Asia              | China         | 4800      |        |
| Asia              | Japan         | 2100      |        |
| **Asia**          | **NULL**      | **6900**  | Region |
| Europe            | Poland        | 980       |        |
| Europe            | Romania       | 2450      |        |
| **Europe**        | **NULL**      | **3430**  | Region |
| North America     | Canada        | 3550      |        |
| North America     | United States | 4250      |        |
| **North America** | **NULL**      | **7800**  | Region |
| **NULL**          | **NULL**      | **18130** | Total  |

## Cube
Cube works similarly to [[#Rollup]], although it will produce all combinantions of specified aggregation columns. Just by changing ROLLUP to CUBE in query above it will produce those aggregation levels:
- Region + Country
- Region
- Country
- Total
```sql
WITH example_sales (region, country, salesman, sale_value) AS (
    SELECT 'Europe', 'Poland', 'Katarzyna Nowak', 980 UNION ALL
    SELECT 'Europe', 'Romania', 'István Kovács', 1350 UNION ALL
    SELECT 'Europe', 'Romania', 'Andrei Popescu', 1100 UNION ALL
    SELECT 'North America', 'United States', 'John Smith', 2200 UNION ALL
    SELECT 'North America', 'Canada', 'Emily Johnson', 1800 UNION ALL
    SELECT 'North America', 'Canada', 'Michael Brown', 1750 UNION ALL
    SELECT 'North America', 'United States', 'Jessica Williams', 2050 UNION ALL
    SELECT 'Asia', 'China', 'Li Wei', 2500 UNION ALL
    SELECT 'Asia', 'Japan', 'Yuki Tanaka', 2100 UNION ALL
    SELECT 'Asia', 'China', 'Wei Chen', 2300
)
  
SELECT
    region,
    country,
    SUM(sale_value)
FROM
    example_sales
GROUP BY CUBE
    (region, country)
```

| region        | country       | sales | level   |
| ------------- | ------------- | ----- | ------- |
| North America | Canada        | 3550  |         |
| NULL          | Canada        | 3550  | Country |
| Asia          | China         | 4800  |         |
| NULL          | China         | 4800  | Country |
| Asia          | Japan         | 2100  |         |
| NULL          | Japan         | 2100  | Country |
| Europe        | Poland        | 980   |         |
| NULL          | Poland        | 980   | Country |
| Europe        | Romania       | 2450  |         |
| NULL          | Romania       | 2450  | Country |
| North America | United States | 4250  |         |
| NULL          | United States | 4250  | Country |
| NULL          | NULL          | 18130 | Total   |
| Asia          | NULL          | 6900  | Region  |
| Europe        | NULL          | 3430  | Region  |
| North America | NULL          | 7800  | Region  |

## Grouping Sets
Grouping sets on the opposite to [[#Cube]], but it will produce only aggregations specified by you. With [[#Rollup]], and [[#Cube]] additional aggregations are generated automatically, you don't have to specify totals aggregation, and region level aggregation - with Grouping Sets only specified levels are produced. To achieve same result as in Rollup you would need query like this:

```sql
WITH example_sales (region, country, salesman, sale_value) AS (
    SELECT 'Europe', 'Poland', 'Katarzyna Nowak', 980 UNION ALL
    SELECT 'Europe', 'Romania', 'István Kovács', 1350 UNION ALL
    SELECT 'Europe', 'Romania', 'Andrei Popescu', 1100 UNION ALL
    SELECT 'North America', 'United States', 'John Smith', 2200 UNION ALL
    SELECT 'North America', 'Canada', 'Emily Johnson', 1800 UNION ALL
    SELECT 'North America', 'Canada', 'Michael Brown', 1750 UNION ALL
    SELECT 'North America', 'United States', 'Jessica Williams', 2050 UNION ALL
    SELECT 'Asia', 'China', 'Li Wei', 2500 UNION ALL
    SELECT 'Asia', 'Japan', 'Yuki Tanaka', 2100 UNION ALL
    SELECT 'Asia', 'China', 'Wei Chen', 2300
)

SELECT
    region,
    country,
    SUM(sale_value)
FROM
    example_sales
GROUP BY GROUPING SETS (
    (region, country),
    (region),
    ()
)
```

##  Grouping  & Grouping_Id

These are  built in functions which are aiming to improve use cases for Rollup, Cube and Grouping Sets, they return information if specified row is being aggregated and on which level. 
In my opinion Grouping isn't most readable, at least in example below.

```sql
WITH example_sales (region, country, salesman, sale_value) AS (
    SELECT 'Europe', 'Poland', 'Katarzyna Nowak', 980 UNION ALL
    SELECT 'Europe', 'Romania', 'István Kovács', 1350 UNION ALL
    SELECT 'Europe', 'Romania', 'Andrei Popescu', 1100 UNION ALL
    SELECT 'North America', 'United States', 'John Smith', 2200 UNION ALL
    SELECT 'North America', 'Canada', 'Emily Johnson', 1800 UNION ALL
    SELECT 'North America', 'Canada', 'Michael Brown', 1750 UNION ALL
    SELECT 'North America', 'United States', 'Jessica Williams', 2050 UNION ALL
    SELECT 'Asia', 'China', 'Li Wei', 2500 UNION ALL
    SELECT 'Asia', 'Japan', 'Yuki Tanaka', 2100 UNION ALL
    SELECT 'Asia', 'China', 'Wei Chen', 2300
)

SELECT
    region,
    country,
    SUM(sale_value) As sales,
    GROUPING(region) As is_region_group,
    GROUPING(country) As is_country_group,
    GROUPING_ID(region, country) As region_group_id,
    CASE GROUPING_ID(region, country)
        WHEN 1 THEN 'Region'
        WHEN 2 THEN 'Country'
        WHEN 3 THEN 'Total'
        ELSE 'Region & Country'
    END As region_group_name
FROM
    example_sales
GROUP BY GROUPING SETS (
    (region, country),
    (region),
    (country),
    ()
)
```

| region        | country       | sales | is_region_group | is_country_group | region_group_id | region_group_name    |
| ------------- | ------------- | ----- | --------------- | ---------------- | --------------- | -------------------- |
| North America | Canada        | 3550  | 0               | 0                | 0               | Region &amp; Country |
| NULL          | Canada        | 3550  | 1               | 0                | 2               | Country              |
| Asia          | China         | 4800  | 0               | 0                | 0               | Region &amp; Country |
| NULL          | China         | 4800  | 1               | 0                | 2               | Country              |
| Asia          | Japan         | 2100  | 0               | 0                | 0               | Region &amp; Country |
| NULL          | Japan         | 2100  | 1               | 0                | 2               | Country              |
| Europe        | Poland        | 980   | 0               | 0                | 0               | Region &amp; Country |
| NULL          | Poland        | 980   | 1               | 0                | 2               | Country              |
| Europe        | Romania       | 2450  | 0               | 0                | 0               | Region &amp; Country |
| NULL          | Romania       | 2450  | 1               | 0                | 2               | Country              |
| North America | United States | 4250  | 0               | 0                | 0               | Region &amp; Country |
| NULL          | United States | 4250  | 1               | 0                | 2               | Country              |
| NULL          | NULL          | 18130 | 1               | 1                | 3               | Total                |
| Asia          | NULL          | 6900  | 0               | 1                | 1               | Region               |
| Europe        | NULL          | 3430  | 0               | 1                | 1               | Region               |
| North America | NULL          | 7800  | 0               | 1                | 1               | Region               |

# Query plans

# Indexes

# CTE
[Common Table Expressions](https://learn.microsoft.com/en-us/sql/t-sql/queries/with-common-table-expression-transact-sql?view=sql-server-ver16) are there mainly to increase readability of queries for example with splitting up large selects into smaller parts. You can declare **multiple** of CTE's in a single query separating them with a comma (it's used  in [[#Recursion]] example below). You can also use INSERT/UPDATE/DELETE inside a CTE.

```sql
-- A cool example for CTE is for sure example data - you can prepare something like this, and just query it like a table using the name
WITH company_data (employee_id, name, manager_id, job_title) AS (
    SELECT 1, 'Alice', NULL, 'CEO' UNION ALL
    SELECT 2, 'Bob', 1, 'VP of Operations' UNION ALL
    SELECT 3, 'Carla', 1, 'VP of Marketing' UNION ALL
    SELECT 4, 'David', 2, 'Operations Manager' UNION ALL
    SELECT 5, 'Emily', 2, 'Marketing Manager' UNION ALL
    SELECT 6, 'Frank', 4, 'Operations Analyst'
)

SELECT * FROM company_data
```

## Recursion
Another use case for CTE is recursion, which might be helpful to retrieve data in a [[Tree]] structure. Example below. This query selects CEO, and unions it with all subordinates of that CEO, then for each subordinate it looks for next ones until there won't be subordinates.

```sql
WITH company_data (employee_id, name, manager_id, job_title) AS (
    SELECT 1, 'Alice', NULL, 'CEO' UNION ALL
    SELECT 2, 'Bob', 1, 'VP of Operations' UNION ALL
    SELECT 3, 'Carla', 1, 'VP of Marketing' UNION ALL
    SELECT 4, 'David', 2, 'Operations Manager' UNION ALL
    SELECT 5, 'Emily', 2, 'Marketing Manager' UNION ALL
    SELECT 6, 'Frank', 4, 'Operations Analyst'
), org_chart AS (
    SELECT
        employee_id,
        name,
        manager_id,
        job_title,
        1 AS level,
        CAST(NULL AS NVARCHAR(50)) AS manager_name
    FROM
        company_data
    WHERE
        manager_id IS NULL

    UNION ALL

    SELECT
        e.employee_id,
        e.name,
        e.manager_id,
        e.job_title,
        oc.level + 1,
        CAST(oc.name AS NVARCHAR(50)) AS manager_name
    FROM
        company_data e
    JOIN
        org_chart oc ON e.manager_id = oc.employee_id
)

SELECT * FROM org_chart
ORDER BY level, name;
```
# Analytical functions

## PARTITION OVER

## LEAD

## LAG





# User Defined Functions & Stored Procedures

# Apply

# Transactions

# Triggers