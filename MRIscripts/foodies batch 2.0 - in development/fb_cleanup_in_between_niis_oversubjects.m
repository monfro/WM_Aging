function fb_cleanup_in_between_niis_oversubjects

global INFO
if isempty(whos('INFO')); error('Please provide INFO structure'); end   % check whether we have INFO structure

for iSubj = 1:numel(INFO.subjects)

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
    
    for iSess = 1:numel(raw_func_dirs) % loop over func datasets
        if strcmp(raw_func_dirs{iSess},'func')
            func_session(iSess).func_dir = fullfile(subj_info.target_dir,INFO.preproc.suffix.func);
            func_session(iSess).info_dir = fullfile(subj_info.target_dir,INFO.preproc.suffix.info);
        else
            func_session(iSess).func_dir = fullfile(subj_info.target_dir,[raw_func_dirs{iSess},'_',INFO.preproc.suffix.func]);
            func_session(iSess).info_dir = fullfile(subj_info.target_dir,[raw_func_dirs{iSess},'_',INFO.preproc.suffix.info]);
        end
        
        
        raw_func_dir = get_func_dir(iSubj,iSess);
        fb_cleanup_in_between_niis(func_session(iSess).func_dir,raw_func_dir,INFO.preproc.cleanup_funcs.savelast,INFO.preproc.cleanup_funcs.what2delete,INFO.preproc.cleanup_funcs.feedback);
    end % loop over functional sessions
end % loop over subjects

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Other functions
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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