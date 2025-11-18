/* 
    Author: [DMCL] Xephros
    Function to render 6DOF skeleton overlay.
    
    Arguments:
        0: Target <UNIT> - Target to render skeleton.
        1: Color <ARRAY> (Optional) - RGBA Color for skeleton render, defaults to light blue.
        2: IFF Icon <STRING> (Optional) - Image file for IFF Icon. Default is question mark.
        3: Render Skeleton <BOOL> (Optional) - Render 6DOF Skeleton overlay.
        4: Display IFF Icon <BOOL> (Optional) - Enable or disable IFF Icon above target.
        5: IFF Name <STRING> (Optional) - Name to display when looking at target.
        6: Max Distance Targets <NUMBER> (Optional) - Ignore enemy renders on targets beyond this distance.
        7: Max Distance Target Skeleton <NUMBER> (Optional) - Ignore skeleton renders on enemy & unknown targets beyond this distance (shows bounding box only).
        8: Max Distance Allies <NUMBER> (Optional) - Ignore allied renders on targets beyond this distance.
        9: Max Distance Allied Skeleton <NUMBER> (Optional) - Ignore skeleton renders on allied targets beyond this distance (shows bounding box only).
        10: Line Size <NUMBER> (Optional) - Thickness of bone lines for skeleton render.
        11: Line Box Size <NUMBER> (Optional) - Thickness of bounding box lines.
        12: IFF Size <NUMBER> (Optional) - Size for IFF Icon.
        13: IFF Offset <NUMBER> (Optional) - IFF Icon height offset above target's head.
    
    Return Value: None

    Example:
        [this] call XK_6DOF_fnc_renderBones;
*/

params [
    ["_target", objNull],
    ["_color", [0.05,0.05,1,1]],
    ["_icon", "\A3\ui_f\data\map\markers\handdrawn\unknown_CA.paa"],
    ["_render", true],
    ["_iffDisplay", true],
    ["_iffName", "Unknown"],
    ["_maxDistTargets", 200],
    ["_maxDistTargetSkel", 100],
    ["_maxDistAllies", 100],
    ["_maxDistAllySkel", 50],
    ["_lineSize", 12],
    ["_lineBoxSize", 3],
    ["_iffSize", 0.3],
    ["_iffOffset", 0.15]
];

//Min max distance cap
if (_maxDistTargets < 50) then {_maxDistTargets = 50};
if (_maxDistTargets > 800) then {_maxDistTargets = 800};
if (_maxDistAllySkel > _maxDistAllies) then {_maxDistAllySkel = _maxDistAllies};

//Init variables
private _isUAVGunner = (UAVControl getConnectedUAV player) isEqualTo [player, "GUNNER"];
private _isAlly = (side player) isEqualTo (side _target);
private _playerDist = player distance _target;
private _targetNum = _target getVariable ["XK_6DOF_Marked", nil];
private _isMarked = !(isNil "_targetNum");
private _visionMode = currentVisionMode player;
private _isUncon = _target getVariable ["ACE_isUnconscious", false];
private _is6dof = _target getVariable ["XK_6DOF_enable",false];

if ( //Exit conditions
    isNil "_target" ||
    isNull _target ||
    !alive player ||
    (!alive _target && !_isMarked) ||
    (_target isEqualTo player && !_isUAVGunner) ||
    !(_target isKindOf "CAManBase") ||
    (_isAlly && (_playerDist > _maxDistAllies)) ||
    (XK_6DOF_filterNVG && _visionMode isEqualTo 0) ||
    (_playerDist > _maxDistTargets && !_isUAVGunner) ||
    (_playerDist < 2 && !_isUAVGunner) ||
    !isNull curatorCamera ||
    (!XK_6DOF_unconCheck && _isUncon && !_isMarked) ||

    //Self Filter Allies
    (XK_6DOF_allyFilter isEqualTo 0 && _isAlly) || //Disabled
    (XK_6DOF_allyFilter isEqualTo 1 && _isAlly && ((group player) isNotEqualTo (group _target))) || //Fireteam only
    (XK_6DOF_allyFilter isEqualTo 2 && _isAlly && !_is6dof) || //6DOF users only

    //Self Filter Allies
    XK_6DOF_targetFilter isEqualTo 0 && !_isAlly //Disabled
) exitWith {};

//Calculate dynamic bounding box width
private _eyePos = eyePos _target;
private _camPos = AGLToASL positionCameraToWorld [0,0,0];
private _targetASL = getPosASL _target;
private _hOffset = 0.3;
private _drawBox = [_target, _eyePos, _camPos, _targetASL, _hOffset] call XK_6DOF_fnc_drawBox;

//Init private variables
private _multiply = 4;

//Calculate render distance
private _tempList = [];
{_tempList append [[_camPos, _x select 0, player, _target, true, 1, "FIRE"]]} forEach _drawBox;
private _intersect = (lineIntersectsSurfaces [_tempList]) select {_x isNotEqualTo []};

