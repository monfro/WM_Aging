function varargout = ME_Combine_GUI(varargin)
% ME_COMBINE_GUI M-file for ME_Combine_GUI.fig
%      ME_COMBINE_GUI, by itself, creates a new ME_COMBINE_GUI or raises the existing
%      singleton*.
%
%      H = ME_COMBINE_GUI returns the handle to a new ME_COMBINE_GUI or the handle to
%      the existing singleton*.
%
%      ME_COMBINE_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ME_COMBINE_GUI.M with the given input arguments.
%
%      ME_COMBINE_GUI('Property','Value',...) creates a new ME_COMBINE_GUI or raises
%      the existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ME_Combine_GUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ME_Combine_GUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ME_Combine_GUI

% Last Modified by GUIDE v2.5 06-Oct-2010 14:53:31

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ME_Combine_GUI_OpeningFcn, ...
                   'gui_OutputFcn',  @ME_Combine_GUI_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

% --- Executes just before ME_Combine_GUI is made visible.
function ME_Combine_GUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ME_Combine_GUI (see VARARGIN)

% Choose default command line output for ME_Combine_GUI
handles.output = hObject;

%% initialization of input parameters%%
handles.WeightVolumes = 0;
handles.KernelSize = 0;
handles.sourcePath = '';
handles.targetPath = '';
handles.prescanPath = '';
handles.numberOfRuns = 1;
handles.deleteOrNot = 0;
handles.smoothing = 0;
handles.numberOfEchoes = 0;
handles.smoothingPrefix = 'r';
% Update handles structure
guidata(hObject, handles);

initialize_gui(hObject, handles, false);

% UIWAIT makes ME_Combine_GUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% --- Outputs from this function are returned to the command line.
function varargout = ME_Combine_GUI_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --------------------------------------------------------------------
function initialize_gui(fig_handle, handles, isreset)
% If the metricdata field is present and the reset flag is false, it means
% we are we are just re-initializing a GUI by calling it from the cmd line
% while it is up. So, bail out as we dont want to reset the data.
if isfield(handles, 'metricdata') && ~isreset
    return;
end

set(handles.text5, 'String', 'mm');

% Update handles structure
guidata(handles.figure1, handles);


function edit7_Callback(hObject, eventdata, handles)
% hObject    handle to edit7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit7 as text
%        str2double(get(hObject,'String')) returns contents of edit7 as a double

NoOfVolumes = str2double(get(hObject, 'String'));
if isnan(NoOfVolumes)
    set(hObject, 'String', 30);
    errordlg('No input for # of volumes for weight calculation, default value of 30 will be used','Error');
end

handles.WeightVolumes = NoOfVolumes;
guidata(hObject,handles)


% --- Executes during object creation, after setting all properties.
function edit7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit8_Callback(hObject, eventdata, handles)
% hObject    handle to edit8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit8 as text
%        str2double(get(hObject,'String')) returns contents of edit8 as a double

KernelSize = str2double(get(hObject, 'String'));
if isnan(KernelSize)
    set(hObject, 'String', 3);
    errordlg('No input for kernel size for smoothing, default value of 3 mm will be used','Error');
end

handles.KernelSize = KernelSize;
guidata(hObject,handles)


% --- Executes during object creation, after setting all properties.
function edit8_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton9.
function pushbutton9_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%% Initialization %%
addpath('/home/common/matlab/spm8');
addpath(pwd);
warning off all
clc
if (exist(handles.sourcePath)~=7 || isempty(handles.sourcePath))
    handles.sourcePath = uigetdir(pwd, 'Select folder for DICOM data (INPUT)');
    guidata(hObject,handles);
end

if (exist(handles.targetPath)~=7 || isempty(handles.targetPath))
   handles.targetPath = uigetdir(pwd, 'Select folder for NIFTI data (OUTPUT)');
   guidata(hObject,handles);
end

if (get(handles.checkbox2,'Value') && isempty(get(handles.edit9,'String')))
    disp('No Input For # of Runs, Assumed to be 1');
    handles.numberOfRuns = 1;
    guidata(hObject,handles);
