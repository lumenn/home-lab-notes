I'll link to Microsoft SQL Server, as this is the one I'm working with, but many databases share some concepts so they should be possible to apply in other SQL technologies too.

# Operations order
Specific parts of the SQL query are executed in order as below:

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

all the rows.
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

## Rollup

## Cube

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