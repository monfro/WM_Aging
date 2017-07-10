function fb_preprocess

global INFO;

if isempty(whos('INFO')); error('Please provide INFO structure'); end   % check whether we have INFO structure

% loop over subjects
for iSubj = 1:numel(INFO.subjects)
    % inform the user
    fprintf('%s: running subject %s\n%s\n',mfilename,INFO.subjects{iSubj},repmat('=',1,100));

    % load file info that was save by fb_copy_mridata
    batch_info_savefolder = fullfile(INFO.dir.exp_root,INFO.subjects{iSubj},INFO.dir.info.batch);
    batch_info_savefile = fullfile(batch_info_savefolder,INFO.raw_data.filename.subject_info);
    if ~exist(batch_info_savefile); error(['file ',batch_info_savefile,' does not exist. Run fb_copy_mridata first']); end
    subj_info           = load(batch_info_savefile);
    
    % convert T1
    t1_dir = fullfile(subj_info.target_dir,'T1');
    if ~exist(t1_dir); mkdir(t1_dir); end
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
    
    % find the folders with functional data in them
    [u_dirs,o2,o3] = unique(subj_info.target_subdirs);
    u_types = subj_info.target_subdirs_type(o2);
    subdirs2exclude = [find(cellfun(@isempty,cellfun(@findstr,u_dirs,repmat({'excess'},size(u_dirs)),'UniformOutput',false))==0),...
        find(cellfun(@isempty,cellfun(@findstr,u_dirs,repmat({'delete'},size(u_dirs)),'UniformOutput',false))==0)];
    u_dirs(subdirs2exclude) = [];
    u_types(subdirs2exclude) = [];
    func_idx = find(ismember(u_dirs,INFO.raw_data.filetypes.func.session_names));
    raw_func_dirs = u_dirs(func_idx);
    
    for iSess = 1:numel(raw_func_dirs) % loop over func datasets     
        if strcmp(raw_func_dirs{iSess},'func')
            func_session(iSess).func_dir = fullfile(subj_info.target_dir,INFO.preproc.suffix.func);
            func_session(iSess).info_dir = fullfile(subj_info.target_dir,INFO.preproc.suffix.info);
        else
            func_session(iSess).func_dir = fullfile(subj_info.target_dir,[raw_func_dirs{iSess},'_',INFO.preproc.suffix.func]);
            func_session(iSess).info_dir = fullfile(subj_info.target_dir,[raw_func_dirs{iSess},'_',INFO.preproc.suffix.info]);
        end
        func_session(iSess).spike_outputdir = fullfile(func_session(iSess).info_dir,INFO.dir.info.spike);
        
        % define target folders
        combined_dir = fullfile(func_session(iSess).func_dir,INFO.dir.multiecho.combined);
        converted_dir = fullfile(func_session(iSess).func_dir,INFO.dir.multiecho.converted);
        
        % copy mean functionals, RPs and T1
        cd(combined_dir);
        converted_vols = dir('M_volume*.nii');
        converted_vols(1:INFO.preproc.multiecho.nPrescans) = [];
        rp_file = dir('rp*01.txt');
        cd(converted_dir);
        mean_func = dir('mean*.nii');
        if numel(mean_func)~=1 || numel(rp_file)~= 1; keyboard; end
            
        mean_func_copy = fullfile(combined_dir,['mean_echo1_',INFO.subjects{iSubj},'.nii']);
        copyfile(mean_func.name,mean_func_copy);
        cd(combined_dir);
        rp = load(rp_file.name);
        rp = rp(INFO.preproc.multiecho.nPrescans+1:end,:);
        rp_newpath = fullfile(combined_dir,['rp_',INFO.subjects{iSubj},'_',num2str(INFO.preproc.multiecho.nPrescans+1),'_onwards.txt']);
        save(rp_newpath,'rp','-ascii');
        
        % get T1 path
        cd(t1_dir);
        t1_convpath = dir('*.nii');     % find converted T1
        % remove already created T1s
        t1_convpath(find(cellfun(@isempty,cellfun(@findstr,repmat({INFO.subjects{iSubj}},1,numel(t1_convpath)),{t1_convpath.name},'UniformOutput',false))==0)) = [];
        if numel(t1_convpath)~=1;keyboard;end
        if strcmp(func_session(iSess).func_dir,'func')
            t1_newpath = fullfile(t1_dir,['T1_',INFO.subjects{iSubj},'.nii']);
        else    % for multiple session, create a separate T1 copy of each session (for coregistration purposes)
            t1_newpath = fullfile(t1_dir,['T1_',INFO.subjects{iSubj},'_',raw_func_dirs{iSess},'.nii']);
        end
        copyfile(t1_convpath.name,t1_newpath);
        
        %% do preprocessing
        load preproc_example_job_control
        % 1) check the combined images for spikes
        matlabbatch{1}.dmb{1}.check_data_quality{1}.cfg_check_spikes.data = {};
        for i = 1:numel(converted_vols)
            matlabbatch{1}.dmb{1}.check_data_quality{1}.cfg_check_spikes.data{i,1} = [fullfile(combined_dir,converted_vols(i).name),',1'];
        end
        matlabbatch{1}.dmb{1}.check_data_quality{1}.cfg_check_spikes.output_dir = {func_session(iSess).spike_outputdir};
        % 2) do slice timing (works with dependencies, therefore no input here)
        % 3) coregister mean functional (echo 1) to func template and apply to all functional images
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
        if ~exist(func_session(iSess).spike_outputdir); mkdir(func_session(iSess).spike_outputdir); end
        if ~exist(func_session(iSess).info_dir); mkdir(func_session(iSess).info_dir); end
        
        preproc_jobfile = fullfile(func_session(iSess).info_dir,[INFO.subjects{iSubj},'_preproc_job.mat']);
        save(preproc_jobfile,'matlabbatch');
        fprintf(' ->saved preprocessing jobfile: %s\n',preproc_jobfile);
        cd(func_session(iSess).func_dir);
        if INFO.preproc.run_immediately
            fprintf(' ->running jobfile: %s\n',preproc_jobfile);
            spm_jobman('run',matlabbatch);
        else
            fprintf(' ->Chosen not to execute jobs immediately, skipping compartment signal part of the job because it relies on files generated by the batch');
            return
        end
        
        %% get compartment signals & combine with realignment regressors
        if strcmp(raw_func_dirs{iSess},'func')
            newsegment_dir = fullfile(t1_dir,'new_segment');
        else
            newsegment_dir = fullfile(t1_dir,'new_segment_',raw_func_dirs{iSess});
        end
        if ~exist(newsegment_dir); mkdir(newsegment_dir); end
        newsegment_t1_path = fullfile(newsegment_dir,['T1_',INFO.subjects{iSubj},'.nii']);
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
        
        matlabbatch{5}.dmb{1}.nuisance_regressors{1}.segment_regressors.directory{1}{1} = func_session(iSess).info_dir; % save compsig regressors to info dir
        rmfield(matlabbatch{6}.dmb{1}.nuisance_regressors{1}.deriv_mov_pars,'regressor')
        matlabbatch{6}.dmb{1}.nuisance_regressors{1}.deriv_mov_pars.regressors = {rp_newpath};
        
        % Combine regressors: movement + movement 1st deriv + compartment
        % signals
        matlabbatch{7}.dmb{1}.nuisance_regressors{1}.combine_regressors.subj_info.target_dir{1} = func_session(iSess).info_dir;
        matlabbatch{7}.dmb{1}.nuisance_regressors{1}.combine_regressors.filename = [INFO.subjects{iSubj},'_rp_rp1stderiv_compsig'];
        matlabbatch{7}.dmb{1}.nuisance_regressors{1}.combine_regressors.target_dir = {func_session(iSess).info_dir};
        
        % Combine regressors: movement + movement 1st deriv
        matlabbatch{8}.dmb{1}.nuisance_regressors{1}.combine_regressors.subj_info.target_dir{1} = func_session(iSess).info_dir;
        matlabbatch{8}.dmb{1}.nuisance_regressors{1}.combine_regressors.filename = [INFO.subjects{iSubj},'_rp_rp1stderiv'];
        matlabbatch{8}.dmb{1}.nuisance_regressors{1}.combine_regressors.target_dir = {func_session(iSess).info_dir};
        
        compsig_jobfile = fullfile(func_session(iSess).info_dir,[INFO.subjects{iSubj},'_compsig_job.mat']);
        save(compsig_jobfile,'matlabbatch');
        spm_jobman('run',matlabbatch);
        
        raw_func_dir = get_func_dir(iSubj,iSess);
        fb_cleanup_in_between_niis(func_session(iSess).func_dir,raw_func_dir,INFO.preproc.cleanup_funcs.savelast,INFO.preproc.cleanup_funcs.what2delete,INFO.preproc.cleanup_funcs.feedback);
    end % loop over functional sessions
