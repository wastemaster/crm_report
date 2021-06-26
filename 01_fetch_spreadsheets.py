from utils import GoogleSheetService


# The spreadsheet to request.
spreadsheet_id = '1Ycg7zTxds9DZnDvTrFcyNNKuTUxg6Yy6WF0a8Wc02WQ'

# create google spreadsheet service
gs = GoogleSheetService(spreadsheet_id)

# save spreadsheet data for each sheet as csv files
ranges = ['transactions!A:D', 'clients!A:C', 'managers!A:C', 'leads!A:F']
for range in ranges:
    gs.save_range(range)
