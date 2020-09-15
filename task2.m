global x1;
global fs1;
global x2;
global fs2;
global SampleRate;
global X1FreqScale;
global X1TimeScale;
global X2FreqScale;
global X2TimeScale;
global merged;
global separated;
global separatedFFT;
global separatedAndFiltered;

[x1,fs1]=audioread("audio1.wav");
[x2,fs2]=audioread("audio2.wav");

resampleToRate(52000);

mergeAndSeparate();

filterAudio();

plotFigures();

writeOutputAudioFiles();

function resampleToRate(rate)
    global SampleRate;
    global x1;
    global x2;
    global fs1;
    global fs2;
    global X1FreqScale;
    global X1TimeScale;
    global X2FreqScale;
    global X2TimeScale;
    SampleRate=rate;
    [p,q]=rat(SampleRate/fs1);
    x1=resample(x1,p,q);
    X1FreqScale=(SampleRate/length(x1))*(0:length(x1)-1);
    X1TimeScale=(1/SampleRate)*(0:length(x1)-1);
    [p,q]=rat(SampleRate/fs2);
    x2=resample(x2,p,q);
    X2FreqScale=(SampleRate/length(x2))*(0:length(x2)-1);
    X2TimeScale=(1/SampleRate)*(0:length(x2)-1);
end

function mergeAndSeparate()
    global merged;
    global separated;
    global x2;
    global x1;
    global X1TimeScale;
    global X2TimeScale;
    merged=zeros(1,length(x2));
    merged=merged+x2';
    merged(1:length(x1))=merged(1:length(x1))+(0.5*(x1.*(cos(2*pi*22050*X1TimeScale)')))';
    separated=4*merged.*(cos(2*pi*22050*X2TimeScale));
end

function filterAudio()
    global separated;
    global SampleRate
    global separatedFFT;
    global x2;
    from=4000*(length(x2)/SampleRate);
    till=(SampleRate-4000)*(length(x2)/SampleRate);
    separatedFFT=fft(separated);
    separatedFFT(cast(from,'int32'):cast(till,'int32'))=0*separatedFFT(cast(from,'int32'):cast(till,'int32'));
end

function plotFigures()
    global x1;
    global x2;
    global X1FreqScale;
    global X2FreqScale;
    global merged;
    global separated;
    figure(1);
    plot(X1FreqScale,abs(fft(x1)));
    figure(2);
    plot(X2FreqScale,abs(fft(x2)));
    figure(3);
    plot(log10(abs(fft(merged))));
    figure(4);
    plot(X2FreqScale,(log10(abs(fft(merged)))));
    figure(5);
    plot(abs(fft(separated)));
    figure(6);
    plot(X2FreqScale,abs(fft(separated)));
end

function writeOutputAudioFiles()
    global merged;
    global SampleRate;
    global separatedFFT;
    global separatedAndFiltered;
    global x1;
    audiowrite('merged.wav',merged,SampleRate);
    separatedAndFiltered=ifft(separatedFFT,'symmetric');
    separatedAndFiltered=separatedAndFiltered(1:length(x1));
    audiowrite('separated.wav',separatedAndFiltered,SampleRate);
end
