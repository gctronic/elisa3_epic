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

% tx[1..9] => 1st robot payload
% tx[10..18] => 2nd robot payload
% tx[19..27] => 3rd robot payload
% tx[28..36] => 4th robot payload
tx = uint8(zeros([1 36]));

% Specify address of the first robot (from interface).
tx(8) = floor(ePic.param.comPort/256);
tx(9) = bitand(ePic.param.comPort, 255);

% Specify address of the second robot.
tx(17) = floor(3486/256);
tx(18) = bitand(3486, 255);

% Specify address of the third robot.
tx(26) = floor(3583/256);
tx(27) = bitand(3583, 255);

% Specify address of the fourth robot.
tx(35) = floor(3501/256);
tx(36) = bitand(3501, 255);

% set motor speed of 1st robot.
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

% set motor speed of 2nd robot
%tx(14) = bitor(int8(30),'uint8'), hex2dec('80')); % positive right
%tx(14) = typecast(-int8(-30),'uint8'); % negative right
tx(14) = tx(5); % same as 1st robot
%tx(15) = bitor(int8(30),'uint8'), hex2dec('80')); % positive left
%tx(15) = typecast(-int8(-30),'uint8'); % negative left
tx(15) = tx(6); % same as 1st robot

% set motor speed of 3rd robot
%tx(23) = bitor(int8(30),'uint8'), hex2dec('80')); % positive right
%tx(23) = typecast(-int8(-30),'uint8'); % negative right
tx(23) = tx(5); % same as 1st robot
%tx(24) = bitor(int8(30),'uint8'), hex2dec('80')); % positive left
%tx(24) = typecast(-int8(-30),'uint8'); % negative left
tx(24) = tx(6); % same as 1st robot

% set motor speed of 4th robot
%tx(32) = bitor(int8(30),'uint8'), hex2dec('80')); % positive right
%tx(32) = typecast(-int8(-30),'uint8'); % negative right
tx(32) = tx(5); % same as 1st robot
%tx(33) = bitor(int8(30),'uint8'), hex2dec('80')); % positive left
%tx(33) = typecast(-int8(-30),'uint8'); % negative left
tx(33) = tx(6); % same as 1st robot


% set green leds values of 1st robot
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

%set green leds values of 2nd robot
tx(16) = tx(7); % same as 1st robot

%set green leds values of 3rd robot
tx(25) = tx(7); % same as 1st robot

%set green leds values of 4th robot
tx(34) = tx(7); % same as 1st robot


% reset and calibrate 1st robot
if(ePic.param.resetAndCalib > 0)
   ePic.param.resetAndCalib = 0;
   tx(4) = bitor(tx(4), bitsll(uint8(1), 4));
end

% reset and calibrate 2nd robot
tx(13) = tx(4); % same as 1st robot

% reset and calibrate 3rd robot
tx(22) = tx(4); % same as 1st robot

% reset and calibrate 4th robot
tx(31) = tx(4); % same as 1st robot


% set RGB led of 1st robot
tx(1) = ePic.set.rgb(1);
tx(2) = ePic.set.rgb(3);
tx(3) = ePic.set.rgb(2);

% set RGB led of 2nd robot
tx(10) = tx(1); % same as 1st robot
tx(11) = tx(2); % same as 1st robot
tx(12) = tx(3); % same as 1st robot

% set RGB led of 3rd robot
tx(19) = tx(1); % same as 1st robot
tx(20) = tx(2); % same as 1st robot
tx(21) = tx(3); % same as 1st robot

% set RGB led of 4th robot
tx(28) = tx(1); % same as 1st robot
tx(29) = tx(2); % same as 1st robot
tx(30) = tx(3); % same as 1st robot

% set back IR and front IR state of 1st robot
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

% set back IR and front IR state of 2nd robot
%tx(13) = bitor(tx(13), bitsll(uint8(1), 0)); % turn on back IR
%tx(13) = bitand(tx(13), bitcmp(bitsll(uint8(1), 0))); % turn off back IR
%tx(13) = bitor(tx(13), bitsll(uint8(1), 1)); % turn on front IRs
%tx(13) = bitand(tx(13), bitcmp(bitsll(uint8(1), 1))); % turn off front IRs
tx(13) = tx(4); % same as 1st robot

