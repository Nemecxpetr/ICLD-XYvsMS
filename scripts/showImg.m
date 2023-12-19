function [] = showImg(path, name) 
%% shows picture
    img = imread(path);
    f = figure('Name', name);
    f.Position(3:4) = [280 210];
    imshow(img);
end