end

if (get(handles.checkbox3,'Value') && ...
        (exist(handles.prescanPath)~=7 || isempty(handles.prescanPath)))
    handles.prescanPath = uigetdir(pwd, 'Select folder for Prescan (DICOM) data (INPUT)');
    guidata(hObject,handles);
end

if (isempty(get(handles.edit8,'String')) && handles.smoothing)
    disp('No Input For the Size of Kernel, Assumed to be  3 mm');
    handles.KernelSize = 3;
    guidata(hObject,handles);
end

if isempty(get(handles.edit7,'String'))
    disp('No Input For # of Weight Volumes, Assumed to be 30');
    handles.WeightVolumes = 30;
    guidata(hObject,handles);
end

if isempty(get(handles.edit12,'String'))
    disp('No Input For # of Echoes, Assumed to be 5');
    handles.numberOfEchoes = 5;
    guidata(hObject,handles);
end

disp('Input parameters are checked!')

startVolume = 1;
cd(handles.sourcePath);
TE = zeros(handles.numberOfRuns,handles.numberOfEchoes);

%% clear output folder %%

if exist([handles.targetPath '/PAID_data']) == 7
    rmdir([handles.targetPath '/PAID_data'],'s');
end
if exist([handles.targetPath '/converted_Weight_Volumes']) == 7
    rmdir([handles.targetPath '/converted_Weight_Volumes'],'s');
end
if exist([handles.targetPath '/converted_Volumes']) == 7
    rmdir([handles.targetPath '/converted_Volumes'],'s');
end
delete([handles.targetPath '/*']);
disp('Output folder is cleared!')

%% Dicom2Nifti %%

if ~isempty(handles.prescanPath) %% first, prescan volumes are converted
    cd([handles.targetPath]); 
    mkdir('converted_Weight_Volumes');
    cd([handles.prescanPath]);
    TE_prescan = RB_ME_PAID_Dicom2Nifti(handles.prescanPath, handles.numberOfRuns, size(TE,2));
    unix(['mv ' handles.prescanPath '/*.nii ' handles.targetPath '/converted_Weight_Volumes']);
    cd([handles.sourcePath]);
end

cd([handles.targetPath]);
mkdir('converted_Volumes');
cd([handles.sourcePath]);
TE = RB_ME_PAID_Dicom2Nifti(pwd, handles.numberOfRuns, size(TE,2));
filesToBeMoved = dir('*.nii');
filesToBeMoved = char(filesToBeMoved.name);
fileMoveForLinux(handles.sourcePath, [handles.targetPath '/converted_Volumes'], filesToBeMoved, 100);
disp('DICOMs are converted!')


%% Realignment %%

