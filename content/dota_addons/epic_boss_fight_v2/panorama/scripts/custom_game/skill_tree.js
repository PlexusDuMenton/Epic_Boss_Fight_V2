var node_size = 64
var node_space_y = 40
var node_space_x = 80
var init_pos_y = 350
var init_pos_x = 10
var ID = Players.GetLocalPlayer()
var skill_tree = {}
var table = {}
var hero_level = 1
var skill_points = 0
var selected_skill = null
var skill_ammounts = 0

Object.size = function(obj) {
    var size = 0, key;
    for (key in obj) {
        if (obj.hasOwnProperty(key)) size++;
    }
    return size;
};

function refresh_visibility(){
  for (skillID = 0; skillID < skill_ammounts+1; skillID++){
    var panel = $("#skill_"+skillID)
    var visible = false
    var skill = skill_tree[skillID]

    if (typeof skill != "undefined" && panel != null){
      if (skillID == 0){
        visible = true
      }else{
        //if (hero_level > skill.min_lvl && skill.once_unlocked == 1){
        if (skill.once_unlocked == 1){
          visible = true
        }
        if (skill.unlocked == 1){
          visible = true
        }
      }
      if(skill.unlocked != 1){
        panel.SetHasClass( "skill_image", false );
        panel.SetHasClass( "skill_image_locked", true );
        panel.SetHasClass( "skill_image_unlock", false );
      }
      if (skill.unlocked == 1 && skill.lvl > 0){
        panel.SetHasClass( "skill_image", true );
        panel.SetHasClass( "skill_image_locked", false );
        panel.SetHasClass( "skill_image_unlock", false );
      }
      if(skill.unlocked == 1 && skill.lvl ==0){
        panel.SetHasClass( "skill_image", false );
        panel.SetHasClass( "skill_image_locked", false );
        panel.SetHasClass( "skill_image_unlock", true );
      }

      panel.visible = visible
    }
  }
}

function close_all(){
	if ($("#main_panel").visible == true){
		close_skill_tree()
	}
	GameUI.CustomUIConfig().Events.FireEvent( "CLOSE_ALL",{})
}

function open_with_command(){
	if ($("#main_panel").visible == true){
		close_skill_tree()
	}else{
		create_tree()
	}
}

GameEvents.Subscribe( "Display_Bar", Update)
	function Update(){
		Game.AddCommand( "+Open_ST", open_with_command, "", 0 );
		Game.AddCommand( "+Close_ALL", close_all, "", 0 );
		$.Schedule(0.2, Updateskill_tree);
	}

	function Updateskill_tree()
	{
		$.Schedule(0.1, Updateskill_tree);
		CustomNetTables.SubscribeNetTableListener
		key = "player_" + ID.toString()
		skill_tree = CustomNetTables.GetTableValue( "skill_tree", key).skill_tree
		table = CustomNetTables.GetTableValue( "skill_table", key).skill_table
		hero_level = CustomNetTables.GetTableValue( "info", key).LVL
		CustomNetTables.SubscribeNetTableListener
		key = "player_" + ID.toString()
		skill_points = CustomNetTables.GetTableValue( "stats", key).stats_points
		if ($("#main_panel").visible == true ){
			$("#Info_skill").text = $.Localize("#Power_Points") + " : " + skill_points
		}
    refresh_visibility()
	}

GameUI.CustomUIConfig().Events.SubscribeEvent( "open_skill_bar", open_with_command)

$("#main_panel").visible = false


function close_skill_tree(){

selected_skill = null
$("#main_panel").visible = false
$("#skill_tree_panel").RemoveAndDeleteChildren()
$("#tooltip_panel").RemoveAndDeleteChildren()
$("#skill_tree_info").RemoveAndDeleteChildren()

}

