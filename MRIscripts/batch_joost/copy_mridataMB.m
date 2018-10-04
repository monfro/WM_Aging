function [target_files,target_subdirs,target_subdirs_type] = copy_mridataMB(mri_data_dir,target_dir)
dbstop if error
range_series_nr = [3 4]; % between which dots can we find the series number?

if nargin < 1
    if ispc
        mri_data_dir = uigetdir('\\LAB-MRI007\MRIData-Skyra','select dir with source files');
    else
        mri_data_dir = uigetdir(cd,'select dir with source files');
    end
end
filelist = dir(mri_data_dir);
filelist(find([filelist.bytes]==0)) = [];
mri_files = {filelist.name}';

%% get info from filenames
locs_dots                   = cellfun(@regexp, mri_files, repmat({'\.'}, size(mri_files)), 'UniformOutput', false);
locs_dots_mat               = cell2mat(locs_dots);
series_nrs_cell             = cellfun(@(x, a, b)x(a:b), mri_files, num2cell(locs_dots_mat(:, range_series_nr(1))+1), num2cell(locs_dots_mat(:, range_series_nr(2))-1), 'UniformOutput', false);
series_nrs                  = cellfun(@str2num,series_nrs_cell);

%% report and copy files to ordered directories
u_series = unique(series_nrs);
protocol_names = cell(size(u_series));
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
if nargin < 2
    target_dir = uigetdir(cd,'select target dir');
end
target_subdirs = repmat({' '},size(source_files));
target_subdirs_type = repmat({' '},size(source_files));
% find T1s
T1_idx = find(cellfun(@isempty,cellfun(@findstr,repmat({'t1'},size(protocol_names)),protocol_names,'UniformOutput',false))==0);

% find EPIs
EPI_idx = find(cellfun(@isempty,cellfun(@findstr,repmat({'multiecho'},size(protocol_names)),protocol_names,'UniformOutput',false))==0);
EPI_echonrs = echo_nrs(EPI_idx);
u_EPI_echonrs = unique(EPI_echonrs);
for i = 1:numel(EPI_idx)
    EPI_nscans(i) = sum(series_nrs==u_series(EPI_idx(i)));
end

if rem(numel(EPI_idx),numel(u_EPI_echonrs))
    error('Nr of echoes unexpected');
elseif numel(EPI_idx) > numel(u_EPI_echonrs)
    % multiple EPI series
    nseries = numel(EPI_idx)/numel(u_EPI_echonrs);
    EPI_series = [];
    EPI_series_names = {};
    for i = 1:length(EPI_idx);%nseries
        EPI_series = [EPI_series,i*ones(1,max(EPI_echonrs))];%[EPI_series,i*ones(1,max(EPI_echonrs))];
        EPI_series = unique(EPI_series);
        dlg_title = ['EPI session ',num2str(i)];
        if EPI_nscans(i*ones(1,max(EPI_echonrs))) > 900
           EPI_series_names = [EPI_series_names,'Stop'];
%         elseif EPI_nscans(i*ones(1,max(EPI_echonrs))) > 400 & EPI_nscans(i*ones(1,max(EPI_echonrs))) < 500
%             EPI_series_names = [EPI_series_names,'Nback'];
        else
            EPI_series_names = [EPI_series_names,'WMAG'];
        end
        %prompt = ['How do you want to name EPI session #',num2str(i),' (containing ',num2str(EPI_nscans((i-1)*max(EPI_echonrs)+1)),' scans)?'];
        %EPI_series_names = [EPI_series_names, inputdlg(prompt,dlg_title,1)];
    end
else % just one series
    EPI_series = ones(1,max(EPI_echonrs));
    EPI_series_names = {'EPI'};
end

%idx_unique_EPI_seriesnames = find(EPI_echonrs==1);
%EPI_series_names =EPI_series_names(idx_unique_EPI_seriesnames);
% check # scans per series
excess_scan = zeros(size(series_nrs));
for i = unique(EPI_series)
    curr_idx = find(EPI_series==i);
    for j = 1:numel(curr_idx)
        if EPI_nscans(curr_idx(j)) > min(EPI_nscans(curr_idx))
            excess_scan(find(series_nrs==EPI_idx(curr_idx(j)),1,'last')) = 1;
        end
    end
