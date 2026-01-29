vector mainCol = <1,0.3,0>;
vector secondCol = <1,0.3,0>;

integer lightChannel;
integer lightListener;

init()
{
    lightChannel = 105 - (integer)("0x" + llGetSubString(llGetOwner(), 29, 35));
    lightListener = llListen(lightChannel,"","","");
    llRegionSayTo(llGetOwner(),lightChannel,"color-q");
}

setPrimParams()
{
    //clouds
    llLinkParticleSystem(
        LINK_THIS,
        [
            PSYS_SRC_PATTERN,PSYS_SRC_PATTERN_ANGLE_CONE,
            PSYS_SRC_BURST_RADIUS,0.8,
            PSYS_SRC_ANGLE_BEGIN,1.5708,
            PSYS_SRC_ANGLE_END,1.5708,
            PSYS_SRC_TARGET_KEY,llGetKey(),
            PSYS_PART_START_COLOR,mainCol,
            PSYS_PART_END_COLOR,secondCol,
            PSYS_PART_START_ALPHA,0,
            PSYS_PART_END_ALPHA,0.5,
            PSYS_PART_START_GLOW,0,
            PSYS_PART_END_GLOW,0.2,
            PSYS_PART_BLEND_FUNC_SOURCE,PSYS_PART_BF_SOURCE_ALPHA,
            PSYS_PART_BLEND_FUNC_DEST,PSYS_PART_BF_ONE_MINUS_SOURCE_ALPHA,
            PSYS_PART_START_SCALE,<0.500000,0.500000,0.000000>,
            PSYS_PART_END_SCALE,<0.031250,0.031250,0.000000>,
            PSYS_SRC_TEXTURE,"e24eefc3-2369-edd8-2aab-fe081c700df6",
            PSYS_SRC_MAX_AGE,0,
            PSYS_PART_MAX_AGE,2,
            PSYS_SRC_BURST_RATE,0.1,
            PSYS_SRC_BURST_PART_COUNT,7,
            PSYS_SRC_ACCEL,<0.000000,0.000000,0.100000>,
            PSYS_SRC_OMEGA,<0.000000,0.000000,0.000000>,
            PSYS_SRC_BURST_SPEED_MIN,0,
            PSYS_SRC_BURST_SPEED_MAX,0.1,
            PSYS_PART_FLAGS,
                0 |
                PSYS_PART_EMISSIVE_MASK |
                PSYS_PART_FOLLOW_VELOCITY_MASK |
                PSYS_PART_INTERP_COLOR_MASK |
                PSYS_PART_INTERP_SCALE_MASK
        ]);
    //dots
    llLinkParticleSystem(
        2,
        [
            PSYS_SRC_PATTERN,PSYS_SRC_PATTERN_ANGLE_CONE,
            PSYS_SRC_BURST_RADIUS,0.8,
            PSYS_SRC_ANGLE_BEGIN,1.5708,
            PSYS_SRC_ANGLE_END,1.5708,
            PSYS_SRC_TARGET_KEY,llGetKey(),
            PSYS_PART_START_COLOR,mainCol,
            PSYS_PART_END_COLOR,secondCol,
            PSYS_PART_START_ALPHA,1,
            PSYS_PART_END_ALPHA,0,
            PSYS_PART_START_GLOW,1.0,
            PSYS_PART_END_GLOW,0,
            PSYS_PART_BLEND_FUNC_SOURCE,PSYS_PART_BF_SOURCE_ALPHA,
            PSYS_PART_BLEND_FUNC_DEST,PSYS_PART_BF_ONE_MINUS_SOURCE_ALPHA,
            PSYS_PART_START_SCALE,<0.500000,0.500000,0.000000>,
            PSYS_PART_END_SCALE,<0.500000,0.500000,0.000000>,
            PSYS_SRC_TEXTURE,"d7c53c90-bf46-5379-fb8d-ac04cbd3aa61",
            PSYS_SRC_MAX_AGE,0,
            PSYS_PART_MAX_AGE,4,
            PSYS_SRC_BURST_RATE,0.1,
            PSYS_SRC_BURST_PART_COUNT,2,
            PSYS_SRC_ACCEL,<0.000000,0.000000,0.100000>,
            PSYS_SRC_OMEGA,<0.000000,0.000000,0.000000>,
            PSYS_SRC_BURST_SPEED_MIN,0,
            PSYS_SRC_BURST_SPEED_MAX,0.05,
            PSYS_PART_FLAGS,
                0 |
                PSYS_PART_EMISSIVE_MASK |
                PSYS_PART_INTERP_COLOR_MASK
        ]);
    //primParams
    llSetLinkPrimitiveParamsFast(
        LINK_THIS,
            [
                PRIM_COLOR,
                    ALL_SIDES,
                    mainCol,
                    1.0,
                PRIM_OMEGA,
                    <0,0,1>,
                    PI/16,
                    1.0
            ]
    );
}

default
{
    state_entry()
    {
        init();
    }
    on_rez(integer param)
    {
        llResetScript();
    }
    listen(integer channel, string name, key id, string text)
    {
        list deets = llParseString2List(text,[" "],[]);
        string cmd = llList2String(deets,0);
        if (cmd == "color")
        {
            mainCol = <llList2Float(deets,1),llList2Float(deets,2),llList2Float(deets,3)>;
            secondCol = mainCol;
            setPrimParams();
        }
    }
}