% set back IR and front IR state of 3rd robot
%tx(22) = bitor(tx(13), bitsll(uint8(1), 0)); % turn on back IR
%tx(22) = bitand(tx(13), bitcmp(bitsll(uint8(1), 0))); % turn off back IR
%tx(22) = bitor(tx(13), bitsll(uint8(1), 1)); % turn on front IRs
%tx(22) = bitand(tx(13), bitcmp(bitsll(uint8(1), 1))); % turn off front IRs
tx(22) = tx(4); % same as 1st robot

% set back IR and front IR state of 4th robot
%tx(31) = bitor(tx(13), bitsll(uint8(1), 0)); % turn on back IR
%tx(31) = bitand(tx(13), bitcmp(bitsll(uint8(1), 0))); % turn off back IR
%tx(31) = bitor(tx(13), bitsll(uint8(1), 1)); % turn on front IRs
%tx(31) = bitand(tx(13), bitcmp(bitsll(uint8(1), 1))); % turn off front IRs
tx(31) = tx(4); % same as 1st robot

prox = ePic.value.proxi; %zeros(1,8);
prox_ambient = ePic.value.light; %zeros(1,8);
ground = ePic.value.floor; %zeros(1,4);
ground_ambient = ePic.value.floorLight; %zeros(1,4);
accel = ePic.value.accel; %zeros(1,3);

