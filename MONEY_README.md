hackbot money
------------
A hackbot script to help us check how much money we need.

# How to update money for a new year

1. Make a Google spreadsheet with the $ amounts.

1. In #botspam, set `money.spreadsheet.url` to the hash in the Google spreadsheet URL -- it's the thing that goes in  `https://docs.google.com/spreadsheets/d/${money.spreadsheet.url}/`.

1. Put the *total $ received* and *total $ committed* in two colums in the spreadsheet. See [hackbot config variables](#hackbot-config-variables) for rules about placement so you can set `money.row`, `money.received.col`, and `money.outstanding.col`. You can also see what the previous settings were in #botspam for reference. Make sure that Google sheets doesn't append "$" to the column value ([fix here](http://www.solveyourtech.com/remove-dollar-sign-google-sheets/) if that happens).

1. In #botspam, set `money.spreadsheet.tabname` to the name of the tab in the Google spreadsheet where the cells are.

1. Invite our Google Service Account email to be able to view the sheet -- run `!serviceaccount` in #botspam to see the email.

1. Now, you should be able to run `hackbot money` or `hackbot $` and see the the numbers!


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
