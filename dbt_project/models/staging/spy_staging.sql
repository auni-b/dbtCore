WITH source AS (
    SELECT * FROM dev.main.spy
),
staging_data AS (
    SELECT
        date_trunc('day', CAST(Date AS DATETIME))::date AS date,
        Close AS close
    FROM source
)

SELECT * FROM staging_data
