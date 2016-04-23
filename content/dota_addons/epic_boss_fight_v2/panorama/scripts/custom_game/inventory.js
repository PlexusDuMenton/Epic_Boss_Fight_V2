var inventory;
var stats;
var inshop = false;
var ID = Players.GetLocalPlayer()
$("#inv_panel").visible = false;
$("#hero_panel").visible = false;
$.Schedule(0.3,Updateinventory);
$("#inventory_button").visible = false;
$("#hero_button").visible = false;
$("#item_main_bar").visible = false;
	function Updateinventory()
	{
		
		
		$.Schedule(0.1, Updateinventory);
		CustomNetTables.SubscribeNetTableListener
		key = "player_" + ID.toString()
		inventory = CustomNetTables.GetTableValue( "inventory", key)
		stats = CustomNetTables.GetTableValue( "stats", key)
		if (typeof CustomNetTables.GetTableValue( "info", key) != 'undefined')
		{
			inshop = CustomNetTables.GetTableValue( "info", key).inshop
			if (inventory.size == 30){
				$("#Inventory_BG").style.clip = "rect( 0% ,100%, 75% ,0% )";
			}
		}
	}
function create_image (i){
				if (typeof inventory != 'undefined'){
					if (typeof inventory.inventory[i+1] != 'undefined')
					{
						var item_slot = i
						var item_name = inventory.inventory[i+1].item_name
						var Item_Image = $("#item_image_"+i.toString())
						if (Item_Image != null) {
							Item_Image.SetImage("file://{images}/custom_game/itemhud/"+item_name+ ".png")
							var Panel = Item_Image.GetParent()
							var ammount = $("#label_item_inv_ammount_"+i.toString())
							if (inventory.inventory[i+1].ammount > 1){
								ammount.text = inventory.inventory[i+1].ammount
							}else
							{
								ammount.text = ""
							}
							if (inventory.inventory[i+1].cat == "weapon"){
							var label_level = $("#label_Level_"+i.toString())
								label_level.SetHasClass( "Inventory_Label_ve_small", true );
								label_level.text = $.Localize("#Level")+" : " + inventory.inventory[item_slot+1].level
								label_level.style.position = "0px 32px 1px";
							}else
							{
								var label_level = $("#label_Level_"+i.toString())
								label_level.text = ""
							}
							Panel.SetPanelEvent("onmouseover", function(){display_info(inventory.inventory[i+1])});
							Panel.SetPanelEvent("onmouseout", function(){$("#Info").RemoveAndDeleteChildren()});	
							Panel.SetPanelEvent('oncontextmenu', (function(){
									GameEvents.SendCustomGameEventToServer( "Use_Item", { Slot : item_slot + 1} );
									$("#Info").RemoveAndDeleteChildren()
									$("#menu_Items").RemoveAndDeleteChildren()
								}))
							Panel.SetPanelEvent('onactivate', (function(){
								var exit = $.CreatePanel("Button",$("#menu_Items"), "exit" );
								exit.SetHasClass( "Main", true );
								var Menu = $.CreatePanel( "Panel", Panel, "menu_"+item_slot.toString() );
								var pos_mouse = GameUI.GetCursorPosition()
								Menu.style.position = (GameUI.GetCursorPosition()[0]) +"px "+(GameUI.GetCursorPosition()[1])+"px 0px";
								Menu.SetHasClass( "Inventory_Menu", true );
								Menu.SetParent($("#menu_Items"))

								var Use = $.CreatePanel( "Button", Menu, "menu_use_"+item_slot.toString() );
								var position_Y = 0
								Use.style.position = "0px " +position_Y +"px 1px";
								position_Y = position_Y + 30
								Use.SetHasClass( "Inventory_Button", true );
								if (inventory.inventory[item_slot+1].cat == "consumable"){
									var Bar = $.CreatePanel( "Button", Menu, "menu_info_"+item_slot.toString() );
									Bar.SetHasClass( "Inventory_Button", true );
									Bar.style.position = "0px " +position_Y +"px 1px";
									position_Y = position_Y + 30
								}
								if (inshop == true )
								{
									var Sell = $.CreatePanel( "Button", Menu, "menu_sell_"+item_slot.toString() );
									Sell.style.position = "0px " +position_Y +"px 1px";
									position_Y = position_Y + 30
									Sell.SetHasClass( "Inventory_Button", true );
									
									var label_Sell = $.CreatePanel( "Label", Sell, "label_sell_"+item_slot.toString() );
									label_Sell.SetHasClass( "Inventory_Label", true );
									label_Sell.text = "Sell" 
								}
								//var Unequip = $.CreatePanel( "Button", Menu, "menu_unequip_"+item_slot.toString() );
								//Unequip.SetHasClass( "Inventory_Button", true );
								//var label_Unequip = $.CreatePanel( "Label", Unequip, "label_unequip_"+item_slot.toString() );
								//Unequip.style.position = "0px " +position_Y +"px 1px";
								//position_Y = position_Y + 30
								
								var Drop = $.CreatePanel( "Button", Menu, "menu_Drop_"+item_slot.toString() );
								Drop.SetHasClass( "Inventory_Button", true );
								Drop.style.position = "0px " +position_Y +"px 1px";
								position_Y = position_Y + 30
								Menu.height = position_Y 
								
								
								var label_Use = $.CreatePanel( "Label", Use, "label_use_"+item_slot.toString() );
								label_Use.SetHasClass( "Inventory_Label", true );
								if (typeof inventory.inventory[item_slot+1] != 'undefined')
								{
									if (inventory.inventory[item_slot+1].Equipement == true){
										label_Use.text = "Equip"
									}else{
										label_Use.text = "Use" 
									}
								}
								
								var label_Drop = $.CreatePanel( "Label", Drop, "label_drop_"+item_slot.toString() );
								label_Drop.SetHasClass( "Inventory_Label", true );
								label_Drop.text= "Drop"
								if (inventory.inventory[item_slot+1].Equipement == 1 ){
									label_Drop.text= "Destroy"
								}
								if (inventory.inventory[item_slot+1].cat == "consumable"){
									var label_Bar = $.CreatePanel( "Label", Bar, "label_info_"+item_slot.toString() );
									label_Bar.SetHasClass( "Inventory_Label", true );
									label_Bar.text= "To Skill Bar"
								}
								exit.SetPanelEvent('onactivate', (function(){
									$("#menu_Items").RemoveAndDeleteChildren()
								}))
								Use.SetPanelEvent('onactivate', (function(){
									GameEvents.SendCustomGameEventToServer( "Use_Item", { Slot : item_slot + 1} );
									$("#Info").RemoveAndDeleteChildren()
									$("#menu_Items").RemoveAndDeleteChildren()
								}))
								if (inshop == true )
								{
									Sell.SetPanelEvent('onactivate', (function(){
										GameEvents.SendCustomGameEventToServer( "Sell_Item", { Slot : item_slot + 1} );
										$("#Info").RemoveAndDeleteChildren()
										$("#menu_Items").RemoveAndDeleteChildren()
									}))
								}
								Drop.SetPanelEvent('onactivate', (function(){
									label_Drop.text = "confirm"
										Drop.SetPanelEvent('onactivate', (function(){
										
										GameEvents.SendCustomGameEventToServer( "Drop_Item", { Slot : item_slot + 1} );
										$("#Info").RemoveAndDeleteChildren()
										$("#menu_Items").RemoveAndDeleteChildren()
									}))
									
								}))
				
								if (inventory.inventory[item_slot+1].cat == "consumable"){
									Bar.SetPanelEvent('onmouseover', (function(){
										if ($("#submenu_"+item_slot.toString()) == null ){
										var SubMenu = $.CreatePanel( "Panel", Panel, "submenu_"+item_slot.toString() );
											SubMenu.style.position = (pos_mouse[0]+100) +"px "+pos_mouse[1]+"px 0px";
											SubMenu.SetHasClass( "Inventory_Menu", true );
											SubMenu.SetParent($("#menu_Items"))
											var sub_position_Y = 0
										for (j = 0; j < 4; j++){
											var Slot = $.CreatePanel( "Button", SubMenu, "menu_use_"+j );
											Slot.style.position = "0px " +sub_position_Y +"px 1px";
											sub_position_Y = sub_position_Y + 30
											Slot.SetHasClass( "Inventory_Button", true );
											
											var label_Slot = $.CreatePanel( "Label", Slot, "label_drop_"+j );
											label_Slot.SetHasClass( "Inventory_Label", true );
											label_Slot.text= "Slot "+ (j + 1)
											var slot_number = j + 1
											if (j == 0){ 
												Slot.SetPanelEvent('onactivate', (function(){
												GameEvents.SendCustomGameEventToServer( "to_item_bar", { Slot : item_slot + 1,Bar_Slot : 1} );
												$("#Info").RemoveAndDeleteChildren()
												$("#menu_Items").RemoveAndDeleteChildren()
										}))
												}
											if (j == 1){ 
												Slot.SetPanelEvent('onactivate', (function(){
												GameEvents.SendCustomGameEventToServer( "to_item_bar", { Slot : item_slot + 1,Bar_Slot : 2} );
												$("#Info").RemoveAndDeleteChildren()
												$("#menu_Items").RemoveAndDeleteChildren()
										}))
												}
											if (j == 2){ 
												Slot.SetPanelEvent('onactivate', (function(){
												GameEvents.SendCustomGameEventToServer( "to_item_bar", { Slot : item_slot + 1,Bar_Slot : 3} );
												$("#Info").RemoveAndDeleteChildren()
												$("#menu_Items").RemoveAndDeleteChildren()
										}))
												}
											if (j == 3){ 
												Slot.SetPanelEvent('onactivate', (function(){
												GameEvents.SendCustomGameEventToServer( "to_item_bar", { Slot : item_slot + 1,Bar_Slot : 4} );
												$("#Info").RemoveAndDeleteChildren()
												$("#menu_Items").RemoveAndDeleteChildren()
										}))
												}
											
										}
										
										Menu.height = sub_position_Y 
									}}))
									Bar.SetPanelEvent('onactivate', (function(){
										$("#Info").RemoveAndDeleteChildren()
										GameEvents.SendCustomGameEventToServer( "to_item_bar", { Slot : item_slot + 1} ); // 
										$("#menu_Items").RemoveAndDeleteChildren()
									}))
								}
								
								
								
								
							})	)
							}
						
					}
					else{
						var Item_Image = $("#item_image_"+i.toString())
						if (Item_Image != null){
							Item_Image.SetImage("")
							
							var Panel = Item_Image.GetParent()
							Panel.SetPanelEvent('onactivate', (function(){}))
							Panel.SetPanelEvent("onmouseover", (function(){}))
							Panel.SetPanelEvent("onmouseout", (function(){}))
							$("#label_Level_"+i.toString()).text = ""
							$("#label_item_inv_ammount_"+i.toString()).text = ""
						}
					}
				}
			}
			
