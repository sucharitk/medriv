function kb = setupKeyboard()
% Setup universal Mac/PC keyboard and keynames

    KbName('UnifyKeyNames');
    kb.escKey = KbName('ESCAPE');
    kb.oneKey = KbName('1!');
    kb.twoKey = KbName('2@');
    kb.threeKey = KbName('3#');
    kb.fourKey = KbName('4$');
    kb.fiveKey = KbName('5%');
    kb.bKey = KbName('b');
    kb.gKey = KbName('g');
    kb.yKey = KbName('y');
    kb.tKey = KbName('t');
    kb.qKey = KbName('q');
    kb.wKey = KbName('w');
    kb.eKey = KbName('e');
    kb.rKey = KbName('r');
    kb.spaceKey = KbName('space');
    kb.spaceKey = KbName('control');
    kb.pKey = KbName('p');
    kb.oKey = KbName('o');
    kb.iKey = KbName('i');
    kb.kKey = KbName('k');
    kb.jKey = KbName('j');
    kb.lKey = KbName('l');
    kb.zKey = KbName('z');
    kb.xKey = KbName('x');
    kb.cKey = KbName('c');
    kb.aKey = KbName('a');
    kb.sKey = KbName('s');
    kb.dKey = KbName('d');
    kb.fKey = KbName('f');
    kb.num1Key = KbName('1');
    kb.num2Key = KbName('2');
    kb.num3Key = KbName('3');
    
    kb.leftArrow = KbName('LeftArrow');
    kb.rightArrow = KbName('RightArrow');
    kb.upArrow = KbName('UpArrow');
    kb.downArrow = KbName('DownArrow');
    
    kb.cwGrating = kb.lKey;
    kb.acwGrating = kb.jKey;
    kb.bothGratings = kb.kKey;
    
    kb.cwGrating = kb.rightArrow;
    kb.acwGrating = kb.leftArrow;
    kb.bothGratings = kb.downArrow;

    % Set up mappings for response pad in key-repeat mode
    kb.incKey = KbName('.>');
    kb.decKey = KbName(',<');

    if ispc
        kb.int = [];
        kb.ext = [];
    else
        devices = getDevices;

        if length(devices.keyInputInternal) > 1
            disp(['More than one internal keypad, devices: ', int2str(devices.keyInputInternal)])
            kb.int = input('Specify internal device number to use: ');
        else
            kb.int = devices.keyInputInternal;
        end
        if length(devices.keyInputExternal) > 1
            disp(['More than one external keypad, devices: ', int2str(devices.keyInputInternal)])
            kb.ext = input('Specify external device number to use: ');
            kb.int = input('Specify "internal" device number to use: ');
        else
            kb.ext = devices.keyInputExternal;
        end
   end
end