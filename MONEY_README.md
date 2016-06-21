hackbot money
------------
A hackbot script to help us check how much money we need.

## Credentials
If the json file on the EC2 instance becomes out of date, follow these steps to get a new one.
* Go to console.developers.google.com and create a project if you do not have one already for hackbot.
* Create a service account
* Enable the Google Drive API
* Download credentials as json.
* Get it onto the EC2 instance using scp or something.
* Invite the service account to the spreadsheet using the @developers.gserviceaccounts.com email

## hackbot config variables
There are some restrictions that this script assumes on where the values will be placed, you can try and refactor this if you want to be more permissive. It assumes also that the values are on the second sheet in the shared Google sheet.
* `money.row` - row that the values are expected to be in, 1-indexed. Both outstanding & received must be in the same row.
* `money.received.col` - column that the amount received is in, 1-indexed. Must be `money.outstanding.col` - 1.
* `money.outstanding.col` - column that the amount outstanding is in, 1-indexed. Must be `money.received.col` + 1.
