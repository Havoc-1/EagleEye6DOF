/* 
    Author: [DMCL] Xephros
    Function to calculate bounding box points for 6DOF overlay.

    Arguments:
        0: Target <OBJECT> - Target unit to calculate box for.
        1: Eye Position <ARRAY> (Optional) - Eye position of target unit. Default is eyePos of target.
        2: Camera Position <ARRAY> (Optional) - World position of the camera. Default is positionCameraToWorld [0,0,0] converted to ASL.
        3: Target ASL Position <ARRAY> (Optional) - ASL position of target unit. Default is getPosASL of target.
        4: Height Offset <SCALAR> (Optional) - Additional height offset for the box. Default is 0.3.

    Example:
        _drawbox = [man1, eyePos man1] call XK_6DOF_fnc_drawBox;

    Return Value:
        <ARRAY> Bounding box points for drawLine3D.
*/

params ["_target", ["_eyePos", eyePos _target],["_camPos", AGLToASL positionCameraToWorld [0,0,0]],["_targetASL", getPosASL _target], ["_hOffset", 0.3]];

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
private _fOffset = 0.1;
private _hSlantOffset = 0.2;
private _baseWidth = 0.4;
private _width = if (_stance isNotEqualTo "STAND") then {_baseWidth + _result} else {_baseWidth - _result};

//Direction from camera to target
private _dirVec = vectorNormalized (_targetASL vectorDiff _camPos);
private _rightVec = vectorNormalized (_dirVec vectorCrossProduct [0,0,1]);

//Calculate bounding box points
private _botL = _targetASL vectorAdd (_rightVec vectorMultiply (_width * -1));
private _botLTemp = _targetASL vectorAdd (_rightVec vectorMultiply ((_width * -1) + _hSlantOffset));
private _botR = _targetASL vectorAdd (_rightVec vectorMultiply  _width);
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

//Return Value
_drawBox;