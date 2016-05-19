function varout = DTAread(FILENAME,delim,num_blocks)
% Reads the .DTA files from the Gamry 600 potentiostat
% Inputs: 
% FILENAME - the file to be read.
% delim - the delimiter of the .DTA lines (set to [] for '\t')
% num_blocks - the number of blocks to read. Set to 0 to read all blocks
% Outputs:
% The output is a cell array:
% - The first cell contains the title of the measurement
% - The rest are measurement blocks containing a structure with fields:
% -- data: a matrix with columns standing for various items
% -- titles: The titles of these columns
% -- units: The units for the numbers in those columns
BlockStart='Pt';
if (num_blocks == 0)
    num_blocks = inf;
end
if (isempty(delim))
    delim = '\t';
end
fid=fopen(FILENAME,'r');
eof = 0;
block_num = 1;
currline=fgetl(fid); currline=fgetl(fid);
tokens=regexp(currline,delim,'split');
varout{1}=tokens{2};
while (block_num <= num_blocks)
    currline=fgetl(fid);
    tokens=regexp(currline,delim,'split');
    if (numel(tokens)>1)
        startline = isempty(tokens{1})*strcmp(tokens{2},'Pt');
    else
        startline = 0;
    end
    while (startline == 0)
        currline=fgetl(fid);
        tokens=regexp(currline,delim,'split');
        if (numel(tokens)>1)
            startline = isempty(tokens{1})*strcmp(tokens{2},'Pt');
        else
            startline = 0;
        end
    end
    Titles=tokens(2:end);
    currline=fgetl(fid);
    tokens=regexp(currline,delim,'split');
    Units=tokens(2:end);
    Data=[];
    currline=fgetl(fid);
    tokens=regexp(currline,delim,'split');
    if (numel(tokens)>1)
        dataline = isempty(tokens{1});
    else
        dataline = 0;
    end
    while (dataline)
        if (isempty(str2num(tokens{end})))
            Data=[Data; cellfun(@str2num,tokens(2:end-1))]; 
        else
            Data=[Data; cellfun(@str2num,tokens(2:end))];
        end
        currline=fgetl(fid);
        if (numel(currline)>1)
            tokens=regexp(currline,delim,'split');
            if (numel(tokens)>1)
                dataline = isempty(tokens{1});
            else
                dataline = 0;
            end
        else
            dataline = 0;
            eof = 1;
        end
    end
    block.titles=Titles;
    block.units=Units;
    block.data=Data;
    varout{block_num+1}=block;
    if (eof == 1)
        break;
    end
    block_num = block_num+1;
end
    
    
