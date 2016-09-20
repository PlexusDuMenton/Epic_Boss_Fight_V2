var ID = Players.GetLocalPlayer()
GameEvents.Subscribe( "start_trading", open_trading)
var intrade = false;
var in_confirm = false;

GameEvents.Subscribe( "stop_trading", function(){
close_trading()
})

GameEvents.Subscribe( "enter_confirmation", function(msg){
	in_confirm = true;
	GameUI.CustomUIConfig().Events.FireEvent( "in_confirm", {} )
		$("#accept_trade").SetPanelEvent('onactivate', (function(){
		}))
		$("#cancel").SetPanelEvent('onactivate', (function(){
		}))
		$("#accept_trade").visible = false
		$("#cancel").visible = false
		$.Schedule(1.5, function(){
			$("#accept_trade").SetPanelEvent('onactivate', (function(){
				GameEvents.SendCustomGameEventToServer( "accept_confirmation", { trading_with : msg.ask_ID } );
			}))
			$("#cancel").SetPanelEvent('onactivate', (function(){
				GameEvents.SendCustomGameEventToServer( "cancel_confirmation", { trading_with : msg.ask_ID } );
				in_confirm = false;
				GameUI.CustomUIConfig().Events.FireEvent( "out_confirm", {} )
				open_trading(msg)
			}))

			$("#accept_trade").visible = true
			$("#cancel").visible = true
			$("#accept_label").text = $.Localize("#CONFIRM_TRADE")
			$("#cancel_label").text = $.Localize("#BACK_TRADE")
		})
})


GameEvents.Subscribe( "stop_confirmation", function(msg){
in_confirm = false;
GameUI.CustomUIConfig().Events.FireEvent( "out_confirm", {} )
open_trading(msg)
})

GameEvents.Subscribe( "asked_trading", ask_trading)
function ask_trading(msg){
	var P_Name = Players.GetPlayerName( msg.ask_ID )
	var Panel = $.CreatePanel("Panel",$("#ask_panel"),"panel")
	Panel.SetHasClass( "ask", true );

	var trade_ask = $.CreatePanel("Label",Panel,"trade_ask")
	trade_ask.SetHasClass( "trade_ask", true );
	trade_ask.text = P_Name + $.Localize("#Trade_Ask")

	var Accept = $.CreatePanel("Panel",Panel,"Accept")
	Accept.SetHasClass( "button_vote", true );
	Accept.style.position = "15px 120px 0px"
	Accept.SetPanelEvent('onactivate', (function(){
		$("#ask_panel").RemoveAndDeleteChildren()
		GameEvents.SendCustomGameEventToServer( "accept_trading", { trading_with : msg.ask_ID } )
	}))
	var Accept_label = $.CreatePanel("Label",Accept, "accept_label" );
	Accept_label.text = $.Localize("#Accept")
	Accept_label.SetHasClass( "normal_label", true );
	Accept_label.hittest = false

	var Refuse = $.CreatePanel("Panel",Panel,"Refuse")
	Refuse.SetHasClass( "button_vote", true );
	Refuse.style.position = "180px 120px 0px"
	Refuse.SetPanelEvent('onactivate', (function(){
		$("#ask_panel").RemoveAndDeleteChildren()
		GameEvents.SendCustomGameEventToServer( "refuse_trading", { trading_with : msg.ask_ID } );
	}))
	var Refuse_label = $.CreatePanel("Label",Refuse, "Refuse_label" );
	Refuse_label.text = $.Localize("#Refuse")
	Refuse_label.SetHasClass( "normal_label", true );
	Refuse_label.hittest = false

}

function close_trading(){
	$("#trading_panel").RemoveAndDeleteChildren()
	$("#Menu_trading").RemoveAndDeleteChildren()
	intrade = false;
	in_confirm = false;

}


