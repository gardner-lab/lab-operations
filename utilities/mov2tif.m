function mov2tif(source_file)

[DIR,fname,ext] = fileparts(source_file);
if isempty(DIR)
    DIR = pwd;
end
if ~strcmp(ext,'tif')
    OBJ = VideoReader(source_file);
    outputFileName = fullfile(DIR,[fname '.tif']);   
    while hasFrame(OBJ)
            vidFrame = readFrame(OBJ);
            if size(vidFrame,3) > 1
                img = rgb2gray(vidFrame);
            else
                img = vidFrame;
            end
            imwrite(img, outputFileName, 'WriteMode', 'append',  'Compression','none');
     end
end
