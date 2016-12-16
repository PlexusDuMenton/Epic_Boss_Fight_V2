var music = Game.EmitSound("Sound.Music.1")
var last_music_played = "Sound.Music.1"
var mute_music = false
var modifier_extended = false
var last_modifier_list = {}
var skill;
var Ent_ID;
var ID = Players.GetLocalPlayer()
var inventory;

create_hud()
create_modifier_display()
create_IG_Bar()




































GameEvents.Subscribe( "mute_music", mute_music)

function mute_music(){
	mute_music = true
	Game.StopSound(music)
}

GameUI.CustomUIConfig().Events.SubscribeEvent( "Mute_Music", Mute_Music)

GameEvents.Subscribe( "play_music", play_music)

function play_music(msg){
	if (msg.music && !mute_music){
		Game.StopSound(music)
		last_music_played = msg.music
		music = Game.EmitSound(msg.music)
	}
}

GameEvents.Subscribe( "play_sound", play_sound)

function Mute_Music(msg){
	mute_music = msg.state
	GameEvents.SendCustomGameEventToServer( "save_mute", {mute : msg.state} )
	if (msg.state != false){
		Game.StopSound(music)
	}else{
		music = Game.EmitSound(last_music_played)
	}
}

function play_sound(msg){
	if (msg.music){
		Game.EmitSound(msg.music)
	}
}

var ID = Players.GetLocalPlayer()
var high = 900
var camera_free = true
GameUI.SetCameraPitchMin( 0 )
GameUI.SetCameraPitchMax( 0 )

function free_camera(){
	GameUI.SetCameraTarget(-1)
	}
function block_camera(){
	GameUI.SetCameraTargetPosition(Entities.GetAbsOrigin(Players.GetPlayerHeroEntityIndex( ID )),0.1)
	GameUI.SetCameraTarget(Players.GetPlayerHeroEntityIndex( ID ))
}

GameEvents.Subscribe( "center_on_hero", center_camera_on_hero)

function center_camera_on_hero(){
	if (camera_free == true){
	free_camera()
	GameUI.SetCameraTargetPosition(Entities.GetAbsOrigin(Players.GetPlayerHeroEntityIndex( ID )),0.1)
	}
}





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
$.Schedule(0.25, UpdateUIrare);
CustomNetTables.SubscribeNetTableListener
	key = "player_" + ID.toString()
	data = CustomNetTables.GetTableValue( "info", key)
	inventory = CustomNetTables.GetTableValue( "inventory_player_"+ID,key)
	var modifiers = CustomNetTables.GetTableValue( "KVFILE","modifier_"+key)
	if (typeof data != 'undefined') {
		update_modifier(modifiers.modifier_list)
		for (i = 0; i < 4; i++) {
			update_item_slot(i)
		}
	}
}

function UpdateUI(){
$.Schedule(0.025, UpdateUI);
	CustomNetTables.SubscribeNetTableListener
	key = "player_" + ID.toString()
	data = CustomNetTables.GetTableValue( "info", key)

	if (typeof CustomNetTables.GetTableValue( "skill", key) != 'undefined'){
		skill = CustomNetTables.GetTableValue( "skill", key).active_skill
	}

	Ent_ID = Players.GetPlayerHeroEntityIndex( ID )

	if (typeof skill != 'undefined'){
			update_skill_bar(skill)
		}



	if (typeof data != 'undefined') {
	update_hud(data)
	}
}



function create_modifier_display()
{
	var modifier_container = $.CreatePanel( "Panel", $.GetContextPanel(), "modifier_parent");
	modifier_container.hittest = false
	modifier_container.SetHasClass("modifier_container",true)
	var sub_container = $.CreatePanel( "Panel", modifier_container, "sub_container");
	sub_container.hittest = false
	sub_container.SetHasClass("sub_container",true)

	var extender = $.CreatePanel( "Panel", modifier_container, "extender");
	extender.hittest = true
	extender.SetHasClass("extender",true)

	extender.SetPanelEvent('onactivate', (function(){
		toggle_modifier_size()
	}))
	var tt = $.CreatePanel( "Panel", $.GetContextPanel(), "tooltip_panel");
	tt.hittest = false
	tt.SetHasClass("tooltip_panel",true)
}

