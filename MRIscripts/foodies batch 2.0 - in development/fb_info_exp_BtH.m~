function info_exp
%--------------------------------------------------------------------------
% Put all info on your experiment in this file
%--------------------------------------------------------------------------

global INFO;

%% Subject info
selection                   = 1;
all_subjects                = {'testsubj2'};
INFO.subjects               = all_subjects(selection);          % contains an array of subjectnames (and in effect the names of the subject directories)
 
%% Data series information
INFO.raw_data.overwrite                         = true;      % overwrite in case the data already was copied?
INFO.raw_data.range_series_nr                   = [3 4]; % between which dots can we find the series number?

% names of the series (folder names will be based on these)
INFO.raw_data.filetypes.func.identifier_str     = 'multiecho'; % string to recognise file type by
INFO.raw_data.filetypes.func.session_names       = {'[1]Stroop','[2]Knutson','resting'};
% expected number of scans (min-max) for each of the series, used to
% determine which is which (use Inf if you only want to use a minimum
INFO.raw_data.filetypes.func.session_expected_nscans    = [300 400;500 Inf;266 266];
% typical order of series within scanning session (in case expected_nscans did not provide a definitive answer
INFO.raw_data.filetypes.func.session_order       = [2 3 1];
% add other file types by (part of) the name of the protocol name
INFO.raw_data.filetypes.T1.identifier_str       = 't1'; % string to recognise file type by
INFO.raw_data.filetypes.DTI.identifier_str      = 'diff'; % string to recognise file type by

INFO.raw_data.filename.subject_info             = 'fb_copy_mridata_info.mat';

%% Directory information
INFO.dir.exp_root           = '/home/language/jooweg/FOCOM/other projects/foodies batch/foodies batch 2.0/testdata Lieneke'; % root folder for the experiment containing subject subfolders
INFO.dir.raw_data           = 'fmri_raw';     % directory with the original images, these stay untouched and are copied to series directories
INFO.dir.info.root_suffix   = 'info';       % root folder suffix (will be appended after series name
INFO.dir.info.batch         = 'batch';      % batch info subfolder name inside info dir
INFO.dir.info.spike         = 'spike';      % spike subfolder name inside info dir
INFO.dir.multiecho.combined = 'PAID_data';  % name of combined volumes directory
INFO.dir.multiecho.converted= 'converted_Volumes';  % name of converted volumes directory

%% Preprocessing information
INFO.preproc.run_immediately            = true;        % run preprocessing immediately (true) or save the jobs to run later (false)?
INFO.preproc.cleanup_funcs              = true;         % clean up functional scans when they are no longer needed?
INFO.preproc.suffix.func                = 'func';
INFO.preproc.suffix.info                = 'info';
INFO.preproc.multiecho.nPrescans        = 30;           % number of volumes to use as prescans
INFO.preproc.multiecho.smoothing        = 1;            % smooth the prescans before determining weights?
INFO.preproc.multiecho.smoothKernelRatio= 1.2;          % size of the smoothing kernel, expressed as a ratio of the voxel size of the functional volumes
