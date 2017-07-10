function info_exp
%--------------------------------------------------------------------------
% Put all info on your experiment in this file
%--------------------------------------------------------------------------

global INFO;

%% Subject info
selection                   = 1;
all_subjects                = {'S01','S02','S03','S04','S05','S06','S07','S08','S09','S10','S11','S12','S13','S14','S15','S16','S17','S18','S19'};
INFO.subjects               = all_subjects(selection);          % contains an array of subjectnames (and in effect the names of the subject directories)
 
%% Data series information
INFO.series.func.names           = {'

%% Directory structure
INFO.dir.raw_data           = 'dicoms';     % directory with the original images, these stay untouched and are copied to series directories
INFO.dir.info.root_suffix   = 'info';       % root folder suffix (will be appended after series name
INFO.dir.info.batch         = 'batch';      % batch info subfolder name inside info dir
INFO.dir.info.spike         = 'spike';      % spike subfolder name inside info dir

