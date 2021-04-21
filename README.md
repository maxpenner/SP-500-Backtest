# SP-500-Backtest
Repo to backtest the S&amp;P 500 or any other index. Downloads data from public sources and tests momentum strategy. 

## Step 1 to 4
The entire repository consists of four individual steps that must be carried out one after the other. Detailed instructions can be found in the subfolders.

- **Step 1**: With the help of [fja05680/sp500](https://github.com/fja05680/sp500), we create a list of all tickers to ever be listed on the index and a matrix showing which of those unique tickers were listed on which date. As of now (April 21, 2021), there have been exactly 1108 different ticker symbols in the S&P 500 since the beginning of 1996.
- **Step 2**: We use the unique ticker symbols from step one and download daily data from [alphavantage](https://www.alphavantage.co/). Not all data can be downloaded, for example, data is missing for tickers that are no longer listed. Here is a chart with the number of tickers of the S&P 500 that are available.

<p align="center">
  <img src="https://user-images.githubusercontent.com/20499620/115525192-29308200-a28f-11eb-958b-7da55f376f96.png" width="500" class="center">
</p>

- **Step 3**: A matrix with all tickers over the entire time period from the beginning of 1996 until today is created. All prices (open, close etc.), dividends and splits are included.
- **Step 4**: We are testing a momentum strategy.

## Momentum Strategy

### Method

Always hold the ten (or any other number) best stocks.

### When do we buy or sell stocks?

The days when it is decided what to buy or sell are called *decision dates*. Between these days is the *decision period*. A *decision period* of 50 means that we rebalance our portfolio every 50 trading days.

For the decision on buying and selling we take the closing price of day x, on day x+1 we buy and sell for the opening price.

### What does 'best stocks' mean?

On each *decision date* we take the closing price and compare it to a closing price in the past. The period we go back for this is called the *comparison period*. A *comparison period* of 100 means that we compare the current price with the price from 100 trading days ago.

If a stock is one of the stocks with the highest percentage gain during this period, it is one of the best stocks. It is possible to buy only stocks from the top 10, but then hold them if they belong to the top 20. This reduces the fees and management efforts for the portfolio.

### Exemplary Results

- **Initial funds**: 20k $
- **Cost per trade (purchase or sale)**: 3 $
- **Time Period**: starting between 2005 to end of 2009, ending in April 2021
- **Iterations**: 100 random starting dates
- **Buy Sell Criteria**: Buy Top 10, Hold Top 20

<p align="center">
  <img src="https://user-images.githubusercontent.com/20499620/115531580-3b152380-a295-11eb-954f-aa6c8282e69f.png" width="500" class="center">
</p>

From the graph, it can be seen that it is best to rebalance every 40 trading days. This is equivalent to about 40/5=8 calendar weeks. It is best to buy stocks that have performed the strongest over the last 175 trading days. This corresponds to approximately 175/5/4=8.75 calendar months.

Here is the minimum performance for reference. This must always be taken into account to see how the worst case would have played out.

<p align="center">
  <img src="https://user-images.githubusercontent.com/20499620/115534074-b1b32080-a297-11eb-8229-b4baddf71e59.png" width="500" class="center">
</p>
