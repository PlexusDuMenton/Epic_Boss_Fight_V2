var inventory;
var inshop = false;
var ID = Players.GetLocalPlayer()
$("#inv_panel").visible = false;
$.Schedule(0.3,Updateinventory);
$("#inventory_button").visible = false;
	function Updateinventory()
	{
		$.Schedule(0.1, Updateinventory);
		CustomNetTables.SubscribeNetTableListener
		key = "player_" + ID.toString()
		inventory = CustomNetTables.GetTableValue( "inventory", key)
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
						Item_Image.SetImage("file://{images}/custom_game/itemhud/"+item_name+ ".png")
						var Panel = Item_Image.GetParent()
						if (inventory.inventory[i+1].cat == "weapon"){
						var label_level = $("#label_Level_"+i.toString())
							label_level.SetHasClass( "Inventory_Label_small", true );
							label_level.text = "Lvl :" + inventory.inventory[item_slot+1].level
							label_level.style.position = "0px 32px 1px";
						}
							
						Panel.SetPanelEvent('onactivate', (function(){
							var exit = $.CreatePanel("Button",$("#menu_Items"), "exit" );
							exit.SetHasClass( "Main", true );
							var Menu = $.CreatePanel( "Panel", Panel, "menu_"+item_slot.toString() );
							Menu.style.position = (GameUI.GetCursorPosition()[0]-60) +"px "+(GameUI.GetCursorPosition()[1]-330)+"px 0px";
							Menu.SetHasClass( "Inventory_Menu", true );
							Menu.SetParent($("#menu_Items"))

							var Use = $.CreatePanel( "Button", Menu, "menu_use_"+item_slot.toString() );
							var position_Y = 0
							Use.style.position = "0px " +position_Y +"px 1px";
							position_Y = position_Y + 30
							Use.SetHasClass( "Inventory_Button", true );
							
							var Info = $.CreatePanel( "Button", Menu, "menu_info_"+item_slot.toString() );
							Info.SetHasClass( "Inventory_Button", true );
							Info.style.position = "0px " +position_Y +"px 1px";
							position_Y = position_Y + 30
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
							var label_Info = $.CreatePanel( "Label", Info, "label_info_"+item_slot.toString() );
							label_Info.SetHasClass( "Inventory_Label", true );
							label_Info.text= "Info"
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
								GameEvents.SendCustomGameEventToServer( "Drop_Item", { Slot : item_slot + 1} );
								$("#Info").RemoveAndDeleteChildren()
								$("#menu_Items").RemoveAndDeleteChildren()
							}))
							Info.SetPanelEvent('onactivate', (function(){
								$("#Info").RemoveAndDeleteChildren()
								display_info(inventory.inventory[item_slot+1])
								$("#menu_Items").RemoveAndDeleteChildren()
							}))
							
							
							
							
						})	)
						
					}
					else{
						var Item_Image = $("#item_image_"+i.toString())
						Item_Image.SetImage("")
						var Panel = Item_Image.GetParent()
						Panel.SetPanelEvent('onactivate', (function(){}))
						$("#label_Level_"+i.toString()).text = ""
					}
				}
			}
			
