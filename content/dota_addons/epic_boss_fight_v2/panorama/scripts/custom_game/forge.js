var ID = Players.GetLocalPlayer()
var inventory
var weapon
var main_slot = -1
var secondary_slot = -1
var selected_tab = "infusion"
var weapon_evolution
var weapon_list
$("#main_panel").visible = false

GameEvents.Subscribe( "item_list", item_list)

function item_list(arg){
	weapon_evolution = arg.weapon_evolution
	weapon_list = arg.weapon_list
}

GameUI.CustomUIConfig().Events.SubscribeEvent( "to_forge_main", (function(arg){
	main_slot = arg.Slot
update_slot("main")}))

GameUI.CustomUIConfig().Events.SubscribeEvent( "to_upgrade", (function(arg){
	main_slot = "weapon"
update_slot("main")}))


GameUI.CustomUIConfig().Events.SubscribeEvent( "to_forge_secondary", (function(arg){
	secondary_slot = arg.Slot
update_slot("secondary")}))

GameEvents.Subscribe( "clean_forge", clean_forge)

function clean_forge(){
		secondary_slot = -1
		if ($("#secondary_slot") != null){
			$("#secondary_slot").ClearPanelEvent( "onmouseover" )
			$("#secondary_slot").ClearPanelEvent( "onmouseout" )
			$("#secondary_slot").SetImage(null)
		}
		if ($("#main_slot") != null){
			$("#main_slot").ClearPanelEvent( "onmouseover" )
			$("#main_slot").ClearPanelEvent( "onmouseout" )
			$("#main_slot").SetImage(null)
		}

		if ($("#stats_gain_stats_damage") != null) {
			$("#stats_gain_stats_damage").text = ""
			$("#stats_gain_stats_m_damage").text = ""
			$("#stats_gain_stats_loh").text = ""
			$("#stats_gain_stats_attack_speed").text = ""
			$("#stats_gain_stats_ls").text = ""
		}
		if ($("#Xp_gain") != null) {
			$("#Xp_gain").text = ""
		}
		if ($("#new_soul_damage") != null) {
			$("#new_soul_damage").text = ""
			$("#new_soul_m_damage").text = ""
			$("#new_soul_loh").text = ""
			$("#new_soul_attack_speed").text = ""
			$("#new_soul_ls").text = ""
		}

		if ($("#button_text") != null) {
			$("#button_text").SetHasClass( "unselected_button_label", false )
		}
		for (i = 0; i < 5; i++){
				if ($("#button_"+i)!= null){
					$("#button_"+i).DeleteAsync(0)
				}
			}
}
function update_slot(priority){
	CustomNetTables.SubscribeNetTableListener
	var key = "player_" + ID.toString()
	inventory = CustomNetTables.GetTableValue( "inventory_player_"+ID, key).inventory
	weapon = CustomNetTables.GetTableValue( "inventory_player_"+ID, key).equipement.weapon
	if (main_slot == secondary_slot){
		if (priority == "main") {
			secondary_slot = -1
			$("#secondary_slot").ClearPanelEvent( "onmouseover" )
			$("#secondary_slot").ClearPanelEvent( "onmouseout" )
			$("#secondary_slot").SetImage(null)
		}
		else{ main_slot = -1
			$("#main_slot").ClearPanelEvent( "onmouseover" )
			$("#main_slot").ClearPanelEvent( "onmouseout" )
			$("#main_slot").SetImage(null)
		}
	}
	if (typeof $("#main_slot") != 'undefined') {
		if (main_slot != -1){
			if (main_slot == "weapon" ){
			$("#main_slot").SetImage("file://{images}/custom_game/itemhud/"+weapon.item_name+ ".png")
			$("#main_slot").SetPanelEvent("onmouseover", function(){GameUI.CustomUIConfig().Events.FireEvent( "display_info", { item : weapon} )});
			}else{
			$("#main_slot").SetImage("file://{images}/custom_game/itemhud/"+inventory[main_slot].item_name+ ".png")
			$("#main_slot").SetPanelEvent("onmouseover", function(){GameUI.CustomUIConfig().Events.FireEvent( "display_info", { item : inventory[main_slot]} )});
			}
			$("#main_slot").SetPanelEvent("onmouseout", function(){GameUI.CustomUIConfig().Events.FireEvent( "hide_info", {} )});
		}
	}
	if (typeof $("#secondary_slot") != 'undefined') {
		if (secondary_slot != -1){
			if (inventory[secondary_slot]!= null){
				if (inventory[secondary_slot].Soul == 1){
					$("#secondary_slot").SetImage("file://{images}/custom_game/itemhud/"+inventory[secondary_slot].item_name+"_" +inventory[secondary_slot].quality+".png")
				}else {
					$("#secondary_slot").SetImage("file://{images}/custom_game/itemhud/"+inventory[secondary_slot].item_name+ ".png")
					}
				$("#secondary_slot").SetPanelEvent("onmouseover", function(){GameUI.CustomUIConfig().Events.FireEvent( "display_info", { item : inventory[secondary_slot]} )});
				$("#secondary_slot").SetPanelEvent("onmouseout", function(){GameUI.CustomUIConfig().Events.FireEvent( "hide_info", {} )});
			}
		}
	}

	if (selected_tab == "infusion"){
		if (secondary_slot != -1){
			if ($("#stats_gain_stats_damage") != null) {
				$("#stats_gain_stats_damage").text = $.Localize("#stats_damage") + inventory[secondary_slot].damage
				$("#stats_gain_stats_m_damage").text = $.Localize("#stats_m_damage") + inventory[secondary_slot].m_damage
				$("#stats_gain_stats_loh").text = $.Localize("#stats_loh")+ inventory[secondary_slot].loh
				$("#stats_gain_stats_attack_speed").text = $.Localize("#stats_attack_speed") + inventory[secondary_slot].attack_speed
				$("#stats_gain_stats_ls").text = $.Localize("#stats_ls") + inventory[secondary_slot].ls
				if (main_slot != -1){
					$("#button_text").SetHasClass( "unselected_button_label", true )
				}
			}
		}
	}
	if (selected_tab == "transmutation"){
		if (secondary_slot != -1){
			if ($("#Xp_gain") != null){
				var damage = 0
				var m_damage = 0
				var loh = 0
				var ls = 0
				var attack_speed = 0
				if (typeof inventory[secondary_slot].damage != "undefined"){damage = inventory[secondary_slot].damage }
				if (typeof inventory[secondary_slot].upgrade_damage != "undefined"){damage = inventory[secondary_slot].upgrade_damage + damage}
				if (typeof inventory[secondary_slot].bonus_damage  != "undefined"){damage = inventory[secondary_slot].bonus_damage + damage}

				if (typeof inventory[secondary_slot].m_damage != "undefined"){m_damage = inventory[secondary_slot].m_damage}
				if (typeof inventory[secondary_slot].upgrade_m_damage  != "undefined"){m_damage = inventory[secondary_slot].upgrade_m_damage + m_damage}
				if (typeof inventory[secondary_slot].bonus_m_damage != "undefined"){m_damage = inventory[secondary_slot].bonus_m_damage + m_damage}

				if (typeof inventory[secondary_slot].loh != "undefined"){loh = inventory[secondary_slot].loh}
				if (typeof inventory[secondary_slot].upgrade_loh != "undefined"){loh = inventory[secondary_slot].upgrade_loh + loh}
				if (typeof inventory[secondary_slot].bonus_loh != "undefined"){loh = inventory[secondary_slot].bonus_loh + loh}

				if (typeof inventory[secondary_slot].ls != "undefined"){ls = inventory[secondary_slot].ls}
				if (typeof inventory[secondary_slot].upgrade_ls != "undefined"){ls = inventory[secondary_slot].upgrade_ls + ls}
				if (typeof inventory[secondary_slot].bonus_ls != "undefined"){ls = inventory[secondary_slot].bonus_ls + ls}

				if (typeof inventory[secondary_slot].attack_speed != "undefined"){attack_speed = inventory[secondary_slot].attack_speed}
				if (typeof inventory[secondary_slot].upgrade_attack_speed != "undefined"){attack_speed = inventory[secondary_slot].upgrade_attack_speed + attack_speed}
				if (typeof inventory[secondary_slot].bonus_attack_speed != "undefined"){attack_speed = inventory[secondary_slot].bonus_attack_speed + attack_speed}
				var xp = ( Math.ceil(inventory[secondary_slot].XP/3 + ( Math.log10( 2 +inventory[secondary_slot].XP/2) + 5*Math.pow(inventory[secondary_slot].level,1.2)) * ( 1 + (0.1*( 0.1 + Math.log10( 2 + damage * 2) + Math.log10( 2 + m_damage * 2) + Math.log10( 2 + attack_speed) + Math.log10(2 + loh) + Math.log10(2 +Math.pow(ls,1.5)) * 10)))))
				xp = xp * Math.pow(inventory[secondary_slot].Ilevel,0.3)
				$("#Xp_gain").text = $.Localize("#Xp_gain") + Math.ceil(xp)
				if (main_slot != -1){
					$("#button_text").SetHasClass( "unselected_button_label", true )
				}
			}
		}
	}

	if (selected_tab == "crystalisation"){
		if (main_slot != -1){
			if ($("#new_soul_damage") != null){
				if (typeof inventory[main_slot].damage == "undefined"){inventory[main_slot].damage = 0}
				if (typeof inventory[main_slot].upgrade_damage == "undefined"){inventory[main_slot].upgrade_damage = 0}
				if (typeof inventory[main_slot].bonus_damage == "undefined"){inventory[main_slot].bonus_damage = 0}

				if (typeof inventory[main_slot].m_damage == "undefined"){inventory[main_slot].m_damage = 0}
				if (typeof inventory[main_slot].upgrade_m_damage == "undefined"){inventory[main_slot].upgrade_m_damage = 0}
				if (typeof inventory[main_slot].bonus_m_damage == "undefined"){inventory[main_slot].bonus_m_damage = 0}

				if (typeof inventory[main_slot].loh == "undefined"){inventory[main_slot].loh = 0}
				if (typeof inventory[main_slot].upgrade_loh == "undefined"){inventory[main_slot].upgrade_loh = 0}
				if (typeof inventory[main_slot].bonus_loh == "undefined"){inventory[main_slot].bonus_loh = 0}

				if (typeof inventory[main_slot].ls == "undefined"){inventory[main_slot].ls = 0}
				if (typeof inventory[main_slot].upgrade_ls == "undefined"){inventory[main_slot].upgrade_ls = 0}
				if (typeof inventory[main_slot].bonus_ls == "undefined"){inventory[main_slot].bonus_ls = 0}

				if (typeof inventory[main_slot].attack_speed == "undefined"){inventory[main_slot].attack_speed = 0}
				if (typeof inventory[main_slot].upgrade_attack_speed == "undefined"){inventory[main_slot].upgrade_attack_speed = 0}
				if (typeof inventory[main_slot].bonus_attack_speed == "undefined"){inventory[main_slot].bonus_attack_speed = 0}

				$("#new_soul_damage").text = $.Localize("#new_soul_damage") + Math.ceil((inventory[main_slot].damage + inventory[main_slot].upgrade_damage + inventory[main_slot].bonus_damage) * 0.25 )
				$("#new_soul_m_damage").text = $.Localize("#new_soul_m_damage") + Math.ceil((inventory[main_slot].m_damage + inventory[main_slot].upgrade_m_damage + inventory[main_slot].bonus_m_damage) * 0.25)
				$("#new_soul_loh").text = $.Localize("#new_soul_loh") + Math.ceil((inventory[main_slot].loh + inventory[main_slot].upgrade_loh + inventory[main_slot].bonus_loh) * 0.25)
				$("#new_soul_attack_speed").text = $.Localize("#new_soul_attack_speed") + Math.ceil((inventory[main_slot].attack_speed + inventory[main_slot].upgrade_attack_speed + inventory[main_slot].bonus_attack_speed)* 0.25)
				$("#new_soul_ls").text = $.Localize("#new_soul_ls") + Math.ceil((inventory[main_slot].ls + inventory[main_slot].upgrade_ls + inventory[main_slot].bonus_ls) * 0.25)
				if (inventory[main_slot].level > 4){
					$("#button_text").SetHasClass( "unselected_button_label", true )
				}
			}
		}
	}
	if (selected_tab == "evolution"){
		if (main_slot != -1){
			var pos_y_button = 0
			reset_evolution()
			if (main_slot != -1){
				if (main_slot == "weapon" ){
				$("#main_slot").SetImage("file://{images}/custom_game/itemhud/"+weapon.item_name+ ".png")
				$("#main_slot").SetPanelEvent("onmouseover", function(){GameUI.CustomUIConfig().Events.FireEvent( "display_info", { item : weapon} )});
				}else{
				$("#main_slot").SetImage("file://{images}/custom_game/itemhud/"+inventory[main_slot].item_name+ ".png")
				$("#main_slot").SetPanelEvent("onmouseover", function(){GameUI.CustomUIConfig().Events.FireEvent( "display_info", { item : inventory[main_slot]} )});
				}
				$("#main_slot").SetPanelEvent("onmouseout", function(){GameUI.CustomUIConfig().Events.FireEvent( "hide_info", {} )});
			}
			if (main_slot == "weapon" ){
				var evolu = weapon_evolution[weapon.item_name]
			}else{
				var evolu = weapon_evolution[inventory[main_slot].item_name]
			}
			var number = 0
			for (key in evolu){
				var evolution = evolu[key]
				create_button(number,key,evolu)
				number = number + 1
			}
			function create_button(number,key,evolu){
				Button = $.CreatePanel( "Panel", $("#display") , "button_"+number );
				Button.style.position = "100px "+(100+pos_y_button)+"px 1px";
				pos_y_button = pos_y_button + 100
				Button.SetHasClass( "big_button", true )
				button_text = $.CreatePanel( "Label", Button , "button_text_"+number );
				$("#button_text_"+number).style.position = "3px 20px 1px";
				$("#button_text_"+number).text = $.Localize("#"+key)
				if (main_slot != -1){
						$("#button_text_"+number).SetHasClass( "unselected_button_label", true )
					}else{$("#button_text_"+number).SetHasClass( "deny_button_label", true ) }
				Button.SetPanelEvent('onmouseover', (function(){
					if (main_slot != -1){
						$("#button_text_"+number).SetHasClass( "button_label_hover", true )
					}else{$("#button_text_"+number).SetHasClass( "deny_button_label_hover", true ) }

				}))
				Button.SetPanelEvent('onmouseout', (function(){
					$("#button_text_"+number).SetHasClass( "deny_button_label_hover", false )
					$("#button_text_"+number).SetHasClass( "button_label_hover", false )
				}))

				Button.SetPanelEvent('onactivate', (function(){
					if (main_slot == "weapon" ){
						display_evolution(number,key,evolu,weapon)
					}else{
						display_evolution(number,key,evolu,inventory[main_slot])
					}
				}))
			}
		}else{
			for (i = 0; i < 5; i++){
				if ($("#button_"+i)!= null){
					$("#button_"+i).DeleteAsync(0)
				}
			}
		}
	}
}



