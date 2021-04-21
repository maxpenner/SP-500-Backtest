function [] = find_longest_history()

    % load alpha vantage data
    load('av_tables.mat', 'av_unique_tickers', 'av_tables');
    
    index_longest_history = 0;
    longest_history = -1;
    
    % find the stock with the longest history
    for i=1:1:numel(av_unique_tickers)

        % downloaded data
        av_table = av_tables{i};
        av_dates = av_table.timestamp;
        
        if numel(av_dates) > longest_history
            index_longest_history = i;
            longest_history = numel(av_dates);
        end
    end
      
    % what is the ticker?
    av_ticker_longest_history = av_unique_tickers(index_longest_history);

    % downloaded data
    av_table = av_tables{index_longest_history};
    av_table = flipud(av_table);  % ascending dates

    % the dates we are actually interested in
    av_dates_longest_history = av_table.timestamp;
    
    save('longest_history.mat', 'av_ticker_longest_history', 'av_dates_longest_history');
end

