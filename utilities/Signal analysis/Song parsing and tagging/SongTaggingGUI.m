function varargout = SongTaggingGUI(varargin)
% SONGTAGGINGGUI MATLAB code for SongTaggingGUI.fig
%      SONGTAGGINGGUI, by itself, creates a new SONGTAGGINGGUI or raises the existing
%      singleton*.
%
%      H = SONGTAGGINGGUI returns the handle to a new SONGTAGGINGGUI or the handle to
%      the existing singleton*.
%
%      SONGTAGGINGGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SONGTAGGINGGUI.M with the given input arguments.
%
%      SONGTAGGINGGUI('Property','Value',...) creates a new SONGTAGGINGGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before SongTaggingGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to SongTaggingGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help SongTaggingGUI

% Last Modified by GUIDE v2.5 07-Dec-2016 18:02:36

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @SongTaggingGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @SongTaggingGUI_OutputFcn, ...
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


% --- Executes just before SongTaggingGUI is made visible.
function SongTaggingGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to SongTaggingGUI (see VARARGIN)

% Choose default command line output for SongTaggingGUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);
 
tagging_data_struct = handles.BaseDirName.UserData;
base_dir = tagging_data_struct.base_dir;

cd(base_dir);
update_tables_and_graphics(handles,1,1,1,0,0,1);
%update_tables_and_graphics(handles,bird_id,date_folder_num,audio_file_num,spectrogram_im,tags_im,filter_design)

% UIWAIT makes SongTaggingGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = SongTaggingGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function BaseDirName_Callback(hObject, eventdata, handles)
% hObject    handle to BaseDirName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of BaseDirName as text
%        str2double(get(hObject,'String')) returns contents of BaseDirName as a double
base_dir = handles.BaseDirName.String;
if exist(fullfile(base_dir),'dir')
    cd(base_dir);
    if exist('TaggingDataStruct.mat')
        load('TaggingDataStruct.mat');
        handles.BaseDirName.UserData = tagging_data_struct;
    else
        
    end
else
    handles.BaseDirName.String = 'input a valid base dir';
end

cd(tagging_data_struct.birds{1});
subdirs = dir; folders = [subdirs.isdir]; subdirs = subdirs(folders); subdirs(1:2) = [];
handles.DateFolders.String = {subdirs.name};
handles.DateFolders.Value = 1;
cd(fullfile(subdirs(1).name,'chop_data','wav'));
wavfiles = dir('*.wav');
handles.AudioFiles.String = {wavfiles.name};
handles.AudioFiles.Value = 1;
[y,fs] = audioread(wavfiles(1).name);
if (str2num(handles.SamplingFrequency.String) ~= fs)
    handles.SamplingFrequency.String = num2str(fs);
    Fst1 = str2num(handles.LowCutoffFreq.String);  % The max frequency (Hz) of the low stop band  
    Fp1 = Fst1+150;   % The min frequency (Hz) of the pass band
    Fp2 = str2num(handles.HighCutoffFreq.String);  % The max frequency (Hz) of the pass band
    Fst2 = Fp2+150; % The min frequency (Hz) of the high stop band
    Ast1 = 60;   % ratio of suppression in low stop band (dB)
    Ap = 1;      % Pass band ripple ratio (dB)
    Ast2 = 60;   % ratio of suppression in high stop band (dB)
    d = fdesign.bandpass('Fst1,Fp1,Fp2,Fst2,Ast1,Ap,Ast2',Fst1,Fp1,Fp2,Fst2,Ast1,Ap,Ast2,fs);
    Hd = design(d,'equiripple');
    handles.FilteringCheck.UserData = Hd;
else
    Hd = handles.FilteringCheck.UserData;
end
if (handles.FilteringCheck.Value == 1)
    filtered = filtfilt(Hd.Numerator,1,y);
    [im,f,t]=zftftb_pretty_sonogram(filtered,fs,'len',str2num(handles.FFTlen.String),'overlap',str2num(handles.WindowOverlap.String),...
					'tscale',str2num(handles.GaussTimescale.String),'zeropad',0,'norm_amp',1,'clipping',[-2 2]);
else
    [im,f,t]=zftftb_pretty_sonogram(y,fs,'len',str2num(handles.FFTlen.String),'overlap',str2num(handles.WindowOverlap.String),...
					'tscale',str2num(handles.GaussTimescale.String),'zeropad',0,'norm_amp',1,'clipping',[-2 2]);
end
axes(handles.SonogramWindow)
imagesc(t,f,uint8(im*62))
axis xy;
handles.TimeSlider.Value = 0; handles.TimeSlider.UserData = max(t);
xlim([0 1]); ylim([str2num(handles.LowCutoffFreq.String) str2num(handles.HighCutoffFreq.String)]);
colormap hot;
xlabel('Time (Sec)');
ylabel('Frequency (Hz)');
cd(base_dir);

% --- Executes during object creation, after setting all properties.
function BaseDirName_CreateFcn(hObject, eventdata, handles)
DEFAULT_BASE_DIR = '/Volumes/quetzalcoatl/Documents/Bird Screening';
% hObject    handle to BaseDirName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
base_dir = DEFAULT_BASE_DIR; %'/Volumes/quetzalcoatl/Documents/Bird Screening';
if exist(fullfile(base_dir),'dir')
    handles.BaseDirName.String = base_dir;
    cd(base_dir);
    if exist('TaggingDataStruct.mat')
        load('TaggingDataStruct.mat');
        hObject.UserData = tagging_data_struct;  
    else
        create_base_structure(handles);
    end
    %update_tables_and_graphics(handles,bird_id,date_folder_num,audio_file_num,spectrogram_im,tags_im,filter_design)
else
    hObject.String = 'input a valid base dir';
end

    
    
