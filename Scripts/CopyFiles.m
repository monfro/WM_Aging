%%Copy relevant log files for DST and WM
clear all, close all, clc

%input: Which task
task = input('Which task? WMAG(1)/CogED(2)?');

%define directories.
rootdir = 'H:\';
studydir = fullfile(rootdir,'control\mirblo\Documents\FOCOM\Tyrosine_Aging_Study\Tyrosine_Aging_Study\Log');
cd(studydir)

destdir = 'M:\B_PhD\Tyro_Old\TYR_data\';

if task == 1
    destfolder = 'WMAG';
    if ~exist(fullfile(destdir,destfolder),'dir')
    mkdir(fullfile(destdir,destfolder));end
elseif task == 2
    destfolder = 'CogED';
    if ~exist(fullfile(destdir,destfolder),'dir')
    mkdir(fullfile(destdir,destfolder));end
else disp('Wrong Input');
end

%define source folder and file
status_all = zeros(30,2);
for SubNum = 1%
     for Day = 1:2
         
sourcefolder = fullfile(studydir,sprintf('TYR_S%d',SubNum),sprintf('Day%d',Day));
if task == 1
    sourcefile = fullfile(sourcefolder, sprintf('WMAG_FMRI_data_s%d_session_%d.mat',SubNum,Day));
%     if ~exist(fullfile(sourcefolder, sourcefile),'file')
%         sourcefile = sprintf('WMAG_data_prep_s%dsession_%d.mat',SubNum,Day); end
elseif task == 2
    sourcefile = sprintf('TYR_nback_s%d_d%d.mat',SubNum,Day);
end

%Copy files
[status] = copyfile(sourcefile,fullfile(destdir,destfolder));
status_all(SubNum, Day) = status;
    end
end

cd(fullfile(destdir, destfolder))
save('copydata')