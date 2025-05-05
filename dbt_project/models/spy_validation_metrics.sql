WITH transformed_data AS (
    SELECT * FROM {{ ref('spy_transformed') }}
),
validation_metrics AS (
    SELECT
        COUNT(*) AS row_count,
        AVG(daily_return_pct) AS mean_daily_return_pct,
        STDDEV(daily_return_pct) AS stddev_daily_return_pct,
        COUNT(CASE WHEN volatility_flag THEN 1 END) AS volatility_day_count,
        MAX(drawdown_pct) AS max_drawdown,
        MAX(date) AS latest_date
    FROM transformed_data
)

SELECT * FROM validation_metrics