function fb_copy_preprocess

global INFO;
dbstop if error

fb_info_exp_TYR;        % get INFO structure
if isempty(whos('INFO')); error('Please provide INFO structure'); end   % check whether we have INFO structure

if INFO.preproc.run_per_subject
    % if the analyses are run per subject (disk space friendlier), we pass
    % each subject to the script separately
    allsubjects = INFO.subjects;
    for iSubj = 1:numel(allsubjects)
        INFO.subjects = allsubjects(iSubj);
        run_preprocess_steps;
    end
else
    run_preprocess_steps;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Other functions
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function run_preprocess_steps

global INFO

fb_copy_mridata_TYR;    % copy and order the MRI data files
initialise_SPM;         % initialize SPM and toolboxes
fb_ME_combine;          % combine multiecho data
fb_preprocess;          % do preprocessing of imaging data
fb_plot_subject_movement;   % plot subject movement


function initialise_SPM
% initialises SPM and the toolboxes we need

spm fmri; % initialise SPM
addpath(genpath('/home/common/matlab/spm_batch/fraleo/dmb'));
% [p1,p2,p3] = fileparts(mfilename('fullpath'));
% addpath(p1); % add the path from which we run this function again to make sure that custom batch functions are used from this path
cfg_util('addapp', dmb_cfg);