function display_evolution(way,name,evolu_need,originel_item){
	$("#display").RemoveAndDeleteChildren()
	main_panel = $.CreatePanel( "Image", $("#display") , "main_slot" )
	main_panel.style.position = "500px 250px 1px";
	main_panel.SetHasClass( "slot", true )
	main_panel.SetImage("file://{images}/custom_game/itemhud/"+name+ ".png")
	main_panel.SetPanelEvent("onmouseover", function(){GameUI.CustomUIConfig().Events.FireEvent( "display_info", { item : weapon_list[name]} )});
	main_panel.SetPanelEvent("onmouseout", function(){GameUI.CustomUIConfig().Events.FireEvent( "hide_info", {} )});

	secondary_slot = $.CreatePanel( "Image", $("#display") , "secondary_slot" );
	secondary_slot.style.position = "500px 350px 1px";
	secondary_slot.SetHasClass( "slot", true )
	secondary_slot.SetImage("file://{images}/custom_game/itemhud/"+originel_item.item_name+ ".png")
	secondary_slot.SetPanelEvent("onmouseover", function(){GameUI.CustomUIConfig().Events.FireEvent( "display_info", { item : originel_item} )});
	secondary_slot.SetPanelEvent("onmouseout", function(){GameUI.CustomUIConfig().Events.FireEvent( "hide_info", {} )});


	explain_text = $.CreatePanel( "Label", $("#display") , "explain_text" );
	explain_text.style.position = "70px "+(50) +"px 1px";
	explain_text.text = $.Localize("#Soul_requirement")
	explain_text.SetHasClass( "normal_label_3", true )
	var can_evolve = true
	var pos_sub_y = 0
	display_req("need_level","level")
	pos_sub_y = pos_sub_y + 35
	display_req("need_damage","damage")
	pos_sub_y = pos_sub_y + 35
	display_req("need_m_damage","m_damage")
	pos_sub_y = pos_sub_y + 35
	display_req("need_loh","loh")
	pos_sub_y = pos_sub_y + 35
	display_req("need_attack_speed","attack_speed")
	pos_sub_y = pos_sub_y + 35
	display_req("need_ls","ls")
	function display_req(cat,stat_name){
			text = $.CreatePanel( "Label", $("#display") , cat );
			text.style.position = "70px "+(100+pos_sub_y) +"px 1px";
			if (typeof originel_item["upgrade_"+stat_name] == "undefined"){originel_item["upgrade_"+stat_name] = 0}
			text.text = $.Localize("#" + cat) + evolu_need[name][stat_name]
			if (originel_item["upgrade_"+stat_name] < evolu_need[name][stat_name]){
				can_evolve = false
				text.style.color = "#FF5522"
			}
			text.SetHasClass( "normal_label_2", true )
	}

	Button = $.CreatePanel( "Image", $("#display") , "button" );
	Button.style.position = "100px 350px 1px";
	Button.SetHasClass( "big_button", true )
	Button.SetPanelEvent('onmouseover', (function(){
		if (can_evolve == true){
			$("#button_text").SetHasClass( "button_label_hover", true )
		}else{$("#button_text").SetHasClass( "deny_button_label_hover", true ) }

	}))
	Button.SetPanelEvent('onmouseout', (function(){
		$("#button_text").SetHasClass( "deny_button_label_hover", false )
		$("#button_text").SetHasClass( "button_label_hover", false )
	}))

	Button.SetPanelEvent('onactivate', (function(){
		if (can_evolve == true){
			if (main_slot == "weapon" ){
				GameEvents.SendCustomGameEventToServer( "evolve_weapon", { main_slot : null , way : way} );
			}else{
				GameEvents.SendCustomGameEventToServer( "evolve_weapon", { main_slot : main_slot , way : way} );
			}
			clean_forge()
		}
	}))

	button_text = $.CreatePanel( "Label", Button , "button_text" );
	button_text.style.position = "0px 5px 1px";
	button_text.text = $.Localize("#EVOLVE")
	if (can_evolve == true){
		button_text.SetHasClass( "unselected_button_label", true )
	}else{
		button_text.SetHasClass( "deny_button_label", true )
	}


}

