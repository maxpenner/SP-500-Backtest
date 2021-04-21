function [] = clear_directory(directory_path)

    % first find all recorded files
    [filenames, n_files] = get_all_filenames(directory_path);

    % delete all files
    for i=1:1:n_files
    	full_filepath = fullfile(filenames(i).folder,filenames(i).name);
        delete(full_filepath);
    end
end

function [filenames, n_files] = get_all_filenames(directory_path)

    filenames = dir(directory_path);
    
    % remove . and ..
    filenames(1) = [];
    filenames(1) = [];
    
    n_files = numel(filenames);
end

