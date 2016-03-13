var ID = Players.GetLocalPlayer()

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
GameEvents.Subscribe( "Display_Bar", display_bar)
function UpdateUI(){
$.Schedule(0.025, UpdateUI);
	CustomNetTables.SubscribeNetTableListener
	key = "player_" + ID.toString()
	data = CustomNetTables.GetTableValue( "info", key)
	if (typeof data != 'undefined') {
	update_bar(data)
	}
}
function display_bar()
{
$("#bar_general").visible = true;
}
$("#bar_general").visible = false;
$("#no_mana").style.clip = "rect( 0% ,0%, 100% ,0% )";
$("#no_weapon").style.clip = "rect( 0% ,0%, 100% ,0% )";

function update_bar(arg)
	{
		$("#hp_bar_parent").style.clip = "rect( 0% ," + ((arg.HP/arg.MAXHP)*77.3+22.7) + "%" + ", 100% ,0% )";
		$("#hp_bar_current").text = numberWithCommas(arg.HP);
		$("#hp_bar_total").text = numberWithCommas(arg.MAXHP);
		
		if (arg.MAXMP != 0){
		$("#no_mana").style.clip = "rect( 0% ,0%, 100% ,0% )";
		$("#mp_bar_parent").style.clip = "rect( 0% ," + ((arg.MP/arg.MAXMP)*63.1+27.0) + "%" + ", 100% ,0% )";
		} else{
		$("#mp_bar_parent").style.clip = "rect( 0% ,100%, 100% ,0% )";
		$("#no_mana").style.clip = "rect( 0% ,100%, 100% ,0% )";
		}
		$("#mp_bar_current").text = numberWithCommas(arg.MP);
		$("#mp_bar_total").text = numberWithCommas(arg.MAXMP);
		
		$("#hxp_bar_parent").style.clip = "rect( 0% ," + ((arg.HXP/arg.MAXHXP)*70.22+29.78) + "%" + ", 100% ,0% )";
		$("#hxp_bar_current").text = numberWithCommas(arg.HXP);
		$("#hxp_bar_total").text = numberWithCommas(arg.MAXHXP);
		if (arg.MAXWXP != 0){
		$("#no_weapon").style.clip = "rect( 0% ,0%, 100% ,0% )";
		$("#wxp_bar_parent").style.clip = "rect( 0% ," + ((arg.WXP/arg.MAXWXP)*56.17+41.93) + "%" + ", 100% ,0% )";
		}else{
		$("#wxp_bar_parent").style.clip = "rect( 0% ,100%, 100% ,0% )";
		$("#no_weapon").style.clip = "rect( 0% ,100%, 100% ,0% )";
		}
		$("#wxp_bar_current").text = numberWithCommas(arg.WXP);
		$("#wxp_bar_total").text = numberWithCommas(arg.MAXWXP);
		$("#wname").text = arg.WName;
		$("#wlevel").text = arg.WLVL;
		
		
		$("#level").text = "Level "+ arg.LVL.toString()
	}
	
function numberWithCommas(x) {
    var parts = x.toString().split(".");
    parts[0] = parts[0].replace(/\B(?=(\d{3})+(?!\d))/g, ",");
    return parts.join(".");
}