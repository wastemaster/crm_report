from clickhouse_driver import Client
from utils import GoogleSheetService


click_url = 'http://localhost:9000/crm_report'
client = Client.from_url(click_url)

data = []
FIELDS = [
    "date",
    "d_utm_source",
    "d_club",
    "d_manager",
    "lead_count",
    "unqualified_lead_count",
    "new_lead_count",
    "buyer_count",
    "new_buyer_count",
    "new_buyer_income"
]
# add header row
data.append(FIELDS)
field_list = ','.join(FIELDS)
query = 'SELECT {} FROM crm_report.lead_report'.format(field_list)
for item in client.execute(query):
    line = list(item)
    line[0] = line[0].strftime('%Y-%m-%d')
    data.append(line)

# The spreadsheet to save to.
spreadsheet_id = '14fDZbjhGSCy6W6ph8-6nxpndWU2u0dZXNdaUJ0uYMM8'

# create google spreadsheet service
gs = GoogleSheetService(spreadsheet_id)
resp = gs.update_range('Sheet1!A:Z', data)
print(resp)
