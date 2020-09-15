global x;
global fs;
global h;
global y;
global cleanX;

[x,fs]=audioread("audio1.wav");

h=GetImpulseResponse(0.25,0.5,0.75);

y=conv(x,h);

cleanX=GetInverseDFT(y,h);

plotFigures();

writeOutputAudioFiles();

function h = GetImpulseResponse(delay1,delay2,delay3)
    global fs;
    h1=[zeros(1,0) 1 zeros(1,fs)];
    h2=[zeros(1,fs*delay1) 0.9 zeros(1,fs-fs*delay1)];
    h3=[zeros(1,fs*delay2) 0.8 zeros(1,fs-fs*delay2)];
    h4=[zeros(1,fs*delay3) 0.7 zeros(1,fs-fs*delay3)];
    h=h1+h2+h3+h4;
end

function InverseDFT = GetInverseDFT(y, h)
    max_length=max([length(y);length(h)]);
    H=fft([h';zeros(max_length-length(h),1)]);
    Y=fft([y;zeros(max_length-length(y),1)]);
    InverseDFT = real(ifft(Y./H));
end

function plotFigures()
    global x;
    global h;
    global y;
    global cleanX;
    figure(1);
    plot(x);
    figure(2);
    plot(cleanX);
    figure(3);
    plot(h);
    figure(4);
    plot(y);
end

function writeOutputAudioFiles()
    global fs;
    global y;
    global cleanX;
    audiowrite("echo.wav",y,fs);
    audiowrite("no-echo.wav",cleanX,fs);
end