if (count _intersect > 0) then {
    _intersect = _intersect apply {_camPos distance (_x select 0 select 0)};
    private _newMultiply = ((_intersect call CBA_fnc_findMin) select 0) * 0.95;
    if (_newMultiply < _multiply) then {_multiply = _newMultiply};
};

//Draw bounding box position
private _light = getLighting select 1;
{
    private _dir1 = _camPos vectorFromTo (_x select 0);
    private _dir2 = _camPos vectorFromTo (_x select 1);
    private _pos1 = ASLToAGL (_camPos vectorAdd (_dir1 vectorMultiply _multiply));
    private _pos2 = ASLToAGL (_camPos vectorAdd (_dir2 vectorMultiply _multiply));
    
    drawLine3D [_pos1, _pos2, _color, _lineBoxSize];

    //Draws lines again to fight opacity in low light environments. Not elegant but works.
    if (_light <= 0.4 && (_visionMode isEqualTo 0)) then {drawLine3D [_pos1, _pos2, _color, _lineBoxSize]};

}forEach _drawBox;

//Render IFF Icons
if (_iffDisplay) then {
    if !(
        (XK_6DOF_iffFilter isEqualTo 0) || //Disabled
        (XK_6DOF_iffFilter isEqualTo 1 && !_isAlly) || //Allies only
        (XK_6DOF_iffFilter isEqualTo 2 && _isAlly) || //Targets only
        (XK_6DOF_iffFilter isEqualTo 3 && ((group player) isNotEqualTo (group _target))) //Fireteam only
    ) then {

        //Targets
        private _iffPosAGL = ASLToAGL [_targetASL select 0, _targetASL select 1, (_eyePos select 2) + _iffOffset + _hOffset];
        private _fovAdjust = (getObjectFOV player - 0.75)/2;
        private _iffSizeAdjust = _iffSize - _fovAdjust;
        private _iffSizeUAV = _iffSize - _fovAdjust*2.5;
        private _colorMark = _color;

        //Render enlarged IFF on self when operating UAV
        if (_target isEqualTo player && _isUAVGunner) then {
            drawIcon3D [
                XK_6DOF_iconUAV,
                _color,
                _iffPosAGL,
                _iffSizeUAV, _iffSizeUAV,
                0, "", 0, 0.03, "TahomaB"
            ];
        };

        //Increase marker size by 50% if target is 6DOF user or player marked
        if (_is6dof) then { _iffSizeAdjust = _iffSizeAdjust * 2};

        if (_isMarked) then {
            _iffSizeAdjust = _iffSizeAdjust * 2.5;
            _colorMark = XK_6DOF_colorMark;
            _colorMark set [3,1];
        };
        
        if (_target isNotEqualTo player) then {
            drawIcon3D [
                _icon,
                _colorMark,
                _iffPosAGL,
                _iffSizeAdjust, _iffSizeAdjust,
                0, "", 0, 0.03, "TahomaB"
            ];
        };
    };        

    //Show target name
    if (!XK_6DOF_nameTags || ((_playerDist > 20) && !_isMarked) || _isUAVGunner) exitWith {};
    private _targetPos = worldToScreen (ASLToAGL _targetASL);

    if (count _targetPos > 1) then {
        if ((((_targetPos select 0) > 0) && ((_targetPos select 0) < 1) && ((_targetPos select 1) > 0) && ((_targetPos select 1) < 1))) then {
            private _name = _target getVariable ["XK_6DOF_Name",nil];
            if !(isNil "_name") then {_iffName = _name};
            private _tempText = 0.028;
            private _scale = linearConversion [2, _maxDistTargets, (_camPos distance _target), 0.01, 2.5, true];
            private _scaleFov = linearConversion [0.75, 0.25, (getObjectFOV player), 0,0.12, true];
            //[format ["%1", _scale - _scaleFov], "renderBones", 3] call XK_6DOF_fnc_diaglog;
            //private _textSize = _tempText - (_scale * (_tempText - 0.008));
            private _topR = (_drawbox select 3 select 0);
            private _textAGL = ASLToAGL _topR;
            //if (_isMarked) then {_textSize = _tempText};

            drawIcon3D ["",
                [1,1,1,1],
                _textAGL,
                0.3, 0,
                0, _iffName, 2,
                _tempText,
                "PuristaMedium", "right"
            ];

            //Draw second line (ID text) dynamically below
            if (!_isAlly && _isMarked) then {
                _idText = format ["ID.%1", _targetNum];
                drawIcon3D [
                    "",
                    [1,1,1,1],
                    _textAGL vectorAdd [0, 0, (_scale - _scaleFov)*-1],
                    0.3, 0,
                    0, _idText, 2,
                    _tempText,
                    "PuristaMedium", "right"
                ];
            };
        };
    };
};

