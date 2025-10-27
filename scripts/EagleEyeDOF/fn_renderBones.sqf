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
        7: Max Distance Allies <NUMBER> (Optional) - Ignore allied renders on targets beyond this distance.
        8: Max Distance Allied Skeleton <NUMBER> (Optional) - Ignore skeleton renders on allied targets beyond this distance (shows bounding box only).
        9: Line Size <NUMBER> (Optional) - Thickness of bone lines for skeleton render.
        10: Line Box Size <NUMBER> (Optional) - Thickness of bounding box lines.
        11: IFF Size <NUMBER> (Optional) - Size for IFF Icon.
        12: IFF Offset <NUMBER> (Optional) - IFF Icon height offset above target's head.
    
    Return Value: None

    Example:
        [this] call XK_6DOF_fnc_renderBones;
        [this, [0.05,0.05,1,1], "\A3\ui_f\data\map\markers\military\dot_CA.paa"] call XK_6DOF_fnc_renderBones;
        [this, [0.05,0.05,1,1], "\A3\ui_f\data\map\markers\military\dot_CA.paa", true, true, 200, 2, 12, 3, 0.3, 0.3, nil] call XK_6DOF_fnc_renderBones;
*/

params [
    ["_target", objNull],
    ["_color", [0.05,0.05,1,1]],
    ["_icon", "\A3\ui_f\data\map\markers\handdrawn\unknown_CA.paa"],
    ["_render", true],
    ["_iffDisplay", true],
    ["_iffName", "Unknown"],
    ["_maxDistTargets", 200],
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
private _sidePlayer = side player;
private _sideTarget = side _target;
private _playerDist = player distance _target;
private _isMarked = _target getVariable ["XK_6DOF_Marked",nil];

if (
    isNil "_target" ||
    isNull _target ||
    !alive player ||
    (!alive _target && !(isNil "_isMarked")) ||
    (_target isEqualTo player && !_isUAVGunner) ||
    !( _target isKindOf "CAManBase") ||
    ((_sideTarget isEqualTo _sidePlayer) && (_playerDist > _maxDistAllies)) ||
    (_playerDist > _maxDistTargets && !_isUAVGunner) ||
    (_playerDist < 2 && !_isUAVGunner) ||
    !isNull curatorCamera
) exitWith {};

//Calculate dynamic bounding box width
private _clamp = 0;
private _stance = stance _target;
switch (_stance) do {
    case "STAND": {_clamp = 0.1};
    case "CROUCH": {_clamp = 0.1};
    case "PRONE": {_clamp = 0.8};
    case "UNDEFINED": {_clamp = 0.8};
};

private _targetDir = getDir _target;
private _dirToPlayer = _target getDir player;
private _angleDiff = abs((_targetDir - _dirToPlayer + 540) % 360 - 180);
private _result = _clamp * (1 - abs(cos(_angleDiff)));

//Reference points to construct bounding box
private _hOffset = 0.3;
private _fOffset = 0.1;
private _hSlantOffset = 0.2;
private _baseWidth = 0.4;
private _width = if (_stance isNotEqualTo "STAND") then {_baseWidth + _result} else {_baseWidth - _result};

private _camPos = AGLToASL positionCameraToWorld [0,0,0];
private _targetASL = getPosASL _target;

//Direction from camera to target
private _dirVec = vectorNormalized (_targetASL vectorDiff _camPos);
private _rightVec = vectorNormalized (_dirVec vectorCrossProduct [0,0,1]);

//Calculate bounding box points
private _botL = _targetASL vectorAdd (_rightVec vectorMultiply (_width * -1));
private _botLTemp = _targetASL vectorAdd (_rightVec vectorMultiply ((_width * -1) + _hSlantOffset));
private _botR = _targetASL vectorAdd (_rightVec vectorMultiply  _width);
private _eyePos = eyePos _target;
private _eyeZ = _eyePos select 2;
private _h = if (_eyeZ - _hSlantOffset < 0.1) then {0.1} else {_eyeZ};
private _topZ = _h + _hOffset;
private _topZslant = _topZ - _hSlantOffset;

//Normalize height
private _baseZ = (_targetASL select 2) - _fOffset;
_botL set [2, _baseZ];
_botR set [2, _baseZ];

//Top positions
private _topLslant = [_botL select 0, _botL select 1, _topZslant];
private _topRslant = [_botLTemp select 0, _botLTemp select 1, _topZ];
private _topR = [_botR select 0, _botR select 1, _topZ];

// Construct final bounding box
private _drawBox = [
    [_botL, _topLslant],
    [_topLslant, _topRslant],
    [_topRslant, _topR],
    [_topR, _botR],
    [_botR, _botL]
];

//Init private variables
private _multiply = 4;

//Calculate render distance
private _tempList = [];
{
    _tempList append [[_camPos, _x select 0, player, _target, true, 1, "FIRE"]];
}forEach _drawBox;
private _intersect = (lineIntersectsSurfaces [_tempList]) select {_x isNotEqualTo []};

if (count _intersect > 0) then {
    _intersect = _intersect apply {_camPos distance (_x select 0 select 0)};
    private _newMultiply = ((_intersect call CBA_fnc_findMin) select 0) * 0.9;
    if (_newMultiply < _multiply) then {_multiply = _newMultiply};
};

//Draw bounding box position
private _light = (getLighting) select 1;
{
    private _dir1 = _camPos vectorFromTo (_x select 0);
    private _dir2 = _camPos vectorFromTo (_x select 1);
    private _pos1 = ASLToAGL (_camPos vectorAdd (_dir1 vectorMultiply _multiply));
    private _pos2 = ASLToAGL (_camPos vectorAdd (_dir2 vectorMultiply _multiply));

    drawLine3D [_pos1, _pos2, _color, _lineBoxSize];

    //Draws lines again to fight opacity in low light environments. Not elegant but works.
    if (_light <= 0.4 && (currentVisionMode player isEqualTo 0)) then {drawLine3D [_pos1, _pos2, _color, _lineBoxSize]};
}forEach _drawBox;

//Render IFF Icons
if (_iffDisplay) then {

    //Targets
    private _iffPosAGL = ASLToAGL [_targetASL select 0, _targetASL select 1, _eyeZ + _iffOffset + _hOffset];
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
    private _is6dof = _target getVariable ["XK_6DOF_enable",false];
    if (_is6dof) then {
        _iffSizeAdjust = _iffSizeAdjust * 2;
    };

    if !(isNil "_isMarked") then {
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
    
    //Show target name
    if (!XK_6DOF_nameTags || ((_playerDist > 20) && (isNil "_isMarked"))) exitWith {};
    private _targetPos = worldToScreen (ASLToAGL _targetASL);
    if (count _targetPos > 1) then {
        if ((((_targetPos select 0) > 0) && ((_targetPos select 0) < 1) && ((_targetPos select 1) > 0) && ((_targetPos select 1) < 1))) then {
            private _name = _target getVariable ["XK_6DOF_Name",nil];
            if !(isNil "_name") then {_iffName = _name};
            private _tempText = 0.028;
            private _scale = linearConversion [10, 20, (_camPos distance _target), 0, 1, true];
            private _textSize = _tempText - (_scale * (_tempText - 0.008));
            private _textAGL = ASLToAGL _topR;
            if !(isNil "_isMarked") then {_textSize = _tempText};

            private _targetNum = _target getVariable ["XK_6DOF_Marked", nil];
            //private _idText = "ID.#";

            drawIcon3D ["",
                [1,1,1,1],
                _textAGL,
                0.3, 0,
                0, _iffName, 2,
                _textSize,
                "PuristaMedium", "right"
            ];

            if ((_sidePlayer isNotEqualTo _sideTarget) && !(isNil "_isMarked")) then {
                _idText = format ["ID.%1", _targetNum];
                
                // Draw second line (ID text) dynamically below
                drawIcon3D [
                    "",
                    [1,1,1,1],
                    _textAGL vectorAdd [0, 0, -0.08],
                    0.3, 0,
                    0, _idText, 2,
                    _textSize,
                    "PuristaMedium", "right"
                ];
            };
        };
    };
};

//Render skeleton
if (_render) then {
    if ((_sideTarget isEqualTo _sidePlayer) && (_playerDist > _maxDistAllySkel)) exitWith {};
    private _bones = [
        ["rightfoot","rightleg"],
        ["rightleg","rightupleg"],
        ["leftfoot","leftleg"],
        ["leftleg","leftupleg"],
        ["rightupleg","pelvis"],
        ["leftupleg","pelvis"],
        ["pelvis","head_hit"],
        ["rightshoulder","leftshoulder"],
        ["rightshoulder","rightforearm"],
        ["rightforearm","righthand"],
        ["leftshoulder","leftforearm"],
        ["leftforearm","lefthand"]
    ];
    
    private _visList = [];
    {
        private _bone1 = _target selectionPosition (_x select 0);
        private _bone2 = _target selectionPosition (_x select 1);
        private _boneA_ASL = AGLToASL (_target modelToWorld _bone1);

        //Bone position adjustment for target head
        private _boneB_ASL = if ((_x select 1) isEqualTo "head_hit") then {
            _eyePos;
        } else {
            AGLToASL (_target modelToWorld _bone2);
        };

        private _avgBoneASL = [
            ((_boneA_ASL select 0) + (_boneB_ASL select 0))/2,
            ((_boneA_ASL select 1) + (_boneB_ASL select 1))/2,
            ((_boneA_ASL select 2) + (_boneB_ASL select 2))/2
        ];

        //If bone pair is obscured, get vector direction from player and multiply to keep drawLine3D in front of face
        private _vis = [player,"VIEW",_target] checkVisibility [_camPos, _avgBoneASL];
        private _visCap = 0.55;
        if (_vis < _visCap) then {

            private _dir1 = _camPos vectorFromTo _boneA_ASL;
            private _dir2 = _camPos vectorFromTo _boneB_ASL;
            private _pos1 = ASLToAGL (_camPos vectorAdd (_dir1 vectorMultiply _multiply));
            private _pos2 = ASLToAGL (_camPos vectorAdd (_dir2 vectorMultiply _multiply));

            drawLine3D [_pos1, _pos2, _color, _lineSize];

            //Draws lines again to fight opacity in low light environments. Not elegant but works.
            if (_light <= 0.4 && (currentVisionMode player isEqualTo 0)) then {drawLine3D [_pos1, _pos2, _color, _lineSize]};
        };

        if (XK_6DOF_Debug) then {
            private _visColor = [1,1,1,1];
            switch (true) do {
                case (_vis < _visCap): {_visColor = [0,1,0,1]};
                case (_vis < 0.3): {_visColor = [1,0,0,1]};
            };

            drawIcon3D [
                "\A3\ui_f\data\map\markers\military\dot_CA.paa",
                _visColor,
                ASLToAGL _avgBoneASL,
                0.5, 0.5, 0, format ["Vis: %1", text (_vis toFixed 2)], 0, 0.02, "RobotoCondensed"
            ];
        };
    } forEach _bones;
};


//Debug
if !(XK_6DOF_Debug) exitWith {};

//Bounding box corners debug
{
    drawIcon3D [
        "\A3\ui_f\data\map\markers\military\dot_CA.paa",
        [1,1,1,1],
        _x,
        0.5, 0.5, 0, format ["%1", _forEachIndex], 0, 0.03, "TahomaB"
    ];
}forEach (_drawBox apply {ASLToAGL (_x select 0)});

//Intersection points check to mark as 6dof target
drawIcon3D [
    "\A3\ui_f\data\map\markers\military\dot_CA.paa",
    [1,1,0,1],
    ASLToAGL (_target modelToWorldVisualWorld (_target selectionPosition "spine2")),
    0.2, 0.2, 0, "VisCheck 2", 0, 0.02, "RobotoCondensed"
];
drawIcon3D [
    "\A3\ui_f\data\map\markers\military\dot_CA.paa",
    [1,1,0,1],
    ASLToAGL _eyePos,
    0.2, 0.2, 0, "VisCheck 1", 0, 0.02, "RobotoCondensed"
];
