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
ePic.updated.exter = 0;


% Construction of the command string
command=[];
sdata=0;

% choices for values asking
if (ePic.update.proxi > 0)   % Proximity
    command=[command -'N'];
    sdata=sdata+16;
end

if (ePic.update.light > 0)   % Light sensors
    command=[command -'O'];
    sdata=sdata+16;
end

if (ePic.update.accel > 0)   % Accelerometer
    command=[command -'a'];
    sdata=sdata+6;
end

if (ePic.update.pos > 0)     % Motor position
    command=[command -'Q'];
    sdata=sdata+4;
end

if (ePic.update.micro > 0)   % Microphones
    command=[command -'u'];
    sdata=sdata+6;
end

if (ePic.update.floor > 0)   % floor sensors
    command=[command -'M'];
    sdata=sdata+6;
end

if (ePic.update.exter > 0 && ePic.param.extSel > 5)
    % external sensor parameters
    extSensorValue = 9999;
    switch ePic.param.extSel
        case {7, 14}   % Gyro, Accelero
            % same as internal accelerometers -> read accelerometer value
            if (ePic.updated.accel == 1)
                ePic.value.exter = ePic.updated.accel;
            else
                ePic.value.exter = zeros(1,3);
                disp 'Error to access external sensor. The selected sensor needs to activate the accelerometer update';
            end
        case {9, 11, 12}   % analog sensors
            extSensorValue = 0;
            sdata=sdata+2;
        case 8                      % i2c compass 
            extSensorValue= -2;
            sdata=sdata+4;
        case {13,15}                % i2c distance sensors
            extSensorValue= -1;
            sdata=sdata+4;
        case 10                      % 5 led IR sensor
            extSensorValue = ePic.param.ledIR(1) *1 + ePic.param.ledIR(2) *2 + ePic.param.ledIR(3)*4 + ePic.param.ledIR(4) *8 + ePic.param.ledIR(5)*16;
            sdata=sdata+2;
    end
    % read external sensor
    if (extSensorValue ~= 9999)
%        c2 = bitshift(extSensorValue,-8); 
%        c1 = extSensorValue - bitshift(c2,8);
        command=[command -'W' typecast(int16(extSensorValue),'int8')];
        
%        flush(ePic);
%        tmp = sprintf('W,%d', extSensorValue);
%        write(ePic, tmp);
%        raw_data = read(ePic);
%        [identifier, ePic.value.exter] = fct_TokString(raw_data);
%        if ( strcmp(upper(identifier),'W') == 0)
%            ePic.value.exter = [0];
%        end
    end
%    ePic.updated.exter = 1;
end


% set motor speed
if (isempty(ePic.set.speed)~=1)          % Set motor speed
    command=[command typecast(int8(-'D'),'int8') typecast(int16(ePic.set.speed(1)),'int8') typecast(int16(ePic.set.speed(2)),'int8')];
    clear ePic.set.speed;
end

% More logical to put it after updating the values.
if (ePic.update.speed > 0)   % Motor speed
    command=[command -'E'];
    sdata=sdata+4;
end

% set led values
for i=1:10
    if (ePic.set.led(i)==1)
        command=[command -'L' i-1 1];
    elseif(ePic.clear.led(i)==1)
        command=[command -'L' i-1 0];
    end
end
ePic.set.led = zeros(1,10); 
ePic.clear.led = zeros(1,10); 

% send the custom command
if (ePic.update.custom > 0)   % Microphones
    command=[command ePic.param.customCommand];
    sdata=sdata+ePic.param.customSize;
end


command=[command 0];

command=[];
command = [command 170];

% Asking for the data
flush(ePic);
writeBin(ePic, command);
%raw_data = readBinSized(ePic, sdata);
raw_data = readBinSized(ePic, 74);

% Converting the data
index=1;

if (size(raw_data,2)>0)
    
    prox = zeros(1,8);
    prox_ambient = zeros(1,8);
    for i=0:7
        prox(i+1)=raw_data(i*4+1)+raw_data(i*4+2)*256;
        prox_ambient(i+1)=raw_data(i*4+3)+raw_data(i*4+4)*256;
    end        
    ePic.value.proxi = filter_Prox(prox);
    ePic.updated.proxi = ePic.updated.proxi + 1;    
    ePic.value.light = filter_Light(prox_ambient);
    ePic.updated.light = ePic.updated.light + 1;

    ground = zeros(1,4);
    ground_ambient = zeros(1,4);
    for i=8:11
        ground(i-7)=raw_data(i*4+1)+raw_data(i*4+2)*256;
        ground_ambient(i-7)=raw_data(i*4+3)+raw_data(i*4+4)*256;
    end
    ePic.value.floor = filter_Floor(ground);
    ePic.updated.floor = ePic.updated.floor + 1;
    
    accel = zeros(1,3);
    accel(1) = two_complement(raw_data(49:50));
    accel(2) = two_complement(raw_data(51:52));
    accel(3) = two_complement(raw_data(53:54));        
    ePic.value.accel = filter_Accel(accel);
    ePic.updated.accel = ePic.updated.accel + 1;
        
    ePic.value.odom(3) = two_complement(raw_data(59:60))/10;   % theta (degrees)
    ePic.value.odom(1) = two_complement(raw_data(61:62));    % x pos (mm)
    ePic.value.odom(2) = two_complement(raw_data(63:64));    % y pos (mm)
    ePic.updated.odom = 1;
    if (ePic.update.odom > 1)   % disable odometry if update value is sup to 1
        ePic.update.odom = 0;
    end
    
    ePic.value.pos(1)=typecast([uint8(raw_data(65)), uint8(raw_data(66)), uint8(raw_data(67)), uint8(raw_data(68))], 'int32');
    ePic.value.pos(2)=typecast([uint8(raw_data(69)), uint8(raw_data(70)), uint8(raw_data(71)), uint8(raw_data(72))], 'int32');    
    ePic.updated.pos =  ePic.updated.pos + 1;
    
    ePic.value.speed(1)=typecast(uint8(raw_data(73)), 'int8');
    ePic.value.speed(2)=typecast(uint8(raw_data(74)), 'int8');
    ePic.updated.speed = ePic.updated.speed + 1; 
    
  
% 
%     if (ePic.update.custom > 0)
%         ePic.value.custom = raw_data(index:index+ePic.param.customSize-1);
%         ePic.updated.custom = ePic.updated.custom + 1;
%         index = index+ePic.param.customSize;
%     end
    
end


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