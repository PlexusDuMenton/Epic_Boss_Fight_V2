var ID = Players.GetLocalPlayer()
$("#main").visible = false
$("#main_panel").visible = true

GameEvents.Subscribe("Open_Shop", open_shop)
GameEvents.Subscribe("Close_Shop", close_shop)

function close_shop(){
	$("#main_panel").RemoveAndDeleteChildren()
	$("#main").visible = false
}

Object.size = function(obj) {
    var size = 0, key;
    for (key in obj) {
        if (obj.hasOwnProperty(key)) size++;
    }
    return size;
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

function set_panel_event(slot,item_info,over_slot){
	slot.SetPanelEvent("onmouseover", function(){GameUI.CustomUIConfig().Events.FireEvent( "display_info", { item : item_info} )});
	slot.SetPanelEvent("onmouseout", function(){GameUI.CustomUIConfig().Events.FireEvent( "hide_info", {} )});
	// slot.SetPanelEvent("onactivate", function(){
		// $.Msg("WTF ?!")
		// over_slot.SetHasClass( "over_slot_selected", true )
		// over_slot.SetHasClass( "over_slot", false )
		// $.Schedule(1.2,(function(){
			// if (over_slot!= null){
				// over_slot.SetHasClass( "over_slot_selected", false )
				// over_slot.SetHasClass( "over_slot", true )
			// }
		// }));
		// GameEvents.SendCustomGameEventToServer( "Buy_Item", { name : item_info.item_name , price : item_info.price} );
	// })
	slot.SetPanelEvent("onactivate", function(){
		$.Schedule(0.8,(function(){
				if (over_slot!= null){
					over_slot.SetHasClass( "over_slot_selected", false )
					over_slot.SetHasClass( "over_slot", true )
				}
			}));
		if (GameUI.IsShiftDown() == true){
			GameEvents.SendCustomGameEventToServer( "Buy_Item", { name : item_info.item_name , price : item_info.price ,ammount : 5} );
		}else if (GameUI.IsControlDown() == true){
			GameEvents.SendCustomGameEventToServer( "Buy_Item", { name : item_info.item_name , price : item_info.price ,ammount : 25} );
		}
		else{
			if (item_info.stackable == true){
												var exit= $.CreatePanel( "Panel", $("#Menu_shop") , "exit" );
												exit.SetHasClass( "Main", true )
												exit.SetPanelEvent("onactivate", function(){
													$("#Menu_shop").RemoveAndDeleteChildren()
												})
												var pos_mouse = GameUI.GetCursorPosition()
												pos_mouse[0] = (pos_mouse[0])*screen_rat()[0]
												pos_mouse[1] = (pos_mouse[1])*screen_rat()[1]
												var text_entry = $.CreatePanel( "TextEntry", $("#Menu_shop"), "TextEntry");
												text_entry.style.position = (pos_mouse[0]-100) +"px "+pos_mouse[1]+"px 0px";
												text_entry.text = "Ammount (max for all)"
												text_entry.maxchars="20"
												text_entry.multiline = false;
												text_entry.SetHasClass( "Text_entry_place_holder", true );
												text_entry.SetPanelEvent('onfocus', (function(){
													text_entry.text = ""
													text_entry.SetHasClass( "Text_entry", true );
												}))
												text_entry.SetPanelEvent('oninputsubmit', (function(){
													GameEvents.SendCustomGameEventToServer( "Buy_Item", { name : item_info.item_name , price : item_info.price ,ammount : text_entry.text} );
													$("#Menu_shop").RemoveAndDeleteChildren()
												}))

			}else{
				over_slot.SetHasClass( "over_slot_selected", true )
				over_slot.SetHasClass( "over_slot", false )
				GameEvents.SendCustomGameEventToServer( "Buy_Item", { name : item_info.item_name , price : item_info.price} );
			}
		}
	})
}

function open_shop(arg){
	var Y_pos = 50
	var shop = arg.shop
	var info = arg.info
	$("#main_panel").RemoveAndDeleteChildren()
	$("#main").visible = true
	$("#main_panel").ScrollToLeftEdge()
	var shop_size = (Object.size(shop))
	for (i = 0; i < shop_size; i++){
		var row = shop[i].row
		var row_name = shop[i].name
		var row_size = (Object.size(row))
		var row_label = $.CreatePanel( "Label", $("#main_panel"), "row_label_"+i )
		row_label.SetHasClass( "title", true );
		row_label.style.position = "100px "+ Y_pos + "px 0px";
		Y_pos = Y_pos + 128
		row_label.text = $.Localize("#"+row_name)
		var X_pos = 100
		for (j = 0; j < row_size; j++){
				var item_name =	 row[j]
				var item_info = info[item_name]
				if(typeof ((j+1)/7)==='number' && (((j+1)/7)%1)===0) {
					X_pos = 100
					Y_pos = Y_pos + 128
				}

				slot = $.CreatePanel( "Image", $("#main_panel") , "item_row_"+i+"_slot_"+j );
				over_slot = $.CreatePanel( "Image", slot , "over_row_"+i+"_slot_"+j );
				slot.style.position = X_pos + "px "+ (-70 + Y_pos) + "px 0px";
				over_slot.SetHasClass( "over_slot", true )
				slot.SetHasClass( "slot", true )
				slot.SetImage("file://{images}/custom_game/itemhud/"+item_name+ ".png")
				set_panel_event(slot,item_info,over_slot)
				price = $.CreatePanel( "Label", $("#main_panel") , "price_"+i+"_slot_"+j );
				price.style.position = X_pos + "px "+ (-90 + Y_pos) + "px 0px";
				price.SetHasClass( "price", true )
				price.text = item_info.price
				X_pos = X_pos + 96
		}

	}
	Y_pos = Y_pos + 64
	space = $.CreatePanel( "Panel", $("#main_panel") , "space" );
	space.style.position = 0 + "px "+ (-70 + Y_pos) + "px 0px";
	space.SetHasClass( "free_space_under", true )
}
