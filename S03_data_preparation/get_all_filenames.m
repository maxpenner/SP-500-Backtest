function [filenames, n_files] = get_all_filenames(directory_path)

    filenames = dir(directory_path);
    
    % remove . and ..
    filenames(1) = [];
    filenames(1) = [];
    
    n_files = numel(filenames);
end