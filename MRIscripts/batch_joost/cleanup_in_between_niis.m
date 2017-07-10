function cleanup_in_between_niis(folder,savelast,what2delete,feedback)
% usage: cleanup_in_between_niis(folder,savelast,what2delete)
% savelast        keep last scan of each series?
% what2delete     vector of delete options (see script for details)
% feedback      choose 'false' if you don't want to be asked questions
% (e.g. about empty folders, default = 'true')

if nargin < 4
    feedback = true;
end
if nargin < 3
    what2delete = [1,2,3,5,6];
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
    fullfile(folder,'EPI'),'*.IMA';...                          % option 1
    fullfile(folder,'func','converted_Volumes'),'f*.nii';...    % option 2
    fullfile(folder,'func','converted_Volumes'),'rf*.nii';...   % option 3
    fullfile(folder,'func','PAID_data'),'M*.nii';...            % option 4
    fullfile(folder,'func','PAID_data'),'aM*.nii';...           % option 5
    fullfile(folder,'func','PAID_data'),'waM*.nii';...          % option 6
    };

oldfolder = cd;

% check whether dicom folder is there
if feedback
    dicomfolder = fullfile(folder,'dicoms');
    if ~exist(dicomfolder)
        choice = menu('DICOMs folder does not exist, are you sure you want to continue?','Yes','No');
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