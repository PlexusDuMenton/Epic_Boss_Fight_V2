var ID = Players.GetLocalPlayer()
var high = 750
GameUI.SetCameraPitchMin( 0 )
GameUI.SetCameraPitchMax( 0 )

GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_TOP_TIMEOFDAY, false);
		GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_TOP_HEROES, false);
		GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_FLYOUT_SCOREBOARD, false);
		GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_ACTION_MINIMAP, false);
		GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_ACTION_PANEL, false);
		GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_INVENTORY_PANEL, false);
		GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_INVENTORY_SHOP, false);
		GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_INVENTORY_ITEMS, false);
		GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_INVENTORY_QUICKBUY, false);
		GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_INVENTORY_COURIER, false);
		GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_INVENTORY_PROTECT, false);
		GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_INVENTORY_GOLD, false);
		GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_SHOP_SUGGESTEDITEMS, false);
		GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_HERO_SELECTION_TEAMS, false);
		GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_HERO_SELECTION_GAME_NAME, false);
		GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_HERO_SELECTION_CLOCK, false);
		GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_TOP_BAR_BACKGROUND, false);
		GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_TOP_MENU_BUTTONS, false);
		GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_ENDGAME, false);

		GameUI.SetRenderBottomInsetOverride(0);
		GameUI.SetRenderTopInsetOverride(0);
		
UpdateUI()
UpdateUIrare()

function UpdateUIrare(){
$.Schedule(1, UpdateUIrare);
CustomNetTables.SubscribeNetTableListener
	key = "player_" + ID.toString()
	data = CustomNetTables.GetTableValue( "info", key)
	if (typeof data != 'undefined') {
	update_rare(data)
	}
}

function UpdateUI(){
$.Schedule(0.025, UpdateUI);
	CustomNetTables.SubscribeNetTableListener
	key = "player_" + ID.toString()
	data = CustomNetTables.GetTableValue( "info", key)
	if (typeof data != 'undefined') {
	update_bar(data)
	}
}
GameEvents.Subscribe( "Display_Bar", display_bar)
function display_bar()
{
$("#bar_general").visible = true;
GameUI.SetCameraDistance( 1300 + high )
}

function MouseFilter( event, arg )
{
    if ( event == 'wheeled' ){
		if ( arg > 0 ) {
			if (high > 50){
				high = high - 50
			}
		}
		else{
			if (high < 1500){
				high = high + 50
				}	
		}
		GameUI.SetCameraDistance( 1300 + high )
        return true;
		}
	if (arg <5){
		return false;
	}
	else {
	return true 
	}
	
}


( function() {
    GameUI.SetMouseCallback( MouseFilter );
} )();  


$("#bar_general").visible = false;
$("#no_mana").style.clip = "rect( 0% ,0%, 100% ,0% )";
$("#no_weapon").style.clip = "rect( 0% ,0%, 100% ,0% )";

function center_camera_on_hero(){
	GameUI.SetCameraTarget(Players.GetPlayerHeroEntityIndex( ID ))
	$.Schedule(0.025,free_camera);
	
	function free_camera(){
	GameUI.SetCameraTarget(-1)
	}
}

function update_rare(arg){
	$("#name").text = $.Localize("#"+arg.Name);
	$("#PortaitImage").heroname = arg.Name
}
function update_bar(arg)
	{
		$("#hp_bar_parent").style.clip = "rect( 0% ," + ((arg.HP/arg.MAXHP)*77.3+22.7) + "%" + ", 100% ,0% )";
		$("#hp_bar_current").text = "Health : " + Number((arg.HP).toFixed(0));
		$("#hp_bar_total").text = Number((arg.MAXHP).toFixed(0));
		
		if (arg.MAXMP != 0){
		$("#no_mana").style.clip = "rect( 0% ,0%, 100% ,0% )";
		$("#mp_bar_parent").style.clip = "rect( 0% ," + ((Number((arg.MP).toFixed(0))/Number((arg.MAXMP).toFixed(0)))*63.1+27.0) + "%" + ", 100% ,0% )";
		} else{
		$("#mp_bar_parent").style.clip = "rect( 0% ,100%, 100% ,0% )";
		$("#no_mana").style.clip = "rect( 0% ,100%, 100% ,0% )";
		}
		$("#mp_bar_current").text = "Mana : " + Number((arg.MP).toFixed(0));
		$("#mp_bar_total").text = Number((arg.MAXMP).toFixed(0));
		
		$("#hxp_bar_parent").style.clip = "rect( 0% ," + ((arg.HXP/arg.MAXHXP)*70.22+29.78) + "%" + ", 100% ,0% )";
		$("#hxp_bar_current").text = "XP : " + Number((arg.HXP).toFixed(2));
		$("#hxp_bar_total").text = Number((arg.MAXHXP).toFixed(2));
		if (arg.MAXWXP != 0){
		$("#no_weapon").style.clip = "rect( 0% ,0%, 100% ,0% )";
		$("#wxp_bar_parent").style.clip = "rect( 0% ," + ((arg.WXP/arg.MAXWXP)*56.17+41.93) + "%" + ", 100% ,0% )";
		}else{
		$("#wxp_bar_parent").style.clip = "rect( 0% ,100%, 100% ,0% )";
		$("#no_weapon").style.clip = "rect( 0% ,100%, 100% ,0% )";
		}
		$("#wxp_bar_current").text = "Weapon XP : " + Number((arg.WXP).toFixed(2));
		$("#wxp_bar_total").text = Number((arg.MAXWXP).toFixed(2));
		$("#wname").text = arg.WName;
		$("#wlevel").text = arg.WLVL;

		
		$("#level").text = "Level "+ arg.LVL.toString()
	}
	
function numberWithCommas(x) {
    var parts = x.toString().split(".");
    parts[0] = parts[0].replace(/\B(?=(\d{3})+(?!\d))/g, ",");
    return parts.join(".");
}