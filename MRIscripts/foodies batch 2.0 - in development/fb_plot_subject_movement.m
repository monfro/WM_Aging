function subj = plot_subject_movement
% usage:
% plot_subject_movement(folder,search_str)
% plots movement parameters like SPM does
% looks for rp files (default search_str = 'rp_f*.txt')
% and plots them to a file

global INFO

if isempty(whos('INFO')); error('Please provide INFO structure'); end   % check whether we have INFO structure

% loop over subjects
for iSubj = 1:numel(INFO.subjects)    
    % load file info that was save by fb_copy_mridata
    batch_info_savefolder = fullfile(INFO.dir.exp_root,INFO.subjects{iSubj},INFO.dir.info.batch);
    batch_info_savefile = fullfile(batch_info_savefolder,INFO.raw_data.filename.subject_info);
    if ~exist(batch_info_savefile); error(['file ',batch_info_savefile,' does not exist. Run fb_copy_mridata first']); end
    subj_info           = load(batch_info_savefile);
    
    % find the folders with functional data in them
    [u_dirs,o2,o3] = unique(subj_info.target_subdirs);
    u_types = subj_info.target_subdirs_type(o2);
    subdirs2exclude = [find(cellfun(@isempty,cellfun(@findstr,u_dirs,repmat({'excess'},size(u_dirs)),'UniformOutput',false))==0),...
        find(cellfun(@isempty,cellfun(@findstr,u_dirs,repmat({'delete'},size(u_dirs)),'UniformOutput',false))==0)];
    u_dirs(subdirs2exclude) = [];
    u_types(subdirs2exclude) = [];
    func_idx = find(ismember(u_dirs,INFO.raw_data.filetypes.func.session_names));
    raw_func_dirs = u_dirs(func_idx);
    
    fileseps = findstr(filesep,subj_info.target_dir);
    
    for iSess = 1:numel(raw_func_dirs) % loop over func datasets
        if strcmp(raw_func_dirs{iSess},'func')
            func_session(iSess).func_dir = fullfile(subj_info.target_dir,INFO.preproc.suffix.func);
            func_session(iSess).info_dir = fullfile(subj_info.target_dir,INFO.preproc.suffix.info);
        else
            func_session(iSess).func_dir = fullfile(subj_info.target_dir,[raw_func_dirs{iSess},'_',INFO.preproc.suffix.func]);
            func_session(iSess).info_dir = fullfile(subj_info.target_dir,[raw_func_dirs{iSess},'_',INFO.preproc.suffix.info]);
        end
        
        %% find the file with the realignment parameters
        combined_dir = fullfile(func_session(iSess).func_dir,INFO.dir.multiecho.combined);
        rp_newpath = fullfile(combined_dir,['rp_',INFO.subjects{iSubj},'_',num2str(INFO.preproc.multiecho.nPrescans+1),'_onwards.txt']);
        
        rpd = load(rp_newpath);
        fg = figure;
        set(fg,'Position',[1,1,1200,800],'Visible','on');
        %% translation part
        subplot(2,1,1);
        plot(rpd(:,1),'r');
        hold on
        plot(rpd(:,2),'g');
        plot(rpd(:,3),'b');
        title('translation');
        xlabel('image');
        ylabel('mm');
        legend('x translation','y translation','z translation','Location','SouthEastOutside');
        
        %% rotation part
        subplot(2,1,2);
        plot(rpd(:,4),'r');
        hold on
        plot(rpd(:,5),'g');
        plot(rpd(:,6),'b');
        title('rotation');
        xlabel('image');
        ylabel('degrees');
        legend('pitch','roll','yaw','Location','SouthEastOutside');
        
        %% save the file
        [p1,p2,p3] = fileparts(rp_newpath); % p2 is the subject folder name
        plotfile = fullfile(func_session(iSess).info_dir,[p2,'_movement.pdf']);
        saveas(gcf,plotfile);
        fprintf('saved movement plot file %s\n',plotfile);
        close(gcf);
        
    end % session loop
