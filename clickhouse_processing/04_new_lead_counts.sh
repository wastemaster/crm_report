# drop new_lead_counts table
docker run -it --rm --link clickhouse_1:clickhouse-server \
             yandex/clickhouse-client \
             --host clickhouse-server \
             --query "DROP TABLE IF EXISTS crm_report.new_lead_counts"

# create new_lead_counts table
docker run -it --rm --link clickhouse_1:clickhouse-server \
             yandex/clickhouse-client \
             --host clickhouse-server \
             --query "
CREATE TABLE crm_report.new_lead_counts (
  date Date,
  d_utm_source FixedString(42),
  d_club FixedString(11),
  d_manager FixedString(11),
  new_lead_count Int16 comment 'количество новых заявок (не было заявок и покупок от этого клиента раньше)'
) ENGINE = MergeTree()
ORDER BY date"

# fill in lead counts metric
docker run -it --rm --link clickhouse_1:clickhouse-server \
             yandex/clickhouse-client \
             --host clickhouse-server \
             --query "
INSERT INTO crm_report.new_lead_counts
    (new_lead_count, d_utm_source, d_manager, d_club, date)
SELECT
    COUNT(l.lead_id) as new_lead_count,
    l.d_utm_source,
    m.d_manager,
    m.d_club,
    date(l.created_at) as date
FROM crm_report.leads as l
LEFT JOIN crm_report.managers as m
ON (l.l_manager_id = m.manager_id)
WHERE l.l_client_id != '00000000-0000-0000-0000-000000000000'
AND l.l_client_id IN (
    SELECT
        el.l_client_id
    FROM (
        SELECT
            DISTINCT(ld.l_client_id) as l_client_id,
            ld.created_at
        FROM crm_report.leads AS ld
        WHERE ld.l_client_id != '00000000-0000-0000-0000-000000000000'
        ORDER BY ld.created_at ASC
    ) AS el
    LEFT JOIN
        (SELECT
            DISTINCT(t.l_client_id) as l_client_id,
            t.created_at
        FROM crm_report.transactions AS t
        WHERE t.l_client_id != '00000000-0000-0000-0000-000000000000'
        AND t.m_real_amount > 0
        ORDER BY t.created_at ASC) as et
    ON (el.l_client_id = et.l_client_id)
    WHERE
        et.l_client_id != '00000000-0000-0000-0000-000000000000'
    AND
        el.created_at < et.created_at
    )
GROUP BY
    l.d_utm_source,
    m.d_manager,
    m.d_club,
    date"
