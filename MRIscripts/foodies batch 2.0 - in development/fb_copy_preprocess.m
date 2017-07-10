function fb_copy_preprocess

global INFO;
dbstop if error

fb_info_exp_BtH;        % get INFO structure
if isempty(whos('INFO')); error('Please provide INFO structure'); end   % check whether we have INFO structure

% fb_copy_mridata;        % copy and order the MRI data files
initialise_SPM;         % initialize SPM and toolboxes
% fb_ME_combine;          % combine multiecho data
fb_preprocess_ip;          % do preprocessing of imaging data
% not finished yet - fb_compsig;             % get compartments signals and combine them with realignment regressors


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

