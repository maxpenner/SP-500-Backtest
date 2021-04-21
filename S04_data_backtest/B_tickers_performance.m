function [tickers_performance_on_decision_dates] = B_tickers_performance(	decision_date_indices,...
                                                                            comparision_date_indices,...
                                                                            trading_dates_fja_unique_tickers_8_presence)
    
    % get some meta
    [~, n_fja_unique_tickers, ~] = size(trading_dates_fja_unique_tickers_8_presence);
    n_decision_date_indices = numel(decision_date_indices);
    
    % what are the correct indices for div and split
    % div is hard to calculate, you might need to hold a stock for a certain time to get the dividend
    % 8 = open, high, low, close, adjusted_close, volume, dividend_amount, split coefficient
    %div_idx = 7;
    split_idx = 8;
    
    % final container
    tickers_performance_on_decision_dates = zeros(n_decision_date_indices, n_fja_unique_tickers);

    % go over each decision day
    for i=1:1:n_decision_date_indices
        
        decision_date_index = decision_date_indices(i);
        compare_date_index = comparision_date_indices(i);
        
        % extract relevant range
        %div_range = trading_dates_fja_unique_tickers_8_presence( this_compare_date_index + 1 : this_decision_date_index, : , div_idx);
        split_range = trading_dates_fja_unique_tickers_8_presence( compare_date_index + 1 : decision_date_index, : , split_idx);
        
        % we need the sum and the product
        %div_sum = sum(div_range, 1);
        split_coeff = prod(split_range, 1);
        
        % get prices
        price_compare = trading_dates_fja_unique_tickers_8_presence(compare_date_index, :, 1);      % open price
        price_decision = trading_dates_fja_unique_tickers_8_presence(decision_date_index, :, 4);    % close price
        
        % adjust for splits
        price_decision = price_decision.*split_coeff;
        
        % get performance
        tickers_performance_on_decision_dates(i, :) = price_decision./price_compare;
    end
end

