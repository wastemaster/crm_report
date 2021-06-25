# drop managers table
docker run -it --rm --link clickhouse_1:clickhouse-server \
             yandex/clickhouse-client \
             --host clickhouse-server \
             --query "DROP TABLE IF EXISTS crm_report.managers"

# create managers table
docker run -it --rm --link clickhouse_1:clickhouse-server \
             yandex/clickhouse-client \
             --host clickhouse-server \
             --query "
CREATE TABLE crm_report.managers (
  manager_id UUID,
  d_manager FixedString(11),
  d_club FixedString(11)
) ENGINE = MergeTree()
ORDER BY manager_id"

cat csv_input_data/managers.csv | docker run -i --rm \
   --link clickhouse_1:clickhouse-server \
   yandex/clickhouse-client \
   --host clickhouse-server \
  --query="INSERT INTO crm_report.managers FORMAT CSV"
