function checkreg_subj(folder)

mricron_fullscreen = 1;
transparency = 0.6;

if nargin < 1
    folder = uigetdir;
end
if mricron_fullscreen
    fullscreen_str = '-x';
else
    fullscreen_str = '';
end

searchstr.subj_t1 = 'T1*.nii';
searchstr.norm_t1 = 'wmT1*.nii';
searchstr.c1_t1   = 'c1*.nii';
searchstr.c2_t1   = 'c2*.nii';
searchstr.c3_t1   = 'c3*.nii';
searchstr.norm_c1_t1   = 'wc1*.nii';
searchstr.norm_c2_t1   = 'wc2*.nii';
searchstr.norm_c3_t1   = 'wc3*.nii';

spm_template_folder = fullfile(filesep,'home','common','matlab','spm8','templates');

fprintf('We are going to check folder %s for quality of coregistration and normalisation\n',folder);

% check number of functional folders
func_folders = dir(fullfile(folder,'func*'));
if isempty(func_folders)
    error('no folders containing ''func'' in the name found')
end

func_folder_names = {func_folders.name};

for f = 1:numel(func_folder_names)
    fprintf('-session %g: %s\n',f,func_folder_names{f});
    
    %% get files
    t1_template = fullfile(spm_template_folder,'T1.nii');
    epi_template = fullfile(spm_template_folder,'EPI.nii');
    
    func_folder = fullfile(folder,func_folder_names{f},'PAID_data');
    t1_folder   = fullfile(folder,'T1');
    
    norm_func = getpics(func_folder,'waM*.nii');
    if isempty(norm_func)
        norm_func = getpics(func_folder,'last_waM*.nii');
    end
    mean_func = getpics(func_folder,'mean*.nii');
    norm_mean_func = getpics(func_folder,'wmean*.nii');
    if isempty(norm_func)
        fprintf('No normalized EPI (wa*) scan found (maybe you deleted them already), using normalised mean functional instead\n');
        norm_func = norm_mean_func;
    end
    
    subj_t1 = getpics(t1_folder,searchstr.subj_t1);
    norm_t1 = getpics(t1_folder,searchstr.norm_t1);
    c1_t1   = getpics(t1_folder,searchstr.c1_t1);
    c2_t1   = getpics(t1_folder,searchstr.c2_t1);
    c3_t1   = getpics(t1_folder,searchstr.c3_t1);
    norm_c1_t1   = getpics(t1_folder,searchstr.norm_c1_t1);
    norm_c2_t1   = getpics(t1_folder,searchstr.norm_c2_t1);
    norm_c3_t1   = getpics(t1_folder,searchstr.norm_c3_t1);
    
    % check existence of files
    scans = whos('*template','*func','*t1');
    for i = 1:numel(scans)
        if prod(scans(i).size) == 0
            fprintf('no scans found for %s\n',scans(i).name);
            keyboard
        end
    end
    
    % check reg mean functional with T1, EPI template and T1 template
    eval(['!mricron ',subj_t1(1).full,' -l 100 -h 300 -o ',mean_func(1).full,' -b -1 ',fullscreen_str,' &']);
    spm_check_registration([spm_vol(mean_func.full),spm_vol(subj_t1(1).full)],{'mean functional','subject T1'});
    opinion.coreg = input('how good is the coregistration of the mean functional and the T1? >>','s');
    kill_mricron_processes;
    
    % check reg normalised mean functional, one scan (wa*), segmented normalised files and T1 canonical, T1 template and EPI template
    % hier gebleven
    
    % check segmentation
    eval(['!mricron ',subj_t1(1).full,' -l 100 -h 300 -o ',c1_t1(1).full,' -o ',c2_t1(1).full,' -o ',c3_t1(1).full,' -b 50 -t -1 ',fullscreen_str,' &']);
    spm_check_registration([spm_vol(subj_t1(1).full),spm_vol(c1_t1(1).full),spm_vol(c2_t1(1).full),spm_vol(c3_t1(1).full)],{'subject T1','GM','WM','CSF'});
    opinion.segment = input('how good is the segmentation of T1? >>','s');
    kill_mricron_processes;
    
    % check normalised T1 with template
    eval(['!mricron ',t1_template,' -l 0 -h 1 -o ',norm_t1(1).full,' -l 10 -h 200 -o ',norm_t1(1).full,' -l 250 -h 335 -b 60 -t 100 ',fullscreen_str,' &']);
    spm_check_registration([spm_vol(norm_t1(1).full),spm_vol(t1_template)],{'norm subject T1','T1 template'});
    opinion.normT1_template = input('how good is the alignment of the normalised T1 with the template? >>','s');
    kill_mricron_processes;
    
    % check mean func with template
    eval(['!mricron ',epi_template,' -l 0 -h 1 -o ',norm_mean_func.full,' -l 350 -h 550  -b -1 -t -1 ',fullscreen_str,'  &']);
    spm_check_registration([spm_vol(norm_mean_func.full),spm_vol(epi_template)],{'norm subject EPI','EPI template'});
    opinion.normEPI_template = input('how good is the alignment of the normalised EPI with the template? >>','s');
    kill_mricron_processes;
    
    % check one func with segmented normalised T1s
    eval(['!mricron ',norm_func(1).full,' -l 350 -h 550 -o ',norm_c1_t1(1).full,' -o ',norm_c2_t1(1).full,' -o ',norm_c3_t1(1).full,' -b 70 -t -1 ',fullscreen_str,' &']);
    spm_check_registration([spm_vol(norm_func(1).full),spm_vol(norm_c1_t1(1).full),spm_vol(norm_c2_t1(1).full),spm_vol(norm_c3_t1(1).full)],{'subject normalized EPI scan','norm GM','norm WM','norm CSF'});
    opinion.normEPI_normsegT1 = input('how good is the alignment of the norm functional with the segmented norm T1s? >>','s');
    kill_mricron_processes;
    
    %% save it all to disk
    if strcmp(func_folder_names{f},'func')
        info_folder_name = 'info';
    else
        info_folder_name = ['info',func_folder_names{f}(5:end)];
    end
    
    fn = fieldnames(opinion);
    filename = fullfile(folder,info_folder_name,['checkreg_opinions',datestr(now),'.txt']);
    fid = fopen(filename,'w');
    % write filenames
    for f = 1:numel(scans)
        if ~isempty(findstr('template',scans(f).name))
            fprintf(fid,'scan %g: %s\n',f,eval(scans(f).name));
        else
            fprintf(fid,'scan %g: %s\n',f,eval([scans(f).name,'(1).full']));
        end
    end
    fprintf(fid,'\n');
    
    % write opinions
    op = fieldnames(opinion);
    for i = 1:numel(op)
        fprintf(fid,'%s: %s\n',op{i},getfield(opinion,op{i}));
    end
    fprintf('Sucessfully written checkreg opinions to %s\n',filename);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Other functions
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function batch_checkreg(imagefiles,reorient_img_ind,maskstooverlay)

