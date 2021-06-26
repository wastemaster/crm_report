import os
import csv
import pandas as pd
from google.oauth2.credentials import Credentials
from google_auth_oauthlib.flow import InstalledAppFlow
from google.auth.transport.requests import Request
from googleapiclient import discovery


SCOPES = ['https://www.googleapis.com/auth/spreadsheets']
CVS_DIR = 'csv_input_data'


class GoogleSheetService():
    credentials = None
    service = None
    spreadsheet_id = None

    def __init__(self, spreadsheet_id):
        self.spreadsheet_id = spreadsheet_id
        self.credentials = self.get_credentials()
        self.service = self.get_service()

    def get_credentials(self):
        # spreadsheets authentication
        if os.path.exists('token.json'):
            self.credentials = Credentials.from_authorized_user_file(
                'token.json', SCOPES)
        # If there are no (valid) credentials available, let the user log in.
        if not self.credentials or not self.credentials.valid:
            if (self.credentials
                    and self.credentials.expired
                    and self.credentials.refresh_token):
                self.credentials.refresh(Request())
            else:
                flow = InstalledAppFlow.from_client_secrets_file(
                    'credentials.json', SCOPES)
                self.credentials = flow.run_local_server(port=0)
            # Save the credentials for the next run
            with open('token.json', 'w') as token:
                token.write(self.credentials.to_json())
        return self.credentials

    def get_service(self):
        return discovery.build(
            'sheets', 'v4', credentials=self.credentials)

    # functions that gets range data from google spreadsheets
    def get_range(self, range):
        request = self.service.spreadsheets().values().get(
            spreadsheetId=self.spreadsheet_id,
            range=range)
        response = request.execute()
        return response

    # function that saves range data in csv file
    def save_range(self, range):
        # get range data
        data = self.get_range(range)

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

    # functions that update range in google spreadsheet with data
    def update_range(self, range, data):
        value_input_option = 'USER_ENTERED'

        body = {
            "range": range,
            "majorDimension": 'ROWS',
            "values": data
        }
        
        request = self.service.spreadsheets().values().update(
            spreadsheetId=self.spreadsheet_id,
            range=range,
            valueInputOption=value_input_option,
            body=body)
        response = request.execute()
        return response
