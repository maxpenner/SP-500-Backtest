function [] = synchronize_data()

    %% load fja05680 data
    load('../S01_data_preparation_fja05680/fja_dates_unique_tickers_presence.mat',...
        'fja_dates', 'fja_unique_tickers', 'fja_dates_unique_tickers_presence');

    % convert table to timetable
    tmp = timetable(fja_dates, fja_dates_unique_tickers_presence);

    % fill missing days
    % by retiming we have every date from 1996 to 202x
    tmp = retime(tmp,'daily','previous');

    fja_dates_retime = tmp.fja_dates;
    
    clear tmp;

    %% load alpha vantage data
    load('av_tables.mat', 'av_tables', 'av_unique_tickers');

    %% synchronize data
    % We have all dates from 1996 to 202x in fja_dates_retime.
    % We also have the data downloaded from alpha vantage in av_tables.
    % Our goal is to put the data from alpha vantage into a large matrix with every date from fja_dates_retime.
    % Many of those dates are not needed, however, combining the data is easier to handle this way.
    
    % first generate the output matrix
    %
    %   Where does the 8 come from?
    %   
    %       8 = open, high, low, close, adjusted_close, volume, dividend_amount, split coefficient
    %
    fja_dates_retime_fja_unique_tickers_8 = ones(numel(fja_dates_retime), numel(fja_unique_tickers), 8)*NaN;

    % process each ticker we were able to download from alpha vantage
    for i=1:1:numel(av_unique_tickers)
        
        % what is the ticker?
        av_ticker = av_unique_tickers(i);
        
        % fja uses dot, alpha vantege dash
        av_ticker = strrep(av_ticker,'-','.');
        
        % where can this ticker be found in all fja_unique_tickers?
        av_ticker_pos_in_fja_unique_tickers = find(strcmp(av_ticker, fja_unique_tickers));
        
        % sanity check
        if isempty(av_ticker_pos_in_fja_unique_tickers) == true
            error("Ticker from av not found in fja.");
        end

        % get av table
        av_table = av_tables{i};
        av_table = flipud(av_table);  % ascending dates

        % separate av table
        av_dates = av_table.timestamp;
        av_8 = table2array(av_table(:,2:end));

        % find common dates
        [~,ia,ib] = intersect(av_dates, fja_dates_retime);
        
        % get av data that is relevant and reshape into third dimensio
        av_data_intersection = av_8(ia, :);
        av_data_intersection = reshape(av_data_intersection, [], 1, 8);

        % write into output matrix
        fja_dates_retime_fja_unique_tickers_8(ib, av_ticker_pos_in_fja_unique_tickers, :) = av_data_intersection;
    end
    
    %% synchronize with presence in index
    % We can download data from av even if the ticker is not in the index.
    % Therefore, we only consider data of a ticker if the ticker was present on the index.
    
    fja_dates_retime_fja_unique_tickers_8_presence = ones(size(fja_dates_retime_fja_unique_tickers_8))*NaN;

    for i=1:1:numel(av_unique_tickers)
        
        % what is the ticker?
        av_ticker = av_unique_tickers(i);
        
        % where can this ticker be found in all unique tickers?
        av_ticker_pos_in_fja_unique_tickers = find(strcmp(av_ticker, fja_unique_tickers));
        
        % get all dates on which the ticker was present in the index
        av_ticker_presence = fja_dates_unique_tickers_presence(:, av_ticker_pos_in_fja_unique_tickers);
        av_ticker_presence_dates = fja_dates(logical(av_ticker_presence));
        
        % sanity check
        if sum(av_ticker_presence) ~= numel(av_ticker_presence_dates)
            error("Numbe of presence dates incorrect.");
        end
        
        % we have to retime the presence dates
        tmp_timetable = timetable(av_ticker_presence_dates, ones(size(av_ticker_presence_dates)));
        tmp_timetable = retime(tmp_timetable,'daily','previous');
        av_ticker_presence_dates_retime = tmp_timetable.av_ticker_presence_dates;

        % find common dates
        [~,~,ib] = intersect(av_ticker_presence_dates_retime, fja_dates_retime);
        
        % cut out relevant data
        tmp_cutout = fja_dates_retime_fja_unique_tickers_8(ib,av_ticker_pos_in_fja_unique_tickers,:);

        % write into output matrix
    	fja_dates_retime_fja_unique_tickers_8_presence(ib,av_ticker_pos_in_fja_unique_tickers,:) = tmp_cutout;
    end
    
    save('fja_dates_retime_fja_unique_tickers_8_presence.mat', 'fja_dates_retime', 'fja_dates_retime_fja_unique_tickers_8_presence');
end

