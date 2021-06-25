docker run -d --restart=always --name clickhouse_1 \
   --ulimit nofile=262144:262144 \
   -p 127.0.0.1:8123:8123 -p 127.0.0.1:9000:9000 \
   -v ${PWD}/clickhouse/log:/var/log/clickhouse-server \
   -v ${PWD}/clickhouse/data:/var/lib/clickhouse \
   -v ${PWD}/clickhouse/etc/users.xml:/etc/clickhouse-server/users.xml \
   -v ${PWD}/clickhouse/etc/config.xml:/etc/clickhouse-server/config.xml \
   yandex/clickhouse-server
