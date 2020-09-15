[x, fs] = audioread("audio1.wav");

% Calculating the Impulse Response
h1 = [zeros(1,0) 1 zeros(1, fs)];
h2 = [zeros(1, fs * 0.25) 0.9 zeros(1, fs- fs * 0.25)];
h3 = [zeros(1, fs * 0.5) 0.8 zeros(1, fs- fs * 0.5)];
h4 = [zeros(1, fs * 0.75) 0.7 zeros(1, fs- fs * 0.75)];
h = h1 + h2 + h3 + h4;

% Calculate Convolution of y
y = conv(x, h);

% Calculate X = Inverse DFT
maxLength = max([length(y); length(h)]);
H = fft([h'; zeros(maxLength - length(h), 1)]);
Y = fft([y; zeros(maxLength - length(y), 1)]);
X = real(ifft(Y./H));

% Display Figures
figure(1);
plot(x);
title('Audio wave input wrt time')

figure(2);
plot(X);
title('Decoded Audio Wave after removing echo wrt time')

figure(3);
plot(h);
title('Impulse response of summation of shifted input')

figure(4);
plot(y);
title('Audio wave after adding echo wrt frequency domain')

% Write Audio Files
audiowrite("echo.wav", y,fs);
audiowrite("no-echo.wav", X, fs);

