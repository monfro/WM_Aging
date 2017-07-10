function fb_cleanup_in_between_niis(func_folder,raw_folder,savelast,what2delete,feedback)
% usage: cleanup_in_between_niis(func_folder,savelast,what2delete)
% savelast        keep last scan of each series?
% what2delete     vector of delete options (see script for details)
% feedback      choose 'false' if you don't want to be asked questions
% (e.g. about empty folders, default = 'true')

global INFO
if isempty(whos('INFO')); error('Please provide INFO structure'); end   % check whether we have INFO structure

if nargin < 4
    feedback = true;
end
if nargin < 3
    what2delete = [1,2,3,6,7]; % by default, leave the combined volumes alone
else
    if isempty(what2delete)
        % if no options are selected, skip this function
        return
    end
end
if nargin < 2
    savelast = true;
end
if nargin < 1
    func_folder = uigetdir(cd,'select folder with functional files');
end
how2delete = 'linux_find'; % 'linux_find lets linux do the searching, 'linux_sep' lets matlab do the searching (warning: slower)

% options for what to delete
options2delete = {...
    fullfile(raw_folder),'*.IMA';...                             % option 1
    fullfile(func_folder,'converted_Volumes'),'f*.nii';...      % option 2
    fullfile(func_folder,'converted_Volumes'),'rf*.nii';...     % option 3
    fullfile(func_folder,'converted_Volumes'),'sf*.nii';...     % option 4
    fullfile(func_folder,'PAID_data'),'M*.nii';...              % option 5
    fullfile(func_folder,'PAID_data'),'aM*.nii';...             % option 6
    fullfile(func_folder,'PAID_data'),'waM*.nii';...            % option 7
    };

oldfolder = cd;
        
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
fprintf('Finished! You gained %g MBs of disk space!\n',int16(diskspacegained/1024^2));
cd(oldfolder);