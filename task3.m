global img;
global dctMx;

img = im2double(imread('image1.bmp'));
[height, width, z] = size(img);

imgRed = img(:,:,1); 
imgGreen = img(:,:,2); 
imgBlue = img(:,:,3); 

figure('Name','RED');
imshow(imgRed);
figure('Name','GREEN');
imshow(imgGreen);
figure('Name','BLUE');
imshow(imgBlue);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calculate PSNR and Compression Ratios then display figures
dctMx = dctmtx(8);
mCount = 4;
psnr = zeros(mCount, 1);
compressionRatio = zeros(mCount, 1);
imgSize = fileSize('image1.bmp');

for i=1:mCount
    compressionSize = dctCompress(imgRed, imgGreen, imgBlue, i, height, width);
    compressionRatio(i) = imgSize / compressionSize;
end

for i=1:mCount
    psnr(i) = dctDecompress(i, height, width);
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

function compressionSize = dctCompress(red, green, blue, m, height, width)
    normalizedHeight = height / (8 / m);
    normalizedWidth = width / (8 / m);
    
    redMx = zeros(normalizedHeight, normalizedWidth);
    greenMx = zeros(normalizedHeight, normalizedWidth);
    blueMx = zeros(normalizedHeight, normalizedWidth);

    for i=1:height/8 
        for j=1:width/8
           x0 = (i - 1) * m + 1;
           x =  m * i;
           y0 = (j - 1) * m + 1;
           y = m * j;
           
           redMx(x0:x, y0:y) = compress(red, i, j, m);
           greenMx(x0:x, y0:y) = compress(green, i, j, m);
           blueMx(x0:x, y0:y) = compress(blue, i, j, m);
        end
    end
    
    compressedImg = half(cat(3, redMx, greenMx, blueMx));
    compressedImgPath = [mfilename('fullpath') 'encodedm' int2str(m) '.mat'];
    save(compressedImgPath, 'compressedImg');
  
    compressionSize = fileSize(compressedImgPath);
end

function psnrVal = dctDecompress(m, height, width)
    global img;
    
    redMx = zeros(height, width);
    greenMx = zeros(height, width);
    blueMx = zeros(height, width);

    imgPath = [mfilename('fullpath') 'encodedm' int2str(m) '.mat'];
    rgbCompressedImg = load(imgPath);
    rgbCompressedImg = rgbCompressedImg.compressedImg;
    
    redCompressedImg = rgbCompressedImg(:,:,1); 
    greenCompressedImg = rgbCompressedImg(:,:,2); 
    blueCompressedImg = rgbCompressedImg(:,:,3);
    
    for i=1:height/8 
        for j=1:width/8
           x0 = (i - 1) * 8 + 1;
           x = i * 8;
           y0 = (j - 1) * 8 + 1;
           y = j * 8;
           
           redMx(x0:x, y0:y) = decompress(redCompressedImg, i, j, m);
           blueMx(x0:x, y0:y) = decompress(blueCompressedImg, i, j, m);
           greenMx(x0:x, y0:y) = decompress(greenCompressedImg, i, j, m);
        end
    end
    
    decompressedImg = (cat(3, redMx, greenMx, blueMx));
    imwrite(decompressedImg, [mfilename('fullpath') int2str(m) '.bmp']);
    
    psnrVal = psnr(decompressedImg, img);
    figure('Name',['Original vs Compressed @m=' int2str(m)]);
    imshowpair(decompressedImg, img, 'montage');
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

function size = fileSize(path)
    fid = fopen(path);
    fseek(fid, 0, 'eof');
    size = ftell(fid);
    fclose(fid); 
end
