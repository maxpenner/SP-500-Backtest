function [] = plot_profits(decision_period, comparison_period, n_jitter, portfolios)

    %% add lib to use it
    export_fig_lib_available = false;

    %% plot yearly profits
    % average across different simulations with save periods
    profit_pa = zeros(numel(decision_period), numel(comparison_period));
    for i = 1:numel(decision_period)
        for j = 1:numel(comparison_period)
            for k=1:1:n_jitter
                portfolio = portfolios{i,j,k};
                profit_pa(i,j) = profit_pa(i,j) + portfolio.profit_pa;
            end
        end
    end
    profit_pa = profit_pa/n_jitter;

    % plot profit p.a.
    set(0,'defaulttextinterpreter','latex')
    set(gca,'TickLabelInterpreter', 'latex','FontSize', 13);

    figure(1)
    imagesc(comparison_period,decision_period,profit_pa)
    colorbar

    xlabel('Comparison Period in Trading Days', 'FontSize', 13);
    ylabel('Decision Period in Trading Days', 'FontSize', 13);
    title('Average Profit p.a. in Percent', 'interpreter', 'latex', 'FontSize', 15);

    axis([min(comparison_period) max(comparison_period) min(decision_period) max(decision_period)])

    op = get(gcf,'OuterPosition');
    set(gcf,'units','pixels','OuterPosition',[op(1),op(2),600,500])

    savefig('plots/performance.fig')

    if export_fig_lib_available == true
        addpath('export_fig_lib')
        export_fig plots/performance.png -m4 -transparent

        addpath('export_fig_lib')
        export_fig plots/performance.eps -m2.5 -transparent
    end

    %% plot yearly profits min
    % average across different simulations with save periods
    profit_pa_min = zeros(numel(decision_period), numel(comparison_period));
    for i = 1:numel(decision_period)
        for j = 1:numel(comparison_period)

            profit_pa_vec = zeros(n_jitter,1);

            for k=1:1:n_jitter
                portfolio = portfolios{i,j,k};
                profit_pa_vec(k) = portfolio.profit_pa;
            end

            profit_pa_min(i,j) = min(profit_pa_vec);
        end
    end
    %profit_pa_min = profit_pa_min/n_jitter;

    % plot profit p.a. std
    set(0,'defaulttextinterpreter','latex')
    set(gca,'TickLabelInterpreter', 'latex','FontSize', 13);

    figure(2)
    imagesc(comparison_period,decision_period,profit_pa_min)
    colorbar

    xlabel('Comparison Period in Trading Days', 'FontSize', 13);
    ylabel('Decision Period in Trading Days', 'FontSize', 13);
    title('Min of Profit p.a. in Percent', 'interpreter', 'latex', 'FontSize', 15);

    axis([min(comparison_period) max(comparison_period) min(decision_period) max(decision_period)])

    op = get(gcf,'OuterPosition');
    set(gcf,'units','pixels','OuterPosition',[op(1),op(2),600,500])

    savefig('plots/performance_min.fig')

    if export_fig_lib_available == true
        addpath('export_fig_lib')
        export_fig plots/performance_min.png -m4 -transparent

        addpath('export_fig_lib')
        export_fig plots/performance_min.eps -m2.5 -transparent
    end

    %% plot yearly profits max
    % average across different simulations with save periods
    profit_pa_max = zeros(numel(decision_period), numel(comparison_period));
    for i = 1:numel(decision_period)
        for j = 1:numel(comparison_period)

            profit_pa_vec = zeros(n_jitter,1);

            for k=1:1:n_jitter
                portfolio = portfolios{i,j,k};
                profit_pa_vec(k) = portfolio.profit_pa;
            end

            profit_pa_max(i,j) = max(profit_pa_vec);
        end
    end
    %profit_pa_max = profit_pa_max/n_jitter;

    % plot profit p.a. std
    set(0,'defaulttextinterpreter','latex')
    set(gca,'TickLabelInterpreter', 'latex','FontSize', 13);

    figure(3)
    imagesc(comparison_period,decision_period,profit_pa_max)
    colorbar

    xlabel('Comparison Period in Trading Days', 'FontSize', 13);
    ylabel('Decision Period in Trading Days', 'FontSize', 13);
    title('Max of Profit p.a. in Percent', 'interpreter', 'latex', 'FontSize', 15);

    axis([min(comparison_period) max(comparison_period) min(decision_period) max(decision_period)])

    op = get(gcf,'OuterPosition');
    set(gcf,'units','pixels','OuterPosition',[op(1),op(2),600,500])

    savefig('plots/performance_max.fig')

    if export_fig_lib_available == true
        addpath('export_fig_lib')
        export_fig plots/performance_max.png -m4 -transparent

        addpath('export_fig_lib')
        export_fig plots/performance_max.eps -m2.5 -transparent
    end
    
    %% plot the minimum number of symbols that were available
    % average across different simulations with save periods
    ticker_availalbe_mins = zeros(numel(decision_period), numel(comparison_period));
    for i = 1:numel(decision_period)
        for j = 1:numel(comparison_period)

            ticker_availalbe_mins_vec = zeros(n_jitter,1);

            for k=1:1:n_jitter
                portfolio = portfolios{i,j,k};
                ticker_availalbe_mins_vec(k) = min(portfolio.n_ticker_available);
            end

            ticker_availalbe_mins(i,j) = min(ticker_availalbe_mins_vec);
        end
    end
    %profit_pa_max = profit_pa_max/n_jitter;

    % plot profit p.a. std
    set(0,'defaulttextinterpreter','latex')
    set(gca,'TickLabelInterpreter', 'latex','FontSize', 13);

    figure(4)
    imagesc(comparison_period,decision_period,ticker_availalbe_mins)
    colorbar

    xlabel('Comparison Period in Trading Days', 'FontSize', 13);
    ylabel('Decision Period in Trading Days', 'FontSize', 13);
    title('Minimum Number of Tickers available', 'interpreter', 'latex', 'FontSize', 15);

    axis([min(comparison_period) max(comparison_period) min(decision_period) max(decision_period)])

    op = get(gcf,'OuterPosition');
    set(gcf,'units','pixels','OuterPosition',[op(1),op(2),600,500])

    savefig('plots/n_symbols_available.fig')

    if export_fig_lib_available == true
        addpath('export_fig_lib')
        export_fig plots/n_symbols_available.png -m4 -transparent

        addpath('export_fig_lib')
        export_fig plots/n_symbols_available.eps -m2.5 -transparent
    end    
end

