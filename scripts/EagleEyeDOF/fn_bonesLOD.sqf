params ["_target", ["_playerDist", _target distance player], ["_eyePos", eyePos _target]];

private _bones = [];
switch (true) do {
    case (_playerDist < 25): { //LOD 0
        _bones = [
            [[["rightfoot","rightleg"]]],
            [[["rightleg","rightupleg"]]],
            [[["leftfoot","leftleg"]]],
            [[["leftleg","leftupleg"]]],
            [[["rightupleg","pelvis"]]],
            [[["leftupleg","pelvis"]]],
            [[["pelvis","head_hit"]]],
            [[["rightshoulder","leftshoulder"]]],
            [[["rightshoulder","rightforearm"]]],
            [[["rightforearm","righthand"]]],
            [[["leftshoulder","leftforearm"]]],
            [[["leftforearm","lefthand"]]]
        ];
        
        { //Calculate positions for visibility check and add to bones array
            private _tempArray = _x select 0 select 0;
            private _bone1 = _target selectionPosition (_tempArray select 0);
            private _bone2 = _target selectionPosition (_tempArray select 1);
            
            private _boneA_ASL = AGLToASL (_target modelToWorld _bone1);
            //Bone position adjustment for target head
            private _boneB_ASL = if ((_tempArray select 1) isEqualTo "head_hit") then {
                _eyePos;
            } else {
                AGLToASL (_target modelToWorld _bone2);
            };
            private _avgBoneASL = (_boneA_ASL vectorAdd _boneB_ASL) vectorMultiply 0.5;
            _x insert [0, [_avgBoneASL]];
        }forEach _bones;
    };
    case (_playerDist < 50): { //LOD 1
        _bones = [
            [[ //Right leg
                ["rightfoot","rightleg"],
                ["rightleg","rightupleg"]
            ]],
            [[ //Left leg
                ["leftfoot","leftleg"],
                ["leftleg","leftupleg"]
            ]],
            [[ //Right arm
                ["rightshoulder","rightforearm"],
                ["rightforearm","righthand"]
            ]],
            [[ //Left arm
                ["leftshoulder","leftforearm"],
                ["leftforearm","lefthand"]
            ]]
        ];

        { //Calculate positions for visibility check and add to bones array
            private _avgBoneASL = AGLToASL (_target modelToWorld (_target selectionPosition (_x select 0 select 0 select 1)));
            _x insert [0, [_avgBoneASL]];
        }forEach _bones;

        _bones append [ //Torso to head
            [AGLToASL (_target modelToWorld (_target selectionPosition "spine3")), [
                ["rightshoulder","leftshoulder"],
                ["rightupleg","pelvis"],
                ["leftupleg","pelvis"],
                ["pelvis","head_hit"]
            ]]
        ];

    };
    default { //LOD 2
        private _rLeg = AGLToASL (_target modelToWorld (_target selectionPosition "rightleg"));
        private _lLeg = AGLToASL (_target modelToWorld (_target selectionPosition "leftleg"));
        private _torso = AGLToASL (_target modelToWorld (_target selectionPosition "spine3"));

        _bones = [
            //Legs
            [((_rLeg vectorAdd _lLeg) vectorMultiply 0.5), [
                ["rightfoot","rightleg"],
                ["rightleg","rightupleg"],
                ["leftfoot","leftleg"],
                ["leftleg","leftupleg"]
            ]],
            //Torso
            [_torso, [
                ["rightshoulder","leftshoulder"],
                ["rightupleg","pelvis"],
                ["leftupleg","pelvis"],
                ["pelvis","head_hit"],
                ["rightshoulder","rightforearm"],
                ["rightforearm","righthand"],
                ["leftshoulder","leftforearm"],
                ["leftforearm","lefthand"]
            ]]
        ];
    };
};

//Return Value
_bones;