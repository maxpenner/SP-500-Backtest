function [decision_date_indices, comparision_date_indices, buysell_date_indices] = A_select_dates(bt_strategy, trading_dates)

    decision_date_start	= bt_strategy.decision_date_start;
    decision_date_end 	= bt_strategy.decision_date_end;
    decision_period   	= bt_strategy.decision_period;
    comparison_period  	= bt_strategy.comparison_period;
    
    n_trading_dates = numel(trading_dates);
    
    % find closest trading date to date_start
    [~, decision_date_start_index]  = min(abs(datenum(trading_dates) - datenum(decision_date_start)));
    [~, decision_date_end_index]    = min(abs(datenum(trading_dates) - datenum(decision_date_end)));
        
    % find the dates of which we decide how to rebalance
    % we have make it "n_trading_dates - 1" to have one final buysell date
    decision_date_indices = decision_date_start_index : decision_period : min(decision_date_end_index, n_trading_dates - 1);
    
    % these are the dates we compare to on each trading day
    comparision_date_indices = decision_date_indices - comparison_period;
    
    % sanity check
    if min(comparision_date_indices) <= 0
        error("First comparison date before first trading day.");
    end     
    
    % we always buy/sell the next trading day
    buysell_date_indices = decision_date_indices + 1;
    
    % sanity check
    if max(buysell_date_indices) > n_trading_dates
        error("Last buysell date after last trading day.");
    end
    
    % make it row vectors
    decision_date_indices       = decision_date_indices';
    comparision_date_indices	= comparision_date_indices';
    buysell_date_indices        = buysell_date_indices';
end

