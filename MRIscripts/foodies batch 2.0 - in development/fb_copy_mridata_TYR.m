function fb_copy_mridata

% dbstop if error
global INFO
if isempty(whos('INFO')); error('Please provide INFO structure'); end   % check whether we have INFO structure

filetypes = fieldnames(INFO.raw_data.filetypes);    % list different file types from INFO structure

% loop over subjects
for iSubj = 1:numel(INFO.subjects)
    % inform the user
    fprintf('%s: running subject %s\n%s\n',mfilename,INFO.subjects{iSubj},repmat('=',1,100));

    %% get file and folder information

    % get folder locations
    mri_data_dir    = fullfile(INFO.dir.exp_root,INFO.subjects{iSubj})%,INFO.dir.raw_data);
    target_dir      = fullfile(INFO.dir.exp_root,INFO.subjects{iSubj});
    
    if ~(exist(mri_data_dir)==7) % check for data directory existence
        mri_data_dir = uigetdir(INFO.dir.exp_root,['select directory with raw MRI files for subject ',INFO.subjects{iSubj}]);
    end
    if ~(exist(target_dir)==7) % check for target directory existence
        target_dir = uigetdir(INFO.dir.exp_root,['select target directory for subject ',INFO.subjects{iSubj}]);
    end
%     % check for spaces (will cause batch to crash
%     if ~isempty(findstr(' ',target_dir))
%         error('Please make sure the target path has no spaces in it');
%     end
    
    batch_info_savefolder = fullfile(INFO.dir.exp_root,INFO.subjects{iSubj},INFO.dir.info.batch);
    batch_info_savefile = fullfile(batch_info_savefolder,INFO.raw_data.filename.subject_info);
    
    if exist(batch_info_savefile) % check whether info on copied files exist (indicating this part has already been run)
        if INFO.raw_data.overwrite
            fprintf('-> Overwriting previous files\n');
        else
            fprintf('-> Files already appear to have been copied, skipping subject (if you want to overwrite, change settings in INFO.raw_data.overwrite\n|\n');
            continue
        end
    end

    % get the files in the raw MRI folder
    filelist = dir(mri_data_dir);
    % remove empty files
    filelist(find([filelist.bytes]==0)) = [];
    % make a list of all the files in the directory
    mri_files = {filelist.name}';
    % remove text files from list
    mri_files(find(cellfun(@isempty,cellfun(@findstr,mri_files,repmat({'.txt'},size(mri_files)),'UniformOutput',false))==0)) = [];
    
    %% get info from filenames
    % find the dots in the filenames
    locs_dots                   = cellfun(@regexp, mri_files, repmat({'\.'}, size(mri_files)), 'UniformOutput', false);
    locs_dots_mat               = cell2mat(locs_dots); % put into a matrix
    series_nrs_cell             = cellfun(@(x, a, b)x(a:b), mri_files, num2cell(locs_dots_mat(:, INFO.raw_data.range_series_nr(1))+1), num2cell(locs_dots_mat(:, INFO.raw_data.range_series_nr(2))-1), 'UniformOutput', false); % isolate the data series numbers
    series_nrs                  = cellfun(@str2num,series_nrs_cell); % put the series numbers in a cell
    
    %% report and copy files to ordered directories
    u_series = unique(series_nrs); % find all unique series numbers
    protocol_names = cell(size(u_series));
    % open the first file in each series and read in protocol name and echo
    % number (for multiecho, if available) from dicom headers
    for i = 1:numel(u_series)
        di = dicominfo(fullfile(mri_data_dir,mri_files{find(series_nrs==u_series(i),1)}));
        protocol_names{i} = di.ProtocolName;
        if isfield(di,'EchoNumber')
            echo_nrs(i) = di.EchoNumber;
        else
            echo_nrs(i) = 0;
        end
    end
    
    source_files = cellfun(@fullfile,repmat({mri_data_dir},size(mri_files)),mri_files,'UniformOutput',false);

    target_subdirs = repmat({' '},size(source_files));
    target_subdirs_type = repmat({' '},size(source_files));
    
    %% find file types
    for iType = 1:numel(filetypes)
        if strcmp(filetypes{iType},'func')
            % handle functional scan series
            func_series_idx = find(cellfun(@isempty,cellfun(@findstr,repmat({'multiecho'},size(protocol_names)),protocol_names,'UniformOutput',false))==0);
            func_series_echonrs = echo_nrs(func_series_idx);       % find out which echo number each scan series nr is
            for i = 1:numel(func_series_idx)                % find out the number of scans per series
                func_series_nscans(i) = sum(series_nrs==u_series(func_series_idx(i)));
                func_series(i) = sum(i>=find(func_series_echonrs==1));  % store which functional session this serie belongs to
            end
            % find out how many scans there are per functional session
            func_session_nscans = func_series_nscans(find(func_series_echonrs==1));
            % figure out the name of each session
            for iSess = 1:numel(func_session_nscans)
                % first, try it based on the number of scans
                candidate_sessions = find(func_session_nscans(iSess) >= INFO.raw_data.filetypes.func.session_expected_nscans(:,1) ...
                    & func_session_nscans(iSess) <= INFO.raw_data.filetypes.func.session_expected_nscans(:,2));
                if numel(candidate_sessions) == 1
                    func_sess_idx = candidate_sessions;  % session was found!
                elseif numel(candidate_sessions) > 1
                    % if session could not be identified by nr of scans,
                    % go for the order of the session
                    func_sess_idx = candidate_sessions(find(candidate_sessions==iSess));
                else
                    % if not matched, mark the series for deletion
                    func_session_names{iSess} = ['delete_func_sess_',num2str(iSess)];
                    keyboard
                end
                func_session_names{iSess} = INFO.raw_data.filetypes.func.session_names{func_sess_idx};
            end
        else
            % handle other types of scans
            eval([filetypes{iType},'_series_idx = find(cellfun(@isempty,cellfun(@findstr,repmat({INFO.raw_data.filetypes.',filetypes{iType},'.identifier_str},size(protocol_names)),protocol_names,''UniformOutput'',false))==0);']);
        end
    end % file type loop
    
    % exclude unwanted sessions    
    func_sessions2delete = find_string_in_cells('delete',func_session_names);
    for i = 1:numel(func_sessions2delete)
        idx2delete = find(func_series==func_sessions2delete(i));
        func_series(idx2delete) = [];
        func_series_nscans(idx2delete) = [];
        func_series_idx(idx2delete) = [];
        func_series_echonrs(idx2delete) = [];
    end
    
    % check # scans per series (for rare case series within session has less
    % scans
    excess_scan = zeros(size(series_nrs));
    for i = unique(func_series)
        curr_idx = find(func_series==i);
        for j = 1:numel(curr_idx)
            if func_series_nscans(curr_idx(j)) > min(func_series_nscans(curr_idx))
                excess_scan(find(series_nrs==func_series_idx(curr_idx(j)),1,'last')) = 1;
            end
        end
    end

    mri_report_file = fopen(fullfile(mri_data_dir,'dicom_series_info.txt'),'w');
    for i = 1:numel(u_series)
        fprintf('+-  %g:%s%g%s files found%s(%s)',u_series(i),char(9),sum(series_nrs==u_series(i)),char(9),char(9),protocol_names{i});
        fprintf(mri_report_file,'%g:%s%g%s files found%s(%s)',u_series(i),char(9),sum(series_nrs==u_series(i)),char(9),char(9),protocol_names{i});
        % Find the file type of the current series. If none is found, files
        % go into 'rest' folder
        curr_filetype = 'rest';
        for iType = 1:numel(filetypes)
            if eval(['ismember(u_series(i),u_series(',filetypes{iType},'_series_idx))'])
                curr_filetype = filetypes{iType};
            end
        end
        
        if strcmp(curr_filetype,'func')
            % get func series info
            curr_func_session = func_series(find(func_series_idx==i));
            curr_func_series_name = func_session_names{curr_func_session};
            fprintf(' -> will be copied to %s folder\n',curr_func_series_name);
            fprintf(mri_report_file,' -> will be copied to %s folder\n',curr_func_series_name);
            target_subdirs(find(series_nrs==u_series(i))) = repmat({curr_func_series_name},size(find(series_nrs==u_series(i))));
            target_subdirs_type(find(series_nrs==u_series(i))) = repmat({curr_func_series_name},size(find(series_nrs==u_series(i))));
        else
            fprintf(' -> will be copied to %s folder\n',curr_filetype);
            fprintf(mri_report_file,' -> will be copied to %s folder\n',curr_filetype);
            target_subdirs(find(series_nrs==u_series(i))) = repmat({curr_filetype},size(find(series_nrs==u_series(i))));
            target_subdirs_type(find(series_nrs==u_series(i))) = repmat({curr_filetype},size(find(series_nrs==u_series(i))));
        end     
    end
    fclose(mri_report_file);
        
    % move excess files to excess folder
    excess_scan_idx = find(excess_scan);
    for i = 1:numel(excess_scan_idx)
        target_subdirs{excess_scan_idx(i)} = [target_subdirs{excess_scan_idx(i)},filesep,'excess'];
    end
    [o1,o2,o3] = unique(target_subdirs);
    u_target_dirs = cellfun(@fullfile,repmat({target_dir},size(unique(target_subdirs))),unique(target_subdirs),'UniformOutput',false);
    u_target_dirs_type = target_subdirs_type(o2);
    for i = 1:numel(u_target_dirs); if ~exist(u_target_dirs{i}); mkdir(u_target_dirs{i}); end; end;
    target_files = cellfun(@fullfile,repmat({target_dir},size(target_subdirs)),target_subdirs,mri_files,'UniformOutput',false);
    
    %% copy the files
    if numel(source_files) ~= numel(target_files); keyboard; end
    status = zeros(size(source_files));
    copyline = ['+-> Copying data from ',mri_data_dir,' to ',target_dir];
    fprintf('%s\n',copyline);
    h = waitbar(0,copyline);
    for i = 1:numel(source_files)
        status(i) = copyfile(source_files{i},target_files{i});
        waitbar(i/numel(source_files));
    end
    close(h);
    
    if any(status==0)
        disp('error while copying');
        keyboard;
    else
        fprintf('+-> Copy succes!\n');
    end
    
    % save information to mat file
    if ~exist(batch_info_savefolder); mkdir(batch_info_savefolder); end
    save(batch_info_savefile,'target*','func*','series*','INFO');
    fprintf('+-> Saved information to %s\n|\n',batch_info_savefile);

end % for iSbuj...

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Other functions
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function out = find_string_in_cells(str,cells)
out = find(cellfun(@isempty,cellfun(@findstr,repmat({str},size(cells)),cells,'UniformOutput',false))==0);
