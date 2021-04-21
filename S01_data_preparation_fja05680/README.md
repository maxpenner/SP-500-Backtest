## Step 1

We have to create two files:
- **fja_unique_tickers**: A list of all tickers ever listed in the index.
- **fja_dates_unique_tickers_presence.mat**: Large matrix showing which unique ticker was listed on which date.

We are using [fja05680/sp500](https://github.com/fja05680/sp500).

1) Download and extract [fja05680/sp500](https://github.com/fja05680/sp500).
2) Open *sp500_changes_since_2019.csv* and manually complete list of changes. Information can taken from [Wikipedia: List of S&P 500 companies](https://en.wikipedia.org/wiki/List_of_S%26P_500_companies).
3) Run *sp500.ipynb*. File *sp500.csv* will be updated.
4) Run *sp500_historical.ipynb*. Make sure list of differences is empty. A new list *S&P 500 Historical Components & Changes(XX-XX-20XX).csv* is created.
5) OPTIONAL: Open *S&P 500 Historical Components & Changes(XX-XX-20XX).csv* and copy last line. Replace the date with today's date.
6) Go to main.m and replace the path in the function readtable(). It has to point to the file *S&P 500 Historical Components & Changes(XX-XX-20XX).csv*.
