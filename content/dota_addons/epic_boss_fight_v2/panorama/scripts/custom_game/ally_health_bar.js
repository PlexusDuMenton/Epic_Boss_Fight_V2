var ID = Players.GetLocalPlayer()
$("#main_panel_ally").visible = false;
$("#hero_panel").visible = false;
var intrade = false;
var can_trade = true;
GameEvents.Subscribe( "Display_Bar", display_bar)
GameUI.CustomUIConfig().Events.SubscribeEvent( "CLOSE_ALL", close_hero)
GameEvents.Subscribe( "start_trading", function(){intrade = true})
GameEvents.Subscribe( "stop_trading", function(){intrade = false})

function display_bar()
{
	$.Schedule(0.025, function(){$("#main_panel_ally").visible = true;});
	create_ally_bar()
	$.Schedule(0.025, refresh);
}
CustomNetTables.SubscribeNetTableListener
function refresh()
{
	$.Schedule(0.025, refresh);
	for (i = 0; i < 5; i++){
		if (i != ID){
			var key = "player_" + i
			var player_info = CustomNetTables.GetTableValue( "info", key)
			var Panel = $("#parent_ally_"+i)
			if (typeof player_info != 'undefined') {
				if (typeof player_info.gold != "undefined"){
					Panel.visible = true
					$("#ally_hb_"+i ).style.clip = "rect( 0% ," + ((Number((player_info.HP).toFixed(0))/Number((player_info.MAXHP).toFixed(0)))*98+0.67) + "%" + ", 100% ,0% )";
					if (player_info.MAXMP>0){
						$("#ally_mb_"+i ).style.clip = "rect( 0% ," + ((Number((player_info.MP).toFixed(0))/Number((player_info.MAXMP).toFixed(0)))*92.33+0.67) + "%" + ", 100% ,0% )";
					}
					$("#ally_hero_"+i ).text =  $.Localize("#"+player_info.Name+"_ebf") + " - "+$.Localize("#Level")+" "+ player_info.LVL.toString()
					$("#ally_name_"+i ).text =  Players.GetPlayerName( i )
				}else{
					Panel.visible = false
				}
			}
		}
	}


}

function add_event(Panel,ID_hero)
{
	Panel.SetPanelEvent('onactivate', (function(){
		$("#main_panel_ally_sub").RemoveAndDeleteChildren()
		var exit = $.CreatePanel("Button",$("#main_panel_ally_sub"), "exit" );
		exit.SetHasClass( "exit_all", true );

		var Menu = $.CreatePanel( "Panel", $("#main_panel_ally_sub"), "menu");
		var pos_mouse = GameUI.GetCursorPosition()
		Menu.style.position = (GameUI.GetCursorPosition()[0]) +"px "+(GameUI.GetCursorPosition()[1])+"px 0px";
		Menu.SetHasClass( "Inventory_Menu", true );
		var equipement = $.CreatePanel( "Button", Menu, "menu_equipement" );
		var position_Y = 0
		equipement.style.position = "0px " +position_Y +"px 1px";
		position_Y = position_Y + 30
		var trading = $.CreatePanel( "Button", Menu, "menu_equipement" );
		trading.style.position = "0px " +position_Y +"px 1px";
		equipement.SetHasClass( "Inventory_Button", true );
		trading.SetHasClass( "Inventory_Button", true );
		var label_equipement = $.CreatePanel( "Label", equipement, "label_equipement" );
		var label_trading = $.CreatePanel( "Label", trading, "label_equipement" );
		label_trading.SetHasClass( "Inventory_Label", true );
		label_trading.text = $.Localize("#Trade_With")
		label_equipement.SetHasClass( "Inventory_Label", true );
		label_equipement.text = $.Localize("#equipement")
		equipement.SetPanelEvent('onactivate', (function(){
			Open_Hero_Panel(ID_hero)
			$("#main_panel_ally_sub").RemoveAndDeleteChildren()
		}))
		trading.SetPanelEvent('onactivate', (function(){
			if (can_trade == true && intrade != true){
			can_trade = false
			$.Schedule(5, function(){can_trade = true});
				$("#main_panel_ally_sub").RemoveAndDeleteChildren()
				GameEvents.SendCustomGameEventToServer( "ask_trading", { trading_with : ID_hero } );
			}
		}))

		exit.SetPanelEvent('onactivate', (function(){
			$("#main_panel_ally_sub").RemoveAndDeleteChildren()
		}))
	}))

}