end % loop over subjects




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Other functions
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function initialise_SPM
% initialises SPM and the toolboxes we need

spm fmri; % initialise SPM
addpath(genpath('/home/common/matlab/spm_batch/fraleo/dmb'));
% [p1,p2,p3] = fileparts(mfilename('fullpath'));
% addpath(p1); % add the path from which we run this function again to make sure that custom batch functions are used from this path
cfg_util('addapp', dmb_cfg);

function raw_func_dir = get_func_dir(iSubj,iSess);

global INFO
% load file info that was save by fb_copy_mridata
batch_info_savefolder = fullfile(INFO.dir.exp_root,INFO.subjects{iSubj},INFO.dir.info.batch);
batch_info_savefile = fullfile(batch_info_savefolder,INFO.raw_data.filename.subject_info);
if ~exist(batch_info_savefile); error(['file ',batch_info_savefile,' does not exist. Run fb_copy_mridata first']); end
subj_info           = load(batch_info_savefile);

% find the folders with functional data in them
[u_dirs,o2,o3] = unique(subj_info.target_subdirs);
u_types = subj_info.target_subdirs_type(o2);
subdirs2exclude = [find(cellfun(@isempty,cellfun(@findstr,u_dirs,repmat({'excess'},size(u_dirs)),'UniformOutput',false))==0),...
    find(cellfun(@isempty,cellfun(@findstr,u_dirs,repmat({'delete'},size(u_dirs)),'UniformOutput',false))==0)];
u_dirs(subdirs2exclude) = [];
u_types(subdirs2exclude) = [];
func_idx = find(ismember(u_dirs,INFO.raw_data.filetypes.func.session_names));
raw_func_dirs = u_dirs(func_idx);

raw_func_dir = fullfile(subj_info.target_dir,raw_func_dirs{iSess});
