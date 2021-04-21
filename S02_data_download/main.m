clear all;
close all;
clc;

% check if folders exist, if not create them
if ~exist('data_csv', 'dir')
    mkdir('data_csv')
end
if ~exist('stage_csv', 'dir')
    mkdir('stage_csv')
end

clear_directory('data_csv');
clear_directory('stage_csv');

% load ticker symbols
tickers = readlines('../S01_data_preparation_fja05680/fja_unique_tickers');
tickers(strcmp(tickers,"")) = [];	% remove empty strings, there might be one at the end
n_tickers = numel(tickers);

% sanity check
if n_tickers == 0
    error('No tickers found.');
end

% load alpha vantage keys
av_keys = readlines('alpha_vantage_keys');
av_keys(strcmp(av_keys,"")) = [];	% remove empty strings, there might be one at the end
n_av_keys = numel(av_keys);

% sanity check
if n_av_keys == 0
    error('Found no av keys. No entries in file alpha_vantage_keys.');
end

% limit search scope within the list of tickers
ticker_start = min(1, n_tickers);
ticker_end = min(1e6, n_tickers);

% configure waiting times
wait_after_success = 1.0;
wait_after_fail = 1.0;
x = 5;
wait_after_x_tries = 62.0;      % five API calls per second possible

% how often do we retry at most for a single ticker in case it fails?
n_tries_per_ticker = 7;

% this will take a while...
cnt_all_tries = 0;
cnt_all_tries_success = 0;
for tckr = ticker_start : 1 : ticker_end
    
    % get ticker
    ticker = tickers(tckr);
    
    % replace . with -
    ticker = strrep(ticker,'.','-');
    
    % we need a char
    ticker_char = convertStringsToChars(ticker);
    
    % pick a key
    av_key_char = av_keys(mod(tckr-1, n_av_keys) + 1);
    av_key_char = convertStringsToChars(av_key_char);
    
    fprintf('\n############################\n');
    fprintf('tckr=%d  ticker=%s  cnt_all_tries=%d  cnt_all_tries_success=%d  key=%s\n', tckr, ticker, cnt_all_tries, cnt_all_tries_success, av_key_char);

    % try downloading ticke
    for tries = 1:1:n_tries_per_ticker
        
        cnt_all_tries = cnt_all_tries + 1;
        
        % only 5 calls per second allowed
        if mod(cnt_all_tries, x) == 0
            fprintf('\nPause!\n');
            pause(wait_after_x_tries);
            fprintf('Pause End!\n\n');
        end        
        
        % call av API
        [err, err_char, av_err_char] = av_try_ticker_download(ticker_char, av_key_char);

        % success?
        if err == 0
            pause(wait_after_success);
            cnt_all_tries_success = cnt_all_tries_success + 1;
            break;
        else
            pause(wait_after_fail);
            fprintf('Error for: tckr=%d  ticker=%s  tries=%d  %s\n', tckr, ticker_char, tries, err_char);
            fprintf('%s\n', av_err_char);
            if tries == n_tries_per_ticker
                fprintf('>>>>>> Error final for tckr=%d  ticker=%s <<<<<<\n', tckr, ticker_char);
            end
        end
    end
end