if isempty(handles.prescanPath) %% there is no prescan
    cd([handles.targetPath '/converted_Volumes']);
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
    cd([handles.targetPath '/converted_Weight_Volumes']); %% first, prescan volumes are realigned
    disp('Realignment of prescan volumes started')

    filesTemp = dir('*01.nii');
    filesPrescan = char(zeros(length(filesTemp),length(filesTemp(1).name)+2,size(TE,2)));
    for i=startVolume:size(filesPrescan,1)
        filesPrescan(i,1:length(filesTemp(i).name),1) = filesTemp(i).name;
    end
    
    cd([handles.targetPath '/converted_Volumes']);
    
    filesTemp = dir('*01.nii');
    files = char(zeros(length(filesTemp),length(filesTemp(1).name)+2,size(TE,2)));
    for i=startVolume:size(files,1)
        files(i,1:length(filesTemp(i).name),1) = filesTemp(i).name;
    end
       
      
    cd([handles.targetPath '/converted_Weight_Volumes']);
    filesToBeMoved = dir('*01.nii');
    filesToBeMoved = char(filesToBeMoved.name);
    fileMoveForLinux([handles.targetPath '/converted_Weight_Volumes'], [handles.targetPath '/converted_Volumes'], filesToBeMoved, 1000);
    
    cd([handles.targetPath '/converted_Volumes']);
    filesFirstEcho = cat(1,filesPrescan(:,:,1),files(:,:,1));    
    spm_realign(filesFirstEcho(:,:,1)); %% first echo volumes are realigned to the first volume of first echo
    
    % move first echoes of prescan back to their original directory
    fileMoveForLinux([handles.targetPath '/converted_Volumes/'], [handles.targetPath '/converted_Weight_Volumes'], filesPrescan(:,1:end-2,1), 1000);
    
    cd([handles.targetPath '/converted_Weight_Volumes']);
    
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
    
    cd([handles.targetPath '/converted_Volumes']); %% all the other volumes are realigned
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
        fileMoveForLinux([handles.targetPath '/converted_Weight_Volumes'], [handles.targetPath '/converted_Volumes'], filesPrescan(:,1:end-2,i), 1000);
    end
    
    
    cd([handles.targetPath '/converted_Volumes']);
    
    resliceFiles = dir('*.nii'); %% reslicing of original scan volumes
    resliceFiles = char(resliceFiles.name);
    spm_reslice(resliceFiles);
    
    for i=1:size(TE,2)
        fileMoveForLinux([handles.targetPath '/converted_Volumes'], [handles.targetPath '/converted_Weight_Volumes'], filesPrescan(:,1:end-2,i), 1000);
        fileMoveForLinux([handles.targetPath '/converted_Volumes'], [handles.targetPath '/converted_Weight_Volumes'], cat(2,repmat('r',[handles.WeightVolumes 1]),filesPrescan(:,1:end-2,i)), 1000);
    end
    
end

disp('Realignment finished!')

%% Smoothing %%
if handles.smoothing
    handles.smoothingPrefix = 's';
    if isempty(handles.prescanPath) %% there is no prescan
        for j=1:size(TE,2)    
            for i=startVolume:startVolume+handles.WeightVolumes-1
                spm_smooth(['r' files(i,:,j)],['s' files(i,:,j)],handles.KernelSize);
            end
        end
    else %% with prescan
        cd([handles.targetPath '/converted_Weight_Volumes']);
        for j=1:size(TE,2)    
            for i=startVolume:startVolume+handles.WeightVolumes-1
                spm_smooth(['r' filesPrescan(i,:,j)],['s' filesPrescan(i,:,j)],handles.KernelSize);
            end
        end
        cd([handles.targetPath '/converted_Volumes']);
    end
    disp('Smoothing is applied to weight calculation volumes')
end
%%

%% Weight Calculation%%

dimVolume = spm_vol(files(1,:,1));
dim = dimVolume.dim;

for i=1:size(TE,2)
    volume4D(:,:,:,:,i) = zeros(dim(1),dim(2),dim(3),handles.WeightVolumes);
end

if isempty(handles.prescanPath) %% there is no prescan
    for i=startVolume:startVolume+handles.WeightVolumes-1
        for j=1:size(TE,2)
            V{j} = spm_vol([handles.smoothingPrefix files(i,:,j)]);
            volume4D(:,:,:,i-(startVolume-1),j) = spm_read_vols(V{j});       
        end
    end
else
    cd([handles.targetPath '/converted_Weight_Volumes']);
    for i=startVolume:startVolume+handles.WeightVolumes-1
        for j=1:size(TE,2)
            V{j} = spm_vol([handles.smoothingPrefix filesPrescan(i,:,j)]);
            volume4D(:,:,:,i-(startVolume-1),j) = spm_read_vols(V{j});       
        end
    end
    cd([handles.targetPath '/converted_Volumes']);
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
cd(handles.targetPath);
mkdir('PAID_data');
cd([handles.targetPath '/converted_Volumes']);

filesToBeMoved = dir('M_volume*');
filesToBeMoved = char(filesToBeMoved.name);
fileMoveForLinux([handles.targetPath '/converted_Volumes'], [handles.targetPath '/PAID_data'], filesToBeMoved, 1000);

