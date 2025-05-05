WITH staged_data AS (
    SELECT * FROM {{ ref('spy_staging') }}
),
transformed_data AS (
    SELECT
        'SPY' AS symbol,
        date,
        close,
        COALESCE(((COALESCE(close - LAG(close, 1) OVER(ORDER BY date), 0)) * 100 / LAG(close, 1) OVER(ORDER BY date)), 0) AS daily_return_pct,
        --Due to days where trading is closed, for ~5.1k records over 20+ years, there are about 5 records per 7d for the index, so using as basis for calculation
        AVG(close) OVER (ORDER BY date ROWS BETWEEN 4 PRECEDING AND CURRENT ROW) AS "7d_ma",
        --Due to days where trading is closed, for ~5.1k records over 20+ years, there are about 20.6 records per 30d for the index, so using as basis for calculation
        AVG(close) OVER (ORDER BY date ROWS BETWEEN 20 PRECEDING AND CURRENT ROW) AS "30d_ma",
        --Due to days where trading is closed, for ~5.1k records over 20+ years, there are about 62 records per 90d for the index, so using as basis for calculation
        AVG(close) OVER (ORDER BY date ROWS between 61 PRECEDING AND CURRENT ROW) AS "90d_ma",
        COALESCE(STDDEV(close) OVER (ORDER BY date ROWS BETWEEN 20 PRECEDING AND CURRENT ROW), 0) AS "30d_volatility",
        (close - FIRST_VALUE(close) OVER (PARTITION BY date_trunc('month', date) ORDER BY date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)) * 100 / 
        (FIRST_VALUE(close) OVER (PARTITION BY date_trunc('month', date) ORDER BY date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)) AS month_to_date_return,
        --Due to days where trading is closed, for ~5.1k records over 20+ years, there are about 253 records per year for the index, so using as basis for calculation
        ROW_NUMBER() OVER (ORDER BY date) AS row_num,
        --When there are less records than an entire year, calculating change from beginning of records
        CAST(CASE WHEN row_num <= 252
            THEN (close - FIRST_VALUE(close) OVER (ORDER BY date)) * 100 / (FIRST_VALUE(close) OVER(ORDER BY date)) 
            ELSE (close - LAG(close, 252) OVER(ORDER BY date)) * 100 / (LAG(close, 252) OVER(ORDER BY date))
            END AS FLOAT) AS yearly_change_pct,
        CAST(CASE WHEN close = MAX(close) OVER (ORDER BY date ROWS BETWEEN 20 PRECEDING AND CURRENT ROW) 
            THEN 'TRUE' ELSE 'FALSE' END AS BOOLEAN) AS high_30d_flag,
        (MAX(close) OVER (ORDER BY date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) - close) * 100 / 
        (MAX(close) OVER (ORDER BY date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)) AS drawdown_pct,
        CAST(CASE WHEN daily_return_pct > 2 THEN 'TRUE' ELSE 'FALSE' END AS BOOLEAN) AS volatility_flag
    FROM staged_data
)

SELECT symbol, date, close, daily_return_pct, "7d_ma", "30d_ma", "90d_ma", "30d_volatility", month_to_date_return, 
yearly_change_pct, high_30d_flag, drawdown_pct, volatility_flag FROM transformed_data
ORDER BY date