GameEvents.Subscribe( "Open_Forge", create_tabs)
GameEvents.Subscribe( "Close_Forge", close_forge)

function close_forge(){
	$("#display").RemoveAndDeleteChildren()
	$("#windows_tabs").RemoveAndDeleteChildren()
	$("#main_panel").visible = false
}


function create_tabs(){
	$("#main_panel").visible = true
	CustomNetTables.SubscribeNetTableListener

	main_slot = -1
	secondary_slot = -1
	selected_tab = "infusion"
	for (i = 0; i < 4; i++){
		create_tab(i)
	}
	display_soul_infusion()
}

function create_tab(i){
	var tab_panel = $.CreatePanel( "Panel", $("#windows_tabs") , "tab_"+i );
	tab_panel.style.position = (10 + i*165)+"px 8px 1px";
	if (i == 0){ tab_panel.SetHasClass( "tab", true ) } else {tab_panel.SetHasClass( "unselected_tab", true )}

	var label = $.CreatePanel( "Label", tab_panel , "tab_label_"+i );
	if (i == 0){ label.SetHasClass( "tab_label", true ) } else {label.SetHasClass( "unselected_tab_label", true )}
	label.text = $.Localize("#forge_tab_"+i)
	label.hittest = false

	tab_panel.SetPanelEvent('onmouseover', (function(){
		$("#tab_label_"+i).SetHasClass( "tab_label_hover", true )

	}))
	tab_panel.SetPanelEvent('onmouseout', (function(){
		$("#tab_label_"+i).SetHasClass( "tab_label_hover", false )
	}))

	tab_panel.SetPanelEvent('onactivate', (function(){
		for (j = 0; j < 4; j++){
			if (i==j) {
				$("#tab_"+i).SetHasClass( "tab", true )
				$("#tab_"+i).SetHasClass( "unselected_tab", false )

				$("#tab_label_"+i).SetHasClass( "tab_label", true )
				$("#tab_label_"+i).SetHasClass( "unselected_tab_label", false )
			}else{
				$("#tab_"+j).SetHasClass( "tab", false )
				$("#tab_"+j).SetHasClass( "unselected_tab", true )
				$("#tab_label_"+j).SetHasClass( "tab_label", false )
				$("#tab_label_"+j).SetHasClass( "unselected_tab_label", true )
			}
		}
		if (i == 0) {
			display_soul_infusion()
		}
		if (i == 1) {
			display_soul_transmutation()
		}
		if (i == 2) {
			display_soul_crystalisation()
		}
		if (i == 3) {
			display_soul_evolution()
		}
	}))
}

