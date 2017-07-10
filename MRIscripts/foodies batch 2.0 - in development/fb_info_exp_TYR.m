function info_exp
%--------------------------------------------------------------------------
% Put all info on your experiment in this file
%--------------------------------------------------------------------------

global INFO;

%% Subject info
subjects2do                 = 16; 
session                    = 2;
selection                   = 1:numel(subjects2do);
all_subjects = {};
for s = 1:numel(subjects2do)
    all_subjects = [all_subjects,sprintf('3017030.06_TYR_S%g%02.0f_test',subjects2do(s), session)];
end
%all_subjects                = {'pp2'};
INFO.subjects               = all_subjects(selection);          % contains an array of subjectnames (and in effect the names of the subject directories)
 
%% Data series information
INFO.raw_data.overwrite                         = true;      % overwrite in case the data already was copied?
INFO.raw_data.range_series_nr                   = [3 4]; % between which dots can we find the series number?

% names of the series (folder names will be based on these)
INFO.raw_data.filetypes.func.identifier_str     = 'multiecho'; % string to recognise file type by
INFO.raw_data.filetypes.func.session_names       = {'Stop', 'WMAG'};
% expected number of scans (min-max) for each of the series, used to
% determine which is which (use Inf if you only want to use a minimum
INFO.raw_data.filetypes.func.session_expected_nscans    = [1000 Inf; 0 999];
% typical order of series within scanning session (in case expected_nscans did not provide a definitive answer
INFO.raw_data.filetypes.func.session_order       = [1 2];
% add other file types by (part of) the name of the protocol name
INFO.raw_data.filetypes.T1.identifier_str       = 't1'; % string to recognise file type by
INFO.raw_data.filetypes.DTI.identifier_str      = 'diff'; % string to recognise file type by

INFO.raw_data.filename.subject_info             = 'fb_copy_mridata_info.mat';

%% Directory information
INFO.dir.exp_root           = '/home/control/mirblo/Documents/TYR_MRI_data'; % root folder for the experiment containing subject subfolders
INFO.dir.raw_data           = 'dicoms';     % directory with the original images, these stay untouched and are copied to series directories
INFO.dir.info.root_suffix   = 'info';       % root folder suffix (will be appended after series name
INFO.dir.info.batch         = 'batch';      % batch info subfolder name inside info dir
INFO.dir.info.spike         = 'spike';      % spike subfolder name inside info dir
INFO.dir.multiecho.combined = 'PAID_data';  % name of combined volumes directory
INFO.dir.multiecho.converted= 'converted_Volumes';  % name of converted volumes directory

%% Preprocessing information
INFO.preproc.run_immediately            = true;        % run preprocessing immediately (true) or save the jobs to run later (false)?
% clean up functional scans when they are no longer needed?
% Options to delete (combine all desired into vector)
% 1) copied raw files 2) converted separate echoes 3) realigned
% separate echoes 4) smoothed separate echoes
% 5) combined volumes 6) slide-time corrected combined
% volumes 7) normalised combined volumes
INFO.preproc.cleanup_funcs.what2delete  = [1,2,3,4,6,7];    % leave the combined volumes alone
INFO.preproc.cleanup_funcs.savelast     = true;             % keep last scan of each series during cleanup?
INFO.preproc.cleanup_funcs.feedback     = false;            % choose 'false' if you don't want to be asked questions during cleanup

INFO.preproc.suffix.func                = 'func';
INFO.preproc.suffix.info                = 'info';
INFO.preproc.multiecho.nPrescans        = 30;           % number of volumes to use as prescans
INFO.preproc.multiecho.smoothing        = true;            % smooth the prescans before determining weights?
INFO.preproc.multiecho.smoothKernelRatio= 1.2;          % size of the smoothing kernel, expressed as a ratio of the voxel size of the functional volumes

INFO.preproc.run_per_subject            = true;     % runs all preprocessing steps per subject, instead of all steps subsequently for all subjects