end % subject loop

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Other functions
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function list = getpics(directory,search_string)
% getpics returns all files in a given directory and its
% subdirectories and returns them in a structure object
%
% Usage: getpics([name of directory],search_string)
%   search_string options:
%    [empty]        - getpics lists all files in directory and subdirectories
%    'jpg'          - getpics looks for all jpg files in directory and subdirectories
%    'smile.jpg'    - getpics looks for the specified filename in directory and subdirectories
%
% JW - 2007.04.02

if nargin < 1
    disp('Error: Please specify directory name - usage instructions below')
    disp(' ')
    help getpics;
    return
end
if nargin < 2
    search_string = '*';
end


% Checks whether a full filename is given
dotloc = findstr(search_string,'.');
if isempty(dotloc)
    filename = '*';
    ext = search_string;
else
    filename = search_string(1:dotloc(1)-1);
    ext = search_string(dotloc(1)+1:size(search_string,2));
end

if ispc
    if directory(length(directory)) == '\'
        dr = directory(1:length(directory)-1);
    else dr = directory;
    end
    
    % Checks if the directory exists
    if ~exist(dr)
        error(['Search directory ' dr ' does not exist'])
    end
    
    % Generates all subdirectories of a given directory
    d = genpath(dr);
    % Uses paths function to put generated directories in a structure object
    pp = paths(d);
    
    % Gets filenames from subdirectories and stores them as full path names in
    % list structure object
    list = struct([]);
    for di = 1:size(pp,2)
        fil = dir([pp(di).dir '\' filename '.' ext]);
        for ff = 1:size(fil,1)
            if ~fil(ff).isdir
                last = size(list,2)+1;
                list(last).dir = pp(di).dir;
                dotloc = findstr(fil(ff).name,'.');
                if isempty(dotloc)
                    list(last).file = fil(ff).name(1:end);
                    list(last).ext  = '';
                    list(last).full = [list(last).dir '\' list(last).file];
                    list(last).bytes = fil(ff).bytes;
                else
                    dotloc = dotloc(size(dotloc,2));
                    list(last).file = fil(ff).name(1:dotloc-1);
                    list(last).ext  = fil(ff).name(dotloc+1:size(fil(ff).name,2));
                    list(last).full = [list(last).dir '\' list(last).file '.' list(last).ext];
                    list(last).bytes = fil(ff).bytes;
                end
            end
        end
    end
    
elseif isunix
    if directory(length(directory)) == '/'
        dr = directory(1:length(directory)-1);
    else dr = directory;
    end
    
    % Checks if the directory exists
    if ~exist(dr)
        error(['Search directory ' dr ' does not exist'])
    end
    
    % Generates all subdirectories of a given directory
    d = genpath(dr);
    % Uses paths function to put generated directories in a structure object
    pp = paths(d);
    
    % Gets filenames from subdirectories and stores them as full path names in
    % list structure object
    list = struct([]);
    for di = 1:size(pp,2)
        fil = dir([pp(di).dir '/' filename '.' ext]);
        for ff = 1:size(fil,1)
            last = size(list,2)+1;
            list(last).dir = pp(di).dir;
            dotloc = findstr(fil(ff).name,'.');
            dotloc = dotloc(size(dotloc,2));
            list(last).file = fil(ff).name(1:dotloc-1);
            list(last).ext  = fil(ff).name(dotloc+1:size(fil(ff).name,2));
            list(last).full = [list(last).dir '/' list(last).file '.' list(last).ext];
            list(last).bytes = fil(ff).bytes;
        end
    end
else disp('Unknow operating system')
end

function p = paths(d)

if ispc
    p(1).dir = '';
    ind = 1;
    for ipath = 1:size(d,2)
        if d(1,ipath) == ';'
            ind = ind + 1;
            p(ind).dir = '';
        else
            p(ind).dir = [p(ind).dir d(1,ipath)];
        end
    end
elseif isunix
    p(1).dir = '';
    ind = 1;
    for ipath = 1:size(d,2)
        if d(1,ipath) == ':'
            ind = ind + 1;
            p(ind).dir = '';
        else
            p(ind).dir = [p(ind).dir d(1,ipath)];
        end
    end
else disp('Unknow operating system')
end