function Open_Inventory(){
	$("#inv_panel").visible = true;
	$("#inv_but_label").text = "Close inv"
	$("#inventory_button").SetPanelEvent('onactivate', close_inventory)
	$.Schedule(0.055,Updateslot);
	function Updateslot()
	{
		if ($("#inv_panel").visible) {
			$.Schedule(0.1, Updateslot);
		}
		for (i = 0; i < inventory.size; i++) {
			create_image (i)
		}
	}
	 
	 $.Schedule(0.05,create_panels);
	 function create_panels(){
		 for (i = 0; i < inventory.size; i++) {
			var Panel = $.CreatePanel( "Panel", $("#Items"), "item_panel_"+i.toString() );
			Panel.SetHasClass( "ItemImage", true );
			var Item_Image = $.CreatePanel( "Image", Panel, "item_image_"+i.toString() );
			Item_Image.SetHasClass( "ItemImage", true );
			Button = $.CreatePanel( "Button", Panel, "item_slot_"+i.toString() );
			Button.SetHasClass( "ItemButton", true );
			$.CreatePanel( "Label", Panel, "label_Level_"+i.toString() );
			if (i <= 9 ){
				Panel.style.position = ( 64*i - i )+"px 0px 1px";
				
			}
			if (i > 9 && i <= 19){
				Panel.style.position = ( 63*(i-10) )+"px 64px 1px";
				
			}
			if (i > 19 && i <= 29){
				Panel.style.position = 63*(i-20) +"px 127px 1px";
			}
			if (i > 29 ){
				Panel.style.position = 63*(i-30) +"px 191px 1px";
			}	
			var am = $.CreatePanel( "Label", Panel, "label_item_inv_ammount_"+i.toString() );
			am.SetHasClass( "Inventory_Label", true );
		}

		var menu_Items = $.CreatePanel( "Panel", $("#Menu"), "menu_Items");
			menu_Items.SetHasClass( "menu_Items", true );
			menu_Items.hittest = false 
	}
}
GameEvents.Subscribe( "Display_Bar", display_but)
function display_but(){
$("#item_main_bar").visible = true;
$("#inventory_button").visible = true;
$("#hero_button").visible = true;
Game.AddCommand( "+Open_Inventory", inv_key, "", 0 );
Game.AddCommand( "+Open_Hero_Panel", hero_key, "", 0 );

function useitem(slot){
	GameEvents.SendCustomGameEventToServer( "Use_Item", { Slot : slot,item_bar : true} )
}
Game.AddCommand( "+item_1", function(){useitem(1)}, "", 0 );
Game.AddCommand( "+item_2", function(){useitem(2)}, "", 0 );
Game.AddCommand( "+item_3", function(){useitem(3)}, "", 0 );
Game.AddCommand( "+item_4", function(){useitem(4)}, "", 0 );
create_skill_bar()
}
function close_info(){
$("#Info").RemoveAndDeleteChildren()
}

