/*
Script by  vyrus714 : https://github.com/vyrus714/Trap-Wars/blob/master/content/dota_addons/trap_wars/panorama/scripts/custom_game/custom_events.js
*/


if(GameUI.CustomUIConfig().Events == null) {GameUI.CustomUIConfig().Events = {};}

GameUI.CustomUIConfig().Events.SubscribeEvent = function(eventName, callbackFunction) {
    var Events = GameUI.CustomUIConfig().Events;

    if(eventName == "SubscribeEvent" || eventName == "UnSubscribeEvent" || eventName == "FireEvent") {return null;}

    if(!Events[eventName]) {Events[eventName] = [];}
    // find the first open index in the event's array
    var i;
    for(i=0; i<Events[eventName].length; i++) {
        if(!Events[eventName][i]) {break;}
    }
    // add the passed callback function to the open index
    Events[eventName][i] = callbackFunction;

    // return the index in case we want to look up said function and remove it
    return i;
}

GameUI.CustomUIConfig().Events.UnSubscribeEvent = function(eventName, eventIndex) {
    var Events = GameUI.CustomUIConfig().Events;

    // if there is no event by this name, or the event doesn't have a callback function for the specified index, return
    if(!Events[eventName] || !Events[eventName][eventIndex]) {return false;}
    // clear out the callback function
    Events[eventName][eventIndex] = undefined;

    return true;
}

GameUI.CustomUIConfig().Events.FireEvent = function(eventName, args) {
    var Events = GameUI.CustomUIConfig().Events;

    // if there is no event by this name, exit
    if(Events[eventName] == null) {return false;}
    // execute this event's callback functions
    for(var i in Events[eventName]) {
        if(Events[eventName][i]) {Events[eventName][i](args);}
    }

    return true;
}