function  writeBin(ePic, data )
% write allow you to send binary datas to the epuck
%
% writeBin(ePic, data )
%
% Parameters :
%   ePic            :   ePicKernel object
%   data            :   binary data to send 



try
    %fwrite(ePic.param.comPort,data,'int8','async');
    fwrite(ePic.param.comPort, data, 'async');
catch
    disp 'Erreur while data binary writing';
end