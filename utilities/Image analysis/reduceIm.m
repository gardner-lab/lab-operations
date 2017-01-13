function reduceIm(ext,factor)
% this script runs over all image files of extention 'ext' and reduce each
% dimension by factor 'factor' (integer). Results are saved with the same name with
% the suffix '_reduced'. for example: reduceIm('.bmp',2).
filenames = dir(['*' ext]);
for fnum = 1:numel(filenames)
    [pth,nam,ex]=fileparts(filenames(fnum).name);
    [x map] = imread(filenames(fnum).name);
    B = imgaussfilt(x,factor);
    OutName = [pth nam '_reduced' ex];
    imwrite(B(1:factor:end,1:factor:end,:),OutName);
end