function display_soul_infusion(){
	selected_tab = "infusion"
	GameUI.CustomUIConfig().Events.FireEvent( "update_forge_panel", { selected_tab : selected_tab} );
	main_slot = -1
	secondary_slot = -1
	$("#display").RemoveAndDeleteChildren()

	main_panel = $.CreatePanel( "Image", $("#display") , "main_slot" );
	main_panel.style.position = "500px 200px 1px";
	secondary_panel = $.CreatePanel( "Image", $("#display") , "secondary_slot" );
	secondary_panel.style.position = "500px 350px 1px";
	main_panel.SetHasClass( "slot", true )
	secondary_panel.SetHasClass( "slot", true )

	description = $.CreatePanel( "Label", $("#display") , "Description" );
	description.style.position = "80px 50px 1px";
	description.text = $.Localize("#forge_tab_0_desc")
	description.SetHasClass( "normal_label", true )

	Button = $.CreatePanel( "Image", $("#display") , "button" );
	Button.style.position = "100px 350px 1px";
	Button.SetHasClass( "big_button", true )
	Button.SetPanelEvent('onmouseover', (function(){
		if (main_slot != -1 && secondary_slot != -1){
			$("#button_text").SetHasClass( "button_label_hover", true )
		}else{$("#button_text").SetHasClass( "deny_button_label_hover", true ) }

	}))
	Button.SetPanelEvent('onmouseout', (function(){
		$("#button_text").SetHasClass( "deny_button_label_hover", false )
		$("#button_text").SetHasClass( "button_label_hover", false )
	}))

	Button.SetPanelEvent('onactivate', (function(){
		if (main_slot != -1 && secondary_slot != -1){
			if (main_slot == "weapon"){
				GameEvents.SendCustomGameEventToServer( "infuse_soul", { main_slot : null , secondary_slot : secondary_slot} );
			}else{
				GameEvents.SendCustomGameEventToServer( "infuse_soul", { main_slot : main_slot , secondary_slot : secondary_slot} );
			}
			clean_forge()
		}
	}))

	button_text = $.CreatePanel( "Label", Button , "button_text" );
	button_text.style.position = "15px 20px 1px";
	button_text.text = $.Localize("#forge_tab_0")
	button_text.SetHasClass( "deny_button_label", true )
	var pos_sub_y = 0
	display_result("stats_damage")
	pos_sub_y = pos_sub_y + 35
	display_result("stats_m_damage")
	pos_sub_y = pos_sub_y + 35
	display_result("stats_loh")
	pos_sub_y = pos_sub_y + 35
	display_result("stats_attack_speed")
	pos_sub_y = pos_sub_y + 35
	display_result("stats_ls")
	function display_result(stats_name){
			button_text = $.CreatePanel( "Label", $("#display") , "stats_gain_"+stats_name );
			button_text.style.position = "15px "+(150+pos_sub_y) +"px 1px";
			button_text.text = ""
			button_text.SetHasClass( "normal_label_2", true )
	}
}

