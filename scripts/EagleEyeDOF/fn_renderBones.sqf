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

//Check if player is looking through drone cam
private _isUAVGunner = (UAVControl getConnectedUAV player) isEqualTo [player, "GUNNER"];

if (
    isNil "_target" ||
    isNull _target ||
    !alive player ||
    (!alive _target && !(_target getVariable ["XK_6dofMarked",false])) ||
    (_target == player && !_isUAVGunner) ||
    !( _target isKindOf "CAManBase") ||
    ((side _target isEqualTo side player) && (_target distance player > _maxDistAllies)) ||
    (player distance _target > _maxDistTargets && !_isUAVGunner) ||
    (player distance _target < 2 && !_isUAVGunner) ||
    !isNull curatorCamera
) exitWith {};

//Calculate dynamic bounding box width
private _clamp = 0;
switch (stance _target) do {
    case "STAND";
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
private _width = 0.4 + _result;
private _hSlantOffset = 0.2;
private _h = if (((eyePos _target) select 2) - _hSlantOffset < 0.1) then {0.1} else {(eyePos _target) select 2};

//Calculate bounding box points
private _botLtemp = _target getPos [_width, ((_target getDir player)+90)];
private _botRtemp = _target getPos [_width, ((_target getDir player)-90)];
private _botL = [_botLtemp select 0, _botLtemp select 1, ((getPosASL _target) select 2) - _fOffset];
private _botR = [_botRtemp select 0, _botRtemp select 1, ((getPosASL _target) select 2) - _fOffset];
private _topLslant = [_botL select 0, _botL select 1, _h + _hOffset - _hSlantOffset];
private _topRslantTemp = (_target getPos [(_width - _hSlantOffset), ((_target getDir player)+90)]);
private _topRslant = [_topRslantTemp select 0, _topRslantTemp select 1, _h + _hOffset];
private _topR = [_botR select 0, _botR select 1, _h + _hOffset];

//Construct draw points for bounding box
private _drawBox = [
    [_botL, _topLslant],
    [_topLslant, _topRslant],
    [_topRslant, _topR],
    [_topR, _botR],
    [_botR, _botL]
];

//Init private variables
private _tempDist = [];
private _camPos = AGLToASL positionCameraToWorld [0,0,0];
private _multiply = 4;

//Calculate render distance
private _tempList = [];
{
    _tempList append [[_camPos, _x select 0, player, _target, true, 1, "FIRE"]];
}forEach _drawBox;
private _intersect = (lineIntersectsSurfaces [_tempList]) select {_x isNotEqualTo []};

if (count _intersect > 0) then {
    _intersect = _intersect apply {_camPos distance (_x select 0 select 0)};
    private _newMultiply = parseNumber ((((_intersect sort true) select 0) * 0.9) toFixed 1);
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
    if (_light <= 0.4) then {drawLine3D [_pos1, _pos2, _color, _lineBoxSize]};
}forEach _drawBox;

//Render IFF Icons
if (_iffDisplay) then {

    //Targets
    private _iffPosAGL = ASLToAGL [(getPosASL _target) select 0, (getPosASL _target) select 1, ((eyePos _target) select 2) + _iffOffset + _hOffset];
    private _iffSizeAdjust = (_iffSize - (getObjectFOV player - 0.75)/2);
    private _iffSizeUAV = (_iffSize - (getObjectFOV player - 0.75)/2)*2.5;

    //Increase marker size by 50% if target is 6DOF user or player marked
    private _is6dof = _target getVariable ["XK_enable6dof",false];
    private _isMarked = _target getVariable ["XK_6dofMarked",false];
    

    //Render enlarged IFF on self when operating UAV
    if (_target isEqualTo player && _isUAVGunner) then {
        drawIcon3D [
            DOF_iconUAV,
            _color,
            _iffPosAGL,
            _iffSizeUAV, _iffSizeUAV,
            0, "", 0, 0.03, "TahomaB"
        ];
    };

    if (_is6dof) then {
        _iffSizeAdjust = _iffSizeAdjust * 2.5;
    };
    if (_isMarked) then {
        _iffSizeAdjust = _iffSizeAdjust * 2.5;
        _color = [0.9,0.4,0.1,1];
    };
    
    if !(_target isEqualTo player) then {
        drawIcon3D [
            _icon,
            _color,
            _iffPosAGL,
            _iffSizeAdjust, _iffSizeAdjust,
            0, "", 0, 0.03, "TahomaB"
        ];
    };
    
    //Show target name
    if (!DOF_Nametags || ((_target distance player > 20) && !_isMarked)) exitWith {};
    private _targetPos = worldToScreen (ASLToAGL getPosASL _target);
    if (count _targetPos > 1) then {
        if ((((_targetPos select 0) > 0) && ((_targetPos select 0) < 1) && ((_targetPos select 1) > 0) && ((_targetPos select 1) < 1))) then {
            private _name = _target getVariable ["XK_6dofName",nil];
            if !(isNil "_name") then {_iffName = _name};
            private _tempText = 0.028;
            private _scale = linearConversion [10, 20, (_camPos distance _target), 0, 1, true];
            private _textSize = _tempText - (_scale * (_tempText - 0.008));
            if (_isMarked) then {_textSize = _tempText};

            drawIcon3D ["",
                [1,1,1,1],
                ASLToAGL _topR,
                0.3, 0,
                0, _iffName, 2,
                _textSize,
                "PuristaMedium", "right"
            ];

            drawIcon3D ["",
                [1,1,1,1],
                (ASLToAGL _topR) vectorAdd [0,0,-0.08],
                0.3, 0,
                0, "ID.#", 2,
                _textSize,
                "PuristaMedium", "right"
            ];
        };
    };
};

//Render skeleton
if (_render) then {
    if ((side _target isEqualTo side player) && (_target distance player > _maxDistAllySkel)) exitWith {};
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
            eyePos _target;
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
        if (_vis < 0.6) then {

            private _dir1 = _camPos vectorFromTo _boneA_ASL;
            private _dir2 = _camPos vectorFromTo _boneB_ASL;
            private _pos1 = ASLToAGL (_camPos vectorAdd (_dir1 vectorMultiply _multiply));
            private _pos2 = ASLToAGL (_camPos vectorAdd (_dir2 vectorMultiply _multiply));

            drawLine3D [_pos1, _pos2, _color, _lineSize];

            //Draws lines again to fight opacity in low light environments. Not elegant but works.
            if (_light <= 0.4) then {drawLine3D [_pos1, _pos2, _color, _lineSize]};
        };
    } forEach _bones;
};


//Debug
if !(DOF_Debug) exitWith {};

//Bounding box corners debug
{
    drawIcon3D [
        "\A3\ui_f\data\map\markers\military\dot_CA.paa",
        [1,1,1,1],
        _x,
        0.5, 0.5, 0, "", 0, 0.03, "TahomaB"
    ];
}forEach (_drawBox apply {ASLToAGL (_x select 0)});

//Intersection points check to mark as 6dof target
drawIcon3D [
    "\A3\ui_f\data\map\markers\military\dot_CA.paa",
    [1,1,0,1],
    ASLToAGL (_target modelToWorldVisualWorld (_target selectionPosition "spine2")),
    0.4, 0.4, 0, "Check Vis 2", 0, 0.02, "TahomaB"
];
drawIcon3D [
    "\A3\ui_f\data\map\markers\military\dot_CA.paa",
    [1,1,0,1],
    ASLToAGL (eyePos _target),
    0.4, 0.4, 0, "Check Vis 1", 0, 0.02, "TahomaB"
];