function Open_Inventory(){
	$("#inv_panel").visible = true;
	$("#inv_but_label").text = "Close inv"
	$("#inventory_button").SetPanelEvent('onactivate', close_inventory)
	$.Schedule(0.075,Updateslot);
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
		}

		var menu_Items = $.CreatePanel( "Panel", $("#Menu"), "menu_Items");
			menu_Items.SetHasClass( "menu_Items", true );
			menu_Items.hittest = false 
	}
}
GameEvents.Subscribe( "Display_Bar", display_but)
function display_but(){
$("#inventory_button").visible = true;
}
function close_info(){
$("#Info").RemoveAndDeleteChildren()
}
function display_info(item) {
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
	Label_Name.text = item.Name
	if (item.quality == "poor") {
	Label_Name.color = "#AAAAAA"
	}
	if (item.quality == "magic") {
	Label_Name.color = "#AAFFAA"
	}
	
	var Label_cat = $.CreatePanel( "Label", Info_Panel, "Info_Item_cat" )
	Label_cat.SetHasClass( "Inventory_Label_ve_small", true );
	Label_cat.style.position = "110px 45px 1px";
	Label_cat.text = item.cat
	var Label_price = $.CreatePanel( "Label", Info_Panel, "Info_Item_cat" )
	Label_price.SetHasClass( "Inventory_Label_ve_small", true );
	Label_price.style.position = "20px 90px 1px";
	Label_price.text =  item.price + " Gold "
	if (item.cat == "weapon"){
		var Label_level = $.CreatePanel( "Label", Info_Panel, "Info_Item_level" )
		Label_level.SetHasClass( "Inventory_Label_small", true );
		Label_level.style.position = "115px 80px 1px";
		Label_level.text = "Level : " + item.level
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
			var Label_dmg = $.CreatePanel( "Label", Info_Panel, "Info_Item_dmg" )
			Label_dmg.SetHasClass( "Inventory_Label_small", true );
			Label_dmg.style.position = "10px "+ pos_y+"px 1px";
			pos_y = pos_y + 25
			if (item.cat == "weapon"){
			Label_dmg.text = "Damage : " + item.damage + " + ("+item.dmg_grow +")"
			}else{
			Label_dmg.text = "Damage : " + item.damage
			}
		}
		if (typeof item.attack_speed != 'undefined') {
			var Label_as = $.CreatePanel( "Label", Info_Panel, "Info_Item_as" )
			Label_as.SetHasClass( "Inventory_Label_small", true );
			Label_as.style.position = "10px "+ pos_y+"px 1px";
			pos_y = pos_y + 25
			if (item.cat == "weapon"){
				Label_as.text = "Attack Speed : " + item.attack_speed + " + ("+item.as_grow +")"
			}else{
				Label_as.text = "Attack Speed : " + item.attack_speed
			}
		}
		if (typeof item.range != 'undefined') {
			var Label_range = $.CreatePanel( "Label", Info_Panel, "Info_Item_range" )
			Label_range.SetHasClass( "Inventory_Label_small", true );
			Label_range.style.position = "10px "+ pos_y+"px 1px";
			pos_y = pos_y + 25
			if (item.cat == "weapon"){
				Label_range.text = "Range : " + item.range + " + ("+item.range_grow +")"
			}else{
				Label_range.text = "Range : " + item.range
			}
		}
		create_label(item.loh,"Health on Hit","")
		create_label(item.ls,"LifeSteal","%")
		create_label(item.hp,"Bonus Health","")
		create_label(item.mp,"Bonus Mana","")
		create_label(item.hp_regen,"Hp Per Second","")
		create_label(item.armor,"Armor","")
		create_label(item.m_ress,"Magical_ress","%")
		create_label(item.movespeed,"Move Speed","")
		
	}
	
	function create_label(stat,stat_name,end){
		if (typeof stat != 'undefined') {
			if (stat != 0) {
				var Label = $.CreatePanel( "Label", Info_Panel, "Info_Item_"+stat_name )
				Label.SetHasClass( "Inventory_Label_small", true );
				Label.style.position = "10px "+ pos_y+"px 1px";
				pos_y = pos_y + 25
				Label.text = stat_name + " : " + stat + end
			}
		}
		
	}
}

function close_inventory() {
	$.Schedule(0.1,del_panel);
	function del_panel(){
		$("#Items").RemoveAndDeleteChildren()
		$("#Menu").RemoveAndDeleteChildren()
		$("#Info").RemoveAndDeleteChildren()
	}
	$("#inv_panel").visible = false;
	$("#inv_but_label").text = "Inventory"
	$("#inventory_button").SetPanelEvent('onactivate',Open_Inventory)
}
