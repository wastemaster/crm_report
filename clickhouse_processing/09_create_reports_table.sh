# drop lead_report table
docker run -it --rm --link clickhouse_1:clickhouse-server \
             yandex/clickhouse-client \
             --host clickhouse-server \
             --query "DROP TABLE IF EXISTS crm_report.lead_report"

# create lead_report table
docker run -it --rm --link clickhouse_1:clickhouse-server \
             yandex/clickhouse-client \
             --host clickhouse-server \
             --query "
CREATE TABLE crm_report.lead_report (
  date Date,
  d_utm_source FixedString(42),
  d_club FixedString(11),
  d_manager FixedString(11),
  lead_count Int16 comment 'количество заявок',
  unqualified_lead_count Int16 comment 'количество мусорных заявок (на основании заявки не создан клиент)',
  new_lead_count Int16 comment 'количество новых заявок (не было заявок и покупок от этого клиента раньше)',
  buyer_count Int16 comment 'количество покупателей (кто купил в течение недели после заявки)',
  new_buyer_count Int16 comment 'количество новых покупателей (кто купил в течение недели после заявки, и не покупал раньше)',
  new_buyer_income Int32 comment 'доход от покупок новых покупателей'
) ENGINE = MergeTree()
ORDER BY date"

# fill in metrics
docker run -it --rm --link clickhouse_1:clickhouse-server \
             yandex/clickhouse-client \
             --host clickhouse-server \
             --query "
INSERT INTO crm_report.lead_report
  (date, d_utm_source, d_club, d_manager, lead_count, unqualified_lead_count, new_lead_count)
SELECT
   d.date,
   d.d_utm_source,
   d.d_club,
   d.d_manager,
   l.lead_count,
   ul.unqualified_lead_count,
   nl.new_lead_count
FROM crm_report.dimensions as d
LEFT JOIN crm_report.lead_counts as l
ON (d.date=l.date)
AND (d.d_utm_source=l.d_utm_source)
AND (d.d_club=l.d_club)
AND (d.d_manager=l.d_manager)

LEFT JOIN crm_report.unqualified_lead_counts as ul
ON (d.date=ul.date)
AND (d.d_utm_source=ul.d_utm_source)
AND (d.d_club=ul.d_club)
AND (d.d_manager=ul.d_manager)

LEFT JOIN crm_report.new_lead_counts as nl
ON (d.date=nl.date)
AND (d.d_utm_source=nl.d_utm_source)
AND (d.d_club=nl.d_club)
AND (d.d_manager=nl.d_manager)
"