function create_ally_bar()
{
	var POS_Y = 0
	for (i = 0; i < 6; i++){
		if (i != ID){
			var Panel = $.CreatePanel("Panel",$("#main_panel_ally"),"parent_ally_"+i)
			Panel.SetHasClass( "Parent_panel_ally", true );
			var BG = $.CreatePanel( "Panel", Panel, "BG_"+i );
			BG.SetHasClass( "BG", true );
			var HB = $.CreatePanel( "Panel", Panel, "ally_hb_"+i );
			HB.SetHasClass( "health_bar", true );
			var MB = $.CreatePanel( "Panel", Panel, "ally_mb_"+i );
			MB.SetHasClass( "mana_bar", true );
			var hero = $.CreatePanel( "Label", Panel, "ally_hero_"+i );
			hero.SetHasClass( "Label", true );
			hero.style.position = "0px 50px 1px";
			var name = $.CreatePanel( "Label", Panel, "ally_name_"+i );
			name.SetHasClass( "Label", true );
			var Over_Line = $.CreatePanel( "Panel", Panel, "Over_Line"+i );
			Over_Line.SetHasClass( "Over_Line", true );
			add_event(Over_Line,i)
			Panel.visible = false
			Panel.style.position = "0px " + POS_Y +"px 1px";
			POS_Y = POS_Y +90

		}
	}

}

function close_hero() {
	$.Schedule(0.025,del_panel);
	function del_panel(){
		$("#equipement").RemoveAndDeleteChildren()
		$("#Menu_h").RemoveAndDeleteChildren()
	}
	$("#hero_panel").visible = false;
}


function create_hero_panel_image(i,inventory){
			var item
			var item_slot
			//0 = weapon , 1 = chest armor , 2 = legs armor , 3 = helmet , 4 = gloves , 5 = boots,6 = necklace, 7 = wings
			if (typeof inventory != 'undefined'){
					if (typeof inventory.equipement != 'undefined'){
						if (i == 0 ){
							item = inventory.equipement.weapon
							item_slot = "weapon"
						}
						if (i == 1 ){
							item = inventory.equipement.chest_armor
							item_slot = "chest"
						}
						if (i == 2 ){
							item = inventory.equipement.legs_armor
							item_slot = "legs"
						}
						if (i == 3 ){
							item = inventory.equipement.helmet
							item_slot = "helmet"
						}
						if (i == 4 ){
							item = inventory.equipement.gloves
							item_slot = "gloves"
						}
						if (i == 5 ){
							item = inventory.equipement.boots
							item_slot = "boots"
						}
						if (i == 6 ){
							item = inventory.equipement.necklace
							item_slot = "necklace"
						}
						if (i == 7 ){
							item = inventory.equipement.wings
							item_slot = "wings"
						}
					}

					if (typeof item != 'undefined')
					{
						var item_name = item.item_name
						var Item_Image = $("#item_hero_image_"+i.toString())
						if (Item_Image != null){
							if (item.Soul == 1){
								Item_Image.SetImage("file://{images}/custom_game/itemhud/"+item_name+"_"+item.quality+".png")
							}
							else
							{
								Item_Image.SetImage("file://{images}/custom_game/itemhud/"+item_name+ ".png")
							}
							var Panel = Item_Image.GetParent()
							var label_level = $("#label_hero_Level_"+i.toString())
							if (item.cat == "weapon"){
								label_level.SetHasClass( "Inventory_Label_ve_small", true );
								label_level.text = $.Localize("#Level") + " : " + item.level
								label_level.style.position = "0px 32px 1px";
							}else
							{
								label_level.text = ""
							}
							Panel.SetPanelEvent("onmouseover", function(){GameUI.CustomUIConfig().Events.FireEvent( "display_info", { item : item} )});
							Panel.SetPanelEvent("onmouseout", function(){GameUI.CustomUIConfig().Events.FireEvent( "hide_info", {} )});
						}
					}
					else{
						var Item_Image = $("#item_hero_image_"+i.toString())
						if (Item_Image != null){
							Item_Image.SetImage("")
							var Panel = Item_Image.GetParent()
							Panel.SetPanelEvent('onactivate', (function(){}))
							Panel.SetPanelEvent("onmouseover", (function(){}))
							Panel.SetPanelEvent("onmouseout", (function(){}))
							$("#label_hero_Level_"+i.toString()).text = ""
						}
					}
				}
			}

