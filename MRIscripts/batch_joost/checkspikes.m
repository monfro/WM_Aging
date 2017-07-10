function checkspikes(folder,search_str,nEchoes,mode)
% checkspikes(folder,search_str,nEchoes,mode)
% defaults:
% folder        current folder
% search_str    'r*' (realigned files)
% nEchoes       4
% mode          2 (1 = check, 2 = remove)

if nargin < 1
    folder = cd;
end
if nargin < 2
    search_str = 'r*';
end
if nargin < 3
    nEchoes = 4;
end
if nargin < 4
    mode = 2;
end

olddir = cd;
output_dir = fullfile(folder,'spike');
if ~exist(output_dir); mkdir(output_dir); end;
cd(folder);

% include fraleo's batch
addpath(genpath(fullfile(filesep,'home','common','matlab','spm_batch','fraleo','dmb')));
cfg_util('addapp', dmb_cfg);

for i=1:nEchoes  % find all scans per echo time
    curr_echo_files = dir([search_str,'0',num2str(i),'.nii']);
    curr_output_dir = fullfile(output_dir,['E',num2str(i)]);
    if ~exist(curr_output_dir); mkdir(curr_output_dir); end;
    
    % fill and run spike check job
    clear matlabbatch
    load example_spikecheck_job
    matlabbatch{1}.dmb{1}.check_data_quality{1}.cfg_check_spikes.files = {{}};
    for f = 1:numel(curr_echo_files)
        matlabbatch{1}.dmb{1}.check_data_quality{1}.cfg_check_spikes.files{1}{f,1} = ...
            [fullfile(folder,curr_echo_files(f).name),',1'];
    end
    
    fileseps = findstr(filesep,targetPath);
    subject_name = targetPath(fileseps(end-1)+1:fileseps(end)-1);
    matlabbatch{1}.dmb{1}.check_data_quality{1}.cfg_check_spikes.subject = subject_name;
    if checkspikes == 1
        matlabbatch{1}.dmb{1}.check_data_quality{1}.cfg_check_spikes.mode = 'check';
    else
        matlabbatch{1}.dmb{1}.check_data_quality{1}.cfg_check_spikes.mode = 'remove';
    end
    matlabbatch{1}.dmb{1}.check_data_quality{1}.cfg_check_spikes.output_dir = {curr_output_dir};
    save(fullfile(output_dir,['spikecheck_echo',num2str(i),'_job.mat']),'matlabbatch');
    spm_jobman('run',matlabbatch);
end
cd(olddir);