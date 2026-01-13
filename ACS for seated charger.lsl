/*
 * Very basic ACS-compatible charger script. Suitable for
 * a simple, single-unit charger sat on the same prim as the
 * script is contained in.
 *
 * This script is only designed to be a minimum viable product.
 * It contains a SIMPLIFIED and PARTIAL implementation of the
 * ACS protocol for electrical chargers as detailed here:
 * http://develop.nanite-systems.com/resources/ACS-charging.pdf
 *
 * Use this as an example to build your own ACS chargers with.
 * --Toothless.Draegonne 2025
 */
 
integer comChannel = 360; //Main ACS communication channel. DO NOT CHANGE THIS.
integer mainListener; //Handle for the main listener.

key sitter; //Currently-sitting user.
string sitterPowerType; /*
                         * Power type pf the sitting user.
                         * If this is not EL, then do not send charge.
                         * Stores the result given by the last powertype message.
                         */
integer sitterMaxCharge; //Maximum charge that can be held by the current sitter's power source.
integer sitterCurrentCharge; //Stores the value given by the last chargeticks message.
integer sitterPower; /*
                      * 0 if sitter is shut down, 1 if active.
                      * Stores the result given by the last chargersummary
                      * or power messages.
                      */
integer sitterChargePercent; //Stores the charge percentage given by the last chargersummary message.
integer sitterIsCharging; //Stores a boolean based on whether the sitter is charging right now.
integer currentChargeRate; //Number of "ticks" (kilojoules) per pulse to send.
integer sitterTicksToFull; /*
                            * One "tick" is one kilojoule. 
                            * Number of ticks required to fill the power source.
                            * Stores the result given by the last chargersummary message.
                            */
integer currentListener; //Handle for listener used by connected user.
integer currentChannel; //Com channel for connected user. Determined during handshake.

init()
{
    llSitTarget(<0,0,1>,ZERO_ROTATION);
    llSetClickAction(CLICK_ACTION_SIT);
    mainListener = llListen(comChannel,"","","");
    sitterMaxCharge = 0;
    sitterPower = 0;
    sitterPowerType = "";
    sitterChargePercent = 0;
    sitterTicksToFull = 0;
    sitterIsCharging = FALSE;
    currentListener = FALSE;
    currentChannel = FALSE;
    currentChargeRate = 100; //Number of charge ticks/kilojoules per pulse.
}

unsit()
{
    llUnSit(sitter);
    sitter = NULL_KEY;
}

disconnect()
{
    if (sitter != NULL_KEY)
    {
        llInstantMessage(sitter, "Goodbye.");
        llRegionSayTo(sitter,currentChannel,"ACS,disconnect:");
        unsit();
    }
    if (currentListener)
    {
        llListenRemove(currentListener);
        currentListener = FALSE;
        currentChannel = FALSE;
    }
    sitterIsCharging = FALSE;
    sitterMaxCharge = 0;
    sitterPower = 0;
    sitterPowerType = "";
    sitterChargePercent = 0;
    sitterTicksToFull = 0;
}

connect()
{
    llRegionSayTo(sitter,comChannel,"ACS,hello,CHARGER");
}

handshake()
{
    llRegionSayTo(sitter,comChannel,"ACS,interface,CHARGER");
}

startCharging()
{
    llRegionSayTo(sitter,currentChannel,"ACS,charging:1");
    sitterIsCharging = TRUE;
    llSetTimerEvent(1.0);
}
stopCharging()
{
    llRegionSayTo(sitter,currentChannel,"ACS,charging:0");
    sitterIsCharging = FALSE;
    llSetTimerEvent(0.0);
}
sendPulse()
{
    llRegionSayTo(sitter,currentChannel,"ACS,chargeseconds:" + (string)currentChargeRate);
}

getSummary()
{
    llRegionSayTo(sitter,currentChannel,"ACS,chargersummary:");
}

/*
 * Parse initial or terminal messages from a connecting or disconnecting unit.
 */
parseMain(string text)
{
    list tokens = llParseString2List(text,[","],[":"]);
    if (llList2String(tokens,0) == "ACS")
    {
        string cmd = llList2String(tokens,1);
        if (cmd == "welcome")
        {
            llInstantMessage(sitter,llList2CSV(tokens));
            handshake();
        }
        if (cmd == "refuse")
        {
            llInstantMessage(sitter, "Controller refused connection. Reason: " + llList2String(tokens,2));
            disconnect();
        }
        /*
         * Sent if CCU was reset.
         */
        if (cmd == "goodbye")
        {
            unsit();
        }
        if (cmd == "interface")
        {
            currentChannel = (integer)llList2String(tokens,2);
            /*
             * According to ACS spec this should be a negative integer, but it seems
             * that ARES provides *positive* integers so uhhhh, ho hum.
             */
            if (currentChannel)
            {
                currentListener = llListen(currentChannel,"","","");
                llInstantMessage(sitter, "Connected.");
                /*
                 * Immediately get caps/summary and start charging.
                 * Other more featureful chargers may present other
                 * options at this stage.
                 */
                getSummary(); 
                startCharging();
            }
            else
            {
                llInstantMessage(sitter, "Failed to negotiate connection.");
                disconnect();
            }
        }
    }
}

/*
 * Parse messages from a connected unit.
 */
parseConnected(string text)
{
    list tokens = llParseString2List(text,[","],[":"]);
    if (llList2String(tokens,0) == "ACS")
    {
        string cmd = llList2String(tokens,1);
        if (cmd == "goodbye")
        {
            unsit();
        }
        if (cmd == "stopcharge")
        {
            disconnect();
        }
        if (cmd == "power")
        {
            sitterPower = (integer)llList2String(tokens,3);
        }
        if (cmd == "chargersummary")
        {
            sitterPower = (integer)llList2String(tokens,3);
            sitterChargePercent = (integer)llList2String(tokens,4);
            sitterTicksToFull = (integer)llList2String(tokens,5);
        }
        if (cmd == "chargeticks")
        {
            sitterCurrentCharge = (integer)llList2String(tokens,3);
        }
        if (cmd == "maxcharge")
        {
            sitterMaxCharge = (integer)llList2String(tokens,3);
        }
        if (cmd == "powertype")
        {
            if (llList2String(tokens,3) == "EL")
            {
                sitterPowerType = "EL";
            }
            else
            {
                sitterPowerType = "other";
            }
        }
    }
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
        if (channel == comChannel)
        {
            if ((id == sitter) || (llGetOwnerKey(id) == sitter))
            {
                parseMain(text);
            }
        }
        if ((channel == currentChannel) && ((id == sitter) || (llGetOwnerKey(id) == sitter)))
        {
            parseConnected(text);
        }
    }
    changed(integer change)
    {
        if (change & CHANGED_LINK)
        {
            key id = llAvatarOnSitTarget();
            if (id != NULL_KEY)
            {
                sitter = id;
                connect();
            }
            else
            {
                disconnect();
            }
        }
    }
    timer() //MVP assumes one pulse per second, more detailed chargers may do more.
    {
        if (currentListener && (sitter != NULL_KEY) && sitterIsCharging && (sitterPowerType == "EL"))
        {
            sendPulse();
        }
    }
}
