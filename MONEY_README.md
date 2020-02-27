# hackbot money

A hackbot script to help us check how much money we need.

## Setting up the spreadsheet

First, make a new Google spreadsheet tracking money in whatever way you'd
like.

Next, make two cells in the same row, one with the **total $ received** and
one with the **total $ outstanding**. Hackbot money requires that they be in the
same row in two different columns, one after the other.

| ... | Total $ received | Total $ outstanding | ... |
| --- | --- | --- | --- |
| ... | 1000 | 99000 | ... |
| ... | ... | ... | ... |

Make sure that these cells display the amounts _without_ a dollar sign (e.g.
`1000`, not `$1000`). See [here][no-dollar] if you're not sure how to do this.

For hackbot to view the sheet, you need to invite our Google Service Account
email to be able to view the sheet. Run `!serviceaccount` in the HackMIT
Slack to see the email.

```bash
!serviceaccount
```

Finally, copy the Google Sheets URL hash -- the thing at
`https://docs.google.com/spreadsheets/d/${URL_HASH}/`.

## Connecting hackbot to the spreadsheet

Hackbot needs five configuration variables for the spreadsheet.

1. `money.spreadsheet.url`: the hash from the spreadsheet URL.

```bash
hackbot conf set money.spreadsheet.url "paste in the hash here"
```

5. `money.spreadsheet.tabname`: the name of the Google Sheets tab that
  contains the two cells.

```bash
hackbot conf set money.spreadsheet.tabname "Money"
```

2. `money.row`: the row you put the "total $ outstanding" and "total $
  received" cells in. The rows are 1-indexed.

```bash
hackbot conf set money.row "1"
```

3. `money.received.col`: the column you put the "total $ received" cell
  in. The columns are 1-indexed.

```bash
hackbot conf set money.received.col "1"
```

4. `money.outstanding.col`: the column you put the "total $ outstanding" cell
  in, directly to the right of the "total $ received" cell. The columns are
  1-indexed.

```bash
hackbot conf set money.outstanding.col "2"
```

You can also check what the previous settings were for reference.

```bash
> hackbot conf get money.spreadsheet.url
money.spreadsheet.url = "abc123"
> hackbot conf get money.spreadsheet.tabname
money.spreadsheet.tabname = "Companies"
> hackbot conf get money.row
money.row = "1"
> hackbot conf get money.received.col
money.received.col = "4"
> hackbot conf get money.outstanding.col
money.outstanding.col = "5"
```

This script is clearly very restrictive. You're welcome to refactor it to be
more permissive.

Once you've set these variables, run `hackbot money` or `hackbot $` to see
the the numbers!

```bash
> hackbot money
Received: $1K
Outstanding: $99K
Total: $100K
```

Hackbot money checks the money spreadsheet every 10 minutes and updates the
channel topic with new amounts if they've changed. It uses the
`money.channel` config variable to know which channel's topic to update.

```bash
> hackbot conf get money.channel
money.channel = "cr"
```

## Credentials

Hackbot money requires a Google service account to view the spreadsheet. The
credentials for this service account are in a file called
`hackmit-money-2015-credentials.json`.

If the json file on the EC2 instance becomes out of date, follow these steps
to get a new one.

* Go to console.developers.google.com and create a project if you do not have
  one already for hackbot.
* Create a service account
* Enable the Google Drive API
* Download credentials as json.
* Get it onto the EC2 instance using `scp` or something.
* Invite the service account to the spreadsheet using the
  @developers.gserviceaccounts.com email as mentioned above

[no-dollar]: http://www.solveyourtech.com/remove-dollar-sign-google-sheets/