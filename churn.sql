with months as(
SELECT 
  '2017-01-01' as first_day,
  '2017-01-31' as last_day
UNION
SELECT 
  '2017-02-01' as first_day,
  '2017-02-28' as last_day  
UNION
SELECT 
  '2017-03-01' as first_day,
  '2017-03-31' as last_day
),
joined as(
select * from subscriptions
cross join months
),
status as(
SELECT id, segment, first_day, 
CASE
  WHEN subscription_start < first_day
  AND (subscription_end >= first_day OR subscription_end IS NULL) THEN 1
  ELSE 0
  END AS is_active,
  CASE
  WHEN subscription_end BETWEEN first_day AND last_day THEN 1
  ELSE 0
  END AS is_cancelled 
FROM joined
)
SELECT segment, first_day, 1.0*SUM(is_cancelled)/SUM(is_active) as mon 
FROM status
GROUP BY first_day, segment;

