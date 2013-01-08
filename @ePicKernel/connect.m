function [ePic, result] = connect(ePic, port)
% function who open serial connection to the e-puck.
%
% [ePic, result] = connect(ePic, port)
%
% Results :
%   ePic            :   updated ePicKernel object
%   result          :   connection result (1:ok, 0:error)
%
% Parameters :
%   ePic            :   ePicKernel object
%   port            :   communication port name 'COMxy'

ePic.param.comPort = str2num(char(port)); %serial(port,'BaudRate', 57600,'inputBuffersize',65536,'OutputBufferSize',4096,'ByteOrder','littleendian');
try
%     % open port
%     fopen(ePic.param.comPort);
%     pause(3);
%     %disp 'Port opened'
%     flush(ePic);
%     %disp 'flushed'
%     command=[];
%     command = [command 1 170];
%     writeBin(ePic, command);   % menu choice 1 + 0xAA (get sensors data)
%     %fwrite(ePic.param.comPort, command)
%     %disp 'menu choice and get data written'
%     readBinSized(ePic, 58);
%     %fread(ePic.param.comPort, 58, 'uint8')

    usb_communication(0);
%     if(ret<0)
%         disp 'Error, Could not open usb device'
%         clear ePic.param.comPort;
%         result = 0;
%         return;
%     end

    disp 'ePic successfully connected'
    result= 1;
    ePic.param.connected = 1;
catch
    
    
    % could not open the port
    disp 'Error, Could not open serial port'
    clear ePic.param.comPort;
    result = 0;
end