function create_tree() {
	close_skill_tree()

	var respec = $.CreatePanel( "Panel", $("#skill_tree_panel") , "upgrade" );
	respec.SetHasClass( "upgrade_button", true );
	respec.style.position = "50px 50px 0px";
	var label_respec = $.CreatePanel( "Label", respec , "upgrade_label" );
	label_respec.SetHasClass( "respec_title", true );
	label_respec.text = $.Localize("#Respec")
	respec.SetPanelEvent("onactivate", function(){
			GameEvents.SendCustomGameEventToServer( "respec", {} );
			close_skill_tree()
			$.Schedule(0.3,function(){create_tree()})
		})

	respec.SetPanelEvent("onmouseover", function(){
		tool_tip_respec(respec)
		})
	respec.SetPanelEvent("onmouseout", function(){
		$("#tooltip_panel").RemoveAndDeleteChildren()
	})
	$("#main_panel").visible = true
	var SP_label = $.CreatePanel( "Label", $("#skill_tree_panel"), "Info_skill" )
		SP_label.SetHasClass( "title", true );
		SP_label.style.position = "500px 50px 1px";
	var table_size = (Object.size(table))
	$("#skill_tree_panel").style.width = ((table_size+1) *(node_space_x + node_size) + init_pos_x) + "px"
	$("#tooltip_panel").style.width = ((table_size+1) *(node_space_x + node_size) + init_pos_x) + "px"
	for (i = 0; i < table_size; i++){
		var coord_x = i*(node_space_x + node_size) + init_pos_x
		var node_ammount = Object.size(table[i])
		var coord_y = (node_ammount/2)*node_size + (node_ammount-1) * (node_space_y/2) + init_pos_y

		for (j = 1; j < node_ammount+1; j++){
			create_node(table[i][j],i,j,coord_x,coord_y)
			coord_y = coord_y - (node_size + node_space_y)
		}

	}
	var Close = $.CreatePanel( "Panel", $("#main_panel") , "close" );
		Close.SetHasClass( "Close", true );
		Close.SetPanelEvent("onactivate", function(){
			close_skill_tree()
		})


}

function create_node(skillID,i,j,coord_x,coord_y){
  skill_ammounts = skill_ammounts + 1
	var skill = skill_tree[skillID]
	var Panel = $.CreatePanel( "Image", $("#skill_tree_panel") , "skill_"+skill.ID );
    Panel.visible = false
		Panel.SetHasClass( "skill_image_unlock", true );
		Panel.style.position = coord_x+"px "+coord_y+"px 0px";

		Panel.SetImage("file://{images}/custom_game/skill_tree/icon/"+skill.file_name+".psd")

		Panel.SetPanelEvent("onmouseover", function(){
			Panel.OverPanel = true
			create_over_bright(Panel,skillID)
			create_fast_tool_tip(Panel,skillID)
		})
		Panel.SetPanelEvent("onmouseout", function(){
			Panel.OverPanel = false
			destroy_over_bright(Panel,skillID)
		})
		Panel.SetPanelEvent("onactivate", function(){
			create_tool_tip(skillID)
		})
		Panel.SetPanelEvent("oncontextmenu", function(){
			GameEvents.SendCustomGameEventToServer( "Upgrade_skill", { skillid : skill.ID} );
			destroy_over_bright(Panel,skillID)
			$.Schedule(0.11,function(){
				if (Panel.OverPanel == true){
					create_over_bright(Panel,skillID)
					create_fast_tool_tip(Panel,skillID)
				}
				if (selected_skill == skillID ){
						create_tool_tip(skillID)
				}
			})
		})
}



