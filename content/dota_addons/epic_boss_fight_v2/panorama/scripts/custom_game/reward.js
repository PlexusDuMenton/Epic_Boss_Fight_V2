var ID = Players.GetLocalPlayer()
GameEvents.Subscribe( "reward", reward)
GameEvents.Subscribe( "super_reward", super_reward)

function close(){
$.GetContextPanel().RemoveAndDeleteChildren()
}

function reward(Item){
	var item = Item.item
	$.Schedule(10,close);
	Main = $.CreatePanel( "Panel", $.GetContextPanel() , "Main" );
	Main.SetHasClass( "Main_Panel", true )
	Main.hittest = false
	
	Label = $.CreatePanel( "Label", Main , "Label" );
	Label.SetHasClass( "Label", true )
	Label.text = $.Localize("#REWARD")
	Label.style.position = "10% 10% 0px"
	Label.hittest = false
	slot = $.CreatePanel( "Image", 	Main , "slot" );
	slot.SetHasClass( "Slot_Panel", true )
	slot.SetPanelEvent("onmouseover", function(){GameUI.CustomUIConfig().Events.FireEvent( "display_info", { item : item} )});
	slot.SetPanelEvent("onmouseout", function(){GameUI.CustomUIConfig().Events.FireEvent( "hide_info", {} )});	
	
	if (item.Soul == 1){
		slot.SetImage("file://{images}/custom_game/itemhud/"+item.item_name+"_" +item.quality+".png")
	}else {
		slot.SetImage("file://{images}/custom_game/itemhud/"+item.item_name+ ".png")
	}
	slot.style.position = "308px 300px 1px";
	
	close_button = $.CreatePanel( "Panel", 	Main , "close_button" );
	close_button.SetHasClass( "close_button", true )
	close_button.SetPanelEvent("onactivate", close);
	close_label = $.CreatePanel( "Label", close_button , "Label" );
	close_label.SetHasClass( "Label", true )
	close_label.text = $.Localize("#close")
	close_label.style.position = "10% 10% 0px"
	close_label.hittest = false
}

function super_reward(Item){
	$.Schedule(20,close);
	Main = $.CreatePanel( "Panel", $.GetContextPanel() , "Main" );
	Main.SetHasClass( "Main_Panel", true )
	
	Label = $.CreatePanel( "Label", Main , "Label" );
	Label.SetHasClass( "Label", true )
	Label.text = $.Localize("#SUPERREWARD")
	Label.style.position = "10% 10% 0px"
	
	var item = Item.item_1
	var item_2 = Item.item_2
	var item_3 = Item.item_3
	slot = $.CreatePanel( "Image", $("#Main") , "slot" );
	slot.SetHasClass( "Slot_Panel", true )
	slot.SetPanelEvent("onmouseover", function(){GameUI.CustomUIConfig().Events.FireEvent( "display_info", { item : item} )});
	slot.SetPanelEvent("onmouseout", function(){GameUI.CustomUIConfig().Events.FireEvent( "hide_info", {} )});	
	if (item.Soul == 1){
		slot.SetImage("file://{images}/custom_game/itemhud/"+item.item_name+"_" +item.quality+".png")
	}else {
		slot.SetImage("file://{images}/custom_game/itemhud/"+item.item_name+ ".png")
	}
	slot.style.position = "208px 300px  1px";
	
	slot_2 = $.CreatePanel( "Image", $("#Main") , "slot_2" );
	slot_2.SetHasClass( "Slot_Panel", true )
	slot_2.SetPanelEvent("onmouseover", function(){GameUI.CustomUIConfig().Events.FireEvent( "display_info", { item : item_2} )});
	slot_2.SetPanelEvent("onmouseout", function(){GameUI.CustomUIConfig().Events.FireEvent( "hide_info", {} )});	
	if (item_2.Soul == 1){
		slot_2.SetImage("file://{images}/custom_game/itemhud/"+item_2.item_name+"_" +item_2.quality+".png")
	}else {
		slot_2.SetImage("file://{images}/custom_game/itemhud/"+item_2.item_name+ ".png")
	}
	slot_2.style.position = "308px 300px  1px";
	
	slot_3 = $.CreatePanel( "Image", $("#Main") , "slot_3" );
	slot_3.SetHasClass( "Slot_Panel", true )
	slot_3.SetPanelEvent("onmouseover", function(){GameUI.CustomUIConfig().Events.FireEvent( "display_info", { item : item_3} )});
	slot_3.SetPanelEvent("onmouseout", function(){GameUI.CustomUIConfig().Events.FireEvent( "hide_info", {} )});	
	if (item_3.Soul == 1){
		slot_3.SetImage("file://{images}/custom_game/itemhud/"+item_3.item_name+"_" +item_3.quality+".png")
	}else {
		slot_3.SetImage("file://{images}/custom_game/itemhud/"+item_3.item_name+ ".png")
	}
	slot_3.style.position = "408px 300px  1px";
	
	close_button = $.CreatePanel( "Panel", 	Main , "close_button" );
	close_button.SetHasClass( "close_button", true )
	close_button.SetPanelEvent("onactivate", close);
	close_label = $.CreatePanel( "Label", close_button , "Label" );
	close_label.SetHasClass( "Label", true )
	close_label.text = $.Localize("#close")
	close_label.style.position = "10% 10% 0px"
	close_label.hittest = false
}
