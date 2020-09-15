% Read image and display its RGB
global img;
img = im2double(imread('image1.bmp'));
imgRed = img(:,:,1); 
imgGreen = img(:,:,2); 
imgBlue = img(:,:,3); 

% figure('Name','RED');
% imshow(imgRed);
% figure('Name','GREEN');
% imshow(imgGreen);
% figure('Name','BLUE');
% imshow(imgBlue);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Get image props that are gonna be used later
[height, width, channelsCount] = size(img);

fid = fopen('image1.bmp');
fseek(fid, 0, 'eof');
imgSize = ftell(fid);
fclose(fid);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Calculate PSNR and Compression Ratios and display figures
global dctMx;
dctMx = dctmtx(8);
mCount = 4;
psnr = zeros(mCount, 1); % Peak Signal To Noise Ratio
compressionRatio = zeros(mCount, 1); % Compression Ratio

for i=1:mCount
    compressionSize = dctCompress(i, height, width, imgRed, imgGreen, imgBlue);
    compressionRatio(i) = imgSize / compressionSize;
end

for i=1:mCount
    psnr(i) = DCTDecompress(i, height, width);
end

figure('Name','PSNR');
bar(1:1:mCount, psnr);
xlabel('m');
ylabel('PSNR');

figure('Name','Compression Ratio');
bar(1:1:mCount, compressionRatio);
xlabel('m');
ylabel('Compression Ratio');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% DCT Compression
function compressionSize = dctCompress(m, height, width, red, green, blue)
    
    % Initialize Metrices
    normalizedHeight = height / (8 / m);
    normalizedWidth = width / (8 / m);
    
    redMx = zeros(normalizedHeight, normalizedWidth);
    greenMx = zeros(normalizedHeight, normalizedWidth);
    blueMx = zeros(normalizedHeight, normalizedWidth);

    % dct compress and mask coefficients around the m*m block of the 8*8
    % block (keeping only m*m coefficient) of each 8*8 coefficient
    for i=1:height/8 
        for j=1:width/8
           x0 = (i - 1) * m + 1;
           x =  m * i;
           y0 = (j - 1) * m + 1;
           y = m * j;
           
           block = compress(red, i, j, m);
           redMx(x0:x, y0:y) = block;
                      
           block = compress(green, i, j, m);
           greenMx(x0:x, y0:y) = block;
           
           block = compress(blue, i, j, m);
           blueMx(x0:x, y0:y) = block;

        end
    end
    
    % save the coefficients to a file
    compressedRgbImage = (cat(3,redMx,greenMx,blueMx));
    compressedRgbImage = half(compressedRgbImage);
    s1 = mfilename('fullpath');
    s2 = 'encodedm';
    s3 = '.mat';
    save([s1 s2 int2str(m) s3], 'compressedRgbImage');
   
    % compressed size is the size needed to store the coefficients and
    % because they are float minimum size in matlab is 2 bytes per
    % coefficient as minimum size float is (half) in matlab
    fid = fopen([s1 s2 int2str(m) s3]);
    fseek(fid, 0, 'eof');
    compressionSize = ftell(fid);
    fclose(fid);
    
end

function thePSNR = DCTDecompress(m, height, width)
    % make matrices to hold the channels of the decompressed image
    newRedChannel = zeros(height, width);
    newBlueChannel = zeros(height, width);
    newGreenChannel = zeros(height, width);
    
    % load the coefficients from the stored comrpessed file
    s1 = mfilename('fullpath');
    s2 = 'encodedm';
    s3 = '.mat';
    rgbImageCompressed = load([s1 s2 int2str(m) s3]);
    rgbImageCompressed = rgbImageCompressed.compressedRgbImage;
    
    % Extract color channels.
    encodedRedChannel = rgbImageCompressed(:,:,1); 
    encodedGreenChannel = rgbImageCompressed(:,:,2); 
    encodedBlueChannel = rgbImageCompressed(:,:,3);
    
    % inverse dct for each block 8*8 which consists of m*m coefficient and
    % zeros around that m*m block 
    for i=1:height/8 
        for j=1:width/8
           block = decompress(encodedBlueChannel, i, j, m);
           newBlueChannel((i-1) * 8 + 1: i * 8, (j-1) * 8 + 1: j * 8) = block;

           block = decompress(encodedRedChannel, i, j, m);
           newRedChannel((i-1) * 8 + 1: i * 8, (j-1) * 8 + 1: j * 8) = block;

           block = decompress(encodedGreenChannel, i, j, m);
           newGreenChannel((i-1) * 8 + 1: i * 8, (j-1) * 8 + 1: j * 8) = block;
        end
    end
    
    % save the decompressed image to file
    DecompressedRgbImage = (cat(3,newRedChannel,newGreenChannel,newBlueChannel));
    s1 = mfilename('fullpath');
    s2 = '.bmp';
    imwrite(DecompressedRgbImage, [s1 int2str(m) s2]);
    
    % calculate the psnr and compare the output with the original visually
    global img;
    thePSNR = psnr(DecompressedRgbImage, img);
    s1 = 'comparison between original and compressed image with m = ';
    figure('Name',[s1 int2str(m)],'NumberTitle','off');
    imshowpair(DecompressedRgbImage, img, 'montage');
end

function result = compress(mx, x0, y0, m)
  global dctMx;
  x1 = (x0 - 1) * 8 + 1;
  x = x0 * 8;
  y1 = (y0 - 1) * 8 + 1;
  y = y0 * 8;
  
  mxTransformed = dctMx * mx(x1:x, y1:y) * dctMx';
  result = mxTransformed(1:m, 1:m);
end

function result = decompress(mx, x0, y0, m)
  global dctMx;
  result = zeros(8, 8);
  
  x1 = (x0 - 1) * m + 1;
  x = x0 * m;
  y1 = (y0 - 1) * m + 1;
  y = y0 * m;
  
  result(1:m, 1:m) = mx(x1:x, y1:y);
  result = dctMx' * result * dctMx;
end
