function [portfolio] = C_run_portfolio(bt_data, bt_portfolio, buysell_date_indices, tickers_performance)

    trading_dates                                = bt_data.trading_dates;
    trading_dates_fja_unique_tickers_8_presence  = bt_data.trading_dates_fja_unique_tickers_8_presence;
    
    initial_cash       	= bt_portfolio.initial_cash;
    trade_flat_fee    	= bt_portfolio.trade_flat_fee;
    n_ticker          	= bt_portfolio.n_ticker;
    n_best_buy_search	= bt_portfolio.n_best_buy_search;
    n_best_sell_search  = bt_portfolio.n_best_sell_search;
    
    % sanity check
    if n_best_buy_search < n_ticker
        error("Number of searchable tickers must be equal/larger than number of tickers hold, best twice as much.");
    end
    
    % we buy at the open
    trading_dates_fja_unique_tickers_8_presence_open = trading_dates_fja_unique_tickers_8_presence(:,:,1);
    trading_dates_fja_unique_tickers_8_presence_split = trading_dates_fja_unique_tickers_8_presence(:,:,8);    

    %% put the portfolio into the initial state
    cash = initial_cash;

    % data we need to keep track of the tickers we hold
 	tickers_hold_slots                  = ones(numel(buysell_date_indices), n_ticker)*NaN;  % indices of tickers we hold
	tickers_hold_amount                 = ones(numel(buysell_date_indices), n_ticker)*NaN;  % amount per ticker
	tickers_hold_buysell_date_indices   = ones(numel(buysell_date_indices), n_ticker)*NaN;  % index of buysell date ticker was bought
    
    %% stat data on each buysell date
    cash_history        	= zeros(numel(buysell_date_indices), 1);
    fees_history            = zeros(numel(buysell_date_indices), 1);
    total_value_history  	= zeros(numel(buysell_date_indices), 1);
    n_ticker_available      = zeros(numel(buysell_date_indices), 1);
    
    %% go over each buysell date
    for i = 1:1:numel(buysell_date_indices)
        
        today_fees = 0;
        
        %% first find the best performing tickers
        candidate_tickers_performance = tickers_performance(i, :);
        
        % sort and put NaN at the end of the list
        [~, best_tickers_indices_sorted] = sort(candidate_tickers_performance, 'descend', 'MissingPlacement','last');
        
        % remember how many tickers are actually available
        n_ticker_available(i) = sum(~isnan(candidate_tickers_performance));
        
        % limit to a certain amount of best stocks
        SELL_best_tickers_indices_sorted = best_tickers_indices_sorted(1:n_best_sell_search);
        BUY_best_tickers_indices_sorted = best_tickers_indices_sorted(1:n_best_buy_search);
        
        %% sell
        
        % we can only sell on the second buysell date
        if i > 1
            
            % we first assume that we continue holding all tickers
        	tickers_hold_slots(i, :)            	= tickers_hold_slots(i-1, :);
            tickers_hold_amount(i, :)              	= tickers_hold_amount(i-1, :);
            tickers_hold_buysell_date_indices(i, :)	= tickers_hold_buysell_date_indices(i-1, :);
        
            % iterate over each ticker we currently hold and decide wether is has to be sold
            for j=1:1:numel(tickers_hold_slots(i, :))
                
                % check if slot is empty
                % if so, skip as not sellable
                if isnan(tickers_hold_slots(i, j)) == true
                    continue;
                end
                
                % SELL CONDITION 1: ticker is not among the best tickers
                still_among_best = ismember(tickers_hold_slots(i, j), SELL_best_tickers_indices_sorted);                
                
                % SELL CONDITION 2: ticker is delisted and we don't see a valid price
                delisted = isnan(trading_dates_fja_unique_tickers_8_presence_open(buysell_date_indices(i), tickers_hold_slots(i, j)));

                % do we sell?
                if still_among_best == false || delisted == true

                    price_open = trading_dates_fja_unique_tickers_8_presence_open(buysell_date_indices(i), tickers_hold_slots(i, j));

                    % adjust for splits
                    split_range = buysell_date_indices(tickers_hold_buysell_date_indices(i, j)) + 1 : buysell_date_indices(i);
                    split_coeff = trading_dates_fja_unique_tickers_8_presence_split(split_range, tickers_hold_slots(i, j));
                    split_coeff = prod(split_coeff);                    
                    
                    % It can happen that a ticker gets delistet before our regular buysell date.
                    % In this case we sell at the last known price when listed.
                    if isnan(price_open) == true
                        tmp = trading_dates_fja_unique_tickers_8_presence_open(1:buysell_date_indices(i), tickers_hold_slots(i, j));
                        last_valid_index = find(~isnan(tmp), 1, 'last');
                        clear tmp;
                        price_open = trading_dates_fja_unique_tickers_8_presence_open(last_valid_index, tickers_hold_slots(i, j));
                        
                        % adjust for splits
                        split_range = buysell_date_indices(tickers_hold_buysell_date_indices(i, j)) + 1 : last_valid_index;
                        split_coeff = trading_dates_fja_unique_tickers_8_presence_split(split_range, tickers_hold_slots(i, j));
                        split_coeff = prod(split_coeff);                        
                    end
                    
                    % some data is corrupted and there is a random NaN within the splits
                    % if so, set split to 1
                    % by doing so, we might miss a split and see a much lower price, but the amount remains the same
                    % therefore, is looks like a big loss
                    if isnan(split_coeff) == true
                        split_coeff = 1;                       
                    end                    

                    amount_adjusted = tickers_hold_amount(i, j)*split_coeff;

                    cash_from_sell = price_open*amount_adjusted - trade_flat_fee;
                    
                    % we can lose all of our money, but we can't get negative
                    if cash_from_sell < 0
                        cash_from_sell = 0;
                    end
                    
                    cash = cash + cash_from_sell;

                    today_fees = today_fees + trade_flat_fee;
                    
                    % free the slot
                    tickers_hold_slots(i, j)                = NaN;
                    tickers_hold_amount(i, j)               = NaN;
                    tickers_hold_buysell_date_indices(i, j)	= NaN;
                end
            end
        end
        
        %% buy
        
        % get a list of best tickers we do not hold currently
        best_tickers_indices_sorted_no_hold = setdiff(BUY_best_tickers_indices_sorted, tickers_hold_slots(i, :), 'stable');
        
        % determine how much cash we can spend per empty slot
        n_empty_slots = sum(isnan(tickers_hold_slots(i, :)));
        cash_per_empty_slot = cash/n_empty_slots;
        
        % go over the best ticker and fill empty slots
        for j=1:1:numel(best_tickers_indices_sorted_no_hold)
            
            % find the index of the next free slot
            next_free_slot_index = find(isnan(tickers_hold_slots(i,:)), 1);
            
            % skip if we don't have anymore free slots
            if isempty(next_free_slot_index) == true
                break;
            end
            
            % get the current price
            price_open = trading_dates_fja_unique_tickers_8_presence_open(buysell_date_indices(i), best_tickers_indices_sorted_no_hold(j));
            
            % can happen: ticker is listed on decision date, buts gets delisted the next day, which is a buysell date
            if isnan(price_open) == true
                % try to buy the next best ticker
                continue;
            end            
            
            % how much can we buy?
            amount = floor((cash_per_empty_slot - trade_flat_fee)/price_open);
            
            % not enough cash, ignore, try to buy next one, it might be cheaper
            if amount == 0
                continue;
            end
            
            % finally buy
            price_buy_full = price_open*amount + trade_flat_fee;
            cash = cash - price_buy_full;
            today_fees = today_fees + trade_flat_fee;            
            
            % sanity check
            if cash < 0
                error("Cash below zero.");
            end
            
            % create entry
            tickers_hold_slots(i, next_free_slot_index)                 = best_tickers_indices_sorted_no_hold(j);
            tickers_hold_amount(i, next_free_slot_index)                = amount;
            tickers_hold_buysell_date_indices(i, next_free_slot_index) 	= i;
        end
        
        % fill history
        cash_history(i) = cash;
        fees_history(i) = today_fees;
        
        % get the current full value of the portfolio
        % all prices should exist, but slots can be empty
        total_value_history(i) = cash;
        for j=1:1:numel(tickers_hold_slots(i,:))
            
            % check if the slot is empty
            slot_empty = isnan(tickers_hold_slots(i, j));
            
            % if empty, it does not contribute to the total portfolio value
            if slot_empty == true
                continue;
            end
            
            price = trading_dates_fja_unique_tickers_8_presence_open(buysell_date_indices(i), tickers_hold_slots(i, j));
            amount = tickers_hold_amount(i, j);
            total_value_history(i) = total_value_history(i) + price*amount;
        end
        
        % sanity check
        if isnan(total_value_history(i)) == true
            error("Total value of portfolio is NaN.");
        end
    end

    % summarize portfolio
    portfolio.timespan_days     = datenum(trading_dates(buysell_date_indices(end))) - datenum(trading_dates(buysell_date_indices(1)));
    portfolio.timespan_years    = portfolio.timespan_days/365;
    portfolio.final_value       = total_value_history(end);
    
    % sanity check
    if portfolio.final_value < 0
        error("Final portfolio value below zero.");
    end
    
    portfolio.multiplication        = portfolio.final_value/initial_cash;
    portfolio.profit_pa             = nthroot(portfolio.multiplication, portfolio.timespan_years)-1;
    
    portfolio.n_ticker_available	= n_ticker_available;
end

