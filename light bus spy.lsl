/*
 * An extremely basic bootstrap that simply opens a channel for communication
 * on the owner's lightbus channel, and does nothing else.
 * --toothless.draegonne, 2025
 */
integer lightChannel;
integer lightListener;

init()
{
    lightChannel = 105 - (integer)("0x" + llGetSubString(llGetOwner(), 29, 35));
    lightListener = llListen(lightChannel,"","","");
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
        //llWhisper(0,"name: " + name + "\nid " + (string)id + "\ntext: " + text);
        llWhisper(0,"text: " + text);
    }
}
