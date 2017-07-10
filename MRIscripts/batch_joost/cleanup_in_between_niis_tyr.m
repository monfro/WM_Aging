function cleanup_in_between_niis(folder,savelast,what2delete)
% usage: cleanup_in_between_niis(folder,savelast,what2delete)
% savelast        keep last scan of each series?
% what2delete     vector of delete options (see script for details)

if nargin < 3
    what2delete = [2,3,4,5,6,7,8,9,10,11,12,13,14,15];
end
if nargin < 2
    savelast = true;
end
if nargin < 1
    folder = uigetdir;
end
how2delete = 'linux_find'; % 'linux_find lets linux do the searching, 'linux_sep' lets matlab do the searching (warning: slower)

% options for what to delete
options2delete = {...
    fullfile(folder),'*.IMA';...                     % option 1
    fullfile(folder,'Stop'),'*.IMA';...                          % option 2    
    fullfile(folder,'WMAG'),'*.IMA';...                           % option 3
    fullfile(folder,'func_WMAG','converted_Volumes'),'f*.nii';...    % option 4
    fullfile(folder,'func_WMAG','converted_Volumes'),'rf*.nii';...   % option 5
    fullfile(folder,'func_WMAG','converted_Volumes'),'sf*.nii';...   % option 6
    fullfile(folder,'func_WMAG','PAID_data'),'M*.nii';...            % option 7
    fullfile(folder,'func_WMAG','PAID_data'),'aM*.nii';...           % option 8
    fullfile(folder,'func_WMAG','PAID_data'),'waM*.nii';...          % option 9
    fullfile(folder,'func_Stop','converted_Volumes'),'f*.nii';...    % option 10
    fullfile(folder,'func_Stop','converted_Volumes'),'rf*.nii';...   % option 11
    fullfile(folder,'func_Stop','converted_Volumes'),'sf*.nii';...   % option 12
    fullfile(folder,'func_Stop','PAID_data'),'M*.nii';...            % option 13
    fullfile(folder,'func_Stop','PAID_data'),'aM*.nii';...           % option 14
    fullfile(folder,'func_Stop','PAID_data'),'waM*.nii';...          % option 15
    };

oldfolder = cd;

% check whether dicom folder is there
dicomfolder = fullfile(folder,'dicoms');
if ~exist(dicomfolder)
    choice = 1;%MB aangepast menu('DICOMs folder does not exist, are you sure you want to continue?','Yes','No');
    if choice == 2
        return;
    end
else
    cd(dicomfolder)
    f = dir;
    if numel(f) <3
        choice = menu('DICOMs folder is empty, are you sure you want to continue?','Yes','No');
        if choice == 2
            return;
        end
    end
end
        
diskspacegained = 0;
for i = 1:numel(what2delete)
    currfolder = options2delete{what2delete(i),1};
    if exist(currfolder)
        cd(currfolder);
        currfiles = dir(options2delete{what2delete(i),2});
        
        if numel(currfiles)
            if savelast
                eval(['!cp ',currfiles(end).name,' ',['last_',currfiles(end).name]]);
            end
            switch how2delete
                case 'linux_sep'
                    h = waitbar(0,'deleting files');
                    for j = 1:numel(currfiles)
                        eval(['!rm ',currfiles(j).name]);
                        waitbar(j/numel(currfiles));
                    end
                    close(h);
                case 'linux_find'
                    eval(['!rm ',options2delete{what2delete(i),2}]);
            end
            fprintf('deleted %g files (%g MB) searching for %s in %s\n',numel(currfiles),round(sum([currfiles.bytes])/1024^2),options2delete{what2delete(i),2},currfolder);
        else
            fprintf('no files found in %s for search query %s\n',currfolder,options2delete{what2delete(i),2});
        end
        diskspacegained = diskspacegained + sum([currfiles.bytes]);
    else
        fprintf('%s does not exist: skipping\n',currfolder);
    end
end
fprintf('Finished! You gained %s MBs of disk space!\n',diskspacegained/1024^2);
cd(oldfolder);