$("#menu").visible = true;
$("#new").visible = false;
$("#load").visible = false;

$("#c1t").text = $.Localize('#npc_dota_hero_legion_commander_ebf')

GameEvents.Subscribe( "Display_Bar", function(){$("#BG").visible = false;})
GameEvents.Subscribe( "load_fail", function(){$("#load").visible = true;})

function display_back(){
	$("#menu").visible = true;
	$("#new").visible = false;
	$("#load").visible = false;
	$("#BG").visible = true;
}

function load()
{
	$("#menu").visible = false;
	$("#new").visible = false;
	$("#load").visible = true;
}

function back()
{
	$("#menu").visible = true;
	$("#new").visible = false;
	$("#load").visible = false;
}

function NC()
{
	$("#menu").visible = false;
	$("#new").visible = true;
	$("#load").visible = false;
}

function load_character(slot){
	$("#menu").visible = false;
	$("#new").visible = false;
	$("#load").visible = false;
	var ID = Players.GetLocalPlayer()
	GameEvents.SendCustomGameEventToServer( "Load_Hero", { PID: ID,Slot : slot} );
}

function new_character(hero){
	$("#menu").visible = false;
	$("#new").visible = false;
	$("#load").visible = false;
	var ID = Players.GetLocalPlayer()
	GameEvents.SendCustomGameEventToServer( "New_Hero", { PID: ID,Hero_Name : hero} );
}