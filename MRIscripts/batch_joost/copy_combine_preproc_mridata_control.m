function copy_combine_preproc_mridata(mri_data_dir,target_dir)

tic
cleanup_EPIs = true; % clean up EPI folder (just a copy of dicoms, not necessary any more after echo combination

% some variables
run_immediately = true;  % should the genereated batch jobs be executed immediately?

% set some settings
spm fmri; % initialize SPM
%addpath(genpath('/home/language/jooweg/matlab/toolbox/dmb'));
addpath(genpath('/home/common/matlab/spm_batch/fraleo/dmb'));
% [p1,p2,p3] = fileparts(mfilename('fullpath'));
% addpath(p1); % add the path from which we run this function again to make sure that custom batch functions are used from this path
cfg_util('addapp', dmb_cfg);
nEchoes = 4;
nPrescans = 30;
MEsmoothing = 1; % smooth the prescans before determining weights?
MEsmoothKernelRatio = 1.2; % size of the smoothing kernel, expressed as a ratio of the voxel size of the functional volumes

if nargin < 1
    mri_data_dir = uigetdir(cd,'select dir with source files');
end
if nargin < 2
    target_dir = uigetdir(cd,'select target dir');
end

% check for spaces (will cause batch to crash
if ~isempty(findstr(' ',target_dir))
    error('Please make sure the target path has no spaces in it');
end

%% copy and sort data into folders
fprintf('copying data from %s to %s\n\n',mri_data_dir,target_dir);
[target_files,target_subdirs,target_subdirs_type] = copy_mridata(mri_data_dir,target_dir);
[u_dirs,o2,o3] = unique(target_subdirs);
u_types = target_subdirs_type(o2);
subdirs2exclude = [find(cellfun(@isempty,cellfun(@findstr,u_dirs,repmat({'excess'},size(u_dirs)),'UniformOutput',false))==0),...
    find(cellfun(@isempty,cellfun(@findstr,u_dirs,repmat({'delete'},size(u_dirs)),'UniformOutput',false))==0)];
u_dirs(subdirs2exclude) = [];
u_types(subdirs2exclude) = [];
EPI_idx = find(cellfun(@strcmp,u_types,repmat({'EPI'},size(u_types))));
EPI_dirs = u_dirs(EPI_idx);

fileseps = findstr(filesep,target_dir);
subject_name = target_dir(fileseps(end)+1:end);
fprintf('subject name is %s\n',subject_name);

for f = 1:numel(EPI_dirs) % loop over EPI datasets
    %% combine echoes
    if strcmp(EPI_dirs{f},'EPI')
        funcdir = fullfile(target_dir,'func');
        info_dir = fullfile(target_dir,'info');
    else
        funcdir = fullfile(target_dir,['func_',EPI_dirs{f}]);
        info_dir = fullfile(target_dir,['info_',EPI_dirs{f}]);
    end
    spike_outputdir = fullfile(info_dir,'spikecheck');
    
    if ~exist(funcdir); mkdir(funcdir); end;
    % ME_Combine_commandline(sourcePath,targetPath,numberOfEchoes,WeightVol
    % umes,prescanPath,numberOfRuns,smoothing,KernelSize)
    epidir = fullfile(target_dir,EPI_dirs{f});
    % get voxel size to determine smoothing kernel
    epis = dir(epidir);
    epi_info = dicominfo(fullfile(epidir,epis(3).name));
    if numel(unique(epi_info.PixelSpacing)) > 1; keyboard; end; % check for isotropic voxels in x and y dimensions
    MEsmoothKernelSize = MEsmoothKernelRatio * epi_info.PixelSpacing(1);
    ME_Combine_commandline(epidir,funcdir,nEchoes,nPrescans,[],[],MEsmoothing,MEsmoothKernelSize);
    
    % clean up EPI folder if desired
    if cleanup_EPIs
        cleanup_in_between_niis(target_dir,false,1,false)
    end
    
    % define target folders
    combined_dir = fullfile(funcdir,'PAID_data');
    converted_dir = fullfile(funcdir,'converted_Volumes');    
    
    % copy mean functionals, RPs and T1
    cd(combined_dir);
    converted_vols = dir('M_volume*.nii');
    converted_vols(1:nPrescans) = [];
    rp_file = dir('rp*.txt');
    cd(converted_dir);
    mean_func = dir('mean*.nii');
    if numel(mean_func)~=1 || numel(rp_file)~= 1; keyboard; end
    mean_func_copy = fullfile(combined_dir,['mean_echo1_',subject_name,'.nii']);
    copyfile(mean_func.name,mean_func_copy);
    cd(combined_dir);
    rp = load(rp_file.name);
    rp = rp(nPrescans+1:end,:);
    rp_newpath = fullfile(combined_dir,['rp_',subject_name,'_',num2str(nPrescans+1),'_onwards.txt']);
    save(rp_newpath,'rp','-ascii');
    
    %% convert T1
    t1_dir = fullfile(target_dir,'T1');
    load('t1_conversion_example_job.mat');
    cd(t1_dir);
    imas = dir('*.IMA');
    if numel(imas)~=192; keyboard;end;
    matlabbatch{1}.spm.util.dicom.data = {};
    for i = 1:numel(imas)
        matlabbatch{1}.spm.util.dicom.data{i,1} = fullfile(t1_dir,imas(i).name);
    end
    matlabbatch{1}.spm.util.dicom.outdir{1} = t1_dir;
    save(fullfile(t1_dir,'conversion_job.mat'),'matlabbatch');
    spm_jobman('run',matlabbatch);
    clear matlabbatch
    
    % get T1 path
    t1_convpath = dir('*.nii');
    t1_convpath(find(cellfun(@isempty,cellfun(@findstr,repmat({subject_name},1,numel(t1_convpath)),{t1_convpath.name},'UniformOutput',false))==0)) = [];
    if numel(t1_convpath)~=1;keyboard;end
    if strcmp(EPI_dirs{f},'EPI')
        t1_newpath = fullfile(t1_dir,['T1_',subject_name,'.nii']);
    else
        t1_newpath = fullfile(t1_dir,['T1_',subject_name,'_',EPI_dirs{f},'.nii']);
    end
    movefile(t1_convpath.name,t1_newpath);
    
    %% do preprocessing
    load preproc_example_job_control
    % 1) check the combined images for spikes
    matlabbatch{1}.dmb{1}.check_data_quality{1}.cfg_check_spikes.data = {};
    for i = 1:numel(converted_vols)
        matlabbatch{1}.dmb{1}.check_data_quality{1}.cfg_check_spikes.data{i,1} = [fullfile(combined_dir,converted_vols(i).name),',1'];
    end
    matlabbatch{1}.dmb{1}.check_data_quality{1}.cfg_check_spikes.output_dir = {spike_outputdir};
    % 2) do slice timing (works with dependencies, therefore no input here)
    % 3) coregister mean functional (echo 1) to EPI template and apply to all functional images
    matlabbatch{3}.spm.spatial.coreg.estimate.source{1} = [mean_func_copy,',1'];
    % 4) coregister T1 to T1 template
    matlabbatch{4}.spm.spatial.coreg.estimate.source{1} = [t1_newpath,',1'];
    % 5) segment the T1
    matlabbatch{5}.spm.spatial.preproc.data{1} = [t1_newpath,',1'];
    % 6) coregister the mean functional to the bias-corrected T1 (produced
    % in step 5)
    matlabbatch{6}.spm.spatial.coreg.estimate.source{1} = [mean_func_copy,',1'];
    % 7) write functionals in normalized space (works with dependencies, therefore no input here)
    % 8) write structural images in normalized space (works with dependencies, therefore no input here)
    % 9) smooth functional images (works with dependencies, therefore no input here)
    
    % save and run preprocessing job
    if ~exist(spike_outputdir); mkdir(spike_outputdir); end
    if ~exist(info_dir); mkdir(info_dir); end
    
    preproc_jobfile = fullfile(info_dir,[subject_name,'_preproc_job.mat']);
    save(preproc_jobfile,'matlabbatch');
    fprintf('saved preprocessing jobfile: %s\n',preproc_jobfile);
    cd(funcdir);
    if run_immediately
        fprintf('running jobfile: %s\n',preproc_jobfile);
        spm_jobman('run',matlabbatch);
    else
        fprintf('Chosen not to execute jobs immediately, skipping compartment signal part of the job because it relies on files generated by the batch');
        return
    end
    
    %% get compartment signals & combine with realignment regressors
    if strcmp(EPI_dirs{f},'EPI')
        newsegment_dir = fullfile(t1_dir,'new_segment');
    else
        newsegment_dir = fullfile(t1_dir,'new_segment_',EPI_dirs{f});
    end
    if ~exist(newsegment_dir); mkdir(newsegment_dir); end
    newsegment_t1_path = fullfile(newsegment_dir,['T1_',subject_name,'.nii']);
    copyfile(t1_newpath,newsegment_t1_path);
    clear matlabbatch
    load example_compsig_job_coreg
    matlabbatch{1}.dmb{1}.nuisance_regressors{1}.preproc8.channel.vols = {[newsegment_t1_path,',1']};
    % find functional (slice-time corrected, not yet normalized) files
    cd(combined_dir);
    stc_files = dir('a*.nii');
    for i = 2:4
        matlabbatch{i}.spm.spatial.coreg.write.ref = {[fullfile(combined_dir,stc_files(1).name),',1']};
    end
    
    matlabbatch{5}.dmb{1}.nuisance_regressors{1}.segment_regressors.data = {};
    for i = 1:numel(stc_files)
        matlabbatch{5}.dmb{1}.nuisance_regressors{1}.segment_regressors.data{i,1} = ...
            [fullfile(combined_dir,stc_files(i).name),',1'];
    end
    
    matlabbatch{5}.dmb{1}.nuisance_regressors{1}.segment_regressors.directory{1}{1} = info_dir; % save compsig regressors to info dir
    rmfield(matlabbatch{6}.dmb{1}.nuisance_regressors{1}.deriv_mov_pars,'regressor')
    matlabbatch{6}.dmb{1}.nuisance_regressors{1}.deriv_mov_pars.regressors = {rp_newpath};
    matlabbatch{7}.dmb{1}.nuisance_regressors{1}.combine_regressors.target_dir{1} = info_dir;
    matlabbatch{7}.dmb{1}.nuisance_regressors{1}.combine_regressors.filename = [subject_name,'_rp_rp1stderiv_compsig'];
    matlabbatch{8}.dmb{1}.nuisance_regressors{1}.combine_regressors.target_dir{1} = info_dir;
    matlabbatch{8}.dmb{1}.nuisance_regressors{1}.combine_regressors.filename = [subject_name,'_rp_rp1stderiv'];
    compsig_jobfile = fullfile(info_dir,[subject_name,'_compsig_job.mat']);
    save(compsig_jobfile,'matlabbatch');
    spm_jobman('run',matlabbatch);
end
cleanup_in_between_niis(target_dir,true,1:5,false);
toc