function create_tool_tip(skillID){

var skill = skill_tree[skillID]
selected_skill = skillID
var tooltip_panel = $("#skill_tree_info")

	tooltip_panel.RemoveAndDeleteChildren()
var Name = $.CreatePanel( "Label", tooltip_panel , "Name" );
	Name.SetHasClass( "title", true );
	Name.text = $.Localize("#"+skill.file_name);
	Name.style.position = "10px 20px 0px";
	if (skill.unlocked != 1) {
		Name.style.color = "#AAAAAA"
	}

	if (skill.lvl == skill.max_lvl) {
		Name.style.color = "#FFFF33"
		Name.style.brightness = 1.5
	}

	var type = $.CreatePanel( "Label", tooltip_panel , "Type" );
	type.SetHasClass( "text", true );
	type.text = $.Localize("#"+skill.type);
	type.style.position = "10px 50px 0px";

	var lvl = $.CreatePanel( "Label", tooltip_panel , "Level" );
	lvl.SetHasClass( "text", true );
	lvl.text = "Level : " + skill.lvl + " / " + skill.max_lvl;
	lvl.style.position = "10px 80px 0px";
	var pos_y = 110
	if (skill.lvl < skill.max_lvl){
		var req = $.CreatePanel( "Label", tooltip_panel , "lvl_requirement" );
		req.SetHasClass( "text", true );
		req.text = $.Localize("#I_level")+" : " + (skill.min_lvl + (skill.lvl)*skill.lvl_gap);
		if ((skill.min_lvl + (skill.lvl)*skill.lvl_gap) > hero_level ) {
			req.style.color = "#FF0000"
		}
		req.style.position = "10px "+pos_y +"px 0px";
	}
	pos_y = pos_y + 30
	if (skill.ID > 0){
		Unlockedby = skill_tree[skill.unloked_by]
		var req_skill = $.CreatePanel( "Label", tooltip_panel , "skill_requirement" );
		req_skill.SetHasClass( "text", true );
		req_skill.text = $.Localize("#Req_ability")+" : " + $.Localize("#"+Unlockedby.file_name);
		req_skill.style.position = "10px "+pos_y +"px 0px";
		if (skill.unlocked != 1) {
			req_skill.style.color = "#FF0000"
		}
		pos_y = pos_y + 40
	}

	var Up = $.CreatePanel( "Panel", tooltip_panel , "upgrade" );
	Up.SetHasClass( "upgrade_button", true );
	Up.style.position = "220px 50px 0px";
	var label_Up = $.CreatePanel( "Label", Up , "upgrade_label" );
	label_Up.SetHasClass( "button_label_unselected", true );
	label_Up.text = $.Localize("#Upgrade_Skill")
	Up.SetPanelEvent("onactivate", function(){
			GameEvents.SendCustomGameEventToServer( "Upgrade_skill", { skillid : skill.ID} );
			$.Schedule(0.21,function(){create_tool_tip(skillID)})
		})
	if (skill.type == "passive"){
	var Desc = $.CreatePanel( "Label", tooltip_panel , "description" );
	Desc.SetHasClass( "text", true );
	Desc.text = $.Localize("#"+skill.file_name+"_desc");
	Desc.style.position = "10px "+(pos_y)+"px 0px";
	}
	if (skill.type == "stats"){
		pos_y = create_label(skill.hp,pos_y,$.Localize("#Bonus_Health"))
		pos_y = create_label(skill.hp_regen,pos_y,$.Localize("#Health_Regen"))
		pos_y = create_label(skill.mp,pos_y,$.Localize("#Bonus_Mana"))
		pos_y = create_label(skill.mp_regen,pos_y,$.Localize("#Mana_Regen"))
		pos_y = create_label(skill.str,pos_y,$.Localize("#Bonus_Strength"))
		pos_y = create_label(skill.agi,pos_y,$.Localize("#Bonus_Agility"))
		pos_y = create_label(skill.int,pos_y,$.Localize("#Bonus_Inteligence"))
		pos_y = create_label(skill.attack_speed,pos_y,$.Localize("#Bonus_Attack_Speed"))
		pos_y = create_label(skill.range,pos_y,$.Localize("#Bonus_Range"))
		pos_y = create_label(skill.move_speed,pos_y,$.Localize("#Bonus_Move_Speed"))
		pos_y = create_label(skill.armor,pos_y,$.Localize("#Bonus_Armor"))
		pos_y = create_label(skill.damage_mult,pos_y,$.Localize("#Bonus_Damage")," %")

		$("#tooltip_panel").style.height = (pos_y + 100) + "px"

		function create_label(stat,pos_y,stat_name,other){
			if (typeof stat != 'undefined') {
				if (typeof other == 'undefined') {other = ""}
				var stats_size = (Object.size(stat))
				var mom = $.CreatePanel( "Label", tooltip_panel, "Info_skill_name" )
				mom.SetHasClass( "text", true );
				mom.style.position = "10px "+ pos_y+"px 1px";
				pos_y = pos_y + 25
				mom.text = $.Localize("#"+stat_name) + " : ";
				var stat_size = (Object.size(stat))
				for (i = 1; i < stat_size; i++){
					var Label = $.CreatePanel( "Label", tooltip_panel, "Info_skill" )
					Label.SetHasClass( "small_text", true );
					Label.style.position = "10px "+ pos_y+"px 1px";
					pos_y = pos_y + 20
					Label.text = $.Localize("#Level")+" " + i + " : " + Number((stat[i]).toFixed(2)) + other
					if (skill.lvl+1 == i && hero_level >= (skill.min_lvl + (i-1)*skill.lvl_gap) && skill.unlocked == 1 )
					{
						Label.style.color = "#FFFF33"
					} else if (skill.lvl+1 == i)
					{
						Label.style.color = "#DD33FF"
					}
					else if (skill.lvl >= i) {
						Label.style.color = "#33FF33"
					}

					else if (hero_level < (skill.min_lvl + (i-1)*skill.lvl_gap)) {
						Label.style.color = "#FF3333"
					}

				}
				return pos_y = pos_y + 15
			}else{return pos_y }

		}
	}
	else if (skill.type == "active" || skill.type == "ultimate")
	{
		var skill_image = $.CreatePanel( "DOTAAbilityImage", tooltip_panel , "skillimage" );
		skill_image.SetHasClass( "skill_image", true );
		skill_image.abilityname = skill.name
		skill_image.style.position = "200px 200px 0px";
		skill_image.SetPanelEvent("onmouseover", function(){
				$.DispatchEvent('DOTAShowAbilityTooltip', skill_image,skill.name)
			})
		skill_image.SetPanelEvent("onmouseout", function(){
			$.DispatchEvent('DOTAHideAbilityTooltip')
		})
		if (skill.lvl > 0){
			var equip = $.CreatePanel( "Panel", tooltip_panel , "equip" );
			equip.style.position = "100px 400px 0px";
			var label_equip = $.CreatePanel( "Label", equip , "equip_label" );
			label_equip.SetHasClass( "button_label_unselected", true );
			equip.SetHasClass( "upgrade_button", true );
			if (skill.equip != 1){
				label_equip.text = $.Localize("#Equip_skill")
				equip.SetPanelEvent("onactivate", function(){
					if (skill.type == "active"){
						equip.visible = false
						var pos_x_but = 50
						for (j = 1; j < 5; j++){
						var button = $.CreatePanel( "Panel", tooltip_panel , "equip_button"+j );
							button.style.position = pos_x_but +"px 400px 0px";
							pos_x_but = pos_x_but + 100
							button.SetHasClass( "equip_button", true );
							create_button_effect(j,skillID,button)

						var label_button = $.CreatePanel( "Label", button , "equip_button_label"+j );
							label_button.SetHasClass( "button_label_unselected", true );
							label_button.text = $.Localize("#slot") + j

						}
					}else{
						GameEvents.SendCustomGameEventToServer( "add_skill", { skillid : skillID,slot : 5} );
						$.Schedule(0.21,function(){create_tool_tip(skillID)})
					}
						})
			}
			else{
				label_equip.text = $.Localize("#Unequip_skill")
				equip.SetPanelEvent("onactivate", function(){
						GameEvents.SendCustomGameEventToServer( "Unequip_skill", { slot : skill.slot} );
						$.Schedule(0.21,function(){create_tool_tip(skillID)})
					})
			}
		}

	}
}