function toggle_modifier_size(){
	if (modifier_extended == true){
		modifier_extended = false
		$("#sub_container").SetHasClass("sub_container",true)
		$("#sub_container").SetHasClass("sub_container_extended",false)
		$("#extender").SetHasClass("extender",true)
		$("#extender").SetHasClass("reducer",false)
	}else{
		modifier_extended = true
		$("#sub_container").SetHasClass("sub_container",false)
		$("#sub_container").SetHasClass("sub_container_extended",true)
		$("#extender").SetHasClass("extender",false)
		$("#extender").SetHasClass("reducer",true)
	}

}

Object.size = function(obj) {
    var size = 0, key;
    for (key in obj) {
        if (obj.hasOwnProperty(key)) size++;
    }
    return size;
};

function is_modifier_list_unchanged(modifiers)
{
	var mod_amm = (Object.size(modifiers))
	if (mod_amm!=(Object.size(last_modifier_list))){
		return false
	}

	for (modifier_ID = 0; modifier_ID < mod_amm; modifier_ID++){
		if(last_modifier_list[modifier_ID].name != modifiers[modifier_ID].name){
			return false
		}
	}
	return true

}


function update_modifier(modifier)
{
	if (is_modifier_list_unchanged(modifier)==false){
		var too_big = false
		last_modifier_list = modifier
		$("#sub_container").RemoveAndDeleteChildren()
		var table_size = (Object.size(modifier))

		if (modifier_extended == false){
			if (table_size>6){
				too_big = true
				table_size = 6
			}

		}else{
			if (table_size>18){
				table_size = 18
			}
			too_big = true
		}
		if (too_big == true){
			$("#extender").visible = true
		}else{
			$("#extender").visible = false
		}
		for (modifier_ID = 0; modifier_ID < table_size; modifier_ID++){
			var row = Math.floor(modifier_ID/6)
			var column = modifier_ID - row*6

			var X_pos = column*55 +0
			var Y_pos = row*55 +0
			var buff_name = modifier[modifier_ID].name

			var debuff = modifier[modifier_ID].debuff

			var modifier_panel = $.CreatePanel( "Panel", $("#sub_container"), "modifier_parent");
			modifier_panel.hittest = false
			modifier_panel.SetHasClass("modifier_main",true)

			modifier_panel.style.position = X_pos+"px "+Y_pos+"px 1px";

			var buff = $.CreatePanel( "Panel", modifier_panel, "buff");
			buff.hittest = false
			if (debuff == false){
				buff.SetHasClass("buff",true)
			}else{
				buff.SetHasClass("debuff",true)
			}

			var modifier_image = $.CreatePanel( "Image", modifier_panel, "modifier_image");
			modifier_image.SetHasClass("modifier_image",true)
			modifier_image.SetImage("file://{images}/custom_game/modifier/"+buff_name+".png")


			//To do : Make tooltip when hovering the modifier :D


			modifier_image.SetPanelEvent("onmouseover", function(){
				tooltip_buff(buff_name,debuff)
				})
			modifier_image.SetPanelEvent("onmouseout", function(){
				$.Schedule(0.1,function(){
					$("#tooltip_panel").RemoveAndDeleteChildren()
					}
				)
			})


		}
	}
}

