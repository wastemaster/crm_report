docker run -it --rm --link clickhouse_1:clickhouse-server \
             yandex/clickhouse-client --host clickhouse-server
