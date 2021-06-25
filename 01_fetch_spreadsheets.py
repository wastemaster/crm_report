import os
import csv
import pandas as pd
from googleapiclient import discovery
from google_auth_oauthlib.flow import InstalledAppFlow
from google.oauth2.credentials import Credentials
from google.auth.transport.requests import Request


SCOPES = ['https://www.googleapis.com/auth/spreadsheets']
CVS_DIR = 'csv_input_data'
credentials = None

# spreadsheets authentication
if os.path.exists('token.json'):
    credentials = Credentials.from_authorized_user_file('token.json', SCOPES)
# If there are no (valid) credentials available, let the user log in.
if not credentials or not credentials.valid:
    if credentials and credentials.expired and credentials.refresh_token:
        credentials.refresh(Request())
    else:
        flow = InstalledAppFlow.from_client_secrets_file(
            'credentials.json', SCOPES)
        credentials = flow.run_local_server(port=0)
    # Save the credentials for the next run
    with open('token.json', 'w') as token:
        token.write(credentials.to_json())

service = discovery.build('sheets', 'v4', credentials=credentials)

# The spreadsheet to request.
spreadsheet_id = '1Ycg7zTxds9DZnDvTrFcyNNKuTUxg6Yy6WF0a8Wc02WQ'


# functions that gets range data from google spreadsheets
def get_range(range):
    request = service.spreadsheets().values().get(
        spreadsheetId=spreadsheet_id,
        range=range)
    response = request.execute()
    return response


# function that saves range data in csv file
def save_range(range):
    # get range data
    data = get_range(range)

    # generate filename from range name
    filename = '{}/{}.csv'.format(CVS_DIR, range.split('!')[0])

    # column names
    columns = data['values'][0]
    # actual database
    thedata = data['values'][1:]

    # create dataframe and export it as csv
    df = pd.DataFrame(thedata, columns=columns)
    df.to_csv(filename,
              index=False,
              quoting=csv.QUOTE_MINIMAL,
              header=False)


# save spreadsheet data for each sheet
ranges = ['transactions!A:D', 'clients!A:C', 'managers!A:C', 'leads!A:F']
for range in ranges:
    save_range(range)
