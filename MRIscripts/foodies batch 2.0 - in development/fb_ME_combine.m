function fb_ME_combine

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
    
    % find the folders with functional data in them
    [u_dirs,o2,o3] = unique(subj_info.target_subdirs);
    u_types = subj_info.target_subdirs_type(o2);
    subdirs2exclude = [find(cellfun(@isempty,cellfun(@findstr,u_dirs,repmat({'excess'},size(u_dirs)),'UniformOutput',false))==0),...
        find(cellfun(@isempty,cellfun(@findstr,u_dirs,repmat({'delete'},size(u_dirs)),'UniformOutput',false))==0)];
    u_dirs(subdirs2exclude) = [];
    u_types(subdirs2exclude) = [];
    func_idx = find(ismember(u_dirs,INFO.raw_data.filetypes.func.session_names));
    raw_func_dirs = u_dirs(func_idx);
    
    fileseps = findstr(filesep,subj_info.target_dir);
    
    for iSess = 1:numel(raw_func_dirs) % loop over func datasets
        %% combine echoes
        if strcmp(raw_func_dirs{iSess},'func')
            func_session(iSess).func_dir = fullfile(subj_info.target_dir,INFO.preproc.suffix.func);
            func_session(iSess).info_dir = fullfile(subj_info.target_dir,INFO.preproc.suffix.info);
        else
            func_session(iSess).func_dir = fullfile(subj_info.target_dir,[raw_func_dirs{iSess},'_',INFO.preproc.suffix.func]);
            func_session(iSess).info_dir = fullfile(subj_info.target_dir,[raw_func_dirs{iSess},'_',INFO.preproc.suffix.info]);
        end
        func_session(iSess).spike_outputdir = fullfile(func_session(iSess).info_dir,INFO.dir.info.spike);
        
        if ~exist(func_session(iSess).func_dir); mkdir(func_session(iSess).func_dir); end;
        if ~exist(func_session(iSess).info_dir); mkdir(func_session(iSess).info_dir); end;
        if ~exist(func_session(iSess).spike_outputdir); mkdir(func_session(iSess).spike_outputdir); end;
        
        raw_func_dir = fullfile(subj_info.target_dir,raw_func_dirs{iSess});
        % get voxel size to determine smoothing kernel
        funcs = dir(raw_func_dir);
        func_info = dicominfo(fullfile(raw_func_dir,funcs(3).name));
        if numel(unique(func_info.PixelSpacing)) > 1; keyboard; end; % check for isotropic voxels in x and y dimensions
        MEsmoothKernelSize = INFO.preproc.multiecho.smoothKernelRatio * func_info.PixelSpacing(1);
        
        % find the number of echoes for this session
        nEchoes = max(subj_info.func_series_echonrs(find(subj_info.func_series==iSess)));


        fprintf(' -> combining echoes from folder %s (into folder %s)\n',raw_func_dir,func_session(iSess).func_dir);
        % ME_Combine_commandline(sourcePath,targetPath,numberOfEchoes,WeightVol
        % umes,prescanPath,numberOfRuns,smoothing,KernelSize)
        ME_Combine_commandline_checkspikes(raw_func_dir,func_session(iSess).func_dir,nEchoes,INFO.preproc.multiecho.nPrescans,[],1,INFO.preproc.multiecho.smoothing,MEsmoothKernelSize);
        
        % clean up func folder if desired
        if ismember(1,INFO.preproc.cleanup_funcs.what2delete)
            fb_cleanup_in_between_niis(func_session(iSess).func_dir,raw_func_dir,INFO.preproc.cleanup_funcs.savelast,1,INFO.preproc.cleanup_funcs.feedback);
        end

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