function tooltip_buff(buff_name,debuff){
	var tooltip_panel = $.CreatePanel( "Panel", $("#tooltip_panel") , "Tooltip" );
	tooltip_panel.hittest = false
	var pos_mouse = GameUI.GetCursorPosition()
	pos_mouse[0] = (pos_mouse[0])*screen_rat()[0]
	pos_mouse[1] = (pos_mouse[1])*screen_rat()[1]
	tooltip_panel.style.position = (pos_mouse[0]-25) +"px "+(pos_mouse[1]-60)+"px 0px";
	tooltip_panel.SetHasClass( "bg_buff", true );

	var text = $.CreatePanel( "Label", tooltip_panel , "Title" );
	text.SetHasClass( "title", true );
	text.text = $.Localize("#modifier_"+buff_name);
	text.style.position = "5px 10px 0px";
	text.hittest = false

	var desc = $.CreatePanel( "Label", tooltip_panel , "Decription" );
	desc.SetHasClass( "desc", true );
	desc.text = $.Localize("#modifier_"+buff_name+"_desc");
	desc.style.position = "5px 30px 0px";
	desc.hittest = false

	var effect_BG = $.CreatePanel( "Image", tooltip_panel, "modifier_image");
	effect_BG.SetHasClass("modifier_image_TT",true)
	if (debuff == false){
		effect_BG.SetHasClass("buff",true)
	}else{
		effect_BG.SetHasClass("debuff",true)
	}
	effect_BG.style.position = "-2px -2px 0px";
	effect_BG.hittest = false

	var effect_image = $.CreatePanel( "Image", tooltip_panel, "modifier_image");
	effect_image.SetHasClass("modifier_image_TT",true)
	effect_image.SetImage("file://{images}/custom_game/modifier/"+buff_name+".png")
	effect_image.hittest = false

	var OLEffect = $.CreatePanel( "Panel", tooltip_panel , "OLEffect" );
	OLEffect.SetHasClass( "overlay_buff", true );
	OLEffect.hittest = false
}


GameEvents.Subscribe( "Display_Bar", display_bar)

function display_bar()
{

	$("#hud_hero").visible = true;
	GameUI.SetCameraDistance( 1300 + high )
}

function right_on_hero(){
	if (camera_free == true){
			camera_free = false
			block_camera()
	}else{
		camera_free = true
		free_camera()
	}
}