//Render skeleton
if (_render && (_isAlly && (_playerDist <= _maxDistAllySkel) || !_isAlly && (_playerDist <= _maxDistTargetSkel))) then {
    
    //Calculate bones based on LOD
    private _bones = [_target, _playerDist, _eyePos] call XK_6DOF_fnc_bonesLOD;

    {//drawLine3D for each bone set
        private _visPos = _x select 0;
        private _boneList = _x select 1;
        private _vis = [player,"VIEW",_target] checkVisibility [_camPos, _visPos];
        private _visCap = 0.55;
        
        if (_vis < _visCap) then {
            {
                private _boneA_ASL = _x select 0;
                private _boneB_ASL = _x select 1;

                private _dir1 = _camPos vectorFromTo _boneA_ASL;
                private _dir2 = _camPos vectorFromTo _boneB_ASL;
                private _pos1 = ASLToAGL (_camPos vectorAdd (_dir1 vectorMultiply _multiply));
                private _pos2 = ASLToAGL (_camPos vectorAdd (_dir2 vectorMultiply _multiply));

                drawLine3D [_pos1, _pos2, _color, _lineSize];

                //Draws lines again to fight opacity in low light environments. Not elegant but works.
                if (_light <= 0.4 && (_visionMode isEqualTo 0)) then {drawLine3D [_pos1, _pos2, _color, _lineSize]};
            }forEach _boneList;
        };

        //Debug bone visibility
        if (XK_6DOF_Debug && !_isUAVGunner) then {
            private _visColor = [0,1,0,1];
            switch (true) do {
                case (_vis < _visCap): {_visColor = [1,0,0,1]};
                case (_vis < 0.3): {_visColor = [1,1,0,1]};
            };

            drawIcon3D [
                "\A3\ui_f\data\map\markers\military\dot_CA.paa",
                _visColor,
                ASLToAGL _visPos,
                0.5, 0.5, 0, format ["%1", text (_vis toFixed 2)], 0, 0.02, "RobotoCondensed"
            ];
        };
    }forEach _bones;

    //Debug LOD & EyePos
    if (XK_6DOF_Debug && !_isUAVGunner) then {
        private _lod = 2;
        switch (true) do {
            case (_playerDist < 25): {_lod = 0};
            case (_playerDist < 50): {_lod = 1};
            default {};
        };
        private _eyePosAGL = ASLToAGL _eyePos;
        private _visPosEye = [player,"VIEW",_target] checkVisibility [_camPos, _eyePos];
        drawIcon3D [
            "\A3\ui_f\data\map\markers\military\dot_CA.paa",
            [0.8,0.8,1,1],
            (_eyePosAGL vectorAdd [0,0,0.4]),
            0.5, 0.5, 0, format ["LOD: %1 | Dist: %2m", _lod, round _playerDist], 2, 0.02, "RobotoCondensed"
        ];
        drawIcon3D [
            "\A3\ui_f\data\map\markers\military\dot_CA.paa",
            [1,1,1,1],
            _eyePosAGL,
            0.5, 0.5, 0, format ["eyePos: %1", text (_visPosEye toFixed 2)], 2, 0.02, "RobotoCondensed"
        ];
    };
};

//Debug visibility for drone and bounding box corners
if !(XK_6DOF_Debug) exitWith {};
if (_isUAVGunner && _target isNotEqualTo player) then {
    private _uav = getConnectedUAV player;
    if (!isEngineOn _uav || (fuel _uav == 0) || !alive _uav) exitWith {};

    private _uavCfg = configFile >> "CfgVehicles" >> typeOf _uav;
    private _camPosSel = getText (_uavCfg >> "uavCameraGunnerPos");
    if (_camPosSel isEqualTo "") exitWith {};
    private _camPos = _uav selectionPosition _camPosSel;
    private _spine = (_target modelToWorldVisualWorld (_target selectionPosition "spine2"));

    private _visCheck1 = [_target,"FIRE"] checkVisibility [_uav modelToWorldVisualWorld _camPos, _eyePos];
    private _visCheck2 = [_target,"VIEW"] checkVisibility [_uav modelToWorldVisualWorld _camPos, _eyePos];
    private _visCheck3 = [_target,"FIRE"] checkVisibility [_uav modelToWorldVisualWorld _camPos, _spine];
    private _visCheck4 = [_target,"VIEW"] checkVisibility [_uav modelToWorldVisualWorld _camPos, _spine];

    //Intersection points check to mark as 6dof target
    drawIcon3D [
        "\A3\ui_f\data\map\markers\military\dot_CA.paa",
        [1,1,0,1],
        ASLToAGL _eyePos,
        0.2, 0.2, 0, format ["Vis Fire/View: %1 | %2", _visCheck1, _visCheck2], 0, 0.02, "RobotoCondensed"
    ];
    drawIcon3D [
        "\A3\ui_f\data\map\markers\military\dot_CA.paa",
        [1,1,0,1],
        ASLToAGL _spine,
        0.2, 0.2, 0, format ["Vis Fire/View: %1 | %2", _visCheck3, _visCheck4], 0, 0.02, "RobotoCondensed"
    ];
} else {

    {//Bounding box corners debug
        drawIcon3D [
            "\A3\ui_f\data\map\markers\military\dot_CA.paa",
            [1,1,1,1],
            _x,
            0.5, 0.5, 0, format ["%1", _forEachIndex], 0, 0.02, "RobotoCondensed"
        ];
    }forEach (_drawBox apply {ASLToAGL (_x select 0)});
};