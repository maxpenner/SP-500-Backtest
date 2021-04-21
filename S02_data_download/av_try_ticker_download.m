function [err, err_char, av_err_char] = av_try_ticker_download(ticker, alpha_vantage_key)

    clear_directory('stage_csv');

    % can be tested in browser
    alpha_vantage_url = av_create_url(ticker, alpha_vantage_key);

    % we first stage the file
    fullfile_stage = fullfile('stage_csv/', [ticker, '_stage.csv']);

    % try downloading
    try
        options = weboptions('Timeout',10);
      	websave(fullfile_stage, alpha_vantage_url, options);
    catch
        err = 1;
        err_char = 'Error: Download failed due to websave() error.';
        av_err_char = '';
        clear_directory('stage_csv');
        return;
    end

    % read entire content of file
    filetext_stage = fileread(fullfile_stage);
    
    % check if downloaded data is valid
    if contains(filetext_stage,'Error') == true
        err = 1;
        err_char = 'Error Message: Download succeded, but file contains word Error.';
        av_err_char = fileread(fullfile_stage);
        clear_directory('stage_csv');
        return;
    end
    
    % check if downloaded data is valid
    if contains(filetext_stage,'open') == false
        err = 1;
        err_char = 'Error Message: Download succeded, but file does not contain word open.';
        av_err_char = fileread(fullfile_stage);
        clear_directory('stage_csv');
        return;
    end    
    
    % make sure file has a minimum size
    file_min_size = 0;

    % get the file size
    s = dir(fullfile_stage);    
    
    % check if downloaded data is valid
    if s.bytes < file_min_size
        err = 1;
        err_char = 'Error Message: Download succeded, but file is too small.';
        av_err_char = fileread(fullfile_stage);
        clear_directory('stage_csv');
        return;
    end
    
    % unstage
    full_filepath = fullfile('data_csv/', [ticker, '.csv']);
    copyfile(fullfile_stage, full_filepath);
    clear_directory('stage_csv');
    
    err = 0;
    err_char = '';
    av_err_char = '';
end

function [alpha_vantage_url] = av_create_url(ticker, alpha_vantage_key)

    base_url = 'https://www.alphavantage.co/query?';
    
    a = 'function=TIME_SERIES_DAILY_ADJUSTED&';
    
    b = ['symbol=', ticker, '&'];
    
    c = ['apikey=', alpha_vantage_key, '&'];
    
    d = 'datatype=csv&';
    
    e = 'outputsize=full';
    
    alpha_vantage_url = [base_url, a, b, c, d, e];
end

