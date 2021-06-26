# drop lead_counts table
docker run -it --rm --link clickhouse_1:clickhouse-server \
             yandex/clickhouse-client \
             --host clickhouse-server \
             --query "DROP TABLE IF EXISTS crm_report.lead_counts"

# create lead_counts table
docker run -it --rm --link clickhouse_1:clickhouse-server \
             yandex/clickhouse-client \
             --host clickhouse-server \
             --query "
CREATE TABLE crm_report.lead_counts (
  date Date,
  d_utm_source FixedString(42),
  d_club FixedString(11),
  d_manager FixedString(11),
  lead_count UInt32 comment 'количество заявок'
) ENGINE = MergeTree()
ORDER BY date"

# fill in lead counts metric
docker run -it --rm --link clickhouse_1:clickhouse-server \
             yandex/clickhouse-client \
             --host clickhouse-server \
             --query "
INSERT INTO crm_report.lead_counts
    (lead_count, d_utm_source, d_manager, d_club, date)
SELECT
    COUNT(l.lead_id) as lead_count,
    l.d_utm_source,
    m.d_manager,
    m.d_club,
    date(l.created_at) as date
FROM crm_report.leads as l
LEFT JOIN crm_report.managers as m
ON (l.l_manager_id = m.manager_id)
GROUP BY
    l.d_utm_source,
    m.d_manager,
    m.d_club,
    date"