function open_trading(msg){
	intrade = true
	in_confirm = false;
	$("#trading_panel").RemoveAndDeleteChildren()
	$("#Menu_trading").RemoveAndDeleteChildren()
	var Panel = $.CreatePanel("Panel",$("#trading_panel"), "Panel" );
	Panel.SetHasClass( "trade", true );
	var NAME_1 = $.CreatePanel("Label",Panel, "Name_1" );
	NAME_1.SetHasClass( "Name_1", true );
	NAME_1.text = Players.GetPlayerName( ID )

	var NAME_2 = $.CreatePanel("Label",Panel, "Name_2" );
	NAME_2.SetHasClass( "Name_2", true );
	NAME_2.text = Players.GetPlayerName( msg.ask_ID )

	var GOLD_1 = $.CreatePanel("Label",Panel, "gold_1" );
	GOLD_1.SetHasClass( "gold_1", true );
	GOLD_1.text = $.Localize("#gold_trade") + " : "

	var GOLD_2 = $.CreatePanel("Label",Panel, "gold_2" );
	GOLD_2.SetHasClass( "gold_2", true );
	GOLD_2.text = $.Localize("#gold_trade") + " : "

	var GOLD_ENTRY = $.CreatePanel("TextEntry",Panel, "gold_entry" );
	GOLD_ENTRY.SetHasClass( "gold_entry", true );
	GOLD_ENTRY.text = "0"
	GOLD_ENTRY.maxchars="20"
	GOLD_ENTRY.multiline = false;
	GOLD_ENTRY.SetPanelEvent('oninputsubmit', (function(){
		$.Msg("input submited")
		if (in_confirm == false) {
			GameEvents.SendCustomGameEventToServer( "set_trade_gold", {gold : GOLD_ENTRY.text} )
			GOLD_ENTRY.text = ""
			$.Schedule(0.1, function(){
				GOLD_ENTRY.text = CustomNetTables.GetTableValue( "info", ("trade_player_" + ID)).trade_gold
			})
		}else{
			GOLD_ENTRY.text = CustomNetTables.GetTableValue( "info", ("trade_player_" + ID)).trade_gold
		}
	}))
	var ACCEPT = $.CreatePanel("Panel",Panel, "accept_trade" );
	ACCEPT.SetHasClass( "ACCEPT_BUTTON", true );

	var ACCEPT_LABEL = $.CreatePanel("Label",ACCEPT, "accept_label" );
	ACCEPT_LABEL.SetHasClass( "ACCEPT_LABEL", true );
	ACCEPT_LABEL.text = $.Localize("#READY_TRADE")

	var CANCEL = $.CreatePanel("Panel",Panel, "cancel" );
	CANCEL.SetHasClass( "CANCEL_BUTTON", true );

	var CANCEL_LABEL = $.CreatePanel("Label",CANCEL, "cancel_label" );
	CANCEL_LABEL.SetHasClass( "CANCEL_LABEL", true );
	CANCEL_LABEL.text = $.Localize("#CANCEL_TRADE")

	ACCEPT.SetPanelEvent('onactivate', (function(){
		in_confirm = true;
		GameUI.CustomUIConfig().Events.FireEvent( "in_confirm", {} )
		GameEvents.SendCustomGameEventToServer( "send_confirmation", { trading_with : msg.ask_ID } );
		CANCEL.visible = false
		ACCEPT.visible = false
		$.Schedule(1.5, function(){
			CANCEL.visible = true
			ACCEPT.visible = true
			ACCEPT_LABEL.text = $.Localize("#CONFIRM_TRADE")
			CANCEL_LABEL.text = $.Localize("#BACK_TRADE")
			CANCEL.SetPanelEvent('onactivate', (function(){
				in_confirm = false;
				GameUI.CustomUIConfig().Events.FireEvent( "out_confirm", {} )
				GameEvents.SendCustomGameEventToServer( "cancel_confirmation", { trading_with : msg.ask_ID } );
				open_trading(msg)
			}))
			ACCEPT.SetPanelEvent('onactivate', (function(){
				GameEvents.SendCustomGameEventToServer( "accept_confirmation", { trading_with : msg.ask_ID } );
			}))
		})
	}))

	CANCEL.SetPanelEvent('onactivate', (function(){
		$.Msg(msg.ask_ID)
		GameEvents.SendCustomGameEventToServer( "cancel_trading", { trading_with : msg.ask_ID } );
		close_trading()
	}))

	var OTHER_READY = $.CreatePanel("Panel",Panel, "accept_trade" );
	OTHER_READY.SetHasClass( "OTHER_READY", true );
	OTHER_READY.hittest = false


	var X_POS = 25
	var Y_POS = 25
	for (i = 0; i < 10; i++) {
		var sub_Panel = $.CreatePanel( "Panel", Panel, "item_panel_"+i+"_1");
		sub_Panel.SetHasClass( "ItemImage", true );
		var Item_Image = $.CreatePanel( "Image", sub_Panel, "item_image_"+i+"_1" );
		Item_Image.SetHasClass( "ItemImage", true );
		Button = $.CreatePanel( "Button", sub_Panel, "item_slot_"+i+"_1" );
		Button.SetHasClass( "ItemButton", true );
		$.CreatePanel( "Label", sub_Panel, "label_Level_"+i+"_1" );
		sub_Panel.style.position = ( X_POS)+"px "+ (Y_POS) +"px 1px";
		X_POS = X_POS + 80
		if (i == 4){
			X_POS = 25
			Y_POS = Y_POS + 80
		}
		var am = $.CreatePanel( "Label", sub_Panel, "label_item_inv_ammount_"+i+"_1" );
		am.SetHasClass( "Inventory_Label", true );
	}
	X_POS = 25
	Y_POS = 330
	for (i = 0; i < 10; i++) {
		var sub_Panel = $.CreatePanel( "Panel", Panel, "item_panel_"+i+"_2");
		sub_Panel.SetHasClass( "ItemImage", true );
		var Item_Image = $.CreatePanel( "Image", sub_Panel, "item_image_"+i+"_2" );
		Item_Image.SetHasClass( "ItemImage", true );
		Button = $.CreatePanel( "Button", sub_Panel, "item_slot_"+i+"_2" );
		Button.SetHasClass( "ItemButton", true );
		$.CreatePanel( "Label", sub_Panel, "label_Level_"+i+"_2" );
		sub_Panel.style.position = (X_POS)+"px "+ (Y_POS) +"px 1px";
		X_POS = X_POS + 80
		if (i == 4){
			X_POS = 25
			Y_POS = Y_POS + 80
		}
		var am = $.CreatePanel( "Label", sub_Panel, "label_item_inv_ammount_"+i+"_2" );
		am.SetHasClass( "Inventory_Label", true );
	}
	update_trade_panel(ID)
	update_trade_panel(msg.ask_ID)
}

