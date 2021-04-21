clear all;
close all;
clc;

if ~exist('plots', 'dir')
    mkdir('plots')
end

clear_directory('plots');

%% load data
load('../S03_data_preparation/trading_dates_fja_unique_tickers_8_presence.mat',...
    'trading_dates', 'trading_dates_fja_unique_tickers_8_presence');

% load data, will be given to each worker
bt_data.trading_dates                                   = trading_dates;
bt_data.trading_dates_fja_unique_tickers_8_presence     = trading_dates_fja_unique_tickers_8_presence;

clear trading_dates;
clear trading_dates_fja_unique_tickers_8_presence;

%% portfolio data fixed across all simulations
bt_portfolio.initial_cash     	= 20e3;
bt_portfolio.trade_flat_fee    	= 3;
bt_portfolio.n_ticker          	= 10; 	% number of positions we hold at most
bt_portfolio.n_best_buy_search	= 20;	% we only buy tickers that are among the 'n_best_buy_search' best tickers
bt_portfolio.n_best_sell_search	= 10;   % we keep holding a ticker if it is among the 'n_best_sell_search' best tickers

%% simulation range
decision_period = 10:5:200;
comparison_period = 50:5:300;
n_jitter = 100;

% output
portfolios = cell(numel(decision_period), numel(comparison_period), n_jitter);

%% randomness across workers
rng('shuffle');     % time dependent
common_random_number = randi(1,1);

%% start backtest
for i = 1:numel(decision_period)

    tic
    fprintf("Starting! %d of %d\n",i,numel(decision_period));

    % each worker get its own unique seed
    rng(common_random_number + i);
    
    local_decision_period = decision_period(i);
    
    local_portfolios = cell(1, numel(comparison_period), n_jitter);
    
    %for j = 1:numel(comparison_period)
    parfor j = 1:numel(comparison_period)   % parfor is most efficient for n_jitter >> 1
        
        for k = 1:1:n_jitter
            
            date_earliest = '2005-01-01';
            date_latest = '2010-01-01';
            
            % pick a random date
            date_random_start = randi([datenum(date_earliest) datenum(date_latest)] , 1, 1);
            
            bt_strategy = [];
            bt_strategy.decision_date_start	= datestr(date_random_start, 'yyyy-mm-dd');
            bt_strategy.decision_date_end 	= '2100-01-01';
            bt_strategy.decision_period     = local_decision_period;
            bt_strategy.comparison_period  	= comparison_period(j);

            portfolio = single_backtest(bt_data, bt_portfolio, bt_strategy);

            local_portfolios(1,j,k) = {portfolio};
        end
    end
    
    portfolios(i,:,:) = local_portfolios;
    
    fprintf("Done! %d of %d after %.2f seconds\n", i, numel(decision_period), toc);
end

%% save results
save('portfolios.mat','decision_period', 'comparison_period', 'n_jitter', 'portfolios');

%% load results, rerunning simulation not required
clear all;
close all;

load('portfolios.mat','decision_period', 'comparison_period', 'n_jitter', 'portfolios');

%% show results
plot_profits(decision_period, comparison_period, n_jitter, portfolios);

