var inventory;
var stats;
var inshop = false;
var inforge = false;
var intrade = false;
var in_confirm = false;
var forge_panel;
var ID = Players.GetLocalPlayer()

$.Schedule(0.3,Updateinventory);

$("#inv_panel").visible = false;
$("#hero_panel").visible = false;
GameUI.CustomUIConfig().Events.SubscribeEvent( "open_inv", inv_key)

GameUI.CustomUIConfig().Events.SubscribeEvent( "open_hero", hero_key)


GameEvents.Subscribe( "start_trading", function(){intrade = true})
GameEvents.Subscribe( "stop_trading", function(){
intrade = false
in_confirm = false
})

GameUI.CustomUIConfig().Events.SubscribeEvent( "in_confirm", function(){in_confirm = true})
GameUI.CustomUIConfig().Events.SubscribeEvent( "out_confirm", function(){in_confirm = false})

GameUI.CustomUIConfig().Events.SubscribeEvent( "update_forge_panel", (function(a){
	forge_panel = a.selected_tab
	}))

	function Updateinventory()
	{


		$.Schedule(0.1, Updateinventory);
		CustomNetTables.SubscribeNetTableListener
		key = "player_" + ID.toString()
		inventory = CustomNetTables.GetTableValue( "inventory_player_"+ID,key)
		stats = CustomNetTables.GetTableValue( "stats", key)
		if (typeof CustomNetTables.GetTableValue( "info", key) != 'undefined')
		{
			inshop = CustomNetTables.GetTableValue( "info", key).inshop
			inforge = CustomNetTables.GetTableValue( "info", key).inforge
			if (inventory.size == 30){
				$("#Inventory_BG").style.clip = "rect( 0% ,100%, 75% ,0% )";
			}
		}
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


GameUI.CustomUIConfig().Events.SubscribeEvent( "display_info", (function(arg){display_info(arg.item)}))
GameUI.CustomUIConfig().Events.SubscribeEvent( "hide_info", (function(){$("#Info").RemoveAndDeleteChildren()}))
function create_image (i){
				if (typeof inventory != 'undefined'){
					if (typeof inventory.inventory[i+1] != 'undefined')
					{
						var item_slot = i
						var item_name = inventory.inventory[i+1].item_name
						var Item_Image = $("#item_image_"+i.toString())
						if (Item_Image != null) {
							if (inventory.inventory[i+1].Soul == 1){
							Item_Image.SetImage("file://{images}/custom_game/itemhud/"+item_name+"_"+ inventory.inventory[i+1].quality + ".png")
							}else{Item_Image.SetImage("file://{images}/custom_game/itemhud/"+item_name+".png")}
							var Panel = Item_Image.GetParent()
							var ammount = $("#label_item_inv_ammount_"+i.toString())
							if (inventory.inventory[i+1].ammount > 1){
								ammount.text = inventory.inventory[i+1].ammount
								ammount.hittest=false
							}else
							{
								ammount.text = ""
								ammount.hittest=false
							}
							if (inventory.inventory[i+1].cat == "weapon"){
							var label_level = $("#label_Level_"+i.toString())
								label_level.SetHasClass( "Inventory_Label_ve_small", true );
								label_level.text = $.Localize("#Level")+" : " + inventory.inventory[item_slot+1].level
								label_level.style.position = "0px 32px 1px";
								label_level.hittest=false
							}else
							{
								var label_level = $("#label_Level_"+i.toString())
								label_level.text = ""
								label_level.hittest=false
							}
							Panel.SetPanelEvent("onmouseover", function(){display_info(inventory.inventory[i+1])});
							Panel.SetPanelEvent("onmouseout", function(){$("#Info").RemoveAndDeleteChildren()});
							Panel.SetPanelEvent('oncontextmenu', (function(){
								if (inventory.inventory[i+1].Soul == 1){
									if (inforge == true && forge_panel == "infusion" ){
											GameUI.CustomUIConfig().Events.FireEvent( "to_forge_secondary", { Slot : item_slot + 1} );
									}
								}else{
									if(inventory.inventory[item_slot+1].cat != "consumable"){
										GameEvents.SendCustomGameEventToServer( "Use_Item", { Slot : item_slot + 1} );
										$("#Info").RemoveAndDeleteChildren()
										$("#menu_Items").RemoveAndDeleteChildren()
									}
								}
							}))
							Panel.SetPanelEvent('onactivate', (function(){
								//if (GameUI.IsAltDown() == true){ // link the item too other player (may ask sort of "item-chat")


								//} else
								if (intrade == true && in_confirm == false && GameUI.IsShiftDown() == true)
								{
									GameEvents.SendCustomGameEventToServer( "add_to_trade", { Slot : item_slot + 1,ammount : 1} );
								}else if (intrade == true && in_confirm == false && GameUI.IsControlDown() == true){
									GameEvents.SendCustomGameEventToServer( "add_to_trade", { Slot : item_slot + 1,ammount : 5} )
								}

								else if (inshop == true && GameUI.IsShiftDown() == true)
								{
									GameEvents.SendCustomGameEventToServer( "Sell_Item", { Slot : item_slot + 1,ammount : 1} )
								}else if (inshop == true && GameUI.IsControlDown() == true){
									GameEvents.SendCustomGameEventToServer( "Sell_Item", { Slot : item_slot + 1,ammount : 5} )
								}else if (inforge == true && GameUI.IsShiftDown() == true){
									if (inventory.inventory[item_slot+1].cat == "weapon"){
										GameUI.CustomUIConfig().Events.FireEvent( "to_forge_main", { Slot : item_slot + 1} );
									}else if (forge_panel == "infusion" && inventory.inventory[item_slot+1].Soul == 1){
												GameUI.CustomUIConfig().Events.FireEvent( "to_forge_secondary", { Slot : item_slot + 1} );
									}
								}else if (inforge == true && GameUI.IsControlDown() == true){
									if (forge_panel == "transmutation" && inventory.inventory[item_slot+1].cat == "weapon"){
												GameUI.CustomUIConfig().Events.FireEvent( "to_forge_secondary", { Slot : item_slot + 1} );
									}

								}else{
									var exit = $.CreatePanel("Button",$("#menu_Items"), "exit" );
									exit.SetHasClass( "Main", true );
									var Menu = $.CreatePanel( "Panel", $("#menu_Items"), "menu_"+item_slot.toString() );
									var pos_mouse = GameUI.GetCursorPosition()
									pos_mouse[0] = (pos_mouse[0])*screen_rat()[0]
									pos_mouse[1] = (pos_mouse[1])*screen_rat()[1]
									Menu.style.position = (GameUI.GetCursorPosition()[0]) +"px "+(GameUI.GetCursorPosition()[1])+"px 0px";
									Menu.SetHasClass( "Inventory_Menu", true );


									var Use = $.CreatePanel( "Button", Menu, "menu_use_"+item_slot.toString() );
									var position_Y = 0
									Use.style.position = "0px " +position_Y +"px 1px";
									position_Y = position_Y + 40
									Use.SetHasClass( "Inventory_Button", true );
									if (inventory.inventory[item_slot+1].cat == "consumable"){
										var Bar = $.CreatePanel( "Button", Menu, "menu_info_"+item_slot.toString() );
										Bar.SetHasClass( "Inventory_Button", true );
										Bar.style.position = "0px " +position_Y +"px 1px";
										position_Y = position_Y + 40
									}
									if (inshop == true )
									{
										var Sell = $.CreatePanel( "Button", Menu, "menu_sell_"+item_slot.toString() );
										Sell.style.position = "0px " +position_Y +"px 1px";
										position_Y = position_Y + 40
										Sell.SetHasClass( "Inventory_Button", true );

										var label_Sell = $.CreatePanel( "Label", Sell, "label_sell_"+item_slot.toString() );
										label_Sell.SetHasClass( "Inventory_Label", true );
										label_Sell.text = $.Localize("#sell")
									}
									if (intrade == true && in_confirm == false )
									{
										var Trade = $.CreatePanel( "Button", Menu, "menu_sell_"+item_slot.toString() );
										Trade.style.position = "0px " +position_Y +"px 1px";
										position_Y = position_Y + 40
										Trade.SetHasClass( "Inventory_Button", true );

										var label_Trade = $.CreatePanel( "Label", Trade, "label_sell_"+item_slot.toString() );
										label_Trade.SetHasClass( "Inventory_Label_small", true );
										label_Trade.text = $.Localize("#trade")

										Trade.SetPanelEvent('onactivate', (function(){
											if (inventory.inventory[i+1].ammount > 1){
												if (typeof Menu != "undefined"){
													Menu.DeleteAsync(0)
													if (typeof $("#submenu") != "undefined"){
														$("#submenu").DeleteAsync(0)
													}
												}
												var text_entry = $.CreatePanel( "TextEntry", $("#menu_Items"), "TextEntry");
												text_entry.style.position = (pos_mouse[0]+250) +"px "+pos_mouse[1]+"px 0px";
												text_entry.text = "Ammount (0 or negative = all)"
												text_entry.maxchars="20"
												text_entry.multiline = false;
												text_entry.SetHasClass( "Text_entry_place_holder", true );
												text_entry.SetPanelEvent('onfocus', (function(){
													text_entry.text = ""
													text_entry.SetHasClass( "Text_entry", true );
												}))
												text_entry.SetPanelEvent('oninputsubmit', (function(){
													GameEvents.SendCustomGameEventToServer( "add_to_trade", { Slot : item_slot + 1,ammount : text_entry.text} )
													$("#Info").RemoveAndDeleteChildren()
													$("#menu_Items").RemoveAndDeleteChildren()
												}))
											}else{
												GameEvents.SendCustomGameEventToServer( "add_to_trade", { Slot : item_slot + 1} );
												$("#Info").RemoveAndDeleteChildren()
												$("#menu_Items").RemoveAndDeleteChildren()
											}
										}))

									}
									if (inforge == true )
									{
										if (inventory.inventory[item_slot+1].Equipement == true){
											var reforge = $.CreatePanel( "Button", Menu, "reforge_"+item_slot.toString() );
											reforge.style.position = "0px " +position_Y +"px 1px";
											position_Y = position_Y + 40
											reforge.SetHasClass( "Inventory_Button", true );

											var label_reforge = $.CreatePanel( "Label", reforge, "label_reforge_"+item_slot.toString() );
											label_reforge.SetHasClass( "Inventory_Label", true );
											label_reforge.text = $.Localize("#reforge")
											}
										if (inventory.inventory[item_slot+1].cat == "weapon"){
											var to_forge = $.CreatePanel( "Button", Menu, "menu_sell_"+item_slot.toString() );
											to_forge.style.position = "0px " +position_Y +"px 1px";
											position_Y = position_Y + 40
											to_forge.SetHasClass( "Inventory_Button", true );

											var label_to_forge = $.CreatePanel( "Label", to_forge, "label_sell_"+item_slot.toString() );
											label_to_forge.SetHasClass( "Inventory_Label", true );
											label_to_forge.text = $.Localize("#add_weapon_1")
										}

										if (forge_panel == "infusion" ){
											if (inventory.inventory[item_slot+1].Soul == 1){
												var to_forge_2 = $.CreatePanel( "Button", Menu, "menu_sell_"+item_slot.toString() );
												to_forge_2.style.position = "0px " +position_Y +"px 1px";
												position_Y = position_Y + 40
												to_forge_2.SetHasClass( "Inventory_Button", true );

												var label_to_forge_2 = $.CreatePanel( "Label", to_forge_2, "label_sell_"+item_slot.toString() );
												label_to_forge_2.SetHasClass( "Inventory_Label", true );
												label_to_forge_2.text = $.Localize("#add_soul")
											}
										}
										if (forge_panel == "transmutation"){
											if (inventory.inventory[item_slot+1].cat == "weapon"){
												var to_forge_2 = $.CreatePanel( "Button", Menu, "menu_sell_"+item_slot.toString() );
												to_forge_2.style.position = "0px " +position_Y +"px 1px";
												position_Y = position_Y + 40
												to_forge_2.SetHasClass( "Inventory_Button", true );

												var label_to_forge_2 = $.CreatePanel( "Label", to_forge_2, "label_sell_"+item_slot.toString() );
												label_to_forge_2.SetHasClass( "Inventory_Label_small", true );
												label_to_forge_2.text = $.Localize("#add_weapon_2")
											}
										}
									}

									//var Unequip = $.CreatePanel( "Button", Menu, "menu_unequip_"+item_slot.toString() );
									//Unequip.SetHasClass( "Inventory_Button", true );
									//var label_Unequip = $.CreatePanel( "Label", Unequip, "label_unequip_"+item_slot.toString() );
									//Unequip.style.position = "0px " +position_Y +"px 1px";
									//position_Y = position_Y + 30

									var Drop = $.CreatePanel( "Button", Menu, "menu_Drop_"+item_slot.toString() );
									Drop.SetHasClass( "Inventory_Button", true );
									Drop.style.position = "0px " +position_Y +"px 1px";
									position_Y = position_Y + 40


									var label_Use = $.CreatePanel( "Label", Use, "label_use_"+item_slot.toString() );
									label_Use.SetHasClass( "Inventory_Label", true );
									if (typeof inventory.inventory[item_slot+1] != 'undefined')
									{
										if (inventory.inventory[item_slot+1].Equipement == true){
											label_Use.text = $.Localize("#Equip")
										}else{
											label_Use.text = $.Localize("#Use")
										}
									}

									var label_Drop = $.CreatePanel( "Label", Drop, "label_drop_"+item_slot.toString() );
									label_Drop.SetHasClass( "Inventory_Label", true );
									label_Drop.text= $.Localize("#Drop")
									if (inventory.inventory[item_slot+1].Equipement == 1 || inventory.inventory[item_slot+1].Soul == 1 ){
										label_Drop.text=$.Localize("#Destroy")
									}
									if (inventory.inventory[item_slot+1].cat == "consumable"){
										var label_Bar = $.CreatePanel( "Label", Bar, "label_info_"+item_slot.toString() );
										label_Bar.SetHasClass( "Inventory_Label", true );
										label_Bar.text=$.Localize("#to_item_bar")
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
											if (inventory.inventory[i+1].ammount > 1){
												if (typeof Menu != "undefined"){
													Menu.DeleteAsync(0)
													if (typeof $("#submenu") != "undefined"){
														$("#submenu").RemoveAndDeleteChildren()
														$("#submenu").DeleteAsync(0)
													}
												}
												var text_entry = $.CreatePanel( "TextEntry", $("#menu_Items"), "TextEntry");
												text_entry.style.position = (pos_mouse[0]+250) +"px "+pos_mouse[1]+"px 0px";
												text_entry.text = "Ammount (0 or negative = all)"
												text_entry.maxchars="20"
												text_entry.multiline = false;
												text_entry.SetHasClass( "Text_entry_place_holder", true );
												text_entry.SetPanelEvent('onfocus', (function(){
													text_entry.text = ""
													text_entry.SetHasClass( "Text_entry", true );
												}))
												text_entry.SetPanelEvent('oninputsubmit', (function(){
													GameEvents.SendCustomGameEventToServer( "Sell_Item", { Slot : item_slot + 1,ammount : text_entry.text} )
													$("#Info").RemoveAndDeleteChildren()
													$("#menu_Items").RemoveAndDeleteChildren()
												}))
											}else{
												GameEvents.SendCustomGameEventToServer( "Sell_Item", { Slot : item_slot + 1} );
												$("#Info").RemoveAndDeleteChildren()
												$("#menu_Items").RemoveAndDeleteChildren()
											}
										}))
									}
									if (inforge == true){
											if (inventory.inventory[item_slot+1].Equipement == true){

												reforge.SetPanelEvent('onactivate', (function(){
													$("#Info").RemoveAndDeleteChildren()
													$("#menu_Items").RemoveAndDeleteChildren()
													GameEvents.SendCustomGameEventToServer( "reforge", { Slot : item_slot + 1} );
												}))

											}
											if (inventory.inventory[item_slot+1].cat == "weapon"){
												to_forge.SetPanelEvent('onactivate', (function(){
												$("#Info").RemoveAndDeleteChildren()
													$("#menu_Items").RemoveAndDeleteChildren()
												GameUI.CustomUIConfig().Events.FireEvent( "to_forge_main", { Slot : item_slot + 1} );
											}))
											}

											if (forge_panel == "infusion" ){
												if (inventory.inventory[item_slot+1].Soul == 1){
													to_forge_2.SetPanelEvent('onactivate', (function(){
													$("#Info").RemoveAndDeleteChildren()
													$("#menu_Items").RemoveAndDeleteChildren()
													GameUI.CustomUIConfig().Events.FireEvent( "to_forge_secondary", { Slot : item_slot + 1} );

												}))
												}
											}
											if (forge_panel == "transmutation"){
												if (inventory.inventory[item_slot+1].cat == "weapon"){
													to_forge_2.SetPanelEvent('onactivate', (function(){
													$("#Info").RemoveAndDeleteChildren()
													$("#menu_Items").RemoveAndDeleteChildren()
													GameUI.CustomUIConfig().Events.FireEvent( "to_forge_secondary", { Slot : item_slot + 1} );

												}))
												}
											}
									}
									Drop.SetPanelEvent('onactivate', (function(){
										label_Drop.text = $.Localize("#confirm")
											Drop.SetPanelEvent('onactivate', (function(){

											GameEvents.SendCustomGameEventToServer( "Drop_Item", { Slot : item_slot + 1} );
											$("#Info").RemoveAndDeleteChildren()
											$("#menu_Items").RemoveAndDeleteChildren()
										}))

									}))

									if (inventory.inventory[item_slot+1].cat == "consumable"){
										Bar.SetPanelEvent('onmouseover', (function(){
											if ($("#submenu") == null ){
											var SubMenu = $.CreatePanel( "Panel", $("#menu_Items"), "submenu");
												SubMenu.style.position = (pos_mouse[0]-200) +"px "+pos_mouse[1]+"px 0px";
												SubMenu.SetHasClass( "Inventory_Menu", true );

												var sub_position_Y = 0
											for (j = 0; j < 4; j++){
												var Slot = $.CreatePanel( "Button", SubMenu, "menu_use_"+j );
												Slot.style.position = "0px " +sub_position_Y +"px 1px";
												sub_position_Y = sub_position_Y + 39
												Slot.SetHasClass( "Inventory_Button", true );

												var label_Slot = $.CreatePanel( "Label", Slot, "label_drop_"+j );
												label_Slot.SetHasClass( "Inventory_Label", true );
												label_Slot.text= $.Localize("#Slot")+ (j + 1)
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
								}


							})	)
							}

					}else{
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
Game.AddCommand( "+Open_Inventory", inv_key, "", 0 );
Game.AddCommand( "+Open_Hero_Panel", hero_key, "", 0 );
Game.AddCommand( "+Close_ALL", CLOSE_ALL, "", 0 );
function useitem(slot){
	GameEvents.SendCustomGameEventToServer( "Use_Item", { Slot : slot,item_bar : true} )
}
Game.AddCommand( "+item_1", function(){useitem(1)}, "", 0 );
Game.AddCommand( "+item_2", function(){useitem(2)}, "", 0 );
Game.AddCommand( "+item_3", function(){useitem(3)}, "", 0 );
Game.AddCommand( "+item_4", function(){useitem(4)}, "", 0 );
}
function close_info(){
$("#Info").RemoveAndDeleteChildren()
}

function create_hero_panel_image(i){
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
							Panel.SetPanelEvent("onmouseover", function(){display_info(item)});
							Panel.SetPanelEvent("onmouseout", function(){$("#Info").RemoveAndDeleteChildren()});
							Panel.SetPanelEvent('oncontextmenu', (function(){
									GameEvents.SendCustomGameEventToServer( "Unequip_Item", { Slot : item_slot} );
								}))

							if (inforge == true )
							{
								if (item.cat == "weapon"){
									if (forge_panel == "infusion"||forge_panel == "transmutation"||forge_panel == "evolution" ){
										Panel.SetPanelEvent('oncontextmenu', (function(){
											GameUI.CustomUIConfig().Events.FireEvent( "to_upgrade", {} );
										}))
									}
								}
							}

							Panel.SetPanelEvent('onactivate', (function(){
									var exit = $.CreatePanel("Button",$("#Menu"), "exit" );
									exit.SetHasClass( "Main", true );
									exit.SetPanelEvent('onactivate', (function(){
										$("#Info").RemoveAndDeleteChildren()
										Menu.DeleteAsync(0)
										exit.DeleteAsync(0)

									}))

									var Menu = $.CreatePanel( "Panel", $("#Menu"), "menu_equipement" );
									Menu.style.position = (GameUI.GetCursorPosition()[0]) +"px "+((GameUI.GetCursorPosition()[1])- 75)+"px 0px";
									Menu.SetHasClass( "Inventory_Menu", true );

									var Unequip = $.CreatePanel( "Button", Menu, "menu_unequip");
									var position_Y = 0
									Unequip.style.position = "0px " +position_Y +"px 1px";
									position_Y = position_Y + 30
									Unequip.SetHasClass( "Inventory_Button", true );

									if (inforge == true )
									{
										if (item.cat == "weapon"){
											if (forge_panel == "infusion"||forge_panel == "transmutation"||forge_panel == "evolution" ){
												var to_up = $.CreatePanel( "Button", Menu, "menu_to_up" );
												to_up.SetHasClass( "Inventory_Button", true );
												to_up.style.position = "0px " +position_Y +"px 1px";
												position_Y = position_Y + 30
												Menu.height = position_Y
											}
										}
										var reforge = $.CreatePanel( "Button", Menu, "menu_reforge" );
										reforge.SetHasClass( "Inventory_Button", true );
										reforge.style.position = "0px " +position_Y +"px 1px";
										position_Y = position_Y + 30
										Menu.height = position_Y
									}


									var label_Unequip = $.CreatePanel( "Label", Unequip, "label_unequip" );
									label_Unequip.SetHasClass( "Inventory_Label", true );
									label_Unequip.text = $.Localize("#Unequip")


									if (inforge == true )
									{
										if (item.cat == "weapon"){
											if (forge_panel == "infusion"||forge_panel == "transmutation"||forge_panel == "evolution" ){
												var label_to_up = $.CreatePanel( "Label", to_up, "label_to_up");
												label_to_up.SetHasClass( "Inventory_Label", true );
												label_to_up.text = $.Localize("#add_weapon_1")
											}
										}
										var label_reforge = $.CreatePanel( "Label", reforge, "label_reforge");
										label_reforge.SetHasClass( "Inventory_Label", true );
										label_reforge.text = $.Localize("#Reforge")
									}


									Unequip.SetPanelEvent('onactivate', (function(){
										GameEvents.SendCustomGameEventToServer( "Unequip_Item", { Slot : item_slot} );
										$("#Info").RemoveAndDeleteChildren()
										Menu.DeleteAsync(0)
										exit.DeleteAsync(0)

									}))
									if (inforge == true )
									{
										if (item.cat == "weapon"){
											if (forge_panel == "infusion"||forge_panel == "transmutation"||forge_panel == "evolution" ){
												to_up.SetPanelEvent('onactivate', (function(){
													GameUI.CustomUIConfig().Events.FireEvent( "to_upgrade", {} );
													$("#Info").RemoveAndDeleteChildren()
													Menu.DeleteAsync(0)
													exit.DeleteAsync(0)
												}))
											}
										}
										reforge.SetPanelEvent('onactivate', (function(){
													GameEvents.SendCustomGameEventToServer( "reforge_equipement", { Slot : item_slot } );
													$("#Info").RemoveAndDeleteChildren()
													Menu.DeleteAsync(0)
													exit.DeleteAsync(0)
												}))
									}





						})	)
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

	$.Schedule(0.055,Updateslot_panel);
	function Updateslot_panel()
	{
		if ($("#hero_panel").visible) {
			$.Schedule(0.1, Updateslot_panel);
		}
		for (i = 0; i <= 7; i++ ){
			create_hero_panel_image(i)
		}
	}

	 $.Schedule(0.05,create_panels_hero);
	 function create_panels_hero(){
		 for (i = 0; i <= 7; i++) {
			var Panel = $.CreatePanel( "Panel", $("#equipement"), "item_hero_panel_"+i.toString() );
			Panel.SetHasClass( "ItemImage", true );
			var Item_Image = $.CreatePanel( "Image", Panel, "item_hero_image_"+i.toString() );
			Item_Image.SetHasClass( "ItemImage", true );
			Button = $.CreatePanel( "Button", Panel, "item_hero_slot_"+i.toString() );
			Button.SetHasClass( "ItemButton", true );
			$.CreatePanel( "Label", Panel, "label_hero_Level_"+i.toString() );
			//0 = weapon , 1 = chest armor , 2 = legs armor , 3 = helmet , 4 = gloves , 5 = boots ,6 = necklace, 7 = wings
			if (i == 0 ){
				Panel.style.position = "62px 219px 1px";
			}
			if (i == 1 ){
				Panel.style.position = "162px 144px 1px";
			}
			if (i == 2 ){
				Panel.style.position = "162px 233px 1px";
			}
			if (i == 3 ){
				Panel.style.position = "162px 68px 1px";
			}
			if (i == 4 ){
				Panel.style.position = "254px 242px 1px";
			}
			if (i == 5 ){
				Panel.style.position = "119px 363px 1px";
			}
			if (i == 6 ){
				Panel.style.position = "62px 68px 1px";
			}
			if (i == 7 ){
				Panel.style.position = "274px 68px 1px";
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

Object.size = function(obj) {
    var size = 0, key;
    for (key in obj) {
        if (obj.hasOwnProperty(key)) size++;
    }
    return size;
}

function display_info(item) {
	$("#Info").RemoveAndDeleteChildren()
	var Info_Panel = $.CreatePanel( "Label", $("#Info"), "Info_panel" )
	Info_Panel.SetHasClass( "Info_panel", true );
	Info_Panel.hittest = false
	var Image = $.CreatePanel( "Image", Info_Panel, "Info_Item_Image" )
	Image.SetHasClass( "ItemImage", true );
	Image.style.position = "20px 20px 1px";
	Image.hittest = false
	var item_compare = null
	if (item.Equipement == true) {
		if (item.cat == "weapon"){
			item_compare = inventory.equipement.weapon
		}
		if (item.cat == "chest"){
			item_compare = inventory.equipement.chest_armor
		}
		if (item.cat == "legs"){
			item_compare = inventory.equipement.legs_armor
		}
		if (item.cat == "helmet"){
			item_compare = inventory.equipement.helmet
		}
		if (item.cat == "gloves"){
			item_compare = inventory.equipement.gloves
		}
		if (item.cat == "boots"){
			item_compare = inventory.equipement.boots
		}
	}

	if (item.Soul == 1){
		Image.SetImage("file://{images}/custom_game/itemhud/"+item.item_name+"_"+item.quality+".png")
		}
	else
		{
		Image.SetImage("file://{images}/custom_game/itemhud/"+item.item_name+ ".png")
		}

	var Label_Name = $.CreatePanel( "Label", Info_Panel, "Info_Item_Name" )
	Label_Name.SetHasClass( "Inventory_Label_small", true );
	Label_Name.style.position = "80px 20px 1px";
	if (typeof item.qualifier != "undefined"){
		Label_Name.text =$.Localize("#"+item.qualifier) + " " + $.Localize("#"+item.item_name)
	}
	else{
		Label_Name.text = $.Localize("#"+item.item_name)
	}
	Label_Name.hittest = false
	if (item.quality == "Poor") {
		Label_Name.style.color = "#888888"
	}
	if (item.quality == "Normal") {
		Label_Name.style.color = "#CCCCCC"
	}
	if (item.quality == "Superior") {
		Label_Name.style.color = "#FFFFFF"
	}
	if (item.quality == "Magic") {
	Label_Name.style.color = "#22ef00"
	}
	if (item.quality == "Rare") {
	Label_Name.style.color = "#ffe400"
	}
	if (item.quality == "Unique") {
	Label_Name.style.color = "#ff7800"
	}
	if (item.quality == "Epic") {
	Label_Name.style.color = "#0084ff"
	}
	if (item.quality == "Mystical") {
	Label_Name.style.color = "#0600ff"
	}
	if (item.quality == "Legendary") {
	Label_Name.style.color = "#5a00ff"
	}
	if (item.quality == "Mythical") {
	Label_Name.style.color = "#ff0000"
	}
	if (item.quality == "Godlike") {
	Label_Name.style.color = "#00ffa2"
	}

	var Label_cat = $.CreatePanel( "Label", Info_Panel, "Info_Item_cat" )
	Label_cat.SetHasClass( "Inventory_Label_ve_small", true );
	Label_cat.style.position = "110px 45px 1px";
	Label_cat.text = $.Localize("#"+item.cat)
	Label_cat.hittest = false
	var Label_price = $.CreatePanel( "Label", Info_Panel, "Info_Item_cat" )
	Label_price.SetHasClass( "Inventory_Label_ve_small", true );
	Label_price.style.position = "20px 90px 1px";
	Label_price.text =  item.price + " " + $.Localize("#Gold")
	Label_price.hittest = false
	if (item.cat == "weapon"){
		var Label_level = $.CreatePanel( "Label", Info_Panel, "Info_Item_level" )
		Label_level.SetHasClass( "Inventory_Label_small", true );
		Label_level.style.position = "115px 80px 1px";
		Label_level.text = $.Localize("#Level") + " : " + item.level
		Label_level.hittest = false
	}
	var pos_y = 120
	if (item.Equipement == true || item.Soul == 1){
		if (typeof item.Ilevel != "undefined"){
			var Label_I_level = $.CreatePanel( "Label", Info_Panel, "Info_Item_dmg" )
				Label_I_level.SetHasClass( "Inventory_Label_small", true );
				Label_I_level.style.position = "10px "+ pos_y+"px 1px";
				pos_y = pos_y + 25
				Label_I_level.text = $.Localize("#I_Level") + " : " + item.Ilevel
				if (item_compare != null){
					if (item_compare.Ilevel < item.Ilevel){
						Label_I_level.style.color = "#CCffCC"
						Label_I_level.text = Label_I_level.text + " ↑"
					}
					if (item_compare.Ilevel > item.Ilevel){
						Label_I_level.style.color = "#ffCCCC"
						Label_I_level.text = Label_I_level.text + " ↓"
					}
				}
				Label_I_level.hittest = false
		}
		if (item.cat == "weapon"){
			if (item.level >0) {
				var Label_xp = $.CreatePanel( "Label", Info_Panel, "Info_Item_xp" )
				Label_xp.SetHasClass( "Inventory_Label_small", true );
				Label_xp.style.position = "10px "+ pos_y+"px 1px";
				pos_y = pos_y + 25

				Label_xp.text = "XP : " + item.XP + " / " + item.Next_Level_XP
				Label_xp.hittest = false
			}
		}
		if (typeof item.damage != 'undefined') {
			if (item.damage != 0 || item.bonus_damage != 0 || item.upgrade_damage != 0 || item.bonus_damage != 'undefined'  || item.upgrade_damage != 'undefined' ) {
				var Label_dmg = $.CreatePanel( "Label", Info_Panel, "Info_Item_dmg" )
				Label_dmg.SetHasClass( "Inventory_Label_small", true );
				Label_dmg.style.position = "10px "+ pos_y+"px 1px";
				pos_y = pos_y + 25
				if (typeof item.bonus_damage == 'undefined'){item.bonus_damage = 0}
				if (typeof item.damage == 'undefined'){item.damage = 0}
				if (typeof item.upgrade_damage == 'undefined'){item.upgrade_damage = 0}
				var damage = (item.bonus_damage+item.damage) + item.upgrade_damage
				if (item_compare != null){
					if (typeof item_compare.bonus_damage == 'undefined'){item_compare.bonus_damage = 0}
					if (typeof item_compare.damage == 'undefined'){item_compare.damage = 0}
					if (typeof item_compare.upgrade_damage == 'undefined'){item_compare.upgrade_damage = 0}
					var compare_dmg = (item_compare.bonus_damage+item_compare.damage) + item_compare.upgrade_damage
				}
				if (item.cat == "weapon"&& item.level >0){
				Label_dmg.text = $.Localize("#Damage") + " : " + (item.bonus_damage+item.damage) + " + ("+item.upgrade_damage+")"
				}else{
				Label_dmg.text = $.Localize("#Damage") + " : " + item.damage
				}
				if (item_compare != null){
					if (compare_dmg < damage){
						Label_dmg.style.color = "#CCffCC"
						Label_dmg.text = Label_dmg.text + " ↑"
					}
					if (compare_dmg > damage){
						Label_dmg.style.color = "#ffCCCC"
						Label_dmg.text = Label_dmg.text + " ↓"
					}
				}
				Label_dmg.hittest = false
			}
		}
		if (typeof item.m_damage != 'undefined') {
			if (item.m_damage != 0 || item.bonus_m_damage != 0 || item.upgrade_m_damage != 0 || item.bonus_m_damage != 'undefined'  || item.upgrade_m_damage != 'undefined' ) {
				var Label_mdmg = $.CreatePanel( "Label", Info_Panel, "Info_Item_dmg" )
				Label_mdmg.SetHasClass( "Inventory_Label_small", true );
				Label_mdmg.style.position = "10px "+ pos_y+"px 1px";
				pos_y = pos_y + 25
				if (typeof item.bonus_m_damage == 'undefined'){item.bonus_m_damage = 0}
				if (typeof item.m_damage == 'undefined'){item.m_damage = 0}
				if (typeof item.upgrade_m_damage == 'undefined'){item.upgrade_m_damage = 0}
				var damage = (item.bonus_m_damage+item.m_damage) + item.upgrade_m_damage
				if (item_compare != null){
					if (typeof item_compare.bonus_m_damage == 'undefined'){item_compare.bonus_m_damage = 0}
					if (typeof item_compare.m_damage == 'undefined'){item_compare.m_damage = 0}
					if (typeof item_compare.upgrade_m_damage == 'undefined'){item_compare.upgrade_m_damage = 0}
					var compare_dmg = (item_compare.bonus_m_damage+item_compare.m_damage) + item_compare.upgrade_m_damage
				}
				if (item.cat == "weapon"&& item.level >0){
					Label_mdmg.text = $.Localize("#M_Damage") + " : " + (item.bonus_m_damage+item.m_damage)+ " + ("+item.upgrade_m_damage+")"
				}else{
					Label_mdmg.text = $.Localize("#M_Damage") + " : " + item.m_damage
				}
				if (item_compare != null){
					if (compare_dmg < damage){
						Label_mdmg.style.color = "#CCffCC"
						Label_mdmg.text = Label_mdmg.text + " ↑"
					}
					if (compare_dmg > damage){
						Label_mdmg.style.color = "#ffCCCC"
						Label_mdmg.text = Label_mdmg.text + " ↓"
					}
				}
				Label_mdmg.hittest = false
			}
		}
		if (typeof item.attack_speed != 'undefined') {
			if (item.attack_speed != 0 || item.bonus_attack_speed != 0 || item.upgrade_attack_speed != 0 || item.bonus_attack_speed != 'undefined'  || item.upgrade_attack_speed != 'undefined' ) {
				var Label_as = $.CreatePanel( "Label", Info_Panel, "Info_Item_as" )
				Label_as.SetHasClass( "Inventory_Label_small", true );
				Label_as.style.position = "10px "+ pos_y+"px 1px";
				pos_y = pos_y + 25
				if (typeof item.bonus_attack_speed == 'undefined'){item.bonus_attack_speed = 0}
				if (typeof item.attack_speed == 'undefined'){item.attack_speed = 0}
				if (typeof item.upgrade_attack_speed == 'undefined'){item.upgrade_attack_speed = 0}
				var as = (item.bonus_attack_speed+item.attack_speed) + item.upgrade_attack_speed
				if (item_compare != null){
					if (typeof item_compare.bonus_attack_speed == 'undefined'){item_compare.bonus_attack_speed = 0}
					if (typeof item_compare.attack_speed == 'undefined'){item_compare.attack_speed = 0}
					if (typeof item_compare.upgrade_attack_speed == 'undefined'){item_compare.upgrade_attack_speed = 0}
					var c_as = (item_compare.bonus_attack_speed+item_compare.attack_speed) + item_compare.upgrade_attack_speed
				}

				if (item.cat == "weapon"&& item.level >0){
					Label_as.text = $.Localize("#Attack_Speed") + " : " + (item.bonus_attack_speed+item.attack_speed) + " + ("+item.upgrade_attack_speed+")"
				}else{
					Label_as.text = $.Localize("#Attack_Speed") + " : " + item.attack_speed
				}
				if (item_compare != null){
					if (c_as < as){
						Label_as.style.color = "#CCffCC"
						Label_as.text = Label_as.text + " ↑"
					}
					if (c_as > as){
						Label_as.style.color = "#ffCCCC"
						Label_as.text = Label_as.text + " ↓"
					}
				}
				Label_as.hittest = false
			}
		}
		if (typeof item.range != 'undefined') {
			if (item.range != 0 || item.bonus_range != 0 || item.upgrade_range != 0 || item.upgrade_range != 'undefined'  || item.bonus_range != 'undefined' ) {
				var Label_range = $.CreatePanel( "Label", Info_Panel, "Info_Item_range" )
				Label_range.SetHasClass( "Inventory_Label_small", true );
				Label_range.style.position = "10px "+ pos_y+"px 1px";
				pos_y = pos_y + 25
				if (typeof item.bonus_range == 'undefined'){item.bonus_range = 0}
				if (typeof item.range == 'undefined'){item.range = 0}
				if (typeof item.upgrade_range == 'undefined'){item.upgrade_range = 0}
				var range = (item.bonus_range+item.range) + item.upgrade_range
				if (item_compare != null){
					if (typeof item_compare.bonus_range == 'undefined'){item_compare.bonus_range = 0}
					if (typeof item_compare.range == 'undefined'){item_compare.range = 0}
					if (typeof item_compare.upgrade_range == 'undefined'){item_compare.upgrade_range = 0}
					var c_range = (item_compare.bonus_range+item_compare.range) + item_compare.upgrade_range
				}
				if (item.cat == "weapon"&& item.level >0){
					Label_range.text = $.Localize("#Range") + " : " + (item.bonus_range+item.range) + " + ("+item.upgrade_range +")"
				}else{
					Label_range.text = $.Localize("#Range") + " : " + item.range
				}
				if (item_compare != null){
					if (c_range < range){
						Label_range.style.color = "#CCffCC"
						Label_range.text = Label_range.text + " ↑"
					}
					if (c_range > range){
						Label_range.style.color = "#ffCCCC"
						Label_range.text = Label_range.text + " ↓"
					}
				}
				Label_range.hittest = false
			}
		}

		if (typeof item.loh != 'undefined') {
			if (item.loh != 0 || item.bonus_loh != 0 || item.bonus_loh != 'undefined' || item.upgrade_loh != 0 || item.upgrade_loh != 'undefined' ) {
				var Label_loh = $.CreatePanel( "Label", Info_Panel, "Info_Item_range" )
				Label_loh.SetHasClass( "Inventory_Label_small", true );
				Label_loh.style.position = "10px "+ pos_y+"px 1px";
				pos_y = pos_y + 25
				if (typeof item.bonus_loh == 'undefined'){item.bonus_loh = 0}
				if (typeof item.loh == 'undefined'){item.loh = 0}
				if (typeof item.upgrade_loh == 'undefined'){item.upgrade_loh = 0}
				var loh = (item.bonus_loh+item.loh) + item.upgrade_loh
				if (item_compare != null){
					if (typeof item_compare.bonus_loh == 'undefined'){item_compare.bonus_loh = 0}
					if (typeof item_compare.loh == 'undefined'){item_compare.loh = 0}
					if (typeof item_compare.upgrade_loh == 'undefined'){item_compare.upgrade_loh = 0}
					var c_loh = (item_compare.bonus_loh+item_compare.loh) + item_compare.upgrade_loh
				}
				if (item.cat == "weapon"&& item.level >0){
					Label_loh.text = $.Localize("#Life_on_Hit") + " : " + (item.bonus_loh+item.loh) + " + ("+item.upgrade_loh +")"
				}else{
					Label_loh.text = $.Localize("#Life_on_Hit") + " : " + item.loh
				}
				if (item_compare != null){
					if (c_loh < loh){
						Label_loh.style.color = "#CCffCC"
						Label_loh.text = Label_loh.text + " ↑"
					}
					if (c_loh > loh){
						Label_loh.style.color = "#ffCCCC"
						Label_loh.text = Label_loh.text + " ↓"
					}
				}
				Label_loh.hittest = false
			}
		}

		if (typeof item.ls != 'undefined') {
			if (item.ls != 0 || item.bonus_ls != 0 || item.upgrade_ls != 0 || item.bonus_ls != 'undefined'  || item.upgrade_ls != 'undefined' ) {
				var ls_label = $.CreatePanel( "Label", Info_Panel, "Info_Item_range" )
				ls_label.SetHasClass( "Inventory_Label_small", true );
				ls_label.style.position = "10px "+ pos_y+"px 1px";
				pos_y = pos_y + 25
				if (typeof item.bonus_ls == 'undefined'){item.bonus_ls = 0}
				if (typeof item.ls == 'undefined'){item.ls = 0}
				if (typeof item.upgrade_ls == 'undefined'){item.upgrade_ls = 0}
				var ls = (item.bonus_ls+item.ls) + item.upgrade_ls
				if (item_compare != null){
					if (typeof item_compare.bonus_ls == 'undefined'){item_compare.bonus_ls = 0}
					if (typeof item_compare.ls == 'undefined'){item_compare.ls = 0}
					if (typeof item_compare.upgrade_ls == 'undefined'){item_compare.upgrade_ls = 0}
					var c_ls = (item_compare.bonus_ls+item_compare.ls) + item_compare.upgrade_ls
				}
				if (item.cat == "weapon"&& item.level >0){
					ls_label.text = $.Localize("#Life_Steal") + " : " + Number((item.bonus_ls+item.ls).toFixed(2))  + "% + ("+Number((item.upgrade_ls).toFixed(2))+"% )"
				}else{
					ls_label.text = $.Localize("#Life_Steal") + " : " + Number((item.ls).toFixed(2)) + "%"
				}
				if (item_compare != null){
					if (c_ls < ls){
						ls_label.style.color = "#CCffCC"
						ls_label.text = ls_label.text + " ↑"
					}
					if (c_ls > ls){
						ls_label.style.color = "#ffCCCC"
						ls_label.text = ls_label.text + " ↓"
					}
				}
				ls_label.hittest = false

			}
		}

		if (typeof item.hp != 'undefined') {
			if (item.hp != 0 || item.bonus_ls != 0 || item.upgrade_ls != 0 || item.bonus_ls != 'undefined'  || item.upgrade_ls != 'undefined' ) {
				var hp = $.CreatePanel( "Label", Info_Panel, "Info_Item_range" )
				hp.SetHasClass( "Inventory_Label_small", true );
				hp.style.position = "10px "+ pos_y+"px 1px";
				pos_y = pos_y + 25
				if (typeof item.hp == 'undefined'){item.hp = 0}
				hp.text = $.Localize("#Bonus_Health") + " : " + Number((item.hp*Math.log10(stats.hero_stats.str + stats.skill_stats.str+ stats.equip_stats.str + 10)).toFixed(1))
				if (item_compare != null){
					if (item_compare.hp < item.hp){
						hp.style.color = "#CCffCC"
						hp.text = hp.text + " ↑"
					}
					if (item_compare.hp > item.hp){
						hp.style.color = "#ffCCCC"
						hp.text = hp.text + " ↓"
					}
				}
				hp.hittest = false

			}
		}

		create_label(item.mp,$.Localize("#Bonus_Mana"),"")
		create_label(item.hp_regen,$.Localize("#HP_per_sec"),"")
		create_label(item.mp_regen,$.Localize("#MP_per_sec"),"")
		create_label(item.armor,$.Localize("#Armor"),"")
		create_label(item.m_ress,$.Localize("#Magic_Ress"),"%")
		create_label(item.movespeed,$.Localize("#Move_Speed"),"")
		create_label(item.str,$.Localize("#Bonus_Strength"),"")
		create_label(item.agi,$.Localize("#Bonus_Agility"),"")
		create_label(item.int,$.Localize("#Bonus_Inteligence"),"")
		create_label(item.upgrade_point,$.Localize("#Upgrade_slot")," " + $.Localize("#Available"))
		pos_y = pos_y + 50

	}

	create_label(item.heal,$.Localize("#Regen"),$.Localize("#Health"))
	create_label(item.heal_pct,$.Localize("#Regen"),"% " + $.Localize("#Health"))
	create_label(item.heal_mana_pct,$.Localize("#Regen"),"% " + $.Localize("#Mana") )
	create_label(item.heal_mana,$.Localize("#Regen"),$.Localize("#Mana") )
	create_label(item.duration,$.Localize("#Duration"),"")

	create_lore(item)
	if (typeof item.effect != 'undefined') {
			if ((Object.size(item.effect))>=1) {
				for (j = 1; j < Object.size(item.effect)+1; j++){
					var Label_effect = $.CreatePanel( "Label", Info_Panel, "Info_Item_effect" )
					Label_effect.SetHasClass( "Inventory_Label_small", true );
					Label_effect.style.position = "-10px "+ pos_y+"px 1px";
					pos_y = pos_y + 90
					Label_effect.hittest = false
					Label_effect.text = $.Localize("#Effect")+ " : " + $.Localize("#" + item.effect[j]) +" | " + $.Localize("#" + item.effect[j] + "_desc")
				}
			}
		}

	function create_label(stat,stat_name,end){
		if (typeof stat != 'undefined') {
			if (stat != 0) {
				var Label = $.CreatePanel( "Label", Info_Panel, "Info_Item_"+stat_name )
				Label.SetHasClass( "Inventory_Label_small", true );
				Label.style.position = "10px "+ pos_y+"px 1px";
				pos_y = pos_y + 30
				if (Players.HasCustomGameTicketForPlayerID( ID ) == true) {
					Label.text = stat_name + " : " + Number((stat*1.1).toFixed(2)) + " " + end
				}
				else{
					Label.text = stat_name + " : " + Number((stat).toFixed(2)) + " " + end
				}
				if (item_compare != null){
					if (item_compare.stat < item.stat){
						Label.style.color = "#00ff22"
						Label.text = Label.text + " ↑"
					}
					if (item_compare.stat > item.stat){
						Label.style.color = "#ff0022"
						Label.text = Label.text + " ↓"
					}
				}
				Label.hittest = false
			}
		}

	}

	function create_lore(item){
				var Label = $.CreatePanel( "Label", Info_Panel, "Info_Item_lore" )
				Label.SetHasClass( "Inventory_Label_small", true );
				Label.style.position = "-10px "+ pos_y+"px 1px";
				pos_y = pos_y + 120
				Label.text = $.Localize("#"+item.item_name+"_desc")
				Label.hittest = false

	}
}

Object.size = function(obj) {
    var size = 0, key;
    for (key in obj) {
        if (obj.hasOwnProperty(key)) size++;
    }
    return size;
};

function inv_key(){
 if ($("#item_panel_0") != null) {
	close_inventory()
 }else{
	Open_Inventory()
 }

}

GameUI.CustomUIConfig().Events.SubscribeEvent( "CLOSE_ALL", CLOSE_ALL)

function CLOSE_ALL(){

 if ($("#item_hero_panel_1") != null) {
	close_hero()
 }
 if ($("#item_panel_0") != null) {
	close_inventory()
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
}

function close_inventory() {
	$.Schedule(0.025,del_panel);
	function del_panel(){
		$("#Items").RemoveAndDeleteChildren()
		$("#Menu").RemoveAndDeleteChildren()
		$("#Info").RemoveAndDeleteChildren()
	}
	$("#inv_panel").visible = false;
}
