# drop leads table
docker run -it --rm --link clickhouse_1:clickhouse-server \
             yandex/clickhouse-client \
             --host clickhouse-server \
             --query "DROP TABLE IF EXISTS crm_report.leads"

# create leads table
docker run -it --rm --link clickhouse_1:clickhouse-server \
            yandex/clickhouse-client \
            --host clickhouse-server \
            --query "
CREATE TABLE IF NOT EXISTS crm_report.leads (
 lead_id UUID,
 created_at DateTime,
 d_utm_medium FixedString(10),
 d_utm_source FixedString(42),
 l_manager_id UUID,
 l_client_id UUID
) ENGINE = MergeTree()
ORDER BY created_at"

# some dirty cleaning inside csv
sed -i 's/ycard#!\/tproduct\/225696739-1498486363994/ycard/g' csv_input_data/leads.csv

cat csv_input_data/leads.csv | docker run -i --rm \
   --link clickhouse_1:clickhouse-server \
   yandex/clickhouse-client \
   --host clickhouse-server \
  --query="INSERT INTO crm_report.leads FORMAT CSV"
