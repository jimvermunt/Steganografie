close all; clear all;

%Select audiofile
[audio_file,path_audiofile] = uigetfile('*.wav;*.mp3','Select the wanted audio file you want to encode the message in.',...
                        'Take on me.wav');

%Append/combine the audio path with the file name
audio_file_and_path = append(path_audiofile, audio_file);

info = audioinfo(audio_file_and_path);

%Only audio files accepted with the same sampling rate as a Compact Disk
%(CD)
if info.SampleRate < 44100
    f = warndlg('Sampling Rate to Low. There could occur noise');
    return
end

% (1/Fs)*32+7 is necessary to save 1 char into an audio file
if info.Duration < 9e-4
    f = warndlg('Duration of audio to short in order to put 1 message in the audio file');
    return
end

%Select the text file that has to be encoded
[Text_file, path_textfile] = uigetfile('*.txt','Select an text File you want to encode',...
                        'lyrics.txt');
%Check Duration Steganography(start timer)                
tic;

%Append/combine the text path with the file name
Text_file_and_path = append(path_textfile, Text_file);

%Put hidden message from text file into char array
hidden_message = fileread(Text_file_and_path);

%Get the stereo input_audio_stereo and the sampling frequency from the audiofile.
[input_audio_stereo, Fs] = audioread(audio_file_and_path);

input_audio_single = single(input_audio_stereo(:));
%Convert stereo input_audio_stereo to its binary representation in form of a matrix
InAuB = dec2bin( typecast( single(input_audio_stereo(:)), 'int16'), 16 ) - '0';

%Convert hidden message to its binary representation.
% 1. dec2bin    = 'Convert decimal integer to its binary representation in text form'
% 2. bin2dec    = 'Convert text representation of binary integer to a double value'
% 3. de2bi      = 'Convert decimal numbers to binary vectors'
InMeB=de2bi(bin2dec(dec2bin(hidden_message, 7)),7);

%Check if Message fits in Audio File
if (((length(hidden_message)*7)+32) > length(InAuB))
    f = warndlg('Text Message is to big for the audio file. There are  = ' + string(length(InAuB)) + ' audio samples, while you need ' + string((length(hidden_message)*7)+32) + ' samples to hide your message.');
    return
end

%Get array size of the hidden message
Size = size(InMeB);
%save rows of the hidden message array in a variable
rows = Size(1);
%save columns of the hidden message array in a variable
columns = Size(2);
%create variable and put audio file in it.
EnAuB = InAuB;

%Bit depth location of the text in the audio file. 
bit_depth = 16;

%write all last significant bits 0 till bit 33.
for i =1: 32
    EnAuB(i,bit_depth) = 0;
end

%Adding commands to audio file
length_msg_decimal = 32; %
k = 32;
total_bits_for_msg_decimal = rows;
total_bits_for_msg_binary = de2bi(total_bits_for_msg_decimal,'left-msb');
i_stop = size(total_bits_for_msg_binary);
i_stop = i_stop(2);
for i = 1:i_stop
    put_lsb = total_bits_for_msg_binary(1,i_stop-i+1);
    EnAuB(k,bit_depth) = put_lsb;
    k = k-1;
end

%Adding message to audio with LSB
k = 33;
for i = 1:rows
    for j = 1:columns
        put_lsb = InMeB(i,j);

         EnAuB(k,bit_depth) = put_lsb;
         k = k+1;
    end
end

encoded_audio_stereo = reshape( typecast( uint16(bin2dec( char(EnAuB + '0') )), 'single' ), size(input_audio_stereo) );
encoded_audio_single = single(encoded_audio_stereo(:));

%end timer
toc

%Save encoded audiofile
[encodedAudio_file,path_encodedAudio] = uiputfile('*.wav;*.mp3', 'Select where you want to save the encoded audio file','EncodedAudioFile.wav');

%Append/combine the encode audio path with the file name
encodedAudio_file = append(path_audiofile, encodedAudio_file);

%save the audio file with a Bits Per Sample of '32  in this folder
audiowrite(encodedAudio_file, encoded_audio_stereo, Fs, 'BitsPerSample', 32);

% Difference of input audio (blue) and encoded audio (orange) with a power spectral density representation.
plot(20*log(abs(fft(encoded_audio_single))))
xlabel('Frequency (Hz)')
ylabel('Amplitude')
hold on
plot(20*log(abs(fft(input_audio_single))))
title({'Difference of input audio (blue) and encoded audio (orange)', 'with a power spectral density representation'})
hold off

%Input audio (orange) and encoded audio (blue) as Absolute Logarithmic Representation with FFT
%Difference with encoded audio is only noticable when bit depth < 12
figure;
encoded_audio_stereo_fft = fft(encoded_audio_stereo);
plot(abs(encoded_audio_stereo_fft(:,1)))
xlabel('Frequency in Hz ')
ylabel('Amplitude')
hold on
input_audio_stereo_fft = fft(input_audio_stereo);
plot(abs(input_audio_stereo_fft(:,1)))
title({'Input audio (orange) and encoded audio (blue)', 'as Absolute Logarithmic Representation with FFT'})
signal_to_noise_ratio = 10*log10((sum(abs((input_audio_single)).^2)/sum(abs((encoded_audio_single-input_audio_single)).^2)))

