# drop transactions table
docker run -it --rm --link clickhouse_1:clickhouse-server \
             yandex/clickhouse-client \
             --host clickhouse-server \
             --query "DROP TABLE IF EXISTS crm_report.transactions"

# create transactions table
docker run -it --rm --link clickhouse_1:clickhouse-server \
            yandex/clickhouse-client \
            --host clickhouse-server \
            --query "
CREATE TABLE IF NOT EXISTS crm_report.transactions (
 transaction_id UUID,
 created_at DateTime,
 m_real_amount Int32,
 l_client_id UUID
) ENGINE = MergeTree()
ORDER BY created_at"

cat csv_input_data/transactions.csv | docker run -i --rm \
   --link clickhouse_1:clickhouse-server \
   yandex/clickhouse-client \
   --host clickhouse-server \
  --query="INSERT INTO crm_report.transactions FORMAT CSV"
