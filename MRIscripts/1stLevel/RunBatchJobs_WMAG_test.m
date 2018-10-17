% List of open inputs
% Run Batch Jobs: String - cfg_entry
% Run Batch Jobs: Directory - cfg_files
% Run Batch Jobs: MATLAB .mat Files - cfg_files
% Run Batch Jobs: Any Files - cfg_files
% Run Batch Jobs: MATLAB .mat Files - cfg_files
% Run Batch Jobs: String - cfg_entry
% Run Batch Jobs: Directory - cfg_files
% Run Batch Jobs: MATLAB .mat Files - cfg_files
% Run Batch Jobs: Any Files - cfg_files
% Run Batch Jobs: MATLAB .mat Files - cfg_files
% Run Batch Jobs: Batch Filename Stub - cfg_entry
nrun = X; % enter the number of runs here
jobfile = {'/home/control/monfro/B_PhD/Tyro_Old/WMAG/WMAG_analysis/MRIscripts/1stlevel/RunBatchJobs_WMAG_test_job.m'};
jobs = repmat(jobfile, 1, nrun);
inputs = cell(11, nrun);
for crun = 1:nrun
    inputs{1, crun} = MATLAB_CODE_TO_FILL_INPUT; % Run Batch Jobs: String - cfg_entry
    inputs{2, crun} = MATLAB_CODE_TO_FILL_INPUT; % Run Batch Jobs: Directory - cfg_files
    inputs{3, crun} = MATLAB_CODE_TO_FILL_INPUT; % Run Batch Jobs: MATLAB .mat Files - cfg_files
    inputs{4, crun} = MATLAB_CODE_TO_FILL_INPUT; % Run Batch Jobs: Any Files - cfg_files
    inputs{5, crun} = MATLAB_CODE_TO_FILL_INPUT; % Run Batch Jobs: MATLAB .mat Files - cfg_files
    inputs{6, crun} = MATLAB_CODE_TO_FILL_INPUT; % Run Batch Jobs: String - cfg_entry
    inputs{7, crun} = MATLAB_CODE_TO_FILL_INPUT; % Run Batch Jobs: Directory - cfg_files
    inputs{8, crun} = MATLAB_CODE_TO_FILL_INPUT; % Run Batch Jobs: MATLAB .mat Files - cfg_files
    inputs{9, crun} = MATLAB_CODE_TO_FILL_INPUT; % Run Batch Jobs: Any Files - cfg_files
    inputs{10, crun} = MATLAB_CODE_TO_FILL_INPUT; % Run Batch Jobs: MATLAB .mat Files - cfg_files
    inputs{11, crun} = MATLAB_CODE_TO_FILL_INPUT; % Run Batch Jobs: Batch Filename Stub - cfg_entry
end
spm('defaults', 'FMRI');
spm_jobman('run', jobs, inputs{:});
