# drop clients table
docker run -it --rm --link clickhouse_1:clickhouse-server \
             yandex/clickhouse-client \
             --host clickhouse-server \
             --query "DROP TABLE IF EXISTS crm_report.clients"

# create clients table
docker run -it --rm --link clickhouse_1:clickhouse-server \
             yandex/clickhouse-client \
             --host clickhouse-server \
             --query "
CREATE TABLE IF NOT EXISTS crm_report.clients (
  client_id UUID,
  created_at Nullable(DateTime),
  l_manager_id Nullable(UUID)
) ENGINE = MergeTree()
ORDER BY client_id"

cat csv_input_data/clients.csv | docker run -i --rm \
   --link clickhouse_1:clickhouse-server \
   yandex/clickhouse-client \
   --host clickhouse-server \
  --query="INSERT INTO crm_report.clients FORMAT CSV"
