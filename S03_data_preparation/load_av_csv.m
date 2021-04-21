function [] = load_av_csv()

    [filenames, n_filenames] = get_all_filenames('../S02_data_download/data_csv');
    
    av_unique_tickers = strings(1, n_filenames);
    
    av_tables = cell(n_filenames,1);
    
    % read file by file
    %for i=1:n_filenames
    parfor i=1:n_filenames
        
        av_tables(i) = {readtable(fullfile(filenames(i).folder, filenames(i).name))};
        
        [~, av_unique_tickers(i), ~] = fileparts(filenames(i).name);
    end
    
    save('av_tables.mat', 'av_unique_tickers', 'av_tables');
end

