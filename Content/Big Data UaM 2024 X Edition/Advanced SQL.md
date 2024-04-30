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
# Grouping

## Rollup

## Cube

# Query plans

# Indexes

# CTE
[Common Table Expressions](https://learn.microsoft.com/en-us/sql/t-sql/queries/with-common-table-expression-transact-sql?view=sql-server-ver16) are there mainly to increase readability of queries for example with splitting up large selects into smaller parts. You can declare **multiple** of CTE's in a single query separating them with a comma.

```sql

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





# UDF / SP

# Apply

# Transactions

# Triggers