function MouseFilter( event, arg )
{
    if ( event == 'wheeled' ){
		if ( arg > 0 ) {
			if (high > 100){
				high = high - 100
			}
		}
		else{
			if (high < 2000){
				high = high + 100
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


function create_IG_Bar()
{
	for (i = 0; i < 6; i++){
			var Panel = $.CreatePanel("Panel",$("#custom_health_bar"),"HB_IG_"+i)
			Panel.SetHasClass( "Parent_panel_ally", true );
			Panel.hittest = false
			var BG = $.CreatePanel( "Panel", Panel, "BG_"+i );
			BG.SetHasClass( "BG", true );
			BG.hittest = false
			var HB = $.CreatePanel( "Panel", Panel, "ally_hb_"+i );
			HB.SetHasClass( "health_bar", true );
			HB.hittest = false
			var MB = $.CreatePanel( "Panel", Panel, "ally_mb_"+i );
			MB.SetHasClass( "mana_bar", true );
			MB.hittest = false
			var hero = $.CreatePanel( "Label", Panel, "ally_hero_"+i );
			hero.SetHasClass( "Label", true );
			hero.hittest = false
			hero.style.position = "0px 35px 1px";
			var name = $.CreatePanel( "Label", Panel, "ally_name_"+i );
			name.SetHasClass( "name", true );
			name.hittest = false
			var Over_Line = $.CreatePanel( "Panel", Panel, "Over_Line"+i );
			Over_Line.SetHasClass( "Over_Line", true );
			Over_Line.hittest = false
			Panel.visible = false
	}
	update_IG_Bar()

}

function screen_rat(){
	var screen_rat = Game.GetScreenWidth()/Game.GetScreenHeight()
	var screen_ration = {}
	var x_size = 1920
	var y_size = 1080
	if(screen_rat == 16/10){
			x_size = 1680
			y_size = 1050
	}
	if(screen_rat == 4/3){
			x_size = 1400
			y_size = 1050
	}
	screen_ration[0] = x_size/ Game.GetScreenWidth()
	screen_ration[1] = y_size/Game.GetScreenHeight()
	return screen_ration
}

function update_IG_Bar()
{
	$.Schedule(0.01, update_IG_Bar);
	for (j = 0; j < 6; j++){
		var key = "player_" + j
		var player_info = CustomNetTables.GetTableValue( "info", key)
		var Panel = $("#HB_IG_"+j)
		if (typeof player_info != 'undefined') {
			if (typeof player_info.gold != "undefined"){
				if (player_info.admin == true){
					$("#ally_hero_"+j ).SetHasClass( "Label", false );
					$("#ally_hero_"+j ).SetHasClass( "admin_label", true );
				}
				if (j == Players.GetLocalPlayer()) {
					$("#ally_name_"+j ).SetHasClass( "name", false );
					$("#ally_name_"+j ).SetHasClass( "self_name", true );
				}
				var abs_origin = Entities.GetAbsOrigin( Players.GetPlayerHeroEntityIndex( j ) )
				var screen_ration = screen_rat()
				var pos_x_hb = (Game.WorldToScreenX( abs_origin[0], abs_origin[1], abs_origin[2]) + 10 +(20/((high+10)*0.005))) * screen_ration[0]
				var pos_y_hb = (Game.WorldToScreenY( abs_origin[0], abs_origin[1], abs_origin[2]) - 40- (20/((high+10)*0.005))) * screen_ration[1]
				if (pos_x_hb > -150 && pos_y_hb > -50 &&pos_y_hb < 1160 &&  pos_x_hb <2100 ){
					Panel.visible = true
					$("#ally_hb_"+j ).style.clip = "rect( 0% ," + ((Number((player_info.HP).toFixed(0))/Number((player_info.MAXHP).toFixed(0)))*98+0.67) + "%" + ", 100% ,0% )";
					if (player_info.MAXMP>0){
						$("#ally_mb_"+j ).style.clip = "rect( 0% ," + ((Number((player_info.MP).toFixed(0))/Number((player_info.MAXMP).toFixed(0)))*92.33+0.67) + "%" + ", 100% ,0% )";
					}

					$("#ally_hero_"+j ).text =  $.Localize("#"+player_info.Name+"_ebf") + " - "+$.Localize("#Level")+" "+ player_info.LVL.toString()
					$("#ally_name_"+j ).text =  Players.GetPlayerName( j )
					Panel.style.position = pos_x_hb+"px " +pos_y_hb+"px 1px";
				}else{
					Panel.visible = false
				}
			}else{
				Panel.visible = false
			}
		}
	}
}

function change_ability_tooltip(name,skill_panel)
{
	skill_panel.SetPanelEvent("onmouseover", function(){
		$.DispatchEvent('DOTAShowAbilityTooltipForEntityIndex', skill_panel,name,Ent_ID)
	})
}



function create_hud()
{
	var hero_icon = $.CreatePanel( "Image", $("#hud_hero") , "hero_icon");
	hero_icon.SetHasClass( "hero_icon", true );

	hero_icon.SetPanelEvent("onactivate", function(){
		center_camera_on_hero()
	})

	hero_icon.SetPanelEvent("oncontextmenu", function(){
		right_on_hero()
	})

	var Background = $.CreatePanel("Panel",$("#hud_hero"),"hud_bg")
	Background.hittest = false
	Background.SetHasClass("hud_background",true)

	for (i = 0; i < 4; i++) {
		var item_panel = $.CreatePanel( "Image", $("#hud_hero") , "item_bar_image_"+i );
		item_panel.SetHasClass( "item_panel", true );
		item_panel.style.position = ((312) + (i+5)*72)+"px -87px 0px";

		var CD = $.CreatePanel( "Label", item_panel, "item_CD"+i.toString() );
		CD.SetHasClass( "Label_CD", true );
		CD.text = ""

		var am = $.CreatePanel( "Label", item_panel, "label_item_ammount_"+i.toString() );
		am.SetHasClass( "Inventory_Label", true );

		var key = $.CreatePanel( "Label", $("#hud_hero"), "item_key_"+i.toString() );
		key.SetHasClass( "button_item", true );
		key.style.position = ((312) + (i+5)*72)+"px -1px 2px";
		key.text = "F"+(i+1)
	}




	for (i = 1; i < 6; i++) {
		var skill_panel = $.CreatePanel( "DOTAAbilityImage", $("#hud_hero") , "skill_panel"+i );
		skill_panel.SetHasClass( "skill_image", true );
		skill_panel.style.position = ((312) + (i-1)*72)+"px -20px 0px";
		if (i == 5) {
			skill_panel.SetPanelEvent("onmouseover", function(){
				$.DispatchEvent('DOTAShowAbilityTooltipForEntityIndex', skill_panel,'empty5',Ent_ID)
			})
		}
		skill_panel.abilityname = "empty"+i.toString()
		change_ability_tooltip("empty"+i,skill_panel)
		skill_panel.SetPanelEvent("onmouseout", function(){
			$.DispatchEvent('DOTAHideAbilityTooltip')
		})
		var mask = $.CreatePanel( "Image", skill_panel , "mask"+i.toString() );
		var Button = $.CreatePanel( "Label", $("#hud_hero") , "button"+i.toString() );
		var Label = $.CreatePanel( "Label", skill_panel , "skill_CD"+i.toString() );
		Button.style.position = ((312) + (i-1)*72)+"px -1px 2px";
		mask.SetHasClass( "mask", true );
		mask.SetImage("file://{images}/custom_game/CD_Mask.png")
		Label.SetHasClass( "Label_CD", true );
		Label.text = ""
		Button.SetHasClass( "button", true );
		Button.text = ""
	}

	var HP_BAR = $.CreatePanel("Panel",$("#hud_hero"),"hud_healthbar")
	HP_BAR.hittest = false
	HP_BAR.SetHasClass("hud_healthbar",true)

	var MP_BAR = $.CreatePanel("Panel",$("#hud_hero"),"hud_manabar")
	MP_BAR.hittest = false
	MP_BAR.SetHasClass("hud_manabar",true)

	var XP_BAR = $.CreatePanel("Panel",$("#hud_hero"),"hud_xpbar")
	XP_BAR.hittest = false
	XP_BAR.SetHasClass("hud_xpbar",true)

	var WXP_BAR = $.CreatePanel("Panel",$("#hud_hero"),"hud_wxpbar")
	WXP_BAR.hittest = false
	WXP_BAR.SetHasClass("hud_wxpbar",true)


	var Overlay = $.CreatePanel("Panel",$("#hud_hero"),"hud_overlay")
	Overlay.hittest = false
	Overlay.SetHasClass("hud_foreground",true)

	var LVL = $.CreatePanel("Label",$("#hud_hero"),"hero_level")
	LVL.hittest = false
	LVL.SetHasClass("hero_level",true)
	LVL.text = "0.000"

	var WLVL = $.CreatePanel("Label",$("#hud_hero"),"weapon_level")
	WLVL.hittest = false
	WLVL.SetHasClass("weapon_level",true)
	WLVL.text = "000"

	var HP = $.CreatePanel("Label",$("#hud_hero"),"hp_value")
	HP.hittest = false
	HP.SetHasClass("hp_value",true)
	HP.text = "00.000.000 / 00.000.000"

	var MP = $.CreatePanel("Label",$("#hud_hero"),"mp_value")
	MP.hittest = false
	MP.SetHasClass("mp_value",true)
	MP.text = "00.000.000 / 00.000.000"

	var Gold = $.CreatePanel("Label",$("#hud_hero"),"gold_value")
	Gold.hittest = false
	Gold.SetHasClass("gold_value",true)
	Gold.text = "00.000.000"

	var hero_name = $.CreatePanel("Label",$("#hud_hero"),"hero_name")
	hero_name.hittest = false
	hero_name.SetHasClass("hero_name",true)
	hero_name.text = "Hero_Name"

	var skill_tree_but = $.CreatePanel("Panel",$("#hud_hero"),"skill_tree_but")
	skill_tree_but.SetHasClass("small_button",true)
	skill_tree_but.style.position = ((959)+0)+"px -23px 0px";
	skill_tree_but.SetPanelEvent('onactivate', (function(){
			GameUI.CustomUIConfig().Events.FireEvent( "open_skill_bar", {} )
		}))

	var hero_panel_but = $.CreatePanel("Panel",$("#hud_hero"),"hero_panel_but")
	hero_panel_but.SetHasClass("small_button",true)
	hero_panel_but.style.position = ((959)+33)+"px -23px 0px";
	hero_panel_but.SetPanelEvent('onactivate', (function(){
			GameUI.CustomUIConfig().Events.FireEvent( "open_hero", {} )
		}))

	var inventory_but = $.CreatePanel("Panel",$("#hud_hero"),"inventory_but")
	inventory_but.SetHasClass("small_button",true)
	inventory_but.style.position = ((959)+66)+"px -23px 0px";
	inventory_but.SetPanelEvent('onactivate', (function(){
			GameUI.CustomUIConfig().Events.FireEvent( "open_inv", {} )
		}))
}



function update_item_slot (i){
				if (typeof inventory != 'undefined'){
					if (typeof CustomNetTables.GetTableValue( "info", key) != 'undefined'){
						var CD = CustomNetTables.GetTableValue( "info", key).CD
						if (CD >0){
							$("#item_CD"+i.toString()).text = CD
						}else
						{
							$("#item_CD"+i.toString()).text = ""
						}
					}
					if (typeof inventory.item_bar[i+1] != 'undefined')
					{
						var item_slot = i
						var item_name = inventory.item_bar[i+1].item_name
						var Item_Image = $("#item_bar_image_"+i.toString())
						var ammount = $("#label_item_ammount_"+i.toString())
						if (inventory.item_bar[i+1].ammount > 1){
							ammount.text = inventory.item_bar[i+1].ammount
						}else
						{
							ammount.text = ""
						}

						if (inventory.item_bar[i+1].Soul == 1){
								Item_Image.SetImage("file://{images}/custom_game/itemhud/"+item_name+"_"+inventory.item_bar[i+1].quality+".png")
							}
							else
							{
								Item_Image.SetImage("file://{images}/custom_game/itemhud/"+item_name+ ".png")
							}
						var Panel = Item_Image
						Panel.SetPanelEvent('oncontextmenu', (function(){
								GameEvents.SendCustomGameEventToServer( "Use_Item", { Slot : item_slot + 1,item_bar : true} );
								$("#Info").RemoveAndDeleteChildren()
								Menu.DeleteAsync(0)
								exit.DeleteAsync(0)
							}))
						Panel.SetPanelEvent('onactivate', (function(){
							if(GameUI.IsShiftDown() == true){
								GameEvents.SendCustomGameEventToServer( "to_inventory", { Slot : item_slot + 1} );
							}

							var exit = $.CreatePanel("Button",$("#hud_hero"), "exit" );
							exit.SetHasClass( "Main", true );

							var Menu = $.CreatePanel( "Panel", $("#hud_hero"), "menu_"+item_slot.toString() );
							Menu.style.position = (GameUI.GetCursorPosition()[0]) +"px "+((GameUI.GetCursorPosition()[1])- 75)+"px 0px";
							Menu.SetHasClass( "Inventory_Menu", true );

							var Use = $.CreatePanel( "Button", Menu, "menu_use_"+item_slot.toString() );
							var position_Y = 0
							Use.style.position = "0px " +position_Y +"px 1px";
							position_Y = position_Y + 30
							Use.SetHasClass( "Inventory_Button", true );

							var to_inv = $.CreatePanel( "Button", Menu, "menu_Drop_"+item_slot.toString() );
							to_inv.SetHasClass( "Inventory_Button", true );
							to_inv.style.position = "0px " +position_Y +"px 1px";
							position_Y = position_Y + 30
							Menu.height = position_Y


							var label_Use = $.CreatePanel( "Label", Use, "label_use_"+item_slot.toString() );
							label_Use.SetHasClass( "Inventory_Label", true );
							label_Use.text = $.Localize("#Use")


							var label_to_inv = $.CreatePanel( "Label", to_inv, "label_to_inv_"+item_slot.toString() );
							label_to_inv.SetHasClass( "Inventory_Label_ve_small", true );
							label_to_inv.text= "to Inventory"
							exit.SetPanelEvent('onactivate', (function(){
								Menu.DeleteAsync(0)
								exit.DeleteAsync(0)
							}))
							Use.SetPanelEvent('onactivate', (function(){
								GameEvents.SendCustomGameEventToServer( "Use_Item", { Slot : item_slot + 1,item_bar : true} );
								Menu.DeleteAsync(0)
								exit.DeleteAsync(0)

							}))
							to_inv.SetPanelEvent('onactivate', (function(){
								GameEvents.SendCustomGameEventToServer( "to_inventory", { Slot : item_slot + 1} );
								Menu.DeleteAsync(0)
								exit.DeleteAsync(0)
							}))




						})	)

					}
					else{
						var Item_Image = $("#item_bar_image_"+i.toString())
						var ammount = $("#label_item_ammount_"+i.toString())
						ammount.text = ""
						Item_Image.SetImage("")
						var Panel = Item_Image.GetParent()
						Panel.SetPanelEvent('onactivate', (function(){}))
						Panel.SetPanelEvent("onmouseover", (function(){}))
						Panel.SetPanelEvent("onmouseout", (function(){}))
					}
				}
			}










function update_skill_bar(skill)
{
	for (i = 1; i < 6; i++) {
		var skill_panel = $("#skill_panel"+i)
		change_ability_tooltip(skill[i].name,skill_panel)
		if (skill[i].name == "empty"+i){
			skill_panel.visible = false
		}else{
			skill_panel.visible = true
		}
		skill_panel.abilityname = skill[i].name
		var ability = Entities.GetAbility( Ent_ID, i-1)
		var level = Abilities.GetLevel(ability)
		var CD = Number((Abilities.GetCooldownTimeRemaining (ability)).toFixed(1));
		var Max_CD = Number((Abilities.GetCooldown (ability)).toFixed(1));
		if (Max_CD > 0) {
			$("#mask"+i).style.clip = "rect( 0% ," + ((CD/Max_CD)*100) + "%" + ", 100% ,0% )";
		}
		else{
		$("#mask"+i).style.clip = "rect( 0% ,0%, 100% ,0% )";
		}
		var KeyBind =  	Abilities.GetKeybind(ability)
		$("#button"+i).text = KeyBind
		if (CD == 0){ $("#skill_CD"+i).text = ""}
		else {$("#skill_CD"+i).text = CD}
	}
}



function update_hud(data){
	$("#hero_name").text = $.Localize("#"+data.Name+"_ebf");

	$("#hero_icon").SetImage("file://{images}/custom_game/HUD/hero_icon/"+data.Name+".png")

	$("#hud_healthbar").style.clip = "rect( 0% ," + ((data.HP/data.MAXHP)*100) + "%" + ", 100% ,0% )";
	$("#hp_value").text = numberWithCommas(Number((data.HP).toFixed(0)))+" / "+numberWithCommas(Number((data.MAXHP).toFixed(0)))

	$("#hud_manabar").style.clip = "rect( 0% ," + ((data.MP/data.MAXMP)*100) + "%" + ", 100% ,0% )";
	$("#mp_value").text = numberWithCommas(Number((data.MP).toFixed(0)))+" / "+numberWithCommas(Number((data.MAXMP).toFixed(0)))

	if (data.MAXWXP != 0){
		$("#hud_wxpbar").style.clip = "rect( "+(100-(data.WXP/data.MAXWXP)*100)+"% ,100%,100%,0% )";
		$("#weapon_level").text = numberWithCommas(Number((data.WLVL).toFixed(0)))
	}else {
		$("#hud_wxpbar").style.clip = "rect( 0% ,100%,100%,0% )";
		$("#weapon_level").text = "0"
	}

	$("#hud_xpbar").style.clip = "rect( "+(100-(data.HXP/data.MAXHXP)*100)+"% ,100%,100%,0% )";
	$("#hero_level").text = Number((data.LVL).toFixed(0))

	$("#gold_value").text = numberWithCommas(Number((data.gold).toFixed(0)))
}


function numberWithCommas(x) {
    var parts = x.toString().split(".");
    parts[0] = parts[0].replace(/\B(?=(\d{3})+(?!\d))/g, ",");
    return parts.join(".");
}
