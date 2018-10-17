clear 
clc

datadir = '/home/control/monfro/B_PhD/Tyro_Old/WMAG/WMAG_data/';  %data
analydir = '/home/control/monfro/B_PhD/Tyro_Old/WMAG/WMAG_analysis/'; %code and analysis output

addpath(datadir)
addpath(analydir)

load(fullfile(datadir, 'Others', 'DrugDecoding_Oct2018.mat'))
Subjects = DrugDecoding.AnalysisWM_mri(:,1);
n = length(Subjects);
%for check, put n to 1


%spm_jobman('initcfg');

for i = 26 %28
    
    nrun = 1; % enter the number of runs here
    jobfile = {'/home/control/monfro/B_PhD/Tyro_Old/WMAG/WMAG_analysis/MRIscripts/1stlevel/RunBatchJobs_WMAG_job.m'};
    jobs = repmat(jobfile, 1, nrun);
    inputs = cell(11, nrun);

    for crun = 1:nrun
        %session 1
        inputs{1, crun} = sprintf('3017030.06_TYR_S%.2d01', Subjects(i)); % Run Batch Jobs: String - cfg_entry
        inputs{2, crun} = {fullfile(datadir, 'fMRI', sprintf('3017030.06_TYR_S%.2d01', Subjects(i)), 'func_WMAG','PAID_data')}; % Run Batch Jobs: Directory - cfg_files
        inputs{3, crun} = {fullfile(analydir, 'Onsets','OnsetFiles',sprintf('NamOnsDur_s%d_session_1.mat', Subjects(i)))}; % Run Batch Jobs: MATLAB .mat Files - cfg_files
        inputs{4, crun} = {fullfile(datadir, 'fMRI',sprintf('3017030.06_TYR_S%.2d01', Subjects(i)), 'func_WMAG','PAID_data', sprintf('rp_3017030.06_TYR_S%.2d01_31_onwards.txt',Subjects(i)))}; % Run Batch Jobs: Any Files - cfg_files
        inputs{5, crun} = {fullfile(datadir, 'fMRI',sprintf('3017030.06_TYR_S%.2d01', Subjects(i)), 'func_WMAG','PAID_data', sprintf('rp_3017030.06_TYR_S%.2d01_31_onwards_deriv1.mat',Subjects(i)))}; % Run Batch Jobs: Any Files - cfg_files
        %session 2
        inputs{6, crun} = sprintf('3017030.06_TYR_S%.2d02', Subjects(i));  % Run Batch Jobs: String - cfg_entry
        inputs{7, crun} = {fullfile(datadir, 'fMRI', sprintf('3017030.06_TYR_S%.2d02', Subjects(i)), 'func_WMAG','PAID_data')}; % Run Batch Jobs: Directory - cfg_files
        inputs{8, crun} = {fullfile(analydir, 'Onsets','OnsetFiles',sprintf('NamOnsDur_s%d_session_2.mat', Subjects(i)))}; % Run Batch Jobs: MATLAB .mat Files - cfg_files
        inputs{9, crun} = {fullfile(datadir, 'fMRI',sprintf('3017030.06_TYR_S%.2d02', Subjects(i)), 'func_WMAG','PAID_data', sprintf('rp_3017030.06_TYR_S%.2d02_31_onwards.txt',Subjects(i)))}; % Run Batch Jobs: Any Files - cfg_files
        inputs{10, crun} = {fullfile(datadir, 'fMRI',sprintf('3017030.06_TYR_S%.2d02', Subjects(i)), 'func_WMAG','PAID_data', sprintf('rp_3017030.06_TYR_S%.2d02_31_onwards_deriv1.mat',Subjects(i)))}; % Run Batch Jobs: MATLAB .mat Files - cfg_files
        %save batch
        inputs{11, crun} = sprintf('WMAG_FirstLevel_Job_S%.2d', Subjects(i)); % Run Batch Jobs: Batch Filename Stub - cfg_entry
    end
    
    spm('defaults', 'FMRI');
    spm_jobman('run', jobs, inputs{:});

end %participant