function create_button_effect(i,skillID,panel){
	panel.SetPanelEvent("onactivate", function(){
					GameEvents.SendCustomGameEventToServer( "add_skill", { skillid : skillID,slot : i} );
					$.Schedule(0.21,function(){create_tool_tip(skillID)})
		})
}

function tool_tip_respec(Panel){
	var tooltip_panel = $.CreatePanel( "Panel", $("#tooltip_panel") , "Tooltip" );
	tooltip_panel.hittest = false
	var Panel_pos_x = 200
	var Panel_pos_y = 100
	tooltip_panel.style.position = Panel_pos_x + "px " + Panel_pos_y +"px 0px";
	tooltip_panel.SetHasClass( "small_tooltip", true );

	var text = $.CreatePanel( "Label", tooltip_panel , "Name" );
	text.SetHasClass( "title", true );
	if (Players.HasCustomGameTicketForPlayerID( ID ) == true){
		text.text = $.Localize("#respec_free");
	}else{
		text.text = $.Localize("#respec_cost")+ "\nXp cost : " + Math.ceil(CustomNetTables.GetTableValue( "info", ("player_" + ID)).MAXHXP*0.05) ;
	}
	text.style.position = "5px 10px 0px";
	text.hittest = false
}



function create_fast_tool_tip(Panel,skillID){
	var skill = skill_tree[skillID]
	var tooltip_panel = $.CreatePanel( "Panel", $("#tooltip_panel") , "Tooltip" );
	tooltip_panel.hittest = false
		var Panel_pos_x = Panel.GetPositionWithinWindow()["x"] + 10

		var Panel_pos_y = Panel.GetPositionWithinWindow()["y"] - 200
		tooltip_panel.style.position = Panel_pos_x + "px " + Panel_pos_y +"px 0px";
		tooltip_panel.SetHasClass( "tooltip", true );

	var Name = $.CreatePanel( "Label", tooltip_panel , "Name" );
	Name.SetHasClass( "title_tt", true );
	Name.text = $.Localize("#"+skill.file_name);
	Name.style.position = "10px 20px 0px";
	Name.hittest = false
	if (skill.unlocked != 1) {
		Name.style.color = "#AAAAAA"
	}else{
    Name.style.color = "#FF5555"
    Name.style.brightness = 0.75
  }

	if (skill.lvl == skill.max_lvl) {
		Name.style.color = "#FFFF33"
		Name.style.brightness = 1.5
	}

	var type = $.CreatePanel( "Label", tooltip_panel , "Name" );
	type.SetHasClass( "text", true );
	type.text = $.Localize("#"+skill.type);
	type.style.position = "10px 50px 0px";
	type.hittest = false

	var lvl = $.CreatePanel( "Label", tooltip_panel , "Name" );
	lvl.SetHasClass( "text", true );
	lvl.text = "Level : " + skill.lvl + " / " + skill.max_lvl;
	lvl.style.position = "10px 80px 0px";
	lvl.hittest = false
	var pos_y = 110
	if (skill.lvl < skill.max_lvl){
		var req = $.CreatePanel( "Label", tooltip_panel , "Name" );
		req.SetHasClass( "text", true );
		req.text = $.Localize("#Required_level") + " : " + (skill.min_lvl + (skill.lvl)*skill.lvl_gap);
		req.hittest = false
		if ((skill.min_lvl + (skill.lvl)*skill.lvl_gap) > hero_level ) {
			req.style.color = "#FF0000"
		}
		req.style.position = "10px "+pos_y +"px 0px";
		pos_y = pos_y + 30
	}
	if (skill.ID > 0){
		Unlockedby = skill_tree[skill.unloked_by]
		var req_skill = $.CreatePanel( "Label", tooltip_panel , "Name" );
		req_skill.SetHasClass( "text", true );
		req_skill.text = $.Localize("#Required_Ability") + " : " + $.Localize("#"+Unlockedby.file_name);
		req_skill.style.position = "10px "+pos_y +"px 0px";
		req_skill.hittest = false
		if (skill.unlocked != 1) {
			req_skill.style.color = "#FF0000"
		}
	}




}


