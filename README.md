Job description https://tomsk.hh.ru/vacancy/44904368?query=data%20analyst%5C

Test task https://docs.google.com/document/d/1OOgPhLCZgtEsqUt47nHAFqFmOvEEL949mwtB-hj8ODk/edit#

Dataset https://docs.google.com/spreadsheets/d/1Ycg7zTxds9DZnDvTrFcyNNKuTUxg6Yy6WF0a8Wc02WQ/edit#gid=0

Result report https://docs.google.com/spreadsheets/d/14fDZbjhGSCy6W6ph8-6nxpndWU2u0dZXNdaUJ0uYMM8/edit?usp=sharing

DataStudio report https://datastudio.google.com/reporting/92bcc7c9-04df-4833-8b8b-f7e52c26ae33

## Cleaning steps

* Filtered out transactions with negative and zero amounts (m_real_amount <= 0)
* Empty d_utm_source set to "not set"
* Added leading zeros in d_manager, "manager #9" -> "manager #09" (for representation purposes)
* d_utm_source value "ycard#!/tproduct/225696739-1498486363994" replaced with "ycard"

## Setup steps

```
# Create and load environment
conda create --name crm_report --file requirements.txt

# Activate environment
conda activate crm_report

# Loading source data from google spreadsheets to local csv files
python 01_fetch_spreadsheets.py

# Starting clickhouse server in docker
bash 02_start_clickhouse.sh

# Importing data into clickhouse database
bash 03_run_clickhouse_import.sh

# Calculate all the metrics
bash 04_process_data.sh

# Starting chproxy for clickhouse (Optional step)
bash 05_run_chproxy.sh

# Export of structured data into google spreadsheet
python 06_export_data.py
```