function update_trade_panel(PID)
{
	var panel_ID = 2
	if (PID != ID){
		panel_ID = 1
	}
	if (intrade == true) {
		$.Schedule(0.25, function(){
		update_trade_panel(PID)
		});
	}
	var key = "trade_player_" + PID
	var trade_info = CustomNetTables.GetTableValue( "info", key)
	if (typeof trade_info != "undefined")
	{
		var ITT = trade_info.trade
		var Gold_for_Trade = trade_info.trade_gold
		if (panel_ID == 1){
			if ($("#gold_"+panel_ID) != null){
				$("#gold_"+panel_ID).text = $.Localize("#gold_trade") + " : " + Gold_for_Trade
			}
		}
		for (i = 0; i < 10; i++) {
				create_image (i,ITT,panel_ID)
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






function create_image (i,ITT,DEF_ID){
				if (typeof ITT != 'undefined'){
					if (typeof ITT[i] != 'undefined')
					{
						var item_slot = i
						var item = ITT[item_slot]
						var item_name = ITT[item_slot].item_name
						var Item_Image = $("#item_image_"+i+"_"+DEF_ID)
						if (Item_Image != null) {
							if (item.Soul == 1){
							Item_Image.SetImage("file://{images}/custom_game/itemhud/"+item_name+"_"+ item.quality + ".png")
							}else{Item_Image.SetImage("file://{images}/custom_game/itemhud/"+item_name+".png")}
							var Panel = Item_Image.GetParent()
							var ammount = $("#label_item_inv_ammount_"+i+"_"+DEF_ID)
							if (item.ammount > 1){
								ammount.text = item.ammount
								ammount.hittest=false
							}else
							{
								ammount.text = ""
								ammount.hittest=false
							}
							if (item.cat == "weapon"){
							var label_level = $("#label_Level_"+i+"_"+DEF_ID)
								label_level.SetHasClass( "Inventory_Label_ve_small", true );
								label_level.text = $.Localize("#Level")+" : " + item.level
								label_level.style.position = "0px 32px 1px";
								label_level.hittest=false
							}else
							{
								var label_level = $("#label_Level_"+i+"_"+DEF_ID)
								label_level.text = ""
								label_level.hittest=false
							}
							Panel.SetPanelEvent("onmouseover", function(){GameUI.CustomUIConfig().Events.FireEvent( "display_info", { item : item} )});
							Panel.SetPanelEvent("onmouseout", function(){GameUI.CustomUIConfig().Events.FireEvent( "hide_info", {} )});
							Panel.SetPanelEvent('onactivate', (function(){
								var exit = $.CreatePanel("Button",$("#Menu_trading"), "exit" );
								exit.SetHasClass( "Main", true );
								var Menu = $.CreatePanel( "Panel", $("#Menu_trading"), "menu_"+item_slot.toString() );
								var pos_mouse = GameUI.GetCursorPosition()
								pos_mouse[0] = (pos_mouse[0])*screen_rat()[0]
								pos_mouse[1] = (pos_mouse[1])*screen_rat()[1]
								Menu.style.position = (GameUI.GetCursorPosition()[0]) +"px "+(GameUI.GetCursorPosition()[1])+"px 0px";
								Menu.SetHasClass( "Inventory_Menu", true );
								var position_Y = 0
								if (in_confirm == false)
								{
									var Trade = $.CreatePanel( "Button", Menu, "menu_sell_"+item_slot.toString() );
									Trade.style.position = "0px " +position_Y +"px 1px";
									position_Y = position_Y + 40
									Trade.SetHasClass( "Inventory_Button", true );

									var label_Trade = $.CreatePanel( "Label", Trade, "label_sell_"+item_slot.toString() );
									label_Trade.SetHasClass( "Inventory_Label_small", true );
									label_Trade.text = $.Localize("#trade_off")
									Trade.SetPanelEvent('onactivate', (function(){
										if (ITT[item_slot].ammount > 1){
											if (typeof Menu != "undefined"){
												Menu.DeleteAsync(0)
											}
											var text_entry = $.CreatePanel( "TextEntry", $("#Menu_trading"), "TextEntry");
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
												GameEvents.SendCustomGameEventToServer( "remove_from_trade", { Slot : item_slot ,ammount : text_entry.text} )
												$("#Menu_trading").RemoveAndDeleteChildren()
											}))
										}else{
												GameEvents.SendCustomGameEventToServer( "remove_from_trade", { Slot : item_slot } );
												$("#Menu_trading").RemoveAndDeleteChildren()

										}
										}))
								}

								exit.SetPanelEvent('onactivate', (function(){
									$("#Menu_trading").RemoveAndDeleteChildren()
								}))
							})	)
							}

					}
					else{
						var Item_Image = $("#item_image_"+i+"_"+DEF_ID)
						if (Item_Image != null){
							Item_Image.SetImage("")

							var Panel = Item_Image.GetParent()
							Panel.SetPanelEvent('onactivate', (function(){}))
							Panel.SetPanelEvent("onmouseover", (function(){}))
							Panel.SetPanelEvent("onmouseout", (function(){}))
							$("#label_Level_"+i+"_"+DEF_ID).text = ""
							$("#label_item_inv_ammount_"+i+"_"+DEF_ID).text = ""
						}
					}
				}
			}
