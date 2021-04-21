function [portfolio] = single_backtest(bt_data, bt_portfolio, bt_strategy)

    trading_dates                                = bt_data.trading_dates;
    trading_dates_fja_unique_tickers_8_presence  = bt_data.trading_dates_fja_unique_tickers_8_presence;
    
    % first step, determine all relevant dates
    [decision_date_indices, comparision_date_indices, buysell_date_indices] = A_select_dates(bt_strategy, trading_dates);

    % second step, measure the peformance of each ticker on each decision date
    tickers_performance_on_decision_dates = B_tickers_performance(	decision_date_indices,...
                                                                    comparision_date_indices,...
                                                                    trading_dates_fja_unique_tickers_8_presence);
    
    % third step is running the portfolio
    portfolio = C_run_portfolio(bt_data, bt_portfolio, buysell_date_indices, tickers_performance_on_decision_dates);
end