function display_soul_transmutation(){
	selected_tab = "transmutation"
	GameUI.CustomUIConfig().Events.FireEvent( "update_forge_panel", { selected_tab : selected_tab} );
	main_slot = -1
	secondary_slot = -1
	$("#display").RemoveAndDeleteChildren()

	main_panel = $.CreatePanel( "Image", $("#display") , "main_slot" );
	main_panel.style.position = "500px 200px 1px";
	secondary_panel = $.CreatePanel( "Image", $("#display") , "secondary_slot" );
	secondary_panel.style.position = "500px 350px 1px";
	main_panel.SetHasClass( "slot", true )
	secondary_panel.SetHasClass( "slot", true )



	description = $.CreatePanel( "Label", $("#display") , "Description" );
	description.style.position = "80px 50px 1px";
	description.text = $.Localize("#forge_tab_1_desc")
	description.SetHasClass( "normal_label", true )

	Button = $.CreatePanel( "Image", $("#display") , "button" );
	Button.style.position = "100px 350px 1px";
	Button.SetHasClass( "big_button", true )
	Button.SetPanelEvent('onmouseover', (function(){
		if (main_slot != -1 && secondary_slot != -1){
			$("#button_text").SetHasClass( "button_label_hover", true )
		}else{$("#button_text").SetHasClass( "deny_button_label_hover", true ) }

	}))
	Button.SetPanelEvent('onmouseout', (function(){
		$("#button_text").SetHasClass( "deny_button_label_hover", false )
		$("#button_text").SetHasClass( "button_label_hover", false )
	}))

	Button.SetPanelEvent('onactivate', (function(){
		if (main_slot != -1 && secondary_slot != -1){
			if (main_slot == "weapon" ){
				GameEvents.SendCustomGameEventToServer( "transmute_weapon", { main_slot : null , secondary_slot : secondary_slot} );
			}else{
				GameEvents.SendCustomGameEventToServer( "transmute_weapon", { main_slot : main_slot , secondary_slot : secondary_slot} );
			}
			clean_forge()
		}
	}))

	button_text = $.CreatePanel( "Label", Button , "button_text" );
	button_text.style.position = "3px 20px 1px";
	button_text.text = $.Localize("#forge_tab_1")
	$("#button_text").SetHasClass( "deny_button_label", true )


	xp_text = $.CreatePanel( "Label", $("#display") , "Xp_gain" );
			xp_text.style.position = "15px "+(300) +"px 1px";
			xp_text.text = ""
			xp_text.SetHasClass( "normal_label_3", true )
}

