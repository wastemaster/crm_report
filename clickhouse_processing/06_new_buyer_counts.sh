# drop new_buyer_counts table
docker run -it --rm --link clickhouse_1:clickhouse-server \
             yandex/clickhouse-client \
             --host clickhouse-server \
             --query "DROP TABLE IF EXISTS crm_report.new_buyer_counts"

# create new_buyer_counts table
docker run -it --rm --link clickhouse_1:clickhouse-server \
             yandex/clickhouse-client \
             --host clickhouse-server \
             --query "
CREATE TABLE crm_report.new_buyer_counts (
  date Date,
  d_utm_source FixedString(42),
  d_club FixedString(11),
  d_manager FixedString(11),
  new_buyer_count Int16 comment 'количество новых покупателей (кто купил в течение недели после заявки, и не покупал раньше)'
) ENGINE = MergeTree()
ORDER BY date"

# fill in buyer_counts metric
docker run -it --rm --link clickhouse_1:clickhouse-server \
             yandex/clickhouse-client \
             --host clickhouse-server \
             --query "
INSERT INTO crm_report.new_buyer_counts
    (new_buyer_count, d_utm_source, d_manager, d_club, date)
    SELECT
        COUNT(l.lead_id) as new_buyer_count,
        l.d_utm_source,
        m.d_manager,
        m.d_club,
        date(t.created_at) as date
    FROM crm_report.leads as l

    LEFT JOIN crm_report.managers as m
    ON (l.l_manager_id = m.manager_id)

    INNER JOIN crm_report.transactions as t
    ON (l.l_client_id = t.l_client_id)

    INNER JOIN (
        SELECT
            COUNT(t.transaction_id) as cnt,
            t.l_client_id
        FROM crm_report.transactions as t
        WHERE t.m_real_amount > 0
        GROUP BY t.l_client_id
        HAVING cnt = 1
    ) as tc
    ON (l.l_client_id = tc.l_client_id)

    WHERE l.created_at < t.created_at
    AND datediff('day', l.created_at, t.created_at) <= 7
    AND t.m_real_amount > 0

    GROUP BY
        l.d_utm_source,
        m.d_manager,
        m.d_club,
        date"
