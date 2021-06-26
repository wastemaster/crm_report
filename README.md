Job description https://tomsk.hh.ru/vacancy/44904368?query=data%20analyst%5C

Test task https://docs.google.com/document/d/1OOgPhLCZgtEsqUt47nHAFqFmOvEEL949mwtB-hj8ODk/edit#

Dataset https://docs.google.com/spreadsheets/d/1Ycg7zTxds9DZnDvTrFcyNNKuTUxg6Yy6WF0a8Wc02WQ/edit#gid=0

Result report https://docs.google.com/spreadsheets/d/14fDZbjhGSCy6W6ph8-6nxpndWU2u0dZXNdaUJ0uYMM8/edit?usp=sharing

DataStudio report https://datastudio.google.com/reporting/92bcc7c9-04df-4833-8b8b-f7e52c26ae33

* учитываются только положительные транзакции (m_real_amount > 0)
* пустой d_utm_source заменяется на "not set"
* добавлен ноль перед идентификатором d_manager, "manager #9" -> "manager #09" (для более удобной сортировки)
* значение d_utm_source "ycard#!/tproduct/225696739-1498486363994" заменено на "ycard"

## Порядок установки

```
# Создаем окружение
conda create --name crm_report --file requirements.txt

# Активируем окружение
conda activate crm_report

# Загружаем исходные данные из google spreadsheet
python 01_fetch_spreadsheets.py

# Закускаем локальный clickhouse
bash 02_start_clickhouse.sh

# Заливаем данные в clickhouse
bash 03_run_clickhouse_import.sh

# Считаем метрики
bash 04_process_data.sh

# (опционально ) Запускаем chproxy (прокси для кликхауса)
bash 05_run_chproxy.sh

# Експортируем структурированные данные из clickhouse в google spreadsheet
python 06_export_data.py
```
