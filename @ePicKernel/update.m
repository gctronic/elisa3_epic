function ePic = update(ePic)
% update ePic parameter. 
% ask for selected sensors information and set motor, led and other
% parameters values on the ePuck.
%
% use the methode '[ePic] = updateDef(ePic, propName, value)' to define
% which sensor will be updated
%   
% ePic = update(ePic)
%
% Results :
%   ePic            :   updated ePicKernel object
%
% Parameters :
%   ePic            :   ePicKernel object


if (ePic.param.connected == 0)
    return;
end

% reset updated values
ePic.updated.accel = 0;
ePic.updated.proxi = 0;
ePic.updated.light = 0;
ePic.updated.micro = 0;
ePic.updated.speed = 0;
ePic.updated.pos = 0;
ePic.updated.floor = 0;
ePic.updated.floorLight = 0;
ePic.updated.exter = 0;

tx = uint8(zeros([1 9]));

tx(8) = floor(ePic.param.comPort/256);
tx(9) = bitand(ePic.param.comPort, 255);

% set motor speed
if (isempty(ePic.set.speed)~=1)          % Set motor speed
    % right speed
    if(ePic.set.speed(2) >= 0)
        tx(5) = bitor(typecast(int8(ePic.set.speed(2)),'uint8'), hex2dec('80'));
        %ePic.value.speed(2)=typecast(uint8(tx(5)), 'int8');
    else
        tx(5) = typecast(-int8(ePic.set.speed(2)),'uint8');
        %ePic.value.speed(2)=typecast(uint8(tx(5)), 'int8');
    end
    
    % left speed
    if(ePic.set.speed(1) >= 0)
        tx(6) = bitor(typecast(int8(ePic.set.speed(1)),'uint8'), hex2dec('80'));
        %ePic.value.speed(1)=typecast(uint8(tx(6)), 'int8');
    else
        tx(6) = typecast(-int8(ePic.set.speed(1)),'uint8');
        %ePic.value.speed(1)=typecast(uint8(tx(6)), 'int8');
    end

    clear ePic.set.speed;
end

% set led values
for i=1:8
    if (ePic.set.led(i)==1)
        ePic.set.ledState = bitor(ePic.set.ledState, bitsll(uint8(1), i-1));
    elseif(ePic.clear.led(i)==1)
        ePic.set.ledState = bitand(ePic.set.ledState, bitcmp(bitsll(uint8(1), i-1)));
    end
end
tx(7) = ePic.set.ledState;
ePic.set.led = zeros(1,10); 
ePic.clear.led = zeros(1,10); 

if(ePic.param.resetAndCalib > 0)
   ePic.param.resetAndCalib = 0;
   tx(4) = bitor(tx(4), bitsll(uint8(1), 4));
end

tx(1) = ePic.set.rgb(1);
tx(2) = ePic.set.rgb(3);
tx(3) = ePic.set.rgb(2);

if(ePic.set.irTx(1)==1)
	tx(4) = bitor(tx(4), bitsll(uint8(1), 0));
else
	tx(4) = bitand(tx(4), bitcmp(bitsll(uint8(1), 0)));
end
if(ePic.set.irTx(2)==1)
	tx(4) = bitor(tx(4), bitsll(uint8(1), 1));
else
	tx(4) = bitand(tx(4), bitcmp(bitsll(uint8(1), 1)));
end

%tx

prox = ePic.value.proxi; %zeros(1,8);
prox_ambient = ePic.value.light; %zeros(1,8);
ground = ePic.value.floor; %zeros(1,4);
ground_ambient = ePic.value.floorLight; %zeros(1,4);
accel = ePic.value.accel; %zeros(1,3);

