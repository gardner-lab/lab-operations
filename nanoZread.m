function varout = nanoZread(FILENAME)
% Reads the .txt files from the nanoZ
% Inputs: 
% FILENAME - the file to be read.
% Outputs:
% The output is a structure with fields:
% -- data: a matrix with columns standing for various items
% -- titles: The titles of these columns
% -- date: measurement date
fid=fopen(FILENAME,'r');
eof = 0;
currline=fgetl(fid);
tokens = regexp(currline,' ','split');
date = tokens{end-3};
currline=fgetl(fid); currline=fgetl(fid);
titles = regexp(currline,'\t','split');
titles=titles(1:3);
Data=[];
while (1==1)
    currline=fgetl(fid);
    tokens = regexp(currline,'\t','split');
    if (strcmp(tokens{1},'Average'))
        eof = 1;
        break;
    end
    idx = find(cellfun(@isempty,tokens(1:end-1)) == 0);
    Data=[Data; cellfun(@str2num,tokens(idx)) nan*ones(1,numel(tokens)-1-numel(idx))]; 
end
varout.data = Data;
varout.date = date;
varout.titles = titles;
    