% --- Executes on button press in BaseDirBrowse.
function BaseDirBrowse_Callback(hObject, eventdata, handles)
% hObject    handle to BaseDirBrowse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.BaseDirName.String = uigetdir;
base_dir = handles.BaseDirName.String;
if exist(fullfile(base_dir),'dir')
    cd(base_dir);
    if exist('TaggingDataStruct.mat')
        load('TaggingDataStruct.mat');
        handles.BaseDirName.UserData = tagging_data_struct;
    else
        dirs = dir; folders = [dirs.isdir]; dirs = dirs(folders); dirs(1:2) = [];
        [Selection,ok] = listdlg('ListString',{dirs.name},'Name','Ignore Dirs.','PromptString',{'Choose directories to ignore because they are not associated with birds'});
        dirs(Selection) = [];
        dates = [];
        for cnt = 1:numel(dirs)
            cd(dirs(cnt).name);
            subdirs = dir; folders = [subdirs.isdir]; subdirs = subdirs(folders); subdirs(1:2) = [];
            datestrs = {subdirs.name};
            dates = [dates; datestrs(cellfun(@datenum,datestrs) == min(cellfun(@datenum,datestrs)))];
            cd(base_dir);
        end
        [tmp, ind] = sort(cellfun(@datenum,dates));
        tagging_data_struct.base_dir = base_dir;
        tagging_data_struct.birds = {dirs(ind).name}';
        tagging_data_struct.first_day = dates(ind);
        tagging_data_struct.template_files = {};
        save('TaggingDataStruct','tagging_data_struct');
        handles.BaseDirName.UserData = tagging_data_struct;
    end
else
    handles.BaseDirName.String = 'input a valid base dir';
end

cd(tagging_data_struct.birds{1});
subdirs = dir; folders = [subdirs.isdir]; subdirs = subdirs(folders); subdirs(1:2) = [];
handles.DateFolders.String = {subdirs.name};
handles.DateFolders.Value = 1;
cd(fullfile(subdirs(1).name,'chop_data','wav'));
wavfiles = dir('*.wav');
handles.AudioFiles.String = {wavfiles.name};
handles.AudioFiles.Value = 1;
[y,fs] = audioread(wavfiles(1).name);
if (str2num(handles.SamplingFrequency.String) ~= fs)
    handles.SamplingFrequency.String = num2str(fs);
    Fst1 = str2num(handles.LowCutoffFreq.String);  % The max frequency (Hz) of the low stop band  
    Fp1 = Fst1+150;   % The min frequency (Hz) of the pass band
    Fp2 = str2num(handles.HighCutoffFreq.String);  % The max frequency (Hz) of the pass band
    Fst2 = Fp2+150; % The min frequency (Hz) of the high stop band
    Ast1 = 60;   % ratio of suppression in low stop band (dB)
    Ap = 1;      % Pass band ripple ratio (dB)
    Ast2 = 60;   % ratio of suppression in high stop band (dB)
    d = fdesign.bandpass('Fst1,Fp1,Fp2,Fst2,Ast1,Ap,Ast2',Fst1,Fp1,Fp2,Fst2,Ast1,Ap,Ast2,fs);
    Hd = design(d,'equiripple');
    handles.FilteringCheck.UserData = Hd;
else
    Hd = handles.FilteringCheck.UserData;
end
if (handles.FilteringCheck.Value == 1)
    filtered = filtfilt(Hd.Numerator,1,y);
    [im,f,t]=zftftb_pretty_sonogram(filtered,fs,'len',str2num(handles.FFTlen.String),'overlap',str2num(handles.WindowOverlap.String),...
					'tscale',str2num(handles.GaussTimescale.String),'zeropad',0,'norm_amp',1,'clipping',[-2 2]);
else
    [im,f,t]=zftftb_pretty_sonogram(y,fs,'len',str2num(handles.FFTlen.String),'overlap',str2num(handles.WindowOverlap.String),...
					'tscale',str2num(handles.GaussTimescale.String),'zeropad',0,'norm_amp',1,'clipping',[-2 2]);
end
axes(handles.SonogramWindow)
imagesc(t,f,uint8(im*62))
axis xy;
handles.TimeSlider.Value = 0; handles.TimeSlider.UserData = max(t);
xlim([0 1]); ylim([str2num(handles.LowCutoffFreq.String) str2num(handles.HighCutoffFreq.String)]);
colormap hot;
xlabel('Time (Sec)');
ylabel('Frequency (Hz)');
cd(base_dir);