filesToBeMoved = dir('*.txt');
filesToBeMoved = char(filesToBeMoved.name);
fileMoveForLinux([handles.targetPath '/converted_Volumes'], [handles.targetPath '/PAID_data'], filesToBeMoved, 1000);

disp('Volumes are combined!')

%% Delete unnecessary output files %%

if ((get(handles.checkbox1,'Value')) == 1)
    filesTemp = dir('PAID_data/*.nii');
    cd([handles.targetPath '/PAID_data']);
    filesTemp = dir('*.nii');
    for i=1:handles.WeightVolumes
        delete([handles.targetPath '/PAID_data/' filesTemp(i).name]);
    end
end


% --- Executes on button press in checkbox1.
function checkbox1_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox1
% temporaryData = guidata(hObject);
handles.deleteOrNot = get(handles.checkbox1,'Value');
guidata(hObject,handles);



% --- Executes on button press in checkbox2.
function checkbox2_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.edit9,'Visible','on');
set(handles.text15,'Visible','on');
set(handles.checkbox3,'Value',1);
set(handles.pushbutton14,'Visible','on');
% Hint: get(hObject,'Value') returns toggle state of checkbox2



function edit9_Callback(hObject, eventdata, handles)
% hObject    handle to edit9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

numberOfRuns = str2double(get(hObject, 'String'));
if isnan(numberOfRuns)
    set(hObject, 'String', 1);
    errordlg('No input for # of runs, default value of 1 will be used','Error');
end

handles.numberOfRuns = numberOfRuns;
guidata(hObject,handles)

% Hints: get(hObject,'String') returns contents of edit9 as text
%        str2double(get(hObject,'String')) returns contents of edit9 as a double


% --- Executes during object creation, after setting all properties.
function edit9_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit10_Callback(hObject, eventdata, handles)
% hObject    handle to edit10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit10 as text
%        str2double(get(hObject,'String')) returns contents of edit10 as a double


% --- Executes during object creation, after setting all properties.
function edit10_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox3.
function checkbox3_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.pushbutton14,'Visible','on');

% Hint: get(hObject,'Value') returns toggle state of checkbox3


% --- Executes on button press in pushbutton10.
function pushbutton10_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function edit11_Callback(hObject, eventdata, handles)
% hObject    handle to edit11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit11 as text
%        str2double(get(hObject,'String')) returns contents of edit11 as a double


% --- Executes during object creation, after setting all properties.
function edit11_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton12.
function pushbutton12_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.sourcePath = uigetdir(pwd, 'Select folder for DICOM data (INPUT)');
guidata(hObject,handles)


% --- Executes on button press in pushbutton13.
function pushbutton13_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.targetPath = uigetdir(pwd, 'Select folder for NIFTI data (OUTPUT)');
guidata(hObject,handles)


% --- Executes on button press in pushbutton14.
function pushbutton14_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.prescanPath = uigetdir(pwd, 'Select folder for Prescan (DICOM) data (INPUT)');
guidata(hObject,handles)


% --- Executes on button press in checkbox4.
function checkbox4_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.smoothing = get(handles.checkbox4,'Value');
guidata(hObject,handles);
set(handles.text2,'Visible','on');
set(handles.edit8,'Visible','on');
set(handles.text5,'Visible','on');

% Hint: get(hObject,'Value') returns toggle state of checkbox4



function edit12_Callback(hObject, eventdata, handles)
% hObject    handle to edit12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

numberOfEchoes = str2double(get(hObject, 'String'));
if isnan(numberOfEchoes)
    set(hObject, 'String', 5);
    errordlg('No input for # of echoes, default value of 5 will be used','Error');
end

handles.numberOfEchoes = numberOfEchoes;
guidata(hObject,handles)

% Hints: get(hObject,'String') returns contents of edit12 as text
%        str2double(get(hObject,'String')) returns contents of edit12 as a double


% --- Executes during object creation, after setting all properties.
function edit12_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when uipanel1 is resized.
function uipanel1_ResizeFcn(hObject, eventdata, handles)
% hObject    handle to uipanel1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