function display_soul_crystalisation(){
	selected_tab = "crystalisation"
	GameUI.CustomUIConfig().Events.FireEvent( "update_forge_panel", { selected_tab : selected_tab} );
	main_slot = -1
	secondary_slot = -1
	$("#display").RemoveAndDeleteChildren()

	main_panel = $.CreatePanel( "Image", $("#display") , "main_slot" );
	main_panel.style.position = "500px 200px 1px";
	main_panel.SetHasClass( "slot", true )

	description = $.CreatePanel( "Label", $("#display") , "Description" );
	description.style.position = "80px 50px 1px";
	description.text = $.Localize("#forge_tab_2_desc")
	description.SetHasClass( "normal_label", true )

	Button = $.CreatePanel( "Image", $("#display") , "button" );
	Button.style.position = "100px 350px 1px";
	Button.SetHasClass( "big_button", true )
	Button.SetPanelEvent('onmouseover', (function(){
		if (main_slot != -1 && secondary_slot != -1){
			$("#button_text").SetHasClass( "button_label_hover", true )
		}else{$("#button_text").SetHasClass( "deny_button_label_hover", true ) }

	}))
	Button.SetPanelEvent('onmouseout', (function(){
		$("#button_text").SetHasClass( "deny_button_label_hover", false )
		$("#button_text").SetHasClass( "button_label_hover", false )
	}))

	Button.SetPanelEvent('onactivate', (function(){
		if (main_slot != -1){
			GameEvents.SendCustomGameEventToServer( "crystalize_weapon", { main_slot : main_slot } );
			clean_forge()
		}
	}))

	button_text = $.CreatePanel( "Label", Button , "button_text" );
	button_text.style.position = "3px 20px 1px";
	button_text.text = $.Localize("#forge_tab_2")
	button_text.SetHasClass( "deny_button_label", true )

	var pos_sub_y = 0
	display_result("new_soul_damage")
	pos_sub_y = pos_sub_y + 35
	display_result("new_soul_m_damage")
	pos_sub_y = pos_sub_y + 35
	display_result("new_soul_loh")
	pos_sub_y = pos_sub_y + 35
	display_result("new_soul_attack_speed")
	pos_sub_y = pos_sub_y + 35
	display_result("new_soul_ls")
	function display_result(stats_name){
			button_text = $.CreatePanel( "Label", $("#display") , stats_name );
			button_text.style.position = "15px "+(150+pos_sub_y) +"px 1px";
			button_text.text = ""
			button_text.SetHasClass( "normal_label_2", true )

	}
}

Object.size = function(obj) {
    var size = 0, key;
    for (key in obj) {
        if (obj.hasOwnProperty(key)) size++;
    }
    return size;
};

function reset_evolution(){
	$("#display").RemoveAndDeleteChildren()
	main_panel = $.CreatePanel( "Image", $("#display") , "main_slot" );
	main_panel.style.position = "500px 300px 1px";
	main_panel.SetHasClass( "slot", true )

	description = $.CreatePanel( "Label", $("#display") , "Description" );
	description.style.position = "80px 50px 1px";
	description.text = $.Localize("#forge_tab_3_desc")
	description.SetHasClass( "normal_label", true )
}

function display_soul_evolution(){
	selected_tab = "evolution"
	GameUI.CustomUIConfig().Events.FireEvent( "update_forge_panel", { selected_tab : selected_tab} );
	main_slot = -1
	secondary_slot = -1
	reset_evolution()

}