mask_colors     =  [0 1 0; 1 0 0 ;1 1 0;0 1 1;0 0 1;1 0 1];

%prepend directory name to file names
%imagefiles = (cellfun(@(x)fullfile(inputdir,x),imagestodisplay,
%'UniformOutput', false)); % old function had as two first inputs inputdir
%and imagestodisplay

% batchdir = fileparts(which('batch_checkreg'));
% jobscriptfile   = 'batchedit_checkreg_template.m'; %just a container for checkreg w/ jobman
%
% spm_jobman('serial', ...
%     {fullfile(batchdir,jobscriptfile)}, '', ...
%     imagefiles);

%% code adjusted by jooweg - DCCN
%spm_orthviews('context_menu','zoom',4);
halfFOVmm = 80;
spm_orthviews('Zoom',halfFOVmm);
if reorient_img_ind
    spm_ov_reorient('context_init',reorient_img_ind);
end

%from spm_orthviews('context_menu','add_c_image',1);
for handle = 1:length(imagestodisplay)
    if ~isempty(maskstooverlay) && iscell(maskstooverlay{1}) % individual masks for each image
        maskfiles = cellfun(@(x)fullfile(inputdir,x),maskstooverlay{handle}, 'UniformOutput', false);
    else
        maskfiles = cellfun(@(x)fullfile(inputdir,x),maskstooverlay, 'UniformOutput', false);
    end
    for k=1:length(maskfiles)
        spm_orthviews('addtruecolourimage',handle,maskfiles{k},mask_colors(k,:));
    end
end

function kill_mricron_processes
% get the process IDs
eval('!pidof mricron > tempdump.out');
pidx = load('tempdump.out');
delete('tempdump.out');
for i = 1:numel(pidx)
    eval(['!kill ',num2str(pidx(i))]);
end

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
            last = size(list,2)+1;
            list(last).dir = pp(di).dir;
            dotloc = findstr(fil(ff).name,'.');
            dotloc = dotloc(size(dotloc,2));
            list(last).file = fil(ff).name(1:dotloc-1);
            list(last).ext  = fil(ff).name(dotloc+1:size(fil(ff).name,2));
            list(last).full = [list(last).dir '\' list(last).file '.' list(last).ext];
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