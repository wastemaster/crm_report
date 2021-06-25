# drop dimensions table
docker run -it --rm --link clickhouse_1:clickhouse-server \
             yandex/clickhouse-client \
             --host clickhouse-server \
             --query "DROP TABLE IF EXISTS crm_report.dimensions"

# create dimensions table
docker run -it --rm --link clickhouse_1:clickhouse-server \
            yandex/clickhouse-client \
            --host clickhouse-server \
            --query "
CREATE table crm_report.dimensions
(
  date Date,
  d_utm_source FixedString(42),
  d_club FixedString(11),
  d_manager FixedString(11)
) ENGINE = MergeTree()
ORDER BY date"

# fill in dimensions table values
docker run -it --rm --link clickhouse_1:clickhouse-server \
            yandex/clickhouse-client \
            --host clickhouse-server \
            --query "
INSERT INTO crm_report.dimensions
(d_club, d_manager, d_utm_source, date)
SELECT
    distinct(c.d_club),
    d.d_manager,
    l.d_utm_source,
    dt.date
FROM crm_report.managers as c
CROSS JOIN
    (select distinct(d_manager) from crm_report.managers) as d
CROSS JOIN
    (select distinct(d_utm_source) from crm_report.leads) as l
CROSS JOIN
    (
    WITH (
        SELECT
        DATE(MAX(created_at))
        FROM crm_report.leads
    ) AS max_date,
    (
        SELECT
        DATE(MIN(created_at))
        FROM crm_report.leads
    ) AS min_date,
    (
        SELECT
        DATE(MAX(created_at)) - DATE(MIN(created_at))
        FROM crm_report.leads
    ) AS duration
    SELECT max_date - arrayJoin(range(toUInt16(duration+1))) as date
    ) as dt"
