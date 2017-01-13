function res = SummDirs(BaseDir,path_to_wavs)
cd(BaseDir);
BaseDirContent = dir; BaseDirContent = BaseDirContent([BaseDirContent.isdir]);
res.datenums = [];
res.songs = {};
for dir_num = 1:numel(BaseDirContent)
    try
        res.datenums = [res.datenums; datenum(BaseDirContent(dir_num).name)];
        res.songs{dir_num} = AudioSegmentsInDir(fullfile(BaseDir,BaseDirContent(dir_num).name,path_to_wavs),'wav',0);
    catch em
    end
end