end


% find DTIs
DTI_idx = find(cellfun(@isempty,cellfun(@findstr,repmat({'diff'},size(protocol_names)),protocol_names,'UniformOutput',false))==0)

for i = 1:numel(u_series)
    fprintf('%g:%s%g%s files found%s(%s)',u_series(i),char(9),sum(series_nrs==u_series(i)),char(9),char(9),protocol_names{i});
    if ismember(u_series(i),u_series(T1_idx))
        fprintf(' -> will be copied to T1 folder\n');
        target_subdirs(find(series_nrs==u_series(i))) = repmat({'T1'},size(find(series_nrs==u_series(i))));
        target_subdirs_type(find(series_nrs==u_series(i))) = repmat({'T1'},size(find(series_nrs==u_series(i))));
    elseif ismember(u_series(i),u_series(EPI_idx))
        EPI_name = EPI_series_names{EPI_series(find(u_series(EPI_idx)==u_series(i)))};
        fprintf(' -> will be copied to %s folder\n',EPI_name);
        target_subdirs(find(series_nrs==u_series(i))) = repmat({EPI_name},size(find(series_nrs==u_series(i))));
        target_subdirs_type(find(series_nrs==u_series(i))) = repmat({'EPI'},size(find(series_nrs==u_series(i))));
    elseif ismember(u_series(i),u_series(DTI_idx))
        fprintf(' -> will be copied to DTI folder\n');
        target_subdirs(find(series_nrs==u_series(i))) = repmat({'DTI'},size(find(series_nrs==u_series(i))));
        target_subdirs_type(find(series_nrs==u_series(i))) = repmat({'DTI'},size(find(series_nrs==u_series(i))));
    else
        fprintf(' -> will be copied to rest folder\n');
        target_subdirs(find(series_nrs==u_series(i))) = repmat({'rest'},size(find(series_nrs==u_series(i))));
        target_subdirs_type(find(series_nrs==u_series(i))) = repmat({'rest'},size(find(series_nrs==u_series(i))));
    end
end

% move excess files to excess folder
excess_scan_idx = find(excess_scan);
for i = 1:numel(excess_scan_idx)
    target_subdirs{excess_scan_idx(i)} = [target_subdirs{excess_scan_idx(i)},filesep,'excess'];
end
[o1,o2,o3] = unique(target_subdirs);
u_target_dirs = cellfun(@fullfile,repmat({target_dir},size(unique(target_subdirs))),unique(target_subdirs),'UniformOutput',false);
u_target_dirs_type = target_subdirs_type(o2);
if sum(strcmp(target_subdirs,'T1'))> 0
    for T1Wmag = 2:3
        if ~exist(u_target_dirs{T1Wmag}); mkdir(u_target_dirs{T1Wmag}); end; end;
else 
    if ~exist(u_target_dirs{2}); mkdir(u_target_dirs{2}); end; 
end
target_files = cellfun(@fullfile,repmat({target_dir},size(target_subdirs)),target_subdirs,mri_files,'UniformOutput',false);

%% copy the files
if numel(source_files) ~= numel(target_files); keyboard; end
status = zeros(size(source_files));
copyline = ['Copying data from ',mri_data_dir,' to ',target_dir];
fprintf('%s\n',copyline);
h = waitbar(0,copyline);
imin = min(find(strcmp(target_subdirs, 'WMAG')));
imax = max(find(strcmp(target_subdirs, 'WMAG')));
for i = imin:imax
    status(i) = copyfile(source_files{i},target_files{i});
    waitbar(i+1-imin/length(imin:imax));
end

T1min = min(find(strcmp(target_subdirs, 'T1')));
T1max = max(find(strcmp(target_subdirs, 'T1')));
for i = T1min: T1max
    status(i) = copyfile(source_files{i},target_files{i});
    waitbar(i+1-T1min/length(T1min:T1max));
end

close(h);


if any(status(imin:imax)==0)
    disp('error while copying');
    keyboard;
else
    fprintf('\n\n COPY SUCCESS\n\n');
end