function varargout = ME_Combine_commandline_checkspikes(sourcePath,targetPath,numberOfEchoes,WeightVolumes,prescanPath,numberOfRuns,smoothing,KernelSize,checkspikes)
% command line version of ME_Combine_GUI
% usage:
% ME_Combine_commandline(sourcePath,targetPath,numberOfEchoes,WeightVolumes,prescanPath,numberOfRuns,smoothing,KernelSize,checkspikes)
% if less arguments are passed, these are the defaults:
%  sourcePath and targetPath will be asked
%  numberOfEchoes: 5
%  WeightVolumes: 30
%  prescanPath: no separate prescan folder
%  numberOfRuns: 1
%  smoothing: no
%  KernelSize: 3mm (if smoothing was manually chosen)
%  checkspikes: 2 (0 = don't check for spikes, 1 = only check, 2 = remove
%
% JooWeg - DCCN - 20130618

if ispc
    addpath('H:\common\matlab\multiecho\RB_ME_CombineGui');
else
    addpath('/home/common/matlab/multiecho/RB_ME_CombineGui');
end

%% Initialization %%
addpath('/home/common/matlab/spm8');
addpath(pwd);
warning off all
clc
if nargin > 0
    if (exist(sourcePath)~=7 || isempty(sourcePath))
        sourcePath = uigetdir(pwd, 'Select folder for DICOM data (INPUT)');
    end
else
    sourcePath = uigetdir(pwd, 'Select folder for DICOM data (INPUT)');
end

if nargin > 1
   if (exist(targetPath)~=7 || isempty(targetPath))
       targetPath = uigetdir(pwd, 'Select folder for NIFTI data (OUTPUT)');
   end
else
   targetPath = uigetdir(pwd, 'Select folder for NIFTI data (OUTPUT)');
end

if nargin < 3
    disp('No Input For # of Echoes, Assumed to be 5');
    numberOfEchoes = 5;
end

if nargin < 4
    disp('No Input For # of Weight Volumes, Assumed to be 30');
    WeightVolumes = 30;
end

if nargin < 5
    disp('No Input for prescanPath given, Assumed no separate prescan folder');
    prescanPath = '';
else
    if exist(prescanPath)~=7 && ~isempty(prescanPath)
        prescanPath = uigetdir(pwd, 'Select folder for Prescan (DICOM) data (INPUT)');
    end
end

if nargin < 6
    disp('No Input For # of Runs, Assumed to be 1');
    numberOfRuns = 1;
end

if nargin < 7
    disp('No smoothing input, Assumed no smoothing is desired');
    smoothing = false;
else
    if nargin < 8 & smoothing
        disp('No Input For the Size of Kernel, Assumed to be  3 mm');
        KernelSize = 3;
    end
end
if nargin < 9
    checkspikes = 2;
end

disp('Input parameters are checked!')

startVolume = 1;
cd(sourcePath);
TE = zeros(numberOfRuns,numberOfEchoes);

%% clear output folder %%
if exist([targetPath '/PAID_data']) == 7
    rmdir([targetPath '/PAID_data'],'s');
end
if exist([targetPath '/converted_Weight_Volumes']) == 7
    rmdir([targetPath '/converted_Weight_Volumes'],'s');
end
if exist([targetPath '/converted_Volumes']) == 7
    rmdir([targetPath '/converted_Volumes'],'s');
end
delete([targetPath '/*']);
disp('Output folder is cleared!')

%% Dicom2Nifti %%

if ~isempty(prescanPath) %% first, prescan volumes are converted
    cd([targetPath]); 
    mkdir('converted_Weight_Volumes');
    cd([prescanPath]);
    TE_prescan = RB_ME_PAID_Dicom2Nifti(prescanPath, numberOfRuns, size(TE,2));
    unix(['mv ' prescanPath '/*.nii ' targetPath '/converted_Weight_Volumes']);
    cd([sourcePath]);
end

cd([targetPath]);
mkdir('converted_Volumes');
cd([sourcePath]);
TE = RB_ME_PAID_Dicom2Nifti(pwd, numberOfRuns, size(TE,2));
filesToBeMoved = dir('*.nii');
filesToBeMoved = char(filesToBeMoved.name);
fileMoveForLinux(sourcePath, [targetPath '/converted_Volumes'], filesToBeMoved, 100);
disp('DICOMs are converted!')

%% Realignment %%

if isempty(prescanPath) %% there is no prescan
    cd([targetPath '/converted_Volumes']);
    disp('Realignment started')

    filesTemp = dir('*01.nii');
    files = char(zeros(length(filesTemp),length(filesTemp(1).name)+2,size(TE,2)));
    for i=startVolume:size(files,1)
        files(i,1:length(filesTemp(i).name),1) = filesTemp(i).name;
    end

    spm_realign(files(:,:,1)); %% first echo volumes is realigned to the first volume of first echo

    for j=2:size(TE,2)
        filesTemp = dir(['*' num2str(j) '.nii']); %% assuming number of echoes is less than 10!
        for i=startVolume:size(files(:,:,j),1)
            files(i,1:length(filesTemp(i).name),j) = filesTemp(i).name;
        end
    end
    
    % Transformation matrices of all volumes of all echoes 
    % (except first echo) are changed to the matrix of first echo,
    % thus, realigned.
    for i=1:size(files,1)
        V{1} = spm_get_space(files(i,:,1));
        for j=2:size(TE,2)
            spm_get_space(files(i,:,j),V{1});
        end
    end
        
    resliceFiles = dir('*.nii'); %% reslicing of all volumes
    resliceFiles = char(resliceFiles.name);
    spm_reslice(resliceFiles);
    
else  %% with prescan
    cd([targetPath '/converted_Weight_Volumes']); %% first, prescan volumes are realigned
    disp('Realignment of prescan volumes started')

    filesTemp = dir('*01.nii');
    filesPrescan = char(zeros(length(filesTemp),length(filesTemp(1).name)+2,size(TE,2)));
    for i=startVolume:size(filesPrescan,1)
        filesPrescan(i,1:length(filesTemp(i).name),1) = filesTemp(i).name;
    end
    
    cd([targetPath '/converted_Volumes']);
    
    filesTemp = dir('*01.nii');
    files = char(zeros(length(filesTemp),length(filesTemp(1).name)+2,size(TE,2)));
    for i=startVolume:size(files,1)
        files(i,1:length(filesTemp(i).name),1) = filesTemp(i).name;
    end
       
      
    cd([targetPath '/converted_Weight_Volumes']);
    filesToBeMoved = dir('*01.nii');
    filesToBeMoved = char(filesToBeMoved.name);
    fileMoveForLinux([targetPath '/converted_Weight_Volumes'], [targetPath '/converted_Volumes'], filesToBeMoved, 1000);
    
    cd([targetPath '/converted_Volumes']);
    filesFirstEcho = cat(1,filesPrescan(:,:,1),files(:,:,1));    
    spm_realign(filesFirstEcho(:,:,1)); %% first echo volumes are realigned to the first volume of first echo
    
    % move first echoes of prescan back to their original directory
    fileMoveForLinux([targetPath '/converted_Volumes/'], [targetPath '/converted_Weight_Volumes'], filesPrescan(:,1:end-2,1), 1000);
    
    cd([targetPath '/converted_Weight_Volumes']);
    
    for j=2:size(TE,2)
        filesTemp = dir(['*' num2str(j) '.nii']); %% assuming number of echoes is less than 10!
        for i=startVolume:size(filesPrescan(:,:,j),1)
            filesPrescan(i,1:length(filesTemp(i).name),j) = filesTemp(i).name;
        end
    end
 
    % Transformation matrices of all volumes of all echoes 
    % (except first echo) are changed to the matrix of first echo,
    % thus, realigned.
    for i=1:size(filesPrescan,1)
        VPrescan{1} = spm_get_space(filesPrescan(i,:,1));
        for j=2:size(TE,2)
            spm_get_space(filesPrescan(i,:,j),VPrescan{1});
        end
    end
    
    % Now, all the prescan volumes, also echoes 2,3,..
    % are realigned ==> by spm_getspace
    % now, taking them back to ..\converted volumes
    % to reslice, but this part should be implmeneted in a better and
    % efficient way
    
%     filesTemp = dir('*.nii');
%     filesPrescan = char(zeros(length(filesTemp),length(filesTemp(1).name)+2,size(TE,2)));
%     for i=startVolume:size(filesPrescan,1)
%         filesPrescan(i,1:length(filesTemp(i).name),1) = filesTemp(i).name;
%     end
        
%     resliceFiles = dir('*.nii'); %% reslicing of weight volumes
%     resliceFiles = char(resliceFiles.name);
%     spm_reslice(resliceFiles);
    
    cd([targetPath '/converted_Volumes']); %% all the other volumes are realigned
    disp('Realignment of all the other volumes started')
    
    for j=2:size(TE,2)
        filesTemp = dir(['*' num2str(j) '.nii']); %% assuming number of echoes is less than 10!
        for i=startVolume:size(filesTemp,1)
            files(i,1:length(filesTemp(i).name),j) = filesTemp(i).name;
        end
    end
    
    % Transformation matrices of all volumes of all echoes 
    % (except first echo) are changed to the matrix of first echo,
    % thus, realigned.
    for i=1:size(files,1)
        V{1} = spm_get_space(files(i,:,1));
        for j=2:size(TE,2)
            spm_get_space(files(i,:,j),V{1});
        end
    end
    
    for i=1:size(TE,2)        
        fileMoveForLinux([targetPath '/converted_Weight_Volumes'], [targetPath '/converted_Volumes'], filesPrescan(:,1:end-2,i), 1000);
    end
    
    
    cd([targetPath '/converted_Volumes']);
    
    resliceFiles = dir('*.nii'); %% reslicing of original scan volumes
    resliceFiles = char(resliceFiles.name);
    spm_reslice(resliceFiles);
    
    for i=1:size(TE,2)
        fileMoveForLinux([targetPath '/converted_Volumes'], [targetPath '/converted_Weight_Volumes'], filesPrescan(:,1:end-2,i), 1000);
        fileMoveForLinux([targetPath '/converted_Volumes'], [targetPath '/converted_Weight_Volumes'], cat(2,repmat('r',[WeightVolumes 1]),filesPrescan(:,1:end-2,i)), 1000);
    end
    
end

disp('Realignment finished!')

%% Check spikes - added by jooweg
if checkspikes
    converted_path = fullfile(targetPath,'converted_Volumes');
    output_dir = fullfile(converted_path,'spike');
    if ~exist(output_dir); mkdir(output_dir); end;
    cd(converted_path);

    % include fraleo's batch
    addpath(genpath(fullfile(filesep,'home','common','matlab','spm_batch','fraleo','dmb')));
    cfg_util('addapp', dmb_cfg);
    
    for i=1:size(TE,2)  % find all scans per echo time
        curr_echo_files = dir(['r*0',num2str(i),'.nii']);
        curr_output_dir = fullfile(output_dir,['E',num2str(i)]);
        if ~exist(curr_output_dir); mkdir(curr_output_dir); end;
        
        % fill and run spike check job
        clear matlabbatch
        load example_spikecheck_job
        matlabbatch{1}.dmb{1}.check_data_quality{1}.cfg_check_spikes.data = {};
        for f = 1:numel(curr_echo_files)
            matlabbatch{1}.dmb{1}.check_data_quality{1}.cfg_check_spikes.data{f,1} = ...
                [fullfile(converted_path,curr_echo_files(f).name),',1'];
        end
        matlabbatch{1}.dmb{1}.check_data_quality{1}.cfg_check_spikes.files = {matlabbatch{1}.dmb{1}.check_data_quality{1}.cfg_check_spikes.data};
        
        fileseps = findstr(filesep,targetPath);
        subject_name = targetPath(fileseps(end-1)+1:fileseps(end)-1);
        matlabbatch{1}.dmb{1}.check_data_quality{1}.cfg_check_spikes.subject = subject_name;
        if checkspikes == 1
            matlabbatch{1}.dmb{1}.check_data_quality{1}.cfg_check_spikes.mode = 'check';
        else
            matlabbatch{1}.dmb{1}.check_data_quality{1}.cfg_check_spikes.mode = 'remove';
        end
        matlabbatch{1}.dmb{1}.check_data_quality{1}.cfg_check_spikes.output_dir = {curr_output_dir};
        save(fullfile(output_dir,['spikecheck_echo',num2str(i),'_job.mat']),'matlabbatch');
        spm_jobman('run',matlabbatch);
    end
end

%% Smoothing %%
if smoothing
    smoothingPrefix = 's';
    if isempty(prescanPath) %% there is no prescan
        for j=1:size(TE,2)    
            for i=startVolume:startVolume+WeightVolumes-1
                spm_smooth(['r' files(i,:,j)],['s' files(i,:,j)],KernelSize);
            end
        end
    else %% with prescan
        cd([targetPath '/converted_Weight_Volumes']);
        for j=1:size(TE,2)    
            for i=startVolume:startVolume+WeightVolumes-1
                spm_smooth(['r' filesPrescan(i,:,j)],['s' filesPrescan(i,:,j)],KernelSize);
            end
        end
        cd([targetPath '/converted_Volumes']);
    end
    disp('Smoothing is applied to weight calculation volumes')
end
%%

%% Weight Calculation%%

dimVolume = spm_vol(files(1,:,1));
dim = dimVolume.dim;

for i=1:size(TE,2)
    volume4D(:,:,:,:,i) = zeros(dim(1),dim(2),dim(3),WeightVolumes);
end

smoothingPrefix = 'r';
if isempty(prescanPath) %% there is no prescan
    for i=startVolume:startVolume+WeightVolumes-1
        for j=1:size(TE,2)
            V{j} = spm_vol([smoothingPrefix files(i,:,j)]);
            volume4D(:,:,:,i-(startVolume-1),j) = spm_read_vols(V{j});       
        end
    end
else
    cd([targetPath '/converted_Weight_Volumes']);
    for i=startVolume:startVolume+WeightVolumes-1
        for j=1:size(TE,2)
            V{j} = spm_vol([smoothingPrefix filesPrescan(i,:,j)]);
            volume4D(:,:,:,i-(startVolume-1),j) = spm_read_vols(V{j});       
        end
    end
    cd([targetPath '/converted_Volumes']);
end

for j=1:size(TE,2)
     tSNR(:,:,:,j) = mean(volume4D(:,:,:,:,j),4)./std(volume4D(:,:,:,:,j),0,4);
     CNR(:,:,:,j) = tSNR(:,:,:,j) * TE(1,j); %% assuming all runs have the same TEs!!
end

CNRTotal = sum(CNR,4);

for i=1:size(TE,2)
    weight(:,:,:,i) = CNR(:,:,:,i) ./ CNRTotal;
end

for i=startVolume:startVolume+size(files,1)-1
    
    for j=1:size(TE,2)
        V{j} = spm_vol(['r' files(i,:,j)]);
    end    
    
    newVolume = V{1};
    if i<10
        newVolume.fname = ['M_volume_000' num2str(i) '.nii'];
    elseif i<100
        newVolume.fname = ['M_volume_00' num2str(i) '.nii'];
    elseif i<1000
        newVolume.fname = ['M_volume_0' num2str(i) '.nii'];
    else
        newVolume.fname = ['M_volume_' num2str(i) '.nii'];
    end
    
    I_weighted = zeros(newVolume.dim);
    for j=1:size(TE,2)
        I(:,:,:,j) = spm_read_vols(V{j});
        I_weighted = I_weighted + I(:,:,:,j).*weight(:,:,:,j); 
    end        
      
    spm_create_vol(newVolume);
    spm_write_vol(newVolume,I_weighted);
    
end
cd(targetPath);
mkdir('PAID_data');
cd([targetPath '/converted_Volumes']);

filesToBeMoved = dir('M_volume*');
filesToBeMoved = char(filesToBeMoved.name);
fileMoveForLinux([targetPath '/converted_Volumes'], [targetPath '/PAID_data'], filesToBeMoved, 1000);

filesToBeMoved = dir('*.txt');
filesToBeMoved = char(filesToBeMoved.name);
fileMoveForLinux([targetPath '/converted_Volumes'], [targetPath '/PAID_data'], filesToBeMoved, 1000);

disp('Volumes are combined!')

%% Delete unnecessary output files %%
% if ((get(checkbox1,'Value')) == 1)
%     filesTemp = dir('PAID_data/*.nii');
%     cd([targetPath '/PAID_data']);
%     filesTemp = dir('*.nii');
%     for i=1:WeightVolumes
%         delete([targetPath '/PAID_data/' filesTemp(i).name]);
%     end
% end
