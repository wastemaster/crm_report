# drop buyer_counts table
docker run -it --rm --link clickhouse_1:clickhouse-server \
             yandex/clickhouse-client \
             --host clickhouse-server \
             --query "DROP TABLE IF EXISTS crm_report.buyer_counts"

# create buyer_counts table
docker run -it --rm --link clickhouse_1:clickhouse-server \
             yandex/clickhouse-client \
             --host clickhouse-server \
             --query "
CREATE TABLE crm_report.buyer_counts (
  date Date,
  d_utm_source FixedString(42),
  d_club FixedString(11),
  d_manager FixedString(11),
  buyer_count Int16 comment 'количество покупателей (кто купил в течение недели после заявки)'
) ENGINE = MergeTree()
ORDER BY date"

# fill in buyer_counts metric
docker run -it --rm --link clickhouse_1:clickhouse-server \
             yandex/clickhouse-client \
             --host clickhouse-server \
             --query "
INSERT INTO crm_report.buyer_counts
    (buyer_count, d_utm_source, d_manager, d_club, date)
SELECT
    COUNT(l.lead_id) as lead_count,
    l.d_utm_source,
    m.d_manager,
    m.d_club,
    date(t.created_at) as date
FROM crm_report.leads as l

LEFT JOIN crm_report.managers as m
ON (l.l_manager_id = m.manager_id)

INNER JOIN crm_report.transactions as t
ON (l.l_client_id = t.l_client_id)

WHERE l.created_at < t.created_at
AND datediff('day', l.created_at, t.created_at) <= 7
AND t.m_real_amount > 0

GROUP BY
    l.d_utm_source,
    m.d_manager,
    m.d_club,
    date"
