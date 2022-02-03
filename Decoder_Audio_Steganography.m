%Close all figures whose handles are still vissible.
%Clear all past variables
close all; clear all;

%Select encoded audiofile
[encoded_audio_file,path_encoded_audiofile] = uigetfile('*.wav;*.mp3','Select the encoded audio file',...
                        'EncodedA
                    udioFile.wav');
%Append/combine the audio path with the file name
encoded_audio_file_and_path = append(path_encoded_audiofile, encoded_audio_file);

%%Save location of the filename audiofile
%filename = 'C:/MATLAB/encodedAudioFile.wav';
%open encoded audio file
[encoded_audio_stereo, Fs] = audioread(encoded_audio_file_and_path);

%Convert stereo encoded_audio_stereo to its binary representation in form of a matrix
InAuB = dec2bin( typecast( single(encoded_audio_stereo(:)), 'int16'), 16 ) - '0';

%Get array size of the hidden message
Size_audio = size(InAuB);
%save rows of the audio file array in a variable
rows_audio = Size_audio(1);
%save columns of the audio file array in a variable
columns_audio = Size_audio(2);
%Extract length of hidden message.
%create an array 1..32 of all zeros called 'length_msg_binary'
length_msg_binary = zeros(1,32);

%Bit depth location of the text in the audio file. 
bit_depth = 16;

%Loop through the InAuB (binary representation of the audio data)
%Get the lsb data of the 16 bit InAuB row. (last bit/16th bit)
%Put value in array variable 'length_msg_binary'
for i = 1:32
    length_msg_binary(1,i) = InAuB(i,bit_depth);
end

% Convert binary vectors to decimal, where the most significant digit is the leftmost bit element
length_msg_decimal = bi2de(length_msg_binary,'left-msb');

%create an empty array for the hidden encoded message
EnMeB = zeros(rows_audio,7);

count = 33;
%Loop through the InAuB (binary representation of the audio data) to decode
%the message out of the audio.
%Get the lsb data of the 16 bit InAuB row. (last bit/16th bit)
%Put value in array variable 'length_msg_binary'
for i = 1:length_msg_decimal
    for j = 1:7
        EnMeB(i,j) = InAuB(count,bit_depth);
        count = count + 1;
    end
end
%Convert Encoded Message matrix to char vector
hidden_message_2 = bin2dec(dec2bin(bi2de(EnMeB)));
%Convert Column char vector to Row char Vector
hidden_message_2_reverse = vec2mat(hidden_message_2, numel(hidden_message_2));
%Convert Row char Vector to Row (ASCII) char Vector
thisChar = char(hidden_message_2_reverse);
%Convert Row (ASCII) char Vector to single string
thisString = convertCharsToStrings(thisChar)
%Save decoded text file
[decoded_text_file,path_decoded_text] = uiputfile('*.txt', 'Select where you want to save the decoded text file.','DecodedTextFile.txt');

%Append/combine the encode audio path with the file name
encoded_audio_file_and_path = append(path_decoded_text, decoded_text_file);

%Open (or create) file 'decoded_msgg.txt' with write access
fid = fopen(encoded_audio_file_and_path,'w');
%Write string data from hidden message to the text file
fprintf(fid,thisString);
%Close opened file
fclose(fid);

%Show contents of the text file in the Command Windows
type(encoded_audio_file_and_path)
