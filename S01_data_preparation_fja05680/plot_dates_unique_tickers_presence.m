function [] = plot_dates_unique_tickers_presence(dates_unique_tickers_presence)

    n_plot_ticker_per_figure = 100;

    [~, n_unique_tickers] = size(dates_unique_tickers_presence);
    
    n_figures = ceil(n_unique_tickers/n_plot_ticker_per_figure);
    
    for fig_idx = 1:1:n_figures
        
        idx_first = 1 + (fig_idx-1)*n_plot_ticker_per_figure;
        
        idx_last = min(idx_first + n_plot_ticker_per_figure-1, n_unique_tickers);
        
        figure(fig_idx)
        clf()
        
        imagesc(dates_unique_tickers_presence(:, idx_first:idx_last));
        
        % plot configuration
        set(0,'defaulttextinterpreter','latex')
        set(gca,'TickLabelInterpreter', 'latex','FontSize', 13);

        xlabel("Unique Ticker", 'FontSize', 13);
        ylabel("Date", 'FontSize', 13);
        title(strcat("Unique Ticker Indices: first: ", num2str(idx_first), " last: ", num2str(idx_last)), 'interpreter', 'latex', 'FontSize', 15);

        op = get(gcf,'OuterPosition');
        set(gcf,'units','pixels','OuterPosition',[op(1),op(2),600,500])   
    end
end

