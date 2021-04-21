clear all;
close all;

%% read csv files
T = readtable("sp500-master/S&P 500 Historical Components & Changes(04-18-2021).csv");
dates = T.date;
tickers_on_each_day_string = string(T.tickers);

n_dates = numel(dates);

%% determine the maximum number of tickers to ever exist on a single date

% first determine the number of stocks on each day
n_tickers_on_each_date = zeros(n_dates,1);
for i=1:1:n_dates
    n_tickers_on_each_date(i) = numel( strsplit(tickers_on_each_day_string(i),',') );
end

max_n_tickers = max(n_tickers_on_each_date);

%% create 2d string array of all dates and tickers, empty string as placeholder
dates_tickers = strings(n_dates, max_n_tickers);
for i=1:1:n_dates
    dates_tickers(i, 1 : n_tickers_on_each_date(i)) = strsplit(tickers_on_each_day_string(i),',');
end

%% find all unique tickers that have ever been in the index
unique_tickers = unique(reshape(dates_tickers,1,[]));

% remove empty strings
unique_tickers(strcmp("",unique_tickers)) = [];

n_unique_tickers = numel(unique_tickers);

%% go over each unique ticker and mark every day it was part of the index
dates_unique_tickers_presence = zeros(n_dates, n_unique_tickers);

%for i=1:1:n_unique_tickers
parfor i=1:n_unique_tickers

    ticker = unique_tickers(i);

    % find ticker symbol
    idx = strcmp(ticker, dates_tickers);
    
    % convert from logical to double
    idx = double(idx);
    
    % we just need it across one day
    idx = sum(idx,2);

    % sanity checks
    if numel(idx) ~= n_dates
        error("Incorrect number of dates.");
    end
    if min(idx) < 0 || 1 < min(idx)
        error("Ticker can only be either not listed, i.e. min(idx)=0, or be listed exactly once, i.e. min(idx)=1.");
    end
    if max(idx) == 0
        error("Ticker never found.");
    end
    if max(idx) > 1
        error("Ticker found more than once on a single day.");
    end     

    dates_unique_tickers_presence(:,i) = idx;
end

% show the results
plot_dates_unique_tickers_presence(dates_unique_tickers_presence);

%% save relevant data
fja_dates                           = dates;
fja_unique_tickers                  = unique_tickers;
fja_dates_unique_tickers_presence   = dates_unique_tickers_presence;
save('fja_dates_unique_tickers_presence.mat', 'fja_dates', 'fja_unique_tickers','fja_dates_unique_tickers_presence');

%% save unique tickers in file
fid = fopen('fja_unique_tickers','w+t');
if fid > 0
    fprintf(fid,'%s\n',fja_unique_tickers(1:end-1));
end
fprintf(fid,'%s',fja_unique_tickers(end));  % avoid empty line a the end
fclose(fid);

