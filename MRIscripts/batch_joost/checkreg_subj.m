function checkreg_subj

folder = '\\fileserver\mirblo$\Documents\TYR_MRI_data\3017030.06_TYR_S0101';
dbstop if error

if nargin < 1
    folder = uigetdir;
end

spm_template_folder = fullfile(filesep,'home','control','monfro','B_PhD','spm8','templates');

fprintf('We are going to check folder %s for quality of coregistration and normalisation\n',folder);

% check number of functional folders
func_folders = dir(fullfile(folder,'func_W*'));
func_folder_names = {func_folders.name};

for f = 1:numel(func_folder_names)
    fprintf('-session %g\n',f);
    
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
    
    subj_t1 = getpics(t1_folder,'T1*.nii');
    norm_t1 = getpics(t1_folder,'wmT1*.nii');
    c1_t1   = getpics(t1_folder,'c1*.nii');
    c2_t1   = getpics(t1_folder,'c2*.nii');
    c3_t1   = getpics(t1_folder,'c3*.nii');
    norm_c1_t1   = getpics(t1_folder,'wc1*.nii');
    norm_c2_t1   = getpics(t1_folder,'wc2*.nii');
    norm_c3_t1   = getpics(t1_folder,'wc3*.nii');
    
    % check existence of files
    scans = whos('*template','*func','*t1');
    for i = 1:numel(scans)
        if prod(scans(i).size) == 0
            fprintf('no scans found for %s\n',scans(i).name);
            keyboard
        end
    end
    
    % check reg mean functional with T1, EPI template and T1 template
    spm_check_registration([spm_vol(mean_func.full),spm_vol(subj_t1(1).full)],{'mean functional','subject T1'});
    opinion.coreg = input('how good is the coregistration of the mean functional and the T1? >>','s');
    
    % check reg normalised mean functional, one scan (wa*), segmented normalised files and T1 canonical, T1 template and EPI template
    % hier gebleven
    % check segmentation
    spm_check_registration([spm_vol(subj_t1(1).full),spm_vol(c1_t1(1).full),spm_vol(c2_t1(1).full),spm_vol(c3_t1(1).full)],{'subject T1','GM','WM','CSF'});
    opinion.segment = input('how good is the segmentation of T1? >>','s');
    
    % check normalised T1 with template
    spm_check_registration([spm_vol(norm_t1(1).full),spm_vol(t1_template)],{'norm subject T1','T1 template'});
    opinion.normT1_template = input('how good is the alignment of the normalised T1 with the template? >>','s');
    
    % check mean func with template
    spm_check_registration([spm_vol(norm_mean_func.full),spm_vol(epi_template)],{'norm subject EPI','EPI template'});
    opinion.normEPI_template = input('how good is the alignment of the normalised EPI with the template? >>','s');
    
    % check one func with segmented normalised T1s
    spm_check_registration([spm_vol(norm_func(1).full),spm_vol(norm_c1_t1(1).full),spm_vol(norm_c2_t1(1).full),spm_vol(norm_c3_t1(1).full)],{'subject normalized EPI scan','norm GM','norm WM','norm CSF'});
    opinion.normEPI_normsegT1 = input('how good is the alignment of the norm functional with the segmented norm T1s? >>','s');
    
    
    %% save it all to disk
    if strcmp(func_folder_names{f},'func')
        info_folder_name = 'info';
    else
        info_folder_name = ['info',func_folder_names{f}(5:end)];
    end
    
    fn = fieldnames(opinion);
    filename = fullfile(folder,info_folder_name,'checkreg_opinions.txt');
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