for i=1:5

    usb_communication(1, tx);
    
    rx = uint8(zeros([1 16]));
    [ret, rx] = usb_communication(2);
    
    if(rx(1) <= 2)  % packet not received correctly from the radio
        continue;
    end
    
    if(rx(1) == 3)  
        prox(1) = typecast([typecast(int8(rx(2)), 'uint8'), typecast(int8(rx(3)), 'uint8')], 'uint16');
        prox(2) = typecast([typecast(int8(rx(4)), 'uint8'), typecast(int8(rx(5)), 'uint8')], 'uint16');
        prox(3) = typecast([typecast(int8(rx(6)), 'uint8'), typecast(int8(rx(7)), 'uint8')], 'uint16');
        prox(4) = typecast([typecast(int8(rx(8)), 'uint8'), typecast(int8(rx(9)), 'uint8')], 'uint16');
        prox(6) = typecast([typecast(int8(rx(10)), 'uint8'), typecast(int8(rx(11)), 'uint8')], 'uint16');
        prox(7) = typecast([typecast(int8(rx(12)), 'uint8'), typecast(int8(rx(13)), 'uint8')], 'uint16');
        prox(8) = typecast([typecast(int8(rx(14)), 'uint8'), typecast(int8(rx(15)), 'uint8')], 'uint16');
        
    elseif(rx(1) == 4)
        prox(5) = typecast([typecast(int8(rx(2)), 'uint8'), typecast(int8(rx(3)), 'uint8')], 'uint16');
        for j=1:4
            ground(j)=typecast([typecast(int8(rx(j*2+2)), 'uint8'), typecast(int8(rx(j*2+3)), 'uint8')], 'uint16');
        end
        accel(1) = typecast([typecast(int8(rx(12)), 'uint8'), typecast(int8(rx(13)), 'uint8')], 'int16');
        accel(2) = typecast([typecast(int8(rx(14)), 'uint8'), typecast(int8(rx(15)), 'uint8')], 'int16');
    
    elseif(rx(1) == 5) 
        prox_ambient(1) = typecast([typecast(int8(rx(2)), 'uint8'), typecast(int8(rx(3)), 'uint8')], 'uint16');
        prox_ambient(2) = typecast([typecast(int8(rx(4)), 'uint8'), typecast(int8(rx(5)), 'uint8')], 'uint16');
        prox_ambient(3) = typecast([typecast(int8(rx(6)), 'uint8'), typecast(int8(rx(7)), 'uint8')], 'uint16');
        prox_ambient(4) = typecast([typecast(int8(rx(8)), 'uint8'), typecast(int8(rx(9)), 'uint8')], 'uint16');
        prox_ambient(6) = typecast([typecast(int8(rx(10)), 'uint8'), typecast(int8(rx(11)), 'uint8')], 'uint16');
        prox_ambient(7) = typecast([typecast(int8(rx(12)), 'uint8'), typecast(int8(rx(13)), 'uint8')], 'uint16');
        prox_ambient(8) = typecast([typecast(int8(rx(14)), 'uint8'), typecast(int8(rx(15)), 'uint8')], 'uint16');        
        
    elseif(rx(1) == 6)
        prox_ambient(5) = typecast([typecast(int8(rx(2)), 'uint8'), typecast(int8(rx(3)), 'uint8')], 'uint16');
        for j=1:4
            ground_ambient(j)=typecast([typecast(int8(rx(j*2+2)), 'uint8'), typecast(int8(rx(j*2+3)), 'uint8')], 'uint16');
        end
        accel(3) = typecast([typecast(int8(rx(12)), 'uint8'), typecast(int8(rx(13)), 'uint8')], 'int16');
        
    elseif(rx(1) == 7)
        ePic.value.odom(3) = typecast([typecast(int8(rx(10)), 'uint8'), typecast(int8(rx(11)), 'uint8')], 'int16')/10; %two_complement(uint16(rx(10:11)))/10;   % theta (degrees)
        ePic.value.odom(1) = typecast([typecast(int8(rx(12)), 'uint8'), typecast(int8(rx(13)), 'uint8')], 'int16'); %two_complement(uint16(rx(12:13)));    % x pos (mm)
        ePic.value.odom(2) = typecast([typecast(int8(rx(14)), 'uint8'), typecast(int8(rx(15)), 'uint8')], 'int16'); %two_complement(uint16(rx(14:15)));    % y pos (mm)   
        ePic.value.pos(1)=typecast([typecast(int8(rx(2)), 'uint8'), typecast(int8(rx(3)), 'uint8'), typecast(int8(rx(4)), 'uint8'), typecast(int8(rx(5)), 'uint8')], 'int32');
        ePic.value.pos(2)=typecast([typecast(int8(rx(6)), 'uint8'), typecast(int8(rx(7)), 'uint8'), typecast(int8(rx(8)), 'uint8'), typecast(int8(rx(9)), 'uint8')], 'int32');        
    end

end
ePic.value.speed(1)=ePic.set.speed(1); %typecast(uint8(tx(6)), 'int8');
ePic.value.speed(2)=ePic.set.speed(2); %typecast(uint8(tx(5)), 'int8');
    
