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
  lead_count UInt32 comment 'количество заявок',
  unqualified_lead_count UInt32 comment 'количество мусорных заявок (на основании заявки не создан клиент)',
  new_lead_count UInt32 comment 'количество новых заявок (не было заявок и покупок от этого клиента раньше)',
  buyer_count UInt32 comment 'количество покупателей (кто купил в течение недели после заявки)',
  new_buyer_count UInt32 comment 'количество новых покупателей (кто купил в течение недели после заявки, и не покупал раньше)',
  new_buyer_income UInt32 comment 'доход от покупок новых покупателей'
) ENGINE = MergeTree()
ORDER BY date"

# fill in metrics
docker run -it --rm --link clickhouse_1:clickhouse-server \
             yandex/clickhouse-client \
             --host clickhouse-server \
             --query "
INSERT INTO crm_report.lead_report
  (date,
  d_utm_source,
  d_club,
  d_manager,
  lead_count,
  unqualified_lead_count,
  new_lead_count,
  buyer_count,
  new_buyer_count,
  new_buyer_income)
SELECT
   d.date,
--   d.d_utm_source,
-- not set value instead of empty
   if(empty(d.d_utm_source), 'not set', d.d_utm_source) as d_utm_source,
   d.d_club,
--   d.d_manager,
-- adding leading zeros to managers
   arrayStringConcat([splitByChar('#', toString(d.d_manager))[1],
      if(toUInt8(splitByChar('#', toString(d.d_manager))[2]) < 10,
          concat('0', splitByChar('#', toString(d.d_manager))[2]),
          splitByChar('#', toString(d.d_manager))[2])], '#') as d_manager,
   l.lead_count,
   ul.unqualified_lead_count,
   nl.new_lead_count,
   b.buyer_count,
   nb.new_buyer_count,
   nbi.new_buyer_income
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

LEFT JOIN crm_report.buyer_counts as b
ON (d.date=b.date)
AND (d.d_utm_source=b.d_utm_source)
AND (d.d_club=b.d_club)
AND (d.d_manager=b.d_manager)

LEFT JOIN crm_report.new_buyer_counts as nb
ON (d.date=nb.date)
AND (d.d_utm_source=nb.d_utm_source)
AND (d.d_club=nb.d_club)
AND (d.d_manager=nb.d_manager)

LEFT JOIN crm_report.new_buyer_income as nbi
ON (d.date=nbi.date)
AND (d.d_utm_source=nbi.d_utm_source)
AND (d.d_club=nbi.d_club)
AND (d.d_manager=nbi.d_manager)
"
