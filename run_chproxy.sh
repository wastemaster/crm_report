docker run -it -d --rm \
        -p 9090:9090 \
        --link clickhouse_1:clickhouse-server \
	-v ${PWD}/chproxy/config.yml:/opt/config.yml \
	tacyuuhon/clickhouse-chproxy