ePic.value.proxi = filter_Prox(prox);
ePic.updated.proxi = ePic.updated.proxi + 1;    
ePic.value.light = filter_Light(prox_ambient);
ePic.updated.light = ePic.updated.light + 1;
ePic.value.floor = filter_Floor(ground);
ePic.updated.floor = ePic.updated.floor + 1;  
ePic.value.floorLight = filter_Light(ground_ambient);
ePic.updated.floorLight = ePic.updated.floorLight + 1; 
ePic.value.accel = filter_Accel(accel);
ePic.updated.accel = ePic.updated.accel + 1;
ePic.updated.odom = 1;
if (ePic.update.odom > 1)   % disable odometry if update value is sup to 1
    ePic.update.odom = 0;
end
ePic.updated.pos =  ePic.updated.pos + 1;
ePic.updated.speed = ePic.updated.speed + 1; 

%command=[];
%command = [command 170];
% % Asking for the data
% flush(ePic);
% writeBin(ePic, command);
% %raw_data = readBinSized(ePic, sdata);
% raw_data = readBinSized(ePic, 74);
%
% % Converting the data
% index=1;
% 
% if (size(raw_data,2)>0)
%     
%     prox = zeros(1,8);
%     prox_ambient = zeros(1,8);
%     for i=0:7
%         prox(i+1)=raw_data(i*4+1)+raw_data(i*4+2)*256;
%         prox_ambient(i+1)=raw_data(i*4+3)+raw_data(i*4+4)*256;
%     end        
%     ePic.value.proxi = filter_Prox(prox);
%     ePic.updated.proxi = ePic.updated.proxi + 1;    
%     ePic.value.light = filter_Light(prox_ambient);
%     ePic.updated.light = ePic.updated.light + 1;
% 
%     ground = zeros(1,4);
%     ground_ambient = zeros(1,4);
%     for i=8:11
%         ground(i-7)=raw_data(i*4+1)+raw_data(i*4+2)*256;
%         ground_ambient(i-7)=raw_data(i*4+3)+raw_data(i*4+4)*256;
%     end
%     ePic.value.floor = filter_Floor(ground);
%     ePic.updated.floor = ePic.updated.floor + 1;
%     
%     accel = zeros(1,3);
%     accel(1) = two_complement(raw_data(49:50));
%     accel(2) = two_complement(raw_data(51:52));
%     accel(3) = two_complement(raw_data(53:54));        
%     ePic.value.accel = filter_Accel(accel);
%     ePic.updated.accel = ePic.updated.accel + 1;
%         
%     ePic.value.odom(3) = two_complement(raw_data(59:60))/10;   % theta (degrees)
%     ePic.value.odom(1) = two_complement(raw_data(61:62));    % x pos (mm)
%     ePic.value.odom(2) = two_complement(raw_data(63:64));    % y pos (mm)
%     ePic.updated.odom = 1;
%     if (ePic.update.odom > 1)   % disable odometry if update value is sup to 1
%         ePic.update.odom = 0;
%     end
%     
%     ePic.value.pos(1)=typecast([uint8(raw_data(65)), uint8(raw_data(66)), uint8(raw_data(67)), uint8(raw_data(68))], 'int32');
%     ePic.value.pos(2)=typecast([uint8(raw_data(69)), uint8(raw_data(70)), uint8(raw_data(71)), uint8(raw_data(72))], 'int32');    
%     ePic.updated.pos =  ePic.updated.pos + 1;
%     
%     ePic.value.speed(1)=typecast(uint8(raw_data(73)), 'int8');
%     ePic.value.speed(2)=typecast(uint8(raw_data(74)), 'int8');
%     ePic.updated.speed = ePic.updated.speed + 1; 
%     
%   
% % 
% %     if (ePic.update.custom > 0)
% %         ePic.value.custom = raw_data(index:index+ePic.param.customSize-1);
% %         ePic.updated.custom = ePic.updated.custom + 1;
% %         index = index+ePic.param.customSize;
% %     end
%     
% end


% Reset update once parameters
if ePic.update.accel == 2
    ePic.update.accel = 0; end;
if ePic.update.proxi == 2
    ePic.update.proxi = 0; end;
if ePic.update.light == 2
    ePic.update.light = 0; end;
if ePic.update.micro == 2
    ePic.update.micro = 0; end;
if ePic.update.speed == 2
    ePic.update.speed = 0; end;
if ePic.update.pos == 2
    ePic.update.pos = 0; end;
if ePic.update.floor == 2
    ePic.update.floor = 0; end;
if ePic.update.exter == 2
    ePic.update.exter = 0; end;
if ePic.update.custom == 2
    ePic.update.custom = 0; end;