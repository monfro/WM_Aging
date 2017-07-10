function rename_disk_archive_folders(folder,study_name,username)
% rename_disk_archive_folders(folder,study_name)
% renames folders with subject coding (e.g. S01) into a encoding key format
% as specified on intranet
% (https://intranet.donders.ru.nl/index.php?id=3968)
% JooWeg 2013-07-05

if nargin < 3
    username = 'jooweg';
end
if nargin < 2
    study_name = '3017030.03';
end
if nargin < 1
    folder = cd;
end

olddir = cd;
cd(folder);

dirs = dir('S*');
dirs(find([dirs.isdir]==0)) = [];
dirs(find(cellfun(@numel,{dirs.name})>4)) = [];

for d = 1:numel(dirs)
    subjectnumber = str2num(dirs(d).name(2:end));
    subject_str = stringify_subject(subjectnumber);
    newname = [study_name,'_',username,'_',subject_str,'_001'];
    do_it = questdlg(['Do you want to rename the folder ',dirs(d).name,' to ',newname,'?'],'Rename?','Yes','No','Yes');
    if strcmp(do_it,'Yes')
        movefile(dirs(d).name,newname);
    end
end
cd(olddir);

function str = stringify_subject(subjectnumber)

total_length = 3;
str = num2str(subjectnumber);
str = [repmat('0',1,total_length-numel(str)),str];
        