function advanced_over_bright(Panel,p,skillID){
var skill = skill_tree[skillID]
if (skill_tree[skill.unlock_id[p]].unlocked == 0){
			Panel.SetImage("file://{images}/custom_game/inventory/item_slot_unlock_locked.png")
		}else {
			Panel.SetImage("file://{images}/custom_game/inventory/item_slot_unlock.png")
		}
}

function create_over_bright(Panel,skillID){
	var skill = skill_tree[skillID]
	var overlay = $.CreatePanel( "Image", Panel , "skill_hover" );
	overlay.SetHasClass( "over_bright", true );
	if (skill.unlocked == 1 && skill.min_lvl + ((skill.lvl)*skill.lvl_gap) <= hero_level){
		overlay.SetImage("file://{images}/custom_game/inventory/item_slot_hover.png")
	}else {
		overlay.SetImage("file://{images}/custom_game/inventory/item_slot_lock.png")
	}
	for (p = 1; p < (Object.size(skill.unlock_id) + 1); p++){
		var unlock_panel = $("#skill_"+skill.unlock_id[p])
		var unlock_panel_overlay = $.CreatePanel( "Image", unlock_panel , "skill_hover_unlock" );
		unlock_panel_overlay.SetHasClass( "over_bright", true );
		advanced_over_bright(unlock_panel_overlay,p,skillID)
	}
	if (skill.ID > 0){
		Unlockedbypanel = $("#skill_"+skill.unloked_by)
		var unlocker_panel_overlay = $.CreatePanel( "Image", Unlockedbypanel , "skill_hover_unlocker" );
		unlocker_panel_overlay.SetHasClass( "over_bright", true );
		if (skill_tree[skill.unloked_by].unlocked == 0 ){
			unlocker_panel_overlay.SetImage("file://{images}/custom_game/inventory/item_slot_active_locked.png")
		}else {
			unlocker_panel_overlay.SetImage("file://{images}/custom_game/inventory/item_slot_active.png")
		}
	}
}

function destroy_over_bright(Panel,skillID){
	var skill = skill_tree[skillID]
	$.Schedule(0.025,destroy);
	function destroy(){
		$("#tooltip_panel").RemoveAndDeleteChildren()
		Panel.RemoveAndDeleteChildren()
		for (p = 1; p < (Object.size(skill.unlock_id) + 1); p++){
			var unlock_panel = $("#skill_"+skill.unlock_id[p])
			unlock_panel.RemoveAndDeleteChildren()
		}
		if (skill.ID > 0){
			Unlockedbypanel = $("#skill_"+skill.unloked_by)
			Unlockedbypanel.RemoveAndDeleteChildren()
		}
	}

}
