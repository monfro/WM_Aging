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