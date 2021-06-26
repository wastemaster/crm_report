from clickhouse_driver import Client


click_url = 'http://localhost:9000/crm_report'
client = Client.from_url(click_url)


def calculate_m1(date, d_utm_source, d_club, d_manager):
    return client.execute("""
SELECT
    COUNT(l.lead_id) as lead_count,
    l.d_utm_source,
    m.d_manager
FROM leads as l
LEFT JOIN managers as m
ON (l.l_manager_id = m.manager_id)

WHERE date(l.created_at) = date(%(date))
AND l.d_utm_source = %(utm_source)
AND m.d_manager = %(d_manager)

GROUP BY
    l.d_utm_source,
    m.d_manager
LIMIT 10""", {})

for item in client.execute('SELECT * FROM crm_report.dimensions limit 10'):
    date, d_utm_source, d_club, d_manager = item
    data = calculate_m1(date, d_utm_source, d_club, d_manager)