function create_hero_panel_image(i){
			var item
			var item_slot 
			//0 = weapon , 1 = chest armor , 2 = legs armor , 3 = helmet , 4 = gloves , 5 = boots
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
					}
				
					if (typeof item != 'undefined')
					{
						var item_name = item.item_name
						var Item_Image = $("#item_hero_image_"+i.toString())
						if (Item_Image != null){
							Item_Image.SetImage("file://{images}/custom_game/itemhud/"+item_name+ ".png")
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
							Panel.SetPanelEvent("onmouseover", function(){display_info(item)});
							Panel.SetPanelEvent("onmouseout", function(){$("#Info").RemoveAndDeleteChildren()});	
							Panel.SetPanelEvent('oncontextmenu', (function(){
									GameEvents.SendCustomGameEventToServer( "Unequip_Item", { Slot : item_slot} );
									$("#Info").RemoveAndDeleteChildren()
									$("#menu_Items_hero").RemoveAndDeleteChildren()
								}))
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

function Open_Hero_Panel(){
	$("#hero_panel").visible = true;
	$("#hero_but_label").text = $.Localize("#Close")
	$("#hero_button").SetPanelEvent('onactivate', close_hero)
	var skill_tree_button = $.CreatePanel( "Panel", $("#hero_panel") , "close" );
		skill_tree_button.SetHasClass( "Skill_tree", true );
		skill_tree_button.SetPanelEvent("onactivate", function(){
			GameEvents.SendCustomGameEventToServer( "skill_bar", {} );
		})	
	var label_st = $.CreatePanel( "Label", skill_tree_button , "close" );
	label_st.SetHasClass( "Inventory_Label_small2", true );
	label_st.text = $.Localize("#Skill_Tree")
		
	$.Schedule(0.055,Updateslot_panel);
	function Updateslot_panel()
	{
		if ($("#hero_panel").visible) {
			$.Schedule(0.1, Updateslot_panel);
		}
		for (i = 0; i <= 5; i++ ){
			create_hero_panel_image(i)
		}
	}
	
	 $.Schedule(0.05,create_panels_hero);
	 function create_panels_hero(){
		 for (i = 0; i <= 5; i++) {
			var Panel = $.CreatePanel( "Panel", $("#equipement"), "item_hero_panel_"+i.toString() );
			Panel.SetHasClass( "ItemImage", true );
			var Item_Image = $.CreatePanel( "Image", Panel, "item_hero_image_"+i.toString() );
			Item_Image.SetHasClass( "ItemImage", true );
			Button = $.CreatePanel( "Button", Panel, "item_hero_slot_"+i.toString() );
			Button.SetHasClass( "ItemButton", true );
			$.CreatePanel( "Label", Panel, "label_hero_Level_"+i.toString() );
			//0 = weapon , 1 = chest armor , 2 = legs armor , 3 = helmet , 4 = gloves , 5 = boots
			if (i == 0 ){
				Panel.style.position = "55px 175px 1px";
			}
			if (i == 1 ){
				Panel.style.position = "150px 134px 1px";
			}
			if (i == 2 ){
				Panel.style.position = "150px 235px 1px";
			}
			if (i == 3 ){
				Panel.style.position = "150px 47px 1px";
			}
			if (i == 4 ){
				Panel.style.position = "251px 190px 1px";
			}
			if (i == 5 ){
				Panel.style.position = "103px 323px 1px";
			}
		}

		var menu_Items_hero = $.CreatePanel( "Panel", $("#Menu_h"), "menu_Items_hero");
			menu_Items_hero.SetHasClass( "menu_Items", true );
			menu_Items_hero.hittest = false 
		}
		var H_menu = $.CreatePanel( "Label", $("#Menu_h"), "menu_info_h" )
		H_menu.SetHasClass( "menu_Items", true );
		H_menu.hittest = false 
		H_menu.style.position = "1150px 150px 1px";
		
		refresh_hero_stat()

	function refresh_hero_stat(){
		if (typeof stats != 'undefined')
		{	
			if ($("#menu_info_h")) {
				$("#menu_info_h").RemoveAndDeleteChildren()
				$.Schedule(0.15,refresh_hero_stat);
			
			var H_name = $.CreatePanel( "Label", $("#menu_info_h"), "Hero_Info_Name" )
			H_name.SetHasClass( "Inventory_Label", true );
			H_name.style.position = "350px 30px 1px";
			H_name.text =  $.Localize("#"+stats.Name);
			
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
			H_str.text = $.Localize("#Strength") + " : "+ Number((stats.hero_stats.str + stats.skill_stats.str).toFixed(2));
			
			var H_agi = $.CreatePanel( "Label", $("#menu_info_h"), "Hero_Info_agi" )
			H_agi.SetHasClass( "Inventory_Label_small", true );
			H_agi.style.position = "350px 175px 1px";
			H_agi.text = $.Localize("#Agility") + " : "+ Number((stats.hero_stats.agi + stats.skill_stats.agi).toFixed(2));
			
			var H_int = $.CreatePanel( "Label", $("#menu_info_h"), "Hero_Info_int" )
			H_int.SetHasClass( "Inventory_Label_small", true );
			H_int.style.position = "350px 200px 1px";
			H_int.text = $.Localize("#Inteligence") + " : "+ Number((stats.hero_stats.int + stats.skill_stats.int).toFixed(2));
			
			var H_dmg = $.CreatePanel( "Label", $("#menu_info_h"), "Hero_Info_dmg" )
			H_dmg.SetHasClass( "Inventory_Label_small", true );
			H_dmg.style.position = "350px 255px 1px";
			var as = Entities.GetAttackSpeed( Players.GetPlayerHeroEntityIndex( ID ) ) + stats.hero_stats.attack_speed + stats.skill_stats.attack_speed + stats.skill_stats.agi*0.33 +stats.equip_stats.attack_speed + stats.hero_stats.agi*0.33
			var attack_speed = ((100 + as) * 0.01) / (Entities.GetBaseAttackTime( Players.GetPlayerHeroEntityIndex( ID ) ))
			var aps = Number((attack_speed).toFixed(2));
			
			var dmg = Number((stats.hero_stats.damage + stats.skill_stats.damage + stats.skill_stats.str*1.5 +stats.hero_stats.str*1.5 + stats.equip_stats.damage + 2).toFixed(2));
			var dps = Number((dmg*aps).toFixed(1));
			H_dmg.text = $.Localize("#Damage") + " : "+ + dmg + "("+ dps + " " + $.Localize("#DPS") + ")";
			
			var H_as = $.CreatePanel( "Label", $("#menu_info_h"), "Hero_Info_as" )
			H_as.SetHasClass( "Inventory_Label_small", true );
			H_as.style.position = "350px 280px 1px";
			as = Number((as).toFixed(2));
			H_as.text =$.Localize("#Attack_Speed") + " : "+ as ;
			
			var H_aps = $.CreatePanel( "Label", $("#menu_info_h"), "Hero_Info_aps" )
			H_aps.SetHasClass( "Inventory_Label_small", true );
			H_aps.style.position = "350px 325px 1px";
			H_aps.text = $.Localize("#Attack_Per_Second") + " : " + aps;
			
			var H_hp = $.CreatePanel( "Label", $("#menu_info_h"), "Hero_Info_hp" )
			H_hp.SetHasClass( "Inventory_Label_small2", true );
			H_hp.style.position = "350px 370px 1px";
			var hp =Entities.GetMaxHealth(Players.GetPlayerHeroEntityIndex( ID ))
			var hp_regen = stats.equip_stats.hp_regen + stats.hero_stats.hp_regen + stats.skill_stats.hp_regen
			H_hp.text = $.Localize("#Health") + " : "+ Number((hp).toFixed(0)) + "\n(" + Number((hp_regen).toFixed(2)) +" "+ $.Localize("#Hp_per_sec") + " )";
			
			var H_mp = $.CreatePanel( "Label", $("#menu_info_h"), "Hero_Info_mp" )
			H_mp.SetHasClass( "Inventory_Label_small2", true );
			H_mp.style.position = "350px 415px 1px";
			var mp =Entities.GetMaxMana(Players.GetPlayerHeroEntityIndex( ID ))
			var mp_regen = stats.equip_stats.mp_regen + stats.hero_stats.mp_regen + stats.skill_stats.mp_regen
			H_mp.text = $.Localize("#Mana") + " : "+ Number((mp).toFixed(2)) + "\n(" + Number((mp_regen).toFixed(2)) +" " + $.Localize("#Mp_per_sec") + " )";
			
			var H_armor = $.CreatePanel( "Label", $("#menu_info_h"), "Hero_Info_armor" )
			H_armor.SetHasClass( "Inventory_Label_small2", true );
			H_armor.style.position = "350px 460px 1px";
			var armor = stats.hero_stats.armor + stats.equip_stats.armor + stats.skill_stats.armor
			var ress = ( 0.06 * armor ) / (1 + 0.06 * armor) * 100; 
			H_armor.text = $.Localize("#Armor") + " : "+ Number((armor).toFixed(2)) + "\n(" + Number((ress).toFixed(2)) + " % " +$.Localize("#Physical_Ress") + ")";
			
			var H_m_armor = $.CreatePanel( "Label", $("#menu_info_h"), "Hero_Info_m_armor" )
			H_m_armor.SetHasClass( "Inventory_Label_small2", true );
			H_m_armor.style.position = "350px 510px 1px";
			var m_armor = stats.equip_stats.m_ress * 0.95 + 5
			H_m_armor.text = $.Localize("#Magic_Ress") + " : "+ Number((m_armor).toFixed(2)) + "%";
			
			var H_ls = $.CreatePanel( "Label", $("#menu_info_h"), "Hero_Info_ls" )
			H_ls.SetHasClass( "Inventory_Label_small2", true );
			H_ls.style.position = "350px 555px 1px";
			var ls = stats.equip_stats.ls + stats.skill_stats.ls
			var loh = stats.equip_stats.loh + stats.skill_stats.loh
			H_ls.text = $.Localize("#Life_Steal") + " : " + Number((ls).toFixed(2)) + "% \n" + $.Localize("#Life_on_Hit") + " : "+ Number((loh).toFixed(2));
			
			var H_range = $.CreatePanel( "Label", $("#menu_info_h"), "Hero_Info_range" )
			H_range.SetHasClass( "Inventory_Label_small2", true );
			H_range.style.position = "350px 605px 1px";
			var range = stats.equip_stats.range + stats.skill_stats.range + Entities.GetAttackRange( Players.GetPlayerHeroEntityIndex( ID ) )
			H_range.text = $.Localize("#Range") + " : " + Number((range).toFixed(2));
			
			var H_ms = $.CreatePanel( "Label", $("#menu_info_h"), "Hero_Info_ms" )
			H_ms.SetHasClass( "Inventory_Label_small2", true );
			H_ms.style.position = "350px 650px 1px";
			var ms = stats.equip_stats.movespeed + stats.skill_stats.range + 280
			H_ms.text = $.Localize("#Move_Speed") + " : "+ Number((ms).toFixed(0)) ;
			
			var H_dodge = $.CreatePanel( "Label", $("#menu_info_h"), "Hero_Info_dodge" )
			H_dodge.SetHasClass( "Inventory_Label_small2", true );
			H_dodge.style.position = "350px 675px 1px";
			var dodge = stats.equip_stats.dodge + stats.skill_stats.dodge
			H_dodge.text = $.Localize("#Dodge") + " : "+ Number((dodge).toFixed(2)) + "%";
			
			
			
			
			
			}
			
			
		}
	}
}

Object.size = function(obj) {
    var size = 0, key;
    for (key in obj) {
        if (obj.hasOwnProperty(key)) size++;
    }
    return size;
};

function display_info(item) {
	$("#Info").RemoveAndDeleteChildren()
	var Info_Panel = $.CreatePanel( "Label", $("#Info"), "Info_panel" )
	Info_Panel.SetHasClass( "Info_panel", true );
	var Exit = $.CreatePanel( "Button", Info_Panel, "Info_Item_exit" )
	Exit.SetHasClass( "Close", true );
	Exit.SetPanelEvent('onactivate',close_info)
	var Image = $.CreatePanel( "Image", Info_Panel, "Info_Item_Image" )
	Image.SetHasClass( "ItemImage", true );
	Image.style.position = "20px 20px 1px";
	Image.SetImage("file://{images}/custom_game/itemhud/"+item.item_name+ ".png")
	
	var Label_Name = $.CreatePanel( "Label", Info_Panel, "Info_Item_Name" )
	Label_Name.SetHasClass( "Inventory_Label_small", true );
	Label_Name.style.position = "80px 20px 1px";
	Label_Name.text = $.Localize("#"+item.Name)
	if (item.quality == "poor") {
	Label_Name.color = "#AAAAAA"
	}
	if (item.quality == "magic") {
	Label_Name.color = "#AAFFAA"
	}
	
	var Label_cat = $.CreatePanel( "Label", Info_Panel, "Info_Item_cat" )
	Label_cat.SetHasClass( "Inventory_Label_ve_small", true );
	Label_cat.style.position = "110px 45px 1px";
	Label_cat.text = $.Localize("#"+item.cat)
	var Label_price = $.CreatePanel( "Label", Info_Panel, "Info_Item_cat" )
	Label_price.SetHasClass( "Inventory_Label_ve_small", true );
	Label_price.style.position = "20px 90px 1px";
	Label_price.text =  item.price + " " + $.Localize("#Gold")
	if (item.cat == "weapon"){
		var Label_level = $.CreatePanel( "Label", Info_Panel, "Info_Item_level" )
		Label_level.SetHasClass( "Inventory_Label_small", true );
		Label_level.style.position = "115px 80px 1px";
		Label_level.text = $.Localize("#Level") + " : " + item.level
	}
	var pos_y = 120
	if (item.Equipement == true){
		if (item.cat == "weapon"){
			var Label_xp = $.CreatePanel( "Label", Info_Panel, "Info_Item_xp" )
			Label_xp.SetHasClass( "Inventory_Label_small", true );
			Label_xp.style.position = "10px "+ pos_y+"px 1px";
			pos_y = pos_y + 25
			
			Label_xp.text = "XP : " + item.XP + " / " + item.Next_Level_XP
		}
		if (typeof item.damage != 'undefined') {
			if (item.damage != 0) {
				var Label_dmg = $.CreatePanel( "Label", Info_Panel, "Info_Item_dmg" )
				Label_dmg.SetHasClass( "Inventory_Label_small", true );
				Label_dmg.style.position = "10px "+ pos_y+"px 1px";
				pos_y = pos_y + 25
				if (item.cat == "weapon"){
				Label_dmg.text = $.Localize("#Damage") + " : " + item.damage + " + ("+item.dmg_grow +")"
				}else{
				Label_dmg.text = $.Localize("#Damage") + " : " + item.damage
				}
			}
		}
		if (typeof item.attack_speed != 'undefined') {
			if (item.attack_speed != 0) {
				var Label_as = $.CreatePanel( "Label", Info_Panel, "Info_Item_as" )
				Label_as.SetHasClass( "Inventory_Label_small", true );
				Label_as.style.position = "10px "+ pos_y+"px 1px";
				pos_y = pos_y + 25
				if (item.cat == "weapon"){
					Label_as.text = $.Localize("#Attack_Speed") + " : " + item.attack_speed + " + ("+item.as_grow +")"
				}else{
					Label_as.text = $.Localize("#Attack_Speed") + " : " + item.attack_speed
				}
			}
		}
		if (typeof item.range != 'undefined') {
			if (item.range != 0) {
				var Label_range = $.CreatePanel( "Label", Info_Panel, "Info_Item_range" )
				Label_range.SetHasClass( "Inventory_Label_small", true );
				Label_range.style.position = "10px "+ pos_y+"px 1px";
				pos_y = pos_y + 25
				if (item.cat == "weapon"){
					Label_range.text = $.Localize("#Range") + " : " + item.range + " + ("+item.range_grow +")"
				}else{
					Label_range.text = $.Localize("#Range") + " : " + item.range
				}
			}
		}
		create_label(item.loh,$.Localize("#Life_on_Hit"),"")
		create_label(item.ls,$.Localize("#Life_Steal"),"%")
		create_label(item.hp,$.Localize("#Bonus_Health"),"")
		create_label(item.mp,$.Localize("#Bonus_Mana"),"")
		create_label(item.hp_regen,$.Localize("#HP_per_sec"),"")
		create_label(item.mp_regen,$.Localize("#MP_per_sec"),"")
		create_label(item.armor,$.Localize("#Armor"),"")
		create_label(item.m_ress,$.Localize("#Magic_Ress"),"%")
		create_label(item.movespeed,$.Localize("#Move_Speed"),"")
		create_label(item.upgrade_point,$.Localize("#Upgrade_slot"),$.Localize("#Available"))
		
		if (typeof item.effect != 'undefined') {
			if (item.effect != "") {
				var Label_effect = $.CreatePanel( "Label", Info_Panel, "Info_Item_effect" )
				Label_effect.SetHasClass( "Inventory_Label_small", true );
				Label_effect.style.position = "10px "+ pos_y+"px 1px";
				pos_y = pos_y + 25
				var effect = ""
				for (i = 1; i < (Object.size(item.effect)+1); i++){
					effect = effect + $.Localize(item.effect[i]) +" | "
				}
				Label_effect.text = $.Localize("#Effect")+ " : " + effect
			}
		}
		
	}
	
	create_label(item.heal,$.Localize("#Regen"),$.Localize("#Health"))
	create_label(item.heal_pct,$.Localize("#Regen"),"% " + $.Localize("#Health"))
	create_label(item.heal_mana_pct,$.Localize("#Regen"),"%" + $.Localize("#Mana") )
	create_label(item.heal_mana,$.Localize("#Regen"),$.Localize("#Mana") )
	create_label(item.duration,$.Localize("#Duration"),"")
	
	create_lore(item)
	
	function create_label(stat,stat_name,end){
		if (typeof stat != 'undefined') {
			if (stat != 0) {
				var Label = $.CreatePanel( "Label", Info_Panel, "Info_Item_"+stat_name )
				Label.SetHasClass( "Inventory_Label_small", true );
				Label.style.position = "10px "+ pos_y+"px 1px";
				pos_y = pos_y + 25
				Label.text = stat_name + " : " + Number((stat).toFixed(2)) + end
			}
		}
		
	}
	
	function create_lore(item){
		if (typeof item.lore != 'undefined') {
			if (stat != 0) {
				var Label = $.CreatePanel( "Label", Info_Panel, "Info_Item_lore" )
				Label.SetHasClass( "Inventory_Label_small", true );
				Label.style.position = "10px "+ pos_y+"px 1px";
				pos_y = pos_y + 25
				Label.text = $.Localize("#"+item.lore)
			}
		}
		
	}
}


function inv_key(){
 if ($("#item_panel_0") != null) {
	close_inventory()
 }else{
	Open_Inventory()
 }

}

function hero_key(){

 if ($("#item_hero_panel_1") != null) {
	close_hero()
 }else{
	Open_Hero_Panel()
 }

}


function close_hero() {
	$.Schedule(0.025,del_panel);
	function del_panel(){
		$("#equipement").RemoveAndDeleteChildren()
		$("#Menu_h").RemoveAndDeleteChildren()
		$("#Info").RemoveAndDeleteChildren()
	}
	$("#hero_panel").visible = false;
	$("#hero_but_label").text = "Hero"
	$("#hero_button").SetPanelEvent('onactivate',Open_Hero_Panel)
}

function close_inventory() {
	$.Schedule(0.025,del_panel);
	function del_panel(){
		$("#Items").RemoveAndDeleteChildren()
		$("#Menu").RemoveAndDeleteChildren()
		$("#Info").RemoveAndDeleteChildren()
	}
	$("#inv_panel").visible = false;
	$("#inv_but_label").text = "Inventory"
	$("#inventory_button").SetPanelEvent('onactivate',Open_Inventory)
}

function create_image_skill_bar (i){
				if (typeof inventory != 'undefined'){
					var CD = CustomNetTables.GetTableValue( "info", key).CD
					if (CD >0){
						$("#item_CD"+i.toString()).text = CD
					}else
					{
						$("#item_CD"+i.toString()).text = ""
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
						
						Item_Image.SetImage("file://{images}/custom_game/itemhud/"+item_name+ ".png")
						var Panel = Item_Image.GetParent()
						Panel.SetPanelEvent("onmouseover", function(){display_info(inventory.item_bar[i+1])});
						Panel.SetPanelEvent("onmouseout", function(){$("#Info").RemoveAndDeleteChildren()});	
						Panel.SetPanelEvent('oncontextmenu', (function(){
								GameEvents.SendCustomGameEventToServer( "Use_Item", { Slot : item_slot + 1,item_bar : true} );
								$("#Info").RemoveAndDeleteChildren()
								$("#menu_Items").RemoveAndDeleteChildren()
							}))
						Panel.SetPanelEvent('onactivate', (function(){
							var exit = $.CreatePanel("Button",$("#menu_Items"), "exit" );
							exit.SetHasClass( "Main", true );
							var Menu = $.CreatePanel( "Panel", Panel, "menu_"+item_slot.toString() );
							Menu.style.position = (GameUI.GetCursorPosition()[0]) +"px "+((GameUI.GetCursorPosition()[1])- 75)+"px 0px";
							Menu.SetHasClass( "Inventory_Menu", true );
							Menu.SetParent($("#menu_Items"))

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
							label_Use.text = "Use" 

							
							var label_to_inv = $.CreatePanel( "Label", to_inv, "label_to_inv_"+item_slot.toString() );
							label_to_inv.SetHasClass( "Inventory_Label_ve_small", true );
							label_to_inv.text= "to Inventory" 
							exit.SetPanelEvent('onactivate', (function(){
								$("#menu_Items").RemoveAndDeleteChildren()
							}))
							Use.SetPanelEvent('onactivate', (function(){
								GameEvents.SendCustomGameEventToServer( "Use_Item", { Slot : item_slot + 1,item_bar : true} );
								$("#Info").RemoveAndDeleteChildren()
								$("#menu_Items").RemoveAndDeleteChildren()
							}))
							to_inv.SetPanelEvent('onactivate', (function(){
								GameEvents.SendCustomGameEventToServer( "to_inventory", { Slot : item_slot + 1} );
								$("#Info").RemoveAndDeleteChildren()
								$("#menu_Items").RemoveAndDeleteChildren()
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
			
function create_skill_bar(){
	$.Schedule(0.055,Updateslot);
	function Updateslot()
	{
		$.Schedule(0.1, Updateslot);
		for (i = 0; i < 4; i++) {
			create_image_skill_bar (i)
		}
	}
	$.Schedule(0.1,create_keys_image);
	function create_keys_image(){
		var Keys = $.CreatePanel( "Panel", $("#item_main_bar"), "item_keys" );
		Keys.SetHasClass( "Keys_image", true );
		Keys.hittest = false
	}
	$.Schedule(0.05,create_panels);
	function create_panels(){
		 for (i = 0; i < 4; i++) {
			var Panel = $.CreatePanel( "Panel", $("#item_bar"), "item_panel_skill_"+i.toString() );
			Panel.SetHasClass( "ItemImage", true );
			var Item_Image = $.CreatePanel( "Image", Panel, "item_bar_image_"+i.toString() );
			Item_Image.SetHasClass( "ItemImage", true );
			var CD = $.CreatePanel( "Label", Panel, "item_CD"+i.toString() );
			CD.SetHasClass( "Inventory_CD", true );
			Button = $.CreatePanel( "Button", Panel, "item_slot_skill_"+i.toString() );
			Button.SetHasClass( "ItemButton", true );
			Panel.style.position = ( 6 + 97*i - i )+"px 5px 1px";
			var am = $.CreatePanel( "Label", Panel, "label_item_ammount_"+i.toString() );
			am.SetHasClass( "Inventory_Label", true );
		}

		var menu_Items = $.CreatePanel( "Panel", $("#Menu"), "menu_Items");
			menu_Items.SetHasClass( "menu_Items", true );
			menu_Items.hittest = false 
	}
}