function Open_Hero_Panel(ID_hero){
	$("#hero_panel").visible = true;
	var key = "player_" + ID_hero
	var inventory = CustomNetTables.GetTableValue( "inventory_player_"+ID_hero,key)
	var stats = CustomNetTables.GetTableValue( "stats", key)
	$.Schedule(0.055,Updateslot_panel);
	function Updateslot_panel()
	{
		if ($("#hero_panel").visible) {
			$.Schedule(0.1, Updateslot_panel);
		}
		for (i = 0; i <= 5; i++ ){
			create_hero_panel_image(i,inventory)
		}
	}

	 $.Schedule(0.05,function(){create_panels_hero(stats,ID_hero)});
	 function create_panels_hero(stats,ID_hero){
		 for (i = 0; i <= 7; i++) {
			var Panel = $.CreatePanel( "Panel", $("#equipement"), "item_hero_panel_"+i.toString() );
			Panel.SetHasClass( "ItemImage", true );
			var Item_Image = $.CreatePanel( "Image", Panel, "item_hero_image_"+i.toString() );
			Item_Image.SetHasClass( "ItemImage", true );
			Button = $.CreatePanel( "Button", Panel, "item_hero_slot_"+i.toString() );
			Button.SetHasClass( "ItemButton", true );
			$.CreatePanel( "Label", Panel, "label_hero_Level_"+i.toString() );
			//0 = weapon , 1 = chest armor , 2 = legs armor , 3 = helmet , 4 = gloves , 5 = boots,6 = necklace, 7 = wings
			if (i == 0 ){
				Panel.style.position = "52px 199px 1px";
			}
			if (i == 1 ){
				Panel.style.position = "152px 124px 1px";
			}
			if (i == 2 ){
				Panel.style.position = "152px 213px 1px";
			}
			if (i == 3 ){
				Panel.style.position = "152px 48px 1px";
			}
			if (i == 4 ){
				Panel.style.position = "244px 222px 1px";
			}
			if (i == 5 ){
				Panel.style.position = "109px 343px 1px";
			}
			if (i == 6 ){
				Panel.style.position = "52px 48px 1px";
			}
			if (i == 7 ){
				Panel.style.position = "264px 48px 1px";
			}
		}

		var menu_Items_hero = $.CreatePanel( "Panel", $("#Menu_h"), "menu_Items_hero");
			menu_Items_hero.SetHasClass( "menu_Items", true );
			menu_Items_hero.hittest = false
		}
		var H_menu = $.CreatePanel( "Label", $("#Menu_h"), "menu_info_h" )
		H_menu.SetHasClass( "menu_Items", true );
		H_menu.hittest = false
		H_menu.style.position = "80px 50px 1px";

		refresh_hero_stat(ID_hero,stats,ID_hero)

	function refresh_hero_stat(ID_hero,stats,hero_id){
		if (typeof stats != 'undefined')
		{
			if ($("#menu_info_h")) {
				$("#menu_info_h").RemoveAndDeleteChildren()
				$.Schedule(0.15,function(){refresh_hero_stat(ID_hero,stats,hero_id)});
			var name = $.CreatePanel( "Label", $("#menu_info_h"), "Hero_Info_Name" )
			name.SetHasClass( "Inventory_Label", true );
			name.style.position = "350px 15px 1px";
			name.text =  Players.GetPlayerName( ID_hero )

			var H_name = $.CreatePanel( "Label", $("#menu_info_h"), "Hero_Info_Name" )
			H_name.SetHasClass( "Inventory_Label", true );
			H_name.style.position = "350px 30px 1px";
			H_name.text =  $.Localize("#"+stats.Name+"_ebf");

			var H_Lvl = $.CreatePanel( "Label", $("#menu_info_h"), "Hero_Info_Lvl" )
			H_Lvl.SetHasClass( "Inventory_Label", true );
			H_Lvl.style.position = "350px 60px 1px";
			H_Lvl.text =  $.Localize("#Level")+" : " +stats.LVL;

			var H_SP = $.CreatePanel( "Label", $("#menu_info_h"), "Hero_Info_SP" )
			H_SP.SetHasClass( "Inventory_Label", true );
			H_SP.style.position = "350px 90px 1px";
			H_SP.text =  $.Localize("#Power_Points") + " : " +stats.stats_points;

			var H_str = $.CreatePanel( "Label", $("#menu_info_h"), "Hero_Info_str" )
			H_str.SetHasClass( "Inventory_Label_small", true );
			H_str.style.position = "350px 150px 1px";
			H_str.text = $.Localize("#Strength") + " : "+ Number((stats.hero_stats.str + stats.skill_stats.str+ stats.equip_stats.str).toFixed(2));

			var H_agi = $.CreatePanel( "Label", $("#menu_info_h"), "Hero_Info_agi" )
			H_agi.SetHasClass( "Inventory_Label_small", true );
			H_agi.style.position = "350px 175px 1px";
			H_agi.text = $.Localize("#Agility") + " : "+ Number((stats.hero_stats.agi + stats.skill_stats.agi+ stats.equip_stats.agi).toFixed(2));

			var H_int = $.CreatePanel( "Label", $("#menu_info_h"), "Hero_Info_int" )
			H_int.SetHasClass( "Inventory_Label_small", true );
			H_int.style.position = "350px 200px 1px";
			H_int.text = $.Localize("#Inteligence") + " : "+ Number((stats.hero_stats.int + stats.skill_stats.int+ stats.equip_stats.int).toFixed(2));

			var H_dmg = $.CreatePanel( "Label", $("#menu_info_h"), "Hero_Info_dmg" )
			H_dmg.SetHasClass( "Inventory_Label_small", true );
			H_dmg.style.position = "350px 255px 1px";
			var as = Entities.GetAttackSpeed( Players.GetPlayerHeroEntityIndex( ID ) ) + stats.effect_bonus.as + stats.hero_stats.attack_speed + stats.skill_stats.attack_speed + stats.skill_stats.agi*0.33 +stats.equip_stats.attack_speed + stats.hero_stats.agi*0.33
			var attack_speed = ((100 + as) * 0.01) / (Entities.GetBaseAttackTime( Players.GetPlayerHeroEntityIndex( ID ) ))
			var aps = Number((attack_speed).toFixed(2));
			var dmg = Number((stats.effect_bonus.damage+stats.equip_stats.m_damage+stats.equip_stats.damage + (stats.skill_stats.str +stats.hero_stats.str+ stats.equip_stats.str)*0.9 +Math.pow((stats.skill_stats.agi*0.9+stats.hero_stats.agi*0.9+ stats.equip_stats.agi*0.9),1.1)+2).toFixed(2));
			var dps = Number((dmg*aps).toFixed(0));
			H_dmg.text = $.Localize("#Damage") + " : "+ + dmg + "\n("+ dps + " " + $.Localize("#DPS") + ")";

			var H_as = $.CreatePanel( "Label", $("#menu_info_h"), "Hero_Info_as" )
			H_as.SetHasClass( "Inventory_Label_small", true );
			H_as.style.position = "350px 300px 1px";
			as = Number((as).toFixed(2));
			H_as.text =$.Localize("#Attack_Speed") + " : "+ as ;

			var H_aps = $.CreatePanel( "Label", $("#menu_info_h"), "Hero_Info_aps" )
			H_aps.SetHasClass( "Inventory_Label_small", true );
			H_aps.style.position = "350px 335px 1px";
			H_aps.text = $.Localize("#Attack_Per_Second") + " : " + aps;

			var H_hp = $.CreatePanel( "Label", $("#menu_info_h"), "Hero_Info_hp" )
			H_hp.SetHasClass( "Inventory_Label_small2", true );
			H_hp.style.position = "350px 380px 1px";
			var hp =Entities.GetMaxHealth(Players.GetPlayerHeroEntityIndex( ID ))
			var hp_regen = stats.equip_stats.hp_regen + stats.hero_stats.hp_regen + stats.skill_stats.hp_regen
			H_hp.text = $.Localize("#Health") + " : "+ Number((hp).toFixed(0)) + "\n(" + Number((hp_regen).toFixed(2)) +" "+ $.Localize("#Hp_per_sec") + " )";

			var H_mp = $.CreatePanel( "Label", $("#menu_info_h"), "Hero_Info_mp" )
			H_mp.SetHasClass( "Inventory_Label_small2", true );
			H_mp.style.position = "350px 425px 1px";
			var mp =Entities.GetMaxMana(Players.GetPlayerHeroEntityIndex( ID ))
			var mp_regen = stats.equip_stats.mp_regen + stats.hero_stats.mp_regen + stats.skill_stats.mp_regen
			H_mp.text = $.Localize("#Mana") + " : "+ Number((mp).toFixed(2)) + "\n(" + Number((mp_regen).toFixed(2)) +" " + $.Localize("#Mp_per_sec") + " )";

			var H_armor = $.CreatePanel( "Label", $("#menu_info_h"), "Hero_Info_armor" )
			H_armor.SetHasClass( "Inventory_Label_small2", true );
			H_armor.style.position = "350px 470px 1px";
			var armor = stats.hero_stats.armor + stats.equip_stats.armor + stats.skill_stats.armor
			var ress = ( 0.06 * armor ) / (1 + 0.06 * armor) * 100;
			H_armor.text = $.Localize("#Armor") + " : "+ Number((armor).toFixed(2)) + "\n(" + Number((ress).toFixed(2)) + " % " +$.Localize("#Physical_Ress") + ")";

			var H_m_armor = $.CreatePanel( "Label", $("#menu_info_h"), "Hero_Info_m_armor" )
			H_m_armor.SetHasClass( "Inventory_Label_small2", true );
			H_m_armor.style.position = "350px 520px 1px";
			var m_armor = stats.equip_stats.m_ress * 0.95 + 5
			H_m_armor.text = $.Localize("#Magic_Ress") + " : "+ Number((m_armor).toFixed(2)) + "%";

			var H_ls = $.CreatePanel( "Label", $("#menu_info_h"), "Hero_Info_ls" )
			H_ls.SetHasClass( "Inventory_Label_small2", true );
			H_ls.style.position = "350px 585px 1px";
			var ls = stats.equip_stats.ls + stats.skill_stats.ls
			var loh = stats.equip_stats.loh + stats.skill_stats.loh
			H_ls.text = $.Localize("#Life_Steal") + " : " + Number((ls).toFixed(2)) + "% \n" + $.Localize("#Life_on_Hit") + " : "+ Number((loh).toFixed(2));

			var H_range = $.CreatePanel( "Label", $("#menu_info_h"), "Hero_Info_range" )
			H_range.SetHasClass( "Inventory_Label_small2", true );
			H_range.style.position = "350px 630px 1px";
			var range = stats.equip_stats.range + stats.skill_stats.range + Entities.GetAttackRange( Players.GetPlayerHeroEntityIndex( ID ) )
			H_range.text = $.Localize("#Range") + " : " + Number((range).toFixed(2));

			var H_ms = $.CreatePanel( "Label", $("#menu_info_h"), "Hero_Info_ms" )
			H_ms.SetHasClass( "Inventory_Label_small2", true );
			H_ms.style.position = "350px 660px 1px";
			var ms = stats.equip_stats.movespeed + stats.skill_stats.range + 280
			H_ms.text = $.Localize("#Move_Speed") + " : "+ Number((ms).toFixed(0)) ;

			var H_dodge = $.CreatePanel( "Label", $("#menu_info_h"), "Hero_Info_dodge" )
			H_dodge.SetHasClass( "Inventory_Label_small2", true );
			H_dodge.style.position = "350px 685px 1px";
			var dodge = stats.equip_stats.dodge + stats.skill_stats.dodge
			H_dodge.text = $.Localize("#Dodge") + " : "+ Number((dodge).toFixed(2)) + "%";
			}


		}
	}
}