for i=1:5

    usb_communication(1, tx);
    
	% rx[1..16] => 1st robot payload
	% rx[17..32] => 2nd robot payload
	% rx[33..48] => 3rd robot payload
	% rx[49..64] => 4th robot payload
    rx = uint8(zeros([1 64]));
    [ret, rx] = usb_communication(2);
	
	% interpret data of the 1st robot
	% rx(1) <= 2 means the packet isn't received correctly from the radio, thus skip it.
    if(rx(1) == 3)  
        prox(1) = typecast([typecast(int8(rx(2)), 'uint8'), typecast(int8(rx(3)), 'uint8')], 'uint16');
        prox(2) = typecast([typecast(int8(rx(4)), 'uint8'), typecast(int8(rx(5)), 'uint8')], 'uint16');
        prox(3) = typecast([typecast(int8(rx(6)), 'uint8'), typecast(int8(rx(7)), 'uint8')], 'uint16');
        prox(4) = typecast([typecast(int8(rx(8)), 'uint8'), typecast(int8(rx(9)), 'uint8')], 'uint16');
        prox(6) = typecast([typecast(int8(rx(10)), 'uint8'), typecast(int8(rx(11)), 'uint8')], 'uint16');
        prox(7) = typecast([typecast(int8(rx(12)), 'uint8'), typecast(int8(rx(13)), 'uint8')], 'uint16');
        prox(8) = typecast([typecast(int8(rx(14)), 'uint8'), typecast(int8(rx(15)), 'uint8')], 'uint16');
		%flagsRx = rx(16);
    elseif(rx(1) == 4)
        prox(5) = typecast([typecast(int8(rx(2)), 'uint8'), typecast(int8(rx(3)), 'uint8')], 'uint16');
        for j=1:4
            ground(j)=typecast([typecast(int8(rx(j*2+2)), 'uint8'), typecast(int8(rx(j*2+3)), 'uint8')], 'uint16');
        end
        accel(1) = typecast([typecast(int8(rx(12)), 'uint8'), typecast(int8(rx(13)), 'uint8')], 'int16');
        accel(2) = typecast([typecast(int8(rx(14)), 'uint8'), typecast(int8(rx(15)), 'uint8')], 'int16');
		%tvRemote = rx(16);		
    elseif(rx(1) == 5) 
        prox_ambient(1) = typecast([typecast(int8(rx(2)), 'uint8'), typecast(int8(rx(3)), 'uint8')], 'uint16');
        prox_ambient(2) = typecast([typecast(int8(rx(4)), 'uint8'), typecast(int8(rx(5)), 'uint8')], 'uint16');
        prox_ambient(3) = typecast([typecast(int8(rx(6)), 'uint8'), typecast(int8(rx(7)), 'uint8')], 'uint16');
        prox_ambient(4) = typecast([typecast(int8(rx(8)), 'uint8'), typecast(int8(rx(9)), 'uint8')], 'uint16');
        prox_ambient(6) = typecast([typecast(int8(rx(10)), 'uint8'), typecast(int8(rx(11)), 'uint8')], 'uint16');
        prox_ambient(7) = typecast([typecast(int8(rx(12)), 'uint8'), typecast(int8(rx(13)), 'uint8')], 'uint16');
        prox_ambient(8) = typecast([typecast(int8(rx(14)), 'uint8'), typecast(int8(rx(15)), 'uint8')], 'uint16');
		%selector = rx(16);		
    elseif(rx(1) == 6)
        prox_ambient(5) = typecast([typecast(int8(rx(2)), 'uint8'), typecast(int8(rx(3)), 'uint8')], 'uint16');
        for j=1:4
            ground_ambient(j)=typecast([typecast(int8(rx(j*2+2)), 'uint8'), typecast(int8(rx(j*2+3)), 'uint8')], 'uint16');
        end
        accel(3) = typecast([typecast(int8(rx(12)), 'uint8'), typecast(int8(rx(13)), 'uint8')], 'int16'); 
		%battery = typecast([typecast(int8(rx(14)), 'uint8'), typecast(int8(rx(15)), 'uint8')], 'int16');
    elseif(rx(1) == 7)
        ePic.value.odom(3) = typecast([typecast(int8(rx(10)), 'uint8'), typecast(int8(rx(11)), 'uint8')], 'int16')/10; %two_complement(uint16(rx(10:11)))/10;   % theta (degrees)
        ePic.value.odom(1) = typecast([typecast(int8(rx(12)), 'uint8'), typecast(int8(rx(13)), 'uint8')], 'int16'); %two_complement(uint16(rx(12:13)));    % x pos (mm)
        ePic.value.odom(2) = typecast([typecast(int8(rx(14)), 'uint8'), typecast(int8(rx(15)), 'uint8')], 'int16'); %two_complement(uint16(rx(14:15)));    % y pos (mm)   
        ePic.value.pos(1)=typecast([typecast(int8(rx(2)), 'uint8'), typecast(int8(rx(3)), 'uint8'), typecast(int8(rx(4)), 'uint8'), typecast(int8(rx(5)), 'uint8')], 'int32');
        ePic.value.pos(2)=typecast([typecast(int8(rx(6)), 'uint8'), typecast(int8(rx(7)), 'uint8'), typecast(int8(rx(8)), 'uint8'), typecast(int8(rx(9)), 'uint8')], 'int32');        
    end

	% interpret data of the 2nd robot
	% rx(17) <= 2 means the packet isn't received correctly from the radio, thus skip it.
    if(rx(17) == 3)  
        %prox(1) = typecast([typecast(int8(rx(18)), 'uint8'), typecast(int8(rx(19)), 'uint8')], 'uint16');
        %prox(2) = typecast([typecast(int8(rx(20)), 'uint8'), typecast(int8(rx(21)), 'uint8')], 'uint16');
        %prox(3) = typecast([typecast(int8(rx(22)), 'uint8'), typecast(int8(rx(23)), 'uint8')], 'uint16');
        %prox(4) = typecast([typecast(int8(rx(24)), 'uint8'), typecast(int8(rx(25)), 'uint8')], 'uint16');
        %prox(6) = typecast([typecast(int8(rx(26)), 'uint8'), typecast(int8(rx(27)), 'uint8')], 'uint16');
        %prox(7) = typecast([typecast(int8(rx(28)), 'uint8'), typecast(int8(rx(29)), 'uint8')], 'uint16');
        %prox(8) = typecast([typecast(int8(rx(30)), 'uint8'), typecast(int8(rx(31)), 'uint8')], 'uint16');
		%flagsRx = rx(32);
    elseif(rx(17) == 4)
        %prox(5) = typecast([typecast(int8(rx(18)), 'uint8'), typecast(int8(rx(19)), 'uint8')], 'uint16');
        %for j=1:4
        %    ground(j)=typecast([typecast(int8(rx(j*2+18)), 'uint8'), typecast(int8(rx(j*2+19)), 'uint8')], 'uint16');
        %end
        %accel(1) = typecast([typecast(int8(rx(28)), 'uint8'), typecast(int8(rx(29)), 'uint8')], 'int16');
        %accel(2) = typecast([typecast(int8(rx(30)), 'uint8'), typecast(int8(rx(31)), 'uint8')], 'int16');
		%tvRemote = rx(32);
    elseif(rx(17) == 5) 
        %prox_ambient(1) = typecast([typecast(int8(rx(18)), 'uint8'), typecast(int8(rx(19)), 'uint8')], 'uint16');
        %prox_ambient(2) = typecast([typecast(int8(rx(20)), 'uint8'), typecast(int8(rx(21)), 'uint8')], 'uint16');
        %prox_ambient(3) = typecast([typecast(int8(rx(22)), 'uint8'), typecast(int8(rx(23)), 'uint8')], 'uint16');
        %prox_ambient(4) = typecast([typecast(int8(rx(24)), 'uint8'), typecast(int8(rx(25)), 'uint8')], 'uint16');
        %prox_ambient(6) = typecast([typecast(int8(rx(26)), 'uint8'), typecast(int8(rx(27)), 'uint8')], 'uint16');
        %prox_ambient(7) = typecast([typecast(int8(rx(28)), 'uint8'), typecast(int8(rx(29)), 'uint8')], 'uint16');
        %prox_ambient(8) = typecast([typecast(int8(rx(30)), 'uint8'), typecast(int8(rx(31)), 'uint8')], 'uint16'); 
		%selector = rx(32);
    elseif(rx(17) == 6)
        %prox_ambient(5) = typecast([typecast(int8(rx(18)), 'uint8'), typecast(int8(rx(19)), 'uint8')], 'uint16');
        %for j=1:4
        %    ground_ambient(j)=typecast([typecast(int8(rx(j*2+18)), 'uint8'), typecast(int8(rx(j*2+19)), 'uint8')], 'uint16');
        %end
        %accel(3) = typecast([typecast(int8(rx(28)), 'uint8'), typecast(int8(rx(29)), 'uint8')], 'int16');        
		%battery = typecast([typecast(int8(rx(30)), 'uint8'), typecast(int8(rx(31)), 'uint8')], 'int16');
    elseif(rx(17) == 7)
        %ePic.value.odom(3) = typecast([typecast(int8(rx(26)), 'uint8'), typecast(int8(rx(27)), 'uint8')], 'int16')/10; %two_complement(uint16(rx(10:11)))/10;   % theta (degrees)
        %ePic.value.odom(1) = typecast([typecast(int8(rx(28)), 'uint8'), typecast(int8(rx(29)), 'uint8')], 'int16'); %two_complement(uint16(rx(12:13)));    % x pos (mm)
        %ePic.value.odom(2) = typecast([typecast(int8(rx(30)), 'uint8'), typecast(int8(rx(31)), 'uint8')], 'int16'); %two_complement(uint16(rx(14:15)));    % y pos (mm)   
        %ePic.value.pos(1)=typecast([typecast(int8(rx(18)), 'uint8'), typecast(int8(rx(19)), 'uint8'), typecast(int8(rx(20)), 'uint8'), typecast(int8(rx(21)), 'uint8')], 'int32');
        %ePic.value.pos(2)=typecast([typecast(int8(rx(22)), 'uint8'), typecast(int8(rx(23)), 'uint8'), typecast(int8(rx(24)), 'uint8'), typecast(int8(rx(25)), 'uint8')], 'int32');        
    end	
	
	% interpret data of the 3rd robot
	% rx(33) <= 2 means the packet isn't received correctly from the radio, thus skip it.
    if(rx(33) == 3)  
        %prox(1) = typecast([typecast(int8(rx(34)), 'uint8'), typecast(int8(rx(35)), 'uint8')], 'uint16');
        %prox(2) = typecast([typecast(int8(rx(36)), 'uint8'), typecast(int8(rx(37)), 'uint8')], 'uint16');
        %prox(3) = typecast([typecast(int8(rx(38)), 'uint8'), typecast(int8(rx(39)), 'uint8')], 'uint16');
        %prox(4) = typecast([typecast(int8(rx(40)), 'uint8'), typecast(int8(rx(41)), 'uint8')], 'uint16');
        %prox(6) = typecast([typecast(int8(rx(42)), 'uint8'), typecast(int8(rx(43)), 'uint8')], 'uint16');
        %prox(7) = typecast([typecast(int8(rx(44)), 'uint8'), typecast(int8(rx(45)), 'uint8')], 'uint16');
        %prox(8) = typecast([typecast(int8(rx(46)), 'uint8'), typecast(int8(rx(47)), 'uint8')], 'uint16');  
		%flagsRx = rx(48);
    elseif(rx(33) == 4)
        %prox(5) = typecast([typecast(int8(rx(34)), 'uint8'), typecast(int8(rx(35)), 'uint8')], 'uint16');
        %for j=1:4
        %    ground(j)=typecast([typecast(int8(rx(j*2+34)), 'uint8'), typecast(int8(rx(j*2+35)), 'uint8')], 'uint16');
        %end
        %accel(1) = typecast([typecast(int8(rx(44)), 'uint8'), typecast(int8(rx(45)), 'uint8')], 'int16');
        %accel(2) = typecast([typecast(int8(rx(46)), 'uint8'), typecast(int8(rx(47)), 'uint8')], 'int16');  
		%tvRemote = rx(48);
    elseif(rx(33) == 5) 
        %prox_ambient(1) = typecast([typecast(int8(rx(34)), 'uint8'), typecast(int8(rx(35)), 'uint8')], 'uint16');
        %prox_ambient(2) = typecast([typecast(int8(rx(36)), 'uint8'), typecast(int8(rx(37)), 'uint8')], 'uint16');
        %prox_ambient(3) = typecast([typecast(int8(rx(38)), 'uint8'), typecast(int8(rx(39)), 'uint8')], 'uint16');
        %prox_ambient(4) = typecast([typecast(int8(rx(40)), 'uint8'), typecast(int8(rx(41)), 'uint8')], 'uint16');
        %prox_ambient(6) = typecast([typecast(int8(rx(42)), 'uint8'), typecast(int8(rx(43)), 'uint8')], 'uint16');
        %prox_ambient(7) = typecast([typecast(int8(rx(44)), 'uint8'), typecast(int8(rx(45)), 'uint8')], 'uint16');
        %prox_ambient(8) = typecast([typecast(int8(rx(46)), 'uint8'), typecast(int8(rx(47)), 'uint8')], 'uint16'); 
		%selector = rx(48);	
    elseif(rx(33) == 6)
        %prox_ambient(5) = typecast([typecast(int8(rx(34)), 'uint8'), typecast(int8(rx(35)), 'uint8')], 'uint16');
        %for j=1:4
        %    ground_ambient(j)=typecast([typecast(int8(rx(j*2+34)), 'uint8'), typecast(int8(rx(j*2+35)), 'uint8')], 'uint16');
        %end
        %accel(3) = typecast([typecast(int8(rx(44)), 'uint8'), typecast(int8(rx(45)), 'uint8')], 'int16');        
		%battery = typecast([typecast(int8(rx(46)), 'uint8'), typecast(int8(rx(47)), 'uint8')], 'int16');
    elseif(rx(33) == 7)
        %ePic.value.odom(3) = typecast([typecast(int8(rx(42)), 'uint8'), typecast(int8(rx(43)), 'uint8')], 'int16')/10; %two_complement(uint16(rx(10:11)))/10;   % theta (degrees)
        %ePic.value.odom(1) = typecast([typecast(int8(rx(44)), 'uint8'), typecast(int8(rx(45)), 'uint8')], 'int16'); %two_complement(uint16(rx(12:13)));    % x pos (mm)
        %ePic.value.odom(2) = typecast([typecast(int8(rx(46)), 'uint8'), typecast(int8(rx(47)), 'uint8')], 'int16'); %two_complement(uint16(rx(14:15)));    % y pos (mm)   
        %ePic.value.pos(1)=typecast([typecast(int8(rx(34)), 'uint8'), typecast(int8(rx(35)), 'uint8'), typecast(int8(rx(36)), 'uint8'), typecast(int8(rx(37)), 'uint8')], 'int32');
        %ePic.value.pos(2)=typecast([typecast(int8(rx(38)), 'uint8'), typecast(int8(rx(39)), 'uint8'), typecast(int8(rx(40)), 'uint8'), typecast(int8(rx(41)), 'uint8')], 'int32');        
    end	

	% interpret data of the 4th robot
	% rx(49) <= 2 means the packet isn't received correctly from the radio, thus skip it.
    if(rx(49) == 3)  
        %prox(1) = typecast([typecast(int8(rx(50)), 'uint8'), typecast(int8(rx(51)), 'uint8')], 'uint16');
        %prox(2) = typecast([typecast(int8(rx(52)), 'uint8'), typecast(int8(rx(53)), 'uint8')], 'uint16');
        %prox(3) = typecast([typecast(int8(rx(54)), 'uint8'), typecast(int8(rx(55)), 'uint8')], 'uint16');
        %prox(4) = typecast([typecast(int8(rx(56)), 'uint8'), typecast(int8(rx(57)), 'uint8')], 'uint16');
        %prox(6) = typecast([typecast(int8(rx(58)), 'uint8'), typecast(int8(rx(59)), 'uint8')], 'uint16');
        %prox(7) = typecast([typecast(int8(rx(60)), 'uint8'), typecast(int8(rx(61)), 'uint8')], 'uint16');
        %prox(8) = typecast([typecast(int8(rx(62)), 'uint8'), typecast(int8(rx(63)), 'uint8')], 'uint16');   
		%flagsRx = rx(64);
    elseif(rx(49) == 4)
        %prox(5) = typecast([typecast(int8(rx(50)), 'uint8'), typecast(int8(rx(51)), 'uint8')], 'uint16');
        %for j=1:4
        %    ground(j)=typecast([typecast(int8(rx(j*2+50)), 'uint8'), typecast(int8(rx(j*2+51)), 'uint8')], 'uint16');
        %end
        %accel(1) = typecast([typecast(int8(rx(60)), 'uint8'), typecast(int8(rx(61)), 'uint8')], 'int16');
        %accel(2) = typecast([typecast(int8(rx(62)), 'uint8'), typecast(int8(rx(63)), 'uint8')], 'int16');
		%tvRemote = rx(64);
    elseif(rx(49) == 5) 
        %prox_ambient(1) = typecast([typecast(int8(rx(50)), 'uint8'), typecast(int8(rx(51)), 'uint8')], 'uint16');
        %prox_ambient(2) = typecast([typecast(int8(rx(52)), 'uint8'), typecast(int8(rx(53)), 'uint8')], 'uint16');
        %prox_ambient(3) = typecast([typecast(int8(rx(54)), 'uint8'), typecast(int8(rx(55)), 'uint8')], 'uint16');
        %prox_ambient(4) = typecast([typecast(int8(rx(56)), 'uint8'), typecast(int8(rx(57)), 'uint8')], 'uint16');
        %prox_ambient(6) = typecast([typecast(int8(rx(58)), 'uint8'), typecast(int8(rx(59)), 'uint8')], 'uint16');
        %prox_ambient(7) = typecast([typecast(int8(rx(60)), 'uint8'), typecast(int8(rx(61)), 'uint8')], 'uint16');
        %prox_ambient(8) = typecast([typecast(int8(rx(62)), 'uint8'), typecast(int8(rx(63)), 'uint8')], 'uint16');
		%selector = rx(64);	
    elseif(rx(49) == 6)
        %prox_ambient(5) = typecast([typecast(int8(rx(50)), 'uint8'), typecast(int8(rx(51)), 'uint8')], 'uint16');
        %for j=1:4
        %    ground_ambient(j)=typecast([typecast(int8(rx(j*2+50)), 'uint8'), typecast(int8(rx(j*2+51)), 'uint8')], 'uint16');
        %end
        %accel(3) = typecast([typecast(int8(rx(60)), 'uint8'), typecast(int8(rx(61)), 'uint8')], 'int16');      
		%battery = typecast([typecast(int8(rx(62)), 'uint8'), typecast(int8(rx(63)), 'uint8')], 'int16');		
    elseif(rx(49) == 7)
        %ePic.value.odom(3) = typecast([typecast(int8(rx(58)), 'uint8'), typecast(int8(rx(59)), 'uint8')], 'int16')/10; %two_complement(uint16(rx(10:11)))/10;   % theta (degrees)
        %ePic.value.odom(1) = typecast([typecast(int8(rx(60)), 'uint8'), typecast(int8(rx(61)), 'uint8')], 'int16'); %two_complement(uint16(rx(12:13)));    % x pos (mm)
        %ePic.value.odom(2) = typecast([typecast(int8(rx(62)), 'uint8'), typecast(int8(rx(63)), 'uint8')], 'int16'); %two_complement(uint16(rx(14:15)));    % y pos (mm)   
        %ePic.value.pos(1)=typecast([typecast(int8(rx(50)), 'uint8'), typecast(int8(rx(51)), 'uint8'), typecast(int8(rx(52)), 'uint8'), typecast(int8(rx(53)), 'uint8')], 'int32');
        %ePic.value.pos(2)=typecast([typecast(int8(rx(54)), 'uint8'), typecast(int8(rx(55)), 'uint8'), typecast(int8(rx(56)), 'uint8'), typecast(int8(rx(57)), 'uint8')], 'int32');        
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