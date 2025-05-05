#!/usr/bin/env python
# There are instances where requests rate limited error may be encountered due to Yahoo API. Using a VPN should resolve the issue

import yfinance as yf
from pathlib import Path

TICKER = 'SPY'
START = '2005-01-01'
END = '2025-04-22'
OUTPUT_NAME = TICKER.lower() #TICKER + '_from_' + START + '_to_' + END
RELATIVE_PATH_FOLDER = 'dbt_project/seeds/'

def get_historical_data():
    ticker = yf.Ticker(TICKER)
    df_ticker = ticker.history(period="max", interval="1d", start=START, end=END, auto_adjust=True, rounding=False)
    print("Checking object type" + str(type(df_ticker)))
    print("Checking header info:")
    df_ticker.info()
    print(df_ticker.head())
    return df_ticker

def output_historical_data(df_tick):
    cwd = Path.cwd()
    print("Current directory: ", cwd)
    relative_path_output = RELATIVE_PATH_FOLDER + OUTPUT_NAME + '.csv'
    output_path = (cwd / relative_path_output).resolve()
    print("CSV output path:", output_path)
    df_tick.to_csv(output_path)

def main():
    hist_data = get_historical_data()
    output_historical_data(hist_data)

if __name__ == '__main__':
    main()