% --- Executes on selection change in BaseDirContent.
function BaseDirContent_Callback(hObject, eventdata, handles)
% hObject    handle to BaseDirContent (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns BaseDirContent contents as cell array
%        contents{get(hObject,'Value')} returns selected item from BaseDirContent

update_tables_and_graphics(handles,handles.BaseDirContent.Value,...
    1,1,0,0,0);
% tagging_data_struct = handles.BaseDirName.UserData;
% base_dir = tagging_data_struct.base_dir;
% loc = hObject.Value;
% cd(tagging_data_struct.birds{loc});
% subdirs = dir; folders = [subdirs.isdir]; subdirs = subdirs(folders); subdirs(1:2) = [];
% handles.DateFolders.String = {subdirs.name};
% handles.DateFolders.Value = 1;
% cd(fullfile(subdirs(1).name,'chop_data','wav'));
% wavfiles = dir('*.wav');
% handles.AudioFiles.String = {wavfiles.name};
% handles.AudioFiles.Value = 1;
% [y,fs] = audioread(wavfiles(1).name);
% if (str2num(handles.SamplingFrequency.String) ~= fs)
%     handles.SamplingFrequency.String = num2str(fs);
%     Fst1 = str2num(handles.LowCutoffFreq.String);  % The max frequency (Hz) of the low stop band  
%     Fp1 = Fst1+150;   % The min frequency (Hz) of the pass band
%     Fp2 = str2num(handles.HighCutoffFreq.String);  % The max frequency (Hz) of the pass band
%     Fst2 = Fp2+150; % The min frequency (Hz) of the high stop band
%     Ast1 = 60;   % ratio of suppression in low stop band (dB)
%     Ap = 1;      % Pass band ripple ratio (dB)
%     Ast2 = 60;   % ratio of suppression in high stop band (dB)
%     d = fdesign.bandpass('Fst1,Fp1,Fp2,Fst2,Ast1,Ap,Ast2',Fst1,Fp1,Fp2,Fst2,Ast1,Ap,Ast2,fs);
%     Hd = design(d,'equiripple');
%     handles.FilteringCheck.UserData = Hd;
% else
%     Hd = handles.FilteringCheck.UserData;
% end
% if (handles.FilteringCheck.Value == 1)
%     filtered = filtfilt(Hd.Numerator,1,y);
%     [im,f,t]=zftftb_pretty_sonogram(filtered,fs,'len',str2num(handles.FFTlen.String),'overlap',str2num(handles.WindowOverlap.String),...
% 					'tscale',str2num(handles.GaussTimescale.String),'zeropad',0,'norm_amp',1,'clipping',[-2 2]);
% else
%     [im,f,t]=zftftb_pretty_sonogram(y,fs,'len',str2num(handles.FFTlen.String),'overlap',str2num(handles.WindowOverlap.String),...
% 					'tscale',str2num(handles.GaussTimescale.String),'zeropad',0,'norm_amp',1,'clipping',[-2 2]);
% end
% axes(handles.SonogramWindow)
% imagesc(t,f,uint8(im*62))
% axis xy;
% handles.TimeSlider.Value = 0; handles.TimeSlider.UserData = max(t);
% xlim([0 1]); ylim([str2num(handles.LowCutoffFreq.String) str2num(handles.HighCutoffFreq.String)]);
% colormap hot;
% xlabel('Time (Sec)');
% ylabel('Frequency (Hz)');
% cd(base_dir);


% --- Executes during object creation, after setting all properties.
function BaseDirContent_CreateFcn(hObject, eventdata, handles)
% hObject    handle to BaseDirContent (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in DateFolders.
function DateFolders_Callback(hObject, eventdata, handles)
% hObject    handle to DateFolders (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns DateFolders contents as cell array
%        contents{get(hObject,'Value')} returns selected item from DateFolders
update_tables_and_graphics(handles,handles.BaseDirContent.Value,...
    handles.DateFolders.Value,1,0,0,0);
% tagging_data_struct = handles.BaseDirName.UserData;
% base_dir = tagging_data_struct.base_dir;
% loc = handles.BaseDirContent.Value;
% cd(tagging_data_struct.birds{loc});
% cd(fullfile(handles.DateFolders.String{handles.DateFolders.Value},'chop_data','wav'));
% wavfiles = dir('*.wav');
% handles.AudioFiles.String = {wavfiles.name};
% [y,fs] = audioread(wavfiles(1).name);
% if (str2num(handles.SamplingFrequency.String) ~= fs)
%     handles.SamplingFrequency.String = num2str(fs);
%     Fst1 = str2num(handles.LowCutoffFreq.String);  % The max frequency (Hz) of the low stop band  
%     Fp1 = Fst1+150;   % The min frequency (Hz) of the pass band
%     Fp2 = str2num(handles.HighCutoffFreq.String);  % The max frequency (Hz) of the pass band
%     Fst2 = Fp2+150; % The min frequency (Hz) of the high stop band
%     Ast1 = 60;   % ratio of suppression in low stop band (dB)
%     Ap = 1;      % Pass band ripple ratio (dB)
%     Ast2 = 60;   % ratio of suppression in high stop band (dB)
%     d = fdesign.bandpass('Fst1,Fp1,Fp2,Fst2,Ast1,Ap,Ast2',Fst1,Fp1,Fp2,Fst2,Ast1,Ap,Ast2,fs);
%     Hd = design(d,'equiripple');
%     handles.FilteringCheck.UserData = Hd;
% else
%     Hd = handles.FilteringCheck.UserData;
% end
% if (handles.FilteringCheck.Value == 1)
%     filtered = filtfilt(Hd.Numerator,1,y);
%     [im,f,t]=zftftb_pretty_sonogram(filtered,fs,'len',str2num(handles.FFTlen.String),'overlap',str2num(handles.WindowOverlap.String),...
% 					'tscale',str2num(handles.GaussTimescale.String),'zeropad',0,'norm_amp',1,'clipping',[-2 2]);
% else
%     [im,f,t]=zftftb_pretty_sonogram(y,fs,'len',str2num(handles.FFTlen.String),'overlap',str2num(handles.WindowOverlap.String),...
% 					'tscale',str2num(handles.GaussTimescale.String),'zeropad',0,'norm_amp',1,'clipping',[-2 2]);
% end
% axes(handles.SonogramWindow)
% imagesc(t,f,uint8(im*62))
% axis xy;
% handles.TimeSlider.Value = 0; handles.TimeSlider.UserData = max(t);
% xlim([0 1]); ylim([str2num(handles.LowCutoffFreq.String) str2num(handles.HighCutoffFreq.String)]);
% colormap hot;
% xlabel('Time (Sec)');
% ylabel('Frequency (Hz)');
% cd(base_dir);


% --- Executes during object creation, after setting all properties.
function DateFolders_CreateFcn(hObject, eventdata, handles)
% hObject    handle to DateFolders (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in AudioFiles.
function AudioFiles_Callback(hObject, eventdata, handles)
% hObject    handle to AudioFiles (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns AudioFiles contents as cell array
%        contents{get(hObject,'Value')} returns selected item from AudioFiles
%update_tables_and_graphics(handles,bird_id,date_folder_num,audio_file_num,spectrogram_im,tags_im,filter_design)
update_tables_and_graphics(handles,handles.BaseDirContent.Value,...
    handles.DateFolders.Value,handles.AudioFiles.Value,0,0,0);
% filename = hObject.String{hObject.Value};
% tagging_data_struct = handles.BaseDirName.UserData;
% base_dir=tagging_data_struct.base_dir;
% [y,fs] = audioread(fullfile(tagging_data_struct.base_dir,tagging_data_struct.birds{handles.BaseDirContent.Value},handles.DateFolders.String{handles.DateFolders.Value},...
%     'chop_data','wav',filename));
% if (str2num(handles.SamplingFrequency.String) ~= fs)
%     handles.SamplingFrequency.String = num2str(fs);
%     Fst1 = str2num(handles.LowCutoffFreq.String);  % The max frequency (Hz) of the low stop band  
%     Fp1 = Fst1+150;   % The min frequency (Hz) of the pass band
%     Fp2 = str2num(handles.HighCutoffFreq.String);  % The max frequency (Hz) of the pass band
%     Fst2 = Fp2+150; % The min frequency (Hz) of the high stop band
%     Ast1 = 60;   % ratio of suppression in low stop band (dB)
%     Ap = 1;      % Pass band ripple ratio (dB)
%     Ast2 = 60;   % ratio of suppression in high stop band (dB)
%     d = fdesign.bandpass('Fst1,Fp1,Fp2,Fst2,Ast1,Ap,Ast2',Fst1,Fp1,Fp2,Fst2,Ast1,Ap,Ast2,fs);
%     Hd = design(d,'equiripple');
%     handles.FilteringCheck.UserData = Hd;
% else
%     Hd = handles.FilteringCheck.UserData;
% end
% if (handles.FilteringCheck.Value == 1)
%     filtered = filtfilt(Hd.Numerator,1,y);
%     [im,f,t]=zftftb_pretty_sonogram(filtered,fs,'len',str2num(handles.FFTlen.String),'overlap',str2num(handles.WindowOverlap.String),...
% 					'tscale',str2num(handles.GaussTimescale.String),'zeropad',0,'norm_amp',1,'clipping',[-2 2]);
% else
%     [im,f,t]=zftftb_pretty_sonogram(y,fs,'len',str2num(handles.FFTlen.String),'overlap',str2num(handles.WindowOverlap.String),...
% 					'tscale',str2num(handles.GaussTimescale.String),'zeropad',0,'norm_amp',1,'clipping',[-2 2]);
% end
% axes(handles.SonogramWindow)
% imagesc(t,f,uint8(im*62))
% axis xy;
% handles.TimeSlider.Value = 0; handles.TimeSlider.UserData = max(t);
% xlim([0 1]); ylim([str2num(handles.LowCutoffFreq.String) str2num(handles.HighCutoffFreq.String)]);
% colormap hot;
% xlabel('Time (Sec)');
% ylabel('Frequency (Hz)');
% cd(base_dir);


% --- Executes during object creation, after setting all properties.
function AudioFiles_CreateFcn(hObject, eventdata, handles)
% hObject    handle to AudioFiles (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function TimeSlider_Callback(hObject, eventdata, handles)
% hObject    handle to TimeSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
axes(handles.SonogramWindow)
v = (hObject.Value)*hObject.UserData;
xlim([v v+str2num(handles.SonogramDuration.String)]);

% --- Executes during object creation, after setting all properties.
function TimeSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TimeSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in FilteringCheck.
function FilteringCheck_Callback(hObject, eventdata, handles)
% hObject    handle to FilteringCheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of FilteringCheck
update_tables_and_graphics(handles,handles.BaseDirContent.Value,...
    handles.DateFolders.Value,handles.AudioFiles.Value,handles.TimeSlider.Value,0,0);
% 
% filename = handles.AudioFiles.String{handles.AudioFiles.Value};
% tagging_data_struct = handles.BaseDirName.UserData;
% base_dir=tagging_data_struct.base_dir;
% [y,fs] = audioread(fullfile(tagging_data_struct.base_dir,tagging_data_struct.birds{handles.BaseDirContent.Value},handles.DateFolders.String{handles.DateFolders.Value},...
%     'chop_data','wav',filename));
% handles.SamplingFrequency.String = num2str(fs);
% Fst1 = str2num(handles.LowCutoffFreq.String);  % The max frequency (Hz) of the low stop band  
% Fp1 = Fst1+150;   % The min frequency (Hz) of the pass band
% Fp2 = str2num(handles.HighCutoffFreq.String);  % The max frequency (Hz) of the pass band
% Fst2 = Fp2+150; % The min frequency (Hz) of the high stop band
% Ast1 = 60;   % ratio of suppression in low stop band (dB)
% Ap = 1;      % Pass band ripple ratio (dB)
% Ast2 = 60;   % ratio of suppression in high stop band (dB)
% d = fdesign.bandpass('Fst1,Fp1,Fp2,Fst2,Ast1,Ap,Ast2',Fst1,Fp1,Fp2,Fst2,Ast1,Ap,Ast2,fs);
% Hd = design(d,'equiripple');
% handles.FilteringCheck.UserData = Hd;
% 
% if (handles.FilteringCheck.Value == 1)
%     filtered = filtfilt(Hd.Numerator,1,y);
%     [im,f,t]=zftftb_pretty_sonogram(filtered,fs,'len',str2num(handles.FFTlen.String),'overlap',str2num(handles.WindowOverlap.String),...
% 					'tscale',str2num(handles.GaussTimescale.String),'zeropad',0,'norm_amp',1,'clipping',[-2 2]);
% else
%     [im,f,t]=zftftb_pretty_sonogram(y,fs,'len',str2num(handles.FFTlen.String),'overlap',str2num(handles.WindowOverlap.String),...
% 					'tscale',str2num(handles.GaussTimescale.String),'zeropad',0,'norm_amp',1,'clipping',[-2 2]);
% end
% axes(handles.SonogramWindow)
% imagesc(t,f,uint8(im*62))
% axis xy;
% handles.TimeSlider.Value = 0; handles.TimeSlider.UserData = max(t);
% xlim([0 1]); ylim([str2num(handles.LowCutoffFreq.String) str2num(handles.HighCutoffFreq.String)]);
% colormap hot;
% xlabel('Time (Sec)');
% ylabel('Frequency (Hz)');
% cd(base_dir);


function LowCutoffFreq_Callback(hObject, eventdata, handles)
% hObject    handle to LowCutoffFreq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of LowCutoffFreq as text
%        str2double(get(hObject,'String')) returns contents of LowCutoffFreq as a double
update_tables_and_graphics(handles,handles.BaseDirContent.Value,...
    handles.DateFolders.Value,handles.AudioFiles.Value,handles.TimeSlider.Value,0,1);

% filename = handles.AudioFiles.String{handles.AudioFiles.Value};
% tagging_data_struct = handles.BaseDirName.UserData;
% base_dir=tagging_data_struct.base_dir;
% [y,fs] = audioread(fullfile(tagging_data_struct.base_dir,tagging_data_struct.birds{handles.BaseDirContent.Value},handles.DateFolders.String{handles.DateFolders.Value},...
%     'chop_data','wav',filename));
% handles.SamplingFrequency.String = num2str(fs);
% Fst1 = str2num(handles.LowCutoffFreq.String);  % The max frequency (Hz) of the low stop band  
% Fp1 = Fst1+150;   % The min frequency (Hz) of the pass band
% Fp2 = str2num(handles.HighCutoffFreq.String);  % The max frequency (Hz) of the pass band
% Fst2 = Fp2+150; % The min frequency (Hz) of the high stop band
% Ast1 = 60;   % ratio of suppression in low stop band (dB)
% Ap = 1;      % Pass band ripple ratio (dB)
% Ast2 = 60;   % ratio of suppression in high stop band (dB)
% d = fdesign.bandpass('Fst1,Fp1,Fp2,Fst2,Ast1,Ap,Ast2',Fst1,Fp1,Fp2,Fst2,Ast1,Ap,Ast2,fs);
% Hd = design(d,'equiripple');
% handles.FilteringCheck.UserData = Hd;
% 
% if (handles.FilteringCheck.Value == 1)
%     filtered = filtfilt(Hd.Numerator,1,y);
%     [im,f,t]=zftftb_pretty_sonogram(filtered,fs,'len',str2num(handles.FFTlen.String),'overlap',str2num(handles.WindowOverlap.String),...
% 					'tscale',str2num(handles.GaussTimescale.String),'zeropad',0,'norm_amp',1,'clipping',[-2 2]);
% else
%     [im,f,t]=zftftb_pretty_sonogram(y,fs,'len',str2num(handles.FFTlen.String),'overlap',str2num(handles.WindowOverlap.String),...
% 					'tscale',str2num(handles.GaussTimescale.String),'zeropad',0,'norm_amp',1,'clipping',[-2 2]);
% end
% axes(handles.SonogramWindow)
% imagesc(t,f,uint8(im*62))
% axis xy;
% handles.TimeSlider.Value = 0; handles.TimeSlider.UserData = max(t);
% xlim([0 1]); ylim([str2num(handles.LowCutoffFreq.String) str2num(handles.HighCutoffFreq.String)]);
% colormap hot;
% xlabel('Time (Sec)');
% ylabel('Frequency (Hz)');
% cd(base_dir);


% --- Executes during object creation, after setting all properties.
function LowCutoffFreq_CreateFcn(hObject, eventdata, handles)
% hObject    handle to LowCutoffFreq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function HighCutoffFreq_Callback(hObject, eventdata, handles)
% hObject    handle to HighCutoffFreq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of HighCutoffFreq as text
%        str2double(get(hObject,'String')) returns contents of HighCutoffFreq as a double
update_tables_and_graphics(handles,handles.BaseDirContent.Value,...
    handles.DateFolders.Value,handles.AudioFiles.Value,handles.TimeSlider.Value,0,1);
% 
% filename = handles.AudioFiles.String{handles.AudioFiles.Value};
% tagging_data_struct = handles.BaseDirName.UserData;
% base_dir=tagging_data_struct.base_dir;
% [y,fs] = audioread(fullfile(tagging_data_struct.base_dir,tagging_data_struct.birds{handles.BaseDirContent.Value},handles.DateFolders.String{handles.DateFolders.Value},...
%     'chop_data','wav',filename));
% handles.SamplingFrequency.String = num2str(fs);
% Fst1 = str2num(handles.LowCutoffFreq.String);  % The max frequency (Hz) of the low stop band  
% Fp1 = Fst1+150;   % The min frequency (Hz) of the pass band
% Fp2 = str2num(handles.HighCutoffFreq.String);  % The max frequency (Hz) of the pass band
% Fst2 = Fp2+150; % The min frequency (Hz) of the high stop band
% Ast1 = 60;   % ratio of suppression in low stop band (dB)
% Ap = 1;      % Pass band ripple ratio (dB)
% Ast2 = 60;   % ratio of suppression in high stop band (dB)
% d = fdesign.bandpass('Fst1,Fp1,Fp2,Fst2,Ast1,Ap,Ast2',Fst1,Fp1,Fp2,Fst2,Ast1,Ap,Ast2,fs);
% Hd = design(d,'equiripple');
% handles.FilteringCheck.UserData = Hd;
% 
% if (handles.FilteringCheck.Value == 1)
%     filtered = filtfilt(Hd.Numerator,1,y);
%     [im,f,t]=zftftb_pretty_sonogram(filtered,fs,'len',str2num(handles.FFTlen.String),'overlap',str2num(handles.WindowOverlap.String),...
% 					'tscale',str2num(handles.GaussTimescale.String),'zeropad',0,'norm_amp',1,'clipping',[-2 2]);
% else
%     [im,f,t]=zftftb_pretty_sonogram(y,fs,'len',str2num(handles.FFTlen.String),'overlap',str2num(handles.WindowOverlap.String),...
% 					'tscale',str2num(handles.GaussTimescale.String),'zeropad',0,'norm_amp',1,'clipping',[-2 2]);
% end
% axes(handles.SonogramWindow)
% imagesc(t,f,uint8(im*62))
% axis xy;
% handles.TimeSlider.Value = 0; handles.TimeSlider.UserData = max(t);
% xlim([0 1]); ylim([str2num(handles.LowCutoffFreq.String) str2num(handles.HighCutoffFreq.String)]);
% colormap hot;
% xlabel('Time (Sec)');
% ylabel('Frequency (Hz)');
% cd(base_dir);


% --- Executes during object creation, after setting all properties.
function HighCutoffFreq_CreateFcn(hObject, eventdata, handles)
% hObject    handle to HighCutoffFreq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function FFTlen_Callback(hObject, eventdata, handles)
% hObject    handle to FFTlen (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of FFTlen as text
%        str2double(get(hObject,'String')) returns contents of FFTlen as a double
update_tables_and_graphics(handles,handles.BaseDirContent.Value,...
    handles.DateFolders.Value,handles.AudioFiles.Value,handles.TimeSlider.Value,0,0);

% filename = handles.AudioFiles.String{handles.AudioFiles.Value};
% tagging_data_struct = handles.BaseDirName.UserData;
% base_dir=tagging_data_struct.base_dir;
% [y,fs] = audioread(fullfile(tagging_data_struct.base_dir,tagging_data_struct.birds{handles.BaseDirContent.Value},handles.DateFolders.String{handles.DateFolders.Value},...
%     'chop_data','wav',filename));
% handles.SamplingFrequency.String = num2str(fs);
% Hd = handles.FilteringCheck.UserData;
% 
% if (handles.FilteringCheck.Value == 1)
%     filtered = filtfilt(Hd.Numerator,1,y);
%     [im,f,t]=zftftb_pretty_sonogram(filtered,fs,'len',str2num(handles.FFTlen.String),'overlap',str2num(handles.WindowOverlap.String),...
% 					'tscale',str2num(handles.GaussTimescale.String),'zeropad',0,'norm_amp',1,'clipping',[-2 2]);
% else
%     [im,f,t]=zftftb_pretty_sonogram(y,fs,'len',str2num(handles.FFTlen.String),'overlap',str2num(handles.WindowOverlap.String),...
% 					'tscale',str2num(handles.GaussTimescale.String),'zeropad',0,'norm_amp',1,'clipping',[-2 2]);
% end
% axes(handles.SonogramWindow)
% imagesc(t,f,uint8(im*62))
% axis xy;
% handles.TimeSlider.Value = 0; handles.TimeSlider.UserData = max(t);
% xlim([0 1]); ylim([str2num(handles.LowCutoffFreq.String) str2num(handles.HighCutoffFreq.String)]);
% colormap hot;
% xlabel('Time (Sec)');
% ylabel('Frequency (Hz)');
% cd(base_dir);


% --- Executes during object creation, after setting all properties.
function FFTlen_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FFTlen (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function WindowOverlap_Callback(hObject, eventdata, handles)
% hObject    handle to WindowOverlap (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of WindowOverlap as text
%        str2double(get(hObject,'String')) returns contents of WindowOverlap as a double
update_tables_and_graphics(handles,handles.BaseDirContent.Value,...
    handles.DateFolders.Value,handles.AudioFiles.Value,handles.TimeSlider.Value,0,0);
% 
% filename = handles.AudioFiles.String{handles.AudioFiles.Value};
% tagging_data_struct = handles.BaseDirName.UserData;
% base_dir=tagging_data_struct.base_dir;
% [y,fs] = audioread(fullfile(tagging_data_struct.base_dir,tagging_data_struct.birds{handles.BaseDirContent.Value},handles.DateFolders.String{handles.DateFolders.Value},...
%     'chop_data','wav',filename));
% handles.SamplingFrequency.String = num2str(fs);
% Hd = handles.FilteringCheck.UserData;
% 
% if (handles.FilteringCheck.Value == 1)
%     filtered = filtfilt(Hd.Numerator,1,y);
%     [im,f,t]=zftftb_pretty_sonogram(filtered,fs,'len',str2num(handles.FFTlen.String),'overlap',str2num(handles.WindowOverlap.String),...
% 					'tscale',str2num(handles.GaussTimescale.String),'zeropad',0,'norm_amp',1,'clipping',[-2 2]);
% else
%     [im,f,t]=zftftb_pretty_sonogram(y,fs,'len',str2num(handles.FFTlen.String),'overlap',str2num(handles.WindowOverlap.String),...
% 					'tscale',str2num(handles.GaussTimescale.String),'zeropad',0,'norm_amp',1,'clipping',[-2 2]);
% end
% axes(handles.SonogramWindow)
% imagesc(t,f,uint8(im*62))
% axis xy;
% handles.TimeSlider.Value = 0; handles.TimeSlider.UserData = max(t);
% xlim([0 1]); ylim([str2num(handles.LowCutoffFreq.String) str2num(handles.HighCutoffFreq.String)]);
% colormap hot;
% xlabel('Time (Sec)');
% ylabel('Frequency (Hz)');
% cd(base_dir);


% --- Executes during object creation, after setting all properties.
function WindowOverlap_CreateFcn(hObject, eventdata, handles)
% hObject    handle to WindowOverlap (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function GaussTimescale_Callback(hObject, eventdata, handles)
% hObject    handle to GaussTimescale (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of GaussTimescale as text
%        str2double(get(hObject,'String')) returns contents of GaussTimescale as a double
update_tables_and_graphics(handles,handles.BaseDirContent.Value,...
    handles.DateFolders.Value,handles.AudioFiles.Value,handles.TimeSlider.Value,0,0);

% filename = handles.AudioFiles.String{handles.AudioFiles.Value};
% tagging_data_struct = handles.BaseDirName.UserData;
% base_dir=tagging_data_struct.base_dir;
% [y,fs] = audioread(fullfile(tagging_data_struct.base_dir,tagging_data_struct.birds{handles.BaseDirContent.Value},handles.DateFolders.String{handles.DateFolders.Value},...
%     'chop_data','wav',filename));
% handles.SamplingFrequency.String = num2str(fs);
% Hd = handles.FilteringCheck.UserData;
% 
% if (handles.FilteringCheck.Value == 1)
%     filtered = filtfilt(Hd.Numerator,1,y);
%     [im,f,t]=zftftb_pretty_sonogram(filtered,fs,'len',str2num(handles.FFTlen.String),'overlap',str2num(handles.WindowOverlap.String),...
% 					'tscale',str2num(handles.GaussTimescale.String),'zeropad',0,'norm_amp',1,'clipping',[-2 2]);
% else
%     [im,f,t]=zftftb_pretty_sonogram(y,fs,'len',str2num(handles.FFTlen.String),'overlap',str2num(handles.WindowOverlap.String),...
% 					'tscale',str2num(handles.GaussTimescale.String),'zeropad',0,'norm_amp',1,'clipping',[-2 2]);
% end
% axes(handles.SonogramWindow)
% imagesc(t,f,uint8(im*62))
% axis xy;
% handles.TimeSlider.Value = 0; handles.TimeSlider.UserData = max(t);
% xlim([0 1]); ylim([str2num(handles.LowCutoffFreq.String) str2num(handles.HighCutoffFreq.String)]);
% colormap hot;
% xlabel('Time (Sec)');
% ylabel('Frequency (Hz)');
% cd(base_dir);


% --- Executes during object creation, after setting all properties.
function GaussTimescale_CreateFcn(hObject, eventdata, handles)
% hObject    handle to GaussTimescale (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function TagsAxes_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TagsAxes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate TagsAxes
set(hObject,'XTick',[]);
set(hObject,'YTick',[]);


% --- Executes on button press in PlayButton.
function PlayButton_Callback(hObject, eventdata, handles)
% hObject    handle to PlayButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in PauseButton.
function PauseButton_Callback(hObject, eventdata, handles)
% hObject    handle to PauseButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in ShowTagCheck.
function ShowTagCheck_Callback(hObject, eventdata, handles)
% hObject    handle to ShowTagCheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ShowTagCheck
if (hObject.Value == 1)
    set(handles.TagsAxes,'Visible','on')
else
    set(handles.TagsAxes,'Visible','off')
end
% --- Executes on button press in AddDTWtagButton.
function AddDTWtagButton_Callback(hObject, eventdata, handles)
% hObject    handle to AddDTWtagButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in AddFeaturesTagButton.
function AddFeaturesTagButton_Callback(hObject, eventdata, handles)
% hObject    handle to AddFeaturesTagButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in RemoveTagButton.
function RemoveTagButton_Callback(hObject, eventdata, handles)
% hObject    handle to RemoveTagButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in UpdateBirdsButton.
function UpdateBirdsButton_Callback(hObject, eventdata, handles)
% hObject    handle to UpdateBirdsButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
create_base_structure(handles);

function create_base_structure(handles)
% this function is only called if the file TaggingDataStruct.mat doesn't
% exist in the base directory
base_dir = handles.BaseDirName.String;
cd(base_dir);
dirs = dir; folders = [dirs.isdir]; dirs = dirs(folders); dirs(1:2) = [];
[Selection,ok] = listdlg('ListString',{dirs.name},'Name','Ignore Dirs.','PromptString',{'Choose directories to ignore because they are not associated with birds'});
dirs(Selection) = [];
dates = [];
for cnt = 1:numel(dirs)
    cd(dirs(cnt).name);
    subdirs = dir; folders = [subdirs.isdir]; subdirs = subdirs(folders); subdirs(1:2) = [];
    datestrs = {subdirs.name};
    dates = [dates; datestrs(cellfun(@datenum,datestrs) == min(cellfun(@datenum,datestrs)))];
    cd(base_dir);
end
[tmp, ind] = sort(cellfun(@datenum,dates));
tagging_data_struct.base_dir = base_dir;
tagging_data_struct.birds = {dirs(ind).name}';
tagging_data_struct.first_day = dates(ind);
save('TaggingDataStruct','tagging_data_struct');
handles.BaseDirName.UserData = tagging_data_struct;
update_tables_and_graphics(handles,1,1,1,0,0,0);

function create_tagging_structure(handles)
% This function is called if there's a need to refresh the structure in
% TaggingDataStruct.mat
base_dir = handles.BaseDirName.String;
cd(base_dir);
tagging_data_struct = handles.BaseDirName.UserData;
if isstruct(tagging_data_struct)
    
end

function update_tables_and_graphics(handles,bird_id,date_folder_num,audio_file_num,spectrogram_im,tags_im,filter_design)

tagging_data_struct = handles.BaseDirName.UserData;
base_dir = handles.BaseDirName.String;
cd(base_dir);
handles.BaseDirContent.String = tagging_data_struct.birds;
handles.BaseDirContent.Value = bird_id;
cd(tagging_data_struct.birds{bird_id});
subdirs = dir; folders = [subdirs.isdir]; subdirs = subdirs(folders); subdirs(1:2) = [];
handles.DateFolders.String = {subdirs.name};
handles.DateFolders.Value = date_folder_num;
cd(fullfile(subdirs(date_folder_num).name,'chop_data','wav'));
wavfiles = dir('*.wav');
handles.AudioFiles.String = {wavfiles.name};
[y,fs] = audioread(wavfiles(audio_file_num).name);
handles.SamplingFrequency.String = num2str(fs);


if (filter_design == 1)
    Fst1 = str2num(handles.LowCutoffFreq.String);  % The max frequency (Hz) of the low stop band  
    Fp1 = Fst1+150;   % The min frequency (Hz) of the pass band
    Fp2 = str2num(handles.HighCutoffFreq.String);  % The max frequency (Hz) of the pass band
    Fst2 = Fp2+150; % The min frequency (Hz) of the high stop band
    Ast1 = 60;   % ratio of suppression in low stop band (dB)
    Ap = 1;      % Pass band ripple ratio (dB)
    Ast2 = 60;   % ratio of suppression in high stop band (dB)
    d = fdesign.bandpass('Fst1,Fp1,Fp2,Fst2,Ast1,Ap,Ast2',Fst1,Fp1,Fp2,Fst2,Ast1,Ap,Ast2,fs);
    Hd = design(d,'equiripple');
    handles.FilteringCheck.UserData = Hd;
else
    Hd = handles.FilteringCheck.UserData;
end
if (handles.FilteringCheck.Value == 1)
    filtered = filtfilt(Hd.Numerator,1,y);
    [im,f,t]=zftftb_pretty_sonogram(filtered,fs,'len',str2num(handles.FFTlen.String),'overlap',str2num(handles.WindowOverlap.String),...
                    'tscale',str2num(handles.GaussTimescale.String),'zeropad',0,'norm_amp',1,'clipping',[-2 2]);
else
    [im,f,t]=zftftb_pretty_sonogram(y,fs,'len',str2num(handles.FFTlen.String),'overlap',str2num(handles.WindowOverlap.String),...
                    'tscale',str2num(handles.GaussTimescale.String),'zeropad',0,'norm_amp',1,'clipping',[-2 2]);
end
if (spectrogram_im >= 0)
    axes(handles.SonogramWindow)
    imagesc(t,f,uint8(im*62))
    axis xy;
    handles.TimeSlider.Value = spectrogram_im; handles.TimeSlider.UserData = max(t);
    
    xlim([spectrogram_im*max(t) spectrogram_im*max(t)+str2num(handles.SonogramDuration.String)]); ylim([str2num(handles.LowCutoffFreq.String) str2num(handles.HighCutoffFreq.String)]);
    colormap hot;
    xlabel('Time (Sec)');
    ylabel('Frequency (Hz)');
end
if tags_im   
    if exist(fullfile(base_dir,tagging_data_struct.birds{handles.BaseDirContent.Value},...
            handles.DateFolders.String{handles.DateFolders.Value},'chop_data','tags'),'dir')
        fname = fullfile(base_dir,tagging_data_struct.birds{handles.BaseDirContent.Value},...
            handles.DateFolders.String{handles.DateFolders.Value},'chop_data','tags',...
            [handles.AudioFiles.String{handles.AudioFiles.Value}(1:end-3) '_tags.mat']);
        if exist(fname,'file')
            load(fname);
            handles.ShowTagCheck.UserData = labels_struct;
        else
            res = detect_audio_segments(data,fs,smoothing_time,thr);
        end
    else
        mkdir(fullfile(base_dir,tagging_data_struct.birds{handles.BaseDirContent.Value},...
            handles.DateFolders.String{handles.DateFolders.Value},'chop_data','tags'));
        fname = fullfile(base_dir,tagging_data_struct.birds{handles.BaseDirContent.Value},...
            handles.DateFolders.String{handles.DateFolders.Value},'chop_data','tags',...
            [handles.AudioFiles.String{handles.AudioFiles.Value}(1:end-3) '_tags.mat']);
    end
    
    load(fullfile(base_dir,tagging_data_struct.birds{handles.BaseDirContent.Value},'TagStructure.mat'));
    handles.ShowTagCheck.UserData = labels_struct;
    if (labels_struct.num_tags > 0)
        handles.LabelsTable.Data = labels_struct.data(:,1:3);
    else
        handles.LabelsTable.Data = {};
    end
else
    labels_struct.bird_id = tagging_data_struct.birds{handles.BaseDirContent.Value};
    labels_struct.num_tags = 0;
    labels_struct.data = {};
    handles.LabelsTable.Data = labels_struct.data;
    handles.ShowTagCheck.UserData = labels_struct;
    save(fullfile(base_dir,tagging_data_struct.birds{handles.BaseDirContent.Value},'TagStructure.mat'),'labels_struct');
end


    
      



function SonogramDuration_Callback(hObject, eventdata, handles)
% hObject    handle to SonogramDuration (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SonogramDuration as text
%        str2double(get(hObject,'String')) returns contents of SonogramDuration as a double


% --- Executes during object creation, after setting all properties.
axes(handles.SonogramWindow)
v = (handles.TimeSlider.Value)*handles.TimeSlider.UserData;
xlim([v v+str2num(handles.SonogramDuration.String)]);

function SonogramDuration_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SonogramDuration (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
