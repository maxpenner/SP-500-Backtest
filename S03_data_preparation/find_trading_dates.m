function [] = find_trading_dates()

    load('fja_dates_retime_fja_unique_tickers_8_presence.mat', 'fja_dates_retime', 'fja_dates_retime_fja_unique_tickers_8_presence');

    load('longest_history.mat', 'av_ticker_longest_history', 'av_dates_longest_history');

    %% find all trading dates by comparing longest history with fja dates retimed
    [~,~,ib] = intersect(av_dates_longest_history, fja_dates_retime);
    
    % these are our trading dates
    trading_dates = fja_dates_retime(ib);
    
    % reduce the large matrix to the size required
    trading_dates_fja_unique_tickers_8_presence = fja_dates_retime_fja_unique_tickers_8_presence(ib, :, :);
    
	save('trading_dates_fja_unique_tickers_8_presence.mat', 'trading_dates', 'trading_dates_fja_unique_tickers_8_presence');

    %% show how many tickers are actually available on each trading date

    % how many tickers are available on each day?
    n_tickers_each_date = sum(trading_dates_fja_unique_tickers_8_presence, 3);
    n_tickers_each_date = ~isnan(n_tickers_each_date);
    n_tickers_each_date = sum(double(n_tickers_each_date), 2);

    fprintf('Minimum number of tickers is %d.\n', min(n_tickers_each_date));

    figure(1)
    clf()
    plot(trading_dates, n_tickers_each_date);
    xlabel('date')
    ylabel('number of tickers available')
    xlim([datetime('1998-01-01') datetime('2022-01-01')])
    ylim([0 550])
    
    % plot configuration
    set(0,'defaulttextinterpreter','latex')
    set(gca,'TickLabelInterpreter', 'latex','FontSize', 13);

    xlabel("Date", 'FontSize', 13);
    ylabel("Number of Tickers available", 'FontSize', 13);
    title("Best Case is something close to 500", 'interpreter', 'latex', 'FontSize', 15);
    xlim([datetime('1995-01-01') datetime('2025-01-01')])
    ylim([0 550])
    
    grid on

    op = get(gcf,'OuterPosition');
    set(gcf,'units','pixels','OuterPosition',[op(1),op(2),600,500])        
end

