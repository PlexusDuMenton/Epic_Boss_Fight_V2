var Selected_slot = 0
var sub_selected = 0
var class_selected = ""

var hero_name = ""
var panel_ammount = 3
var hero_list = {}

Object.size = function(obj) {
    var size = 0, key;
    for (key in obj) {
        if (obj.hasOwnProperty(key)) size++;
    }
    return size;
};
var ID = Players.GetLocalPlayer()

if (Players.HasCustomGameTicketForPlayerID( ID ) == true) {
	panel_ammount = 6
}

GameEvents.Subscribe( "update_slot", update_slot)
GameEvents.Subscribe( "Display_Bar", close_all)
var empty_slot = {}
for (i = 1; i < 7; i++){
	empty_slot[i] = true
}

function update_slot(val){
		$.Schedule(0.5,function(){
			GameEvents.SendCustomGameEventToServer( "get_save", {} );
		})
		var data = val.data
    if (typeof data != "undefined"){
  		hero_list = val.hero_list
  		var table_size = panel_ammount
  		for (i = 1; i < table_size+1; i++){
  			var hero = data[String(i)]

  			var panel = $("#slot_"+i)
  			panel.RemoveAndDeleteChildren()
  			if (typeof hero != 'undefined'){

  				empty_slot[i] = false
  				var icon = $.CreatePanel( "Image", panel , "icon_"+i );
  				icon.SetHasClass( "icon", true );
  				icon.SetImage("file://{images}/custom_game/hero/"+hero.hero_name+".png")
  				var XPBG = $.CreatePanel( "Panel", panel , "XPBG_"+i );
  				XPBG.SetHasClass( "XPBG_Bars", true );
  				var XPB = $.CreatePanel( "Panel", panel , "XP_Bar_"+i );
  				XPB.SetHasClass( "XP_Bars", true );


  				var Label = $.CreatePanel( "Label", panel , "hero_name_"+i );
  				Label.SetHasClass( "hero_name", true );
  				Label.text=$.Localize("#"+hero.hero_name+"_ebf")

  				var XP = $.CreatePanel( "Label", panel , "XP_"+i );
  				XP.SetHasClass( "hero_xp", true );
  				XP.text=$.Localize("#XP")+" : "+ hero.xp +" / " + hero.max_xp

  				var level = $.CreatePanel( "Label", panel , "XP_"+i );
  				level.SetHasClass( "hero_level", true );
  				level.text=$.Localize("#Level") + " " + hero.level


  				XPB.style.clip = "rect( 0% ," + ((Number((hero.xp).toFixed(0))/Number((hero.max_xp).toFixed(0)))*86.33+0.59) + "%" + ", 100% ,0% )";


  			}else{
  				empty_slot[i] = true
  				var icon = $.CreatePanel( "Image", panel , "icon_"+i );
  				icon.SetHasClass( "unknow_icon", true );
  				var Label = $.CreatePanel( "Label", panel , "new_hero_"+i );
  				Label.SetHasClass( "Create_NH", true );
  				Label.text=$.Localize("#Create_New_Hero")
  			}
  		}
    }
}

function close_all(){
	$.GetContextPanel().DeleteAsync(0)
}

function Display_hero_info(panel){
	var parent = panel.GetParent()
	if ($("#sub_parent")!=null){
		$("#sub_parent").DeleteAsync(0)
	}

	var sub_parent = $.CreatePanel( "Label", parent , "sub_parent");
	sub_parent.SetHasClass( "sub_parent", true );

	var Description = $.CreatePanel( "Label", sub_parent , "hero_desc");
	Description.SetHasClass( "Label_Desc", true );
	Description.text=$.Localize("#"+class_selected+"_ebf_desc")


	$.Schedule(0.10,function(){
		var hero_panel = $.CreatePanel( "Panel", sub_parent, "Create_hero" );
		hero_panel.SetHasClass( "slot_unselected", true );
		hero_panel.SetPanelEvent('onactivate', (function(){
			GameEvents.SendCustomGameEventToServer( "New_Hero", { PID: ID,Hero_Name : class_selected,Slot : Selected_slot} );
		}))
		var New_Hero = $.CreatePanel( "Label", hero_panel , "New_Hero");
		hero_panel.style.position = "0px "+(Description.actuallayoutheight+100)+"px 1px";


		New_Hero.SetHasClass( "Create_NH", true );
		New_Hero.text=$.Localize("#New_Hero")
		})

}

function update_selected_slot(){
	class_selected = ""
	if ($("#hero_panel_parent") != null){
		$("#hero_panel_parent").DeleteAsync(0)
	}
	if (empty_slot[Selected_slot] == true){
		function set_click(slot_panel,id,hero_name)
		{

			slot_panel.SetPanelEvent('onactivate', (function(){
				class_selected = hero_name
				var other_panel = $("#hero_panel_"+sub_selected)
				if (other_panel != null){
				other_panel.SetHasClass( "slot_selected", false );
				other_panel.SetHasClass( "slot_unselected", true );
			}
				slot_panel.SetHasClass( "slot_selected", true );
				slot_panel.SetHasClass( "slot_unselected", false );
				sub_selected = id
				Display_hero_info(slot_panel)
			}))
		}
		var hero_ammount = (Object.size(hero_list))
		var parent = $.CreatePanel( "Panel", $("#parent") , "hero_panel_parent" );
		parent.SetHasClass( "parent_hero_choice", true );
		for (i = 1; i < hero_ammount+1; i++){
			var hero_name = hero_list[i]
			var hero_panel = $.CreatePanel( "Panel", parent, "hero_panel_"+i );
			hero_panel.SetHasClass( "slot_unselected", true );
			hero_panel.style.position = "430px "+(149*(i-1)+29) +"px 1px";
			var hero_icon = $.CreatePanel( "Image", hero_panel , "hero_icon_"+i );
			hero_icon.SetHasClass( "icon", true );
			hero_icon.SetImage("file://{images}/custom_game/hero/"+hero_name+".png");

			var Label = $.CreatePanel( "Label", hero_panel , "hero_name_"+i );
			Label.SetHasClass( "Create_NH", true );
			Label.text=$.Localize("#"+hero_name+"_ebf")
			set_click(hero_panel,i,hero_name)
		}
	}else{
		var parent = $.CreatePanel( "Panel", $("#parent") , "hero_panel_parent" );
		parent.SetHasClass( "parent_load_choice", true );
		var load_panel = $.CreatePanel( "Panel", parent, "option_1" );
		load_panel.SetHasClass( "slot_unselected", true );
		load_panel.style.position = "0px "+(0+29) +"px 1px";
		var Label_1 = $.CreatePanel( "Label", load_panel , "hero_name_"+i );
		Label_1.SetHasClass( "Create_NH", true );
		Label_1.text=$.Localize("#LOAD")
		load_panel.SetPanelEvent('onactivate', (function(){
			GameEvents.SendCustomGameEventToServer( "Load_Hero", { PID: ID,Slot : Selected_slot} );
		}))

		var delete_panel = $.CreatePanel( "Panel", parent, "option_2" );
		delete_panel.SetHasClass( "slot_unselected", true );
		delete_panel.style.position = "0px "+(149+29) +"px 1px";
		var Label_2 = $.CreatePanel( "Label", delete_panel , "hero_name_"+i );
		Label_2.SetHasClass( "Create_NH", true );
		Label_2.text=$.Localize("#DELETE_HERO")
		Label_2.style.color = "#FF5566"
		delete_panel.SetPanelEvent('onactivate', (function(){
			Label_2.text=$.Localize("#WAIT")
			delete_panel.SetPanelEvent('onactivate',(function(){}))
				$.Schedule(1.0,function(){
					Label_2.text=$.Localize("#confirm")
					delete_panel.SetPanelEvent('onactivate', (function(){
						GameEvents.SendCustomGameEventToServer( "delete_slot", { PID: ID,Slot : Selected_slot} );
						$.Schedule(0.10,function(){
							Reset_Screen()
						})
					}))
				})
		}))
	}

}
function Reset_Screen()
{
	$("#parent").RemoveAndDeleteChildren()
	Create_screen()
}

Create_screen()
function Create_screen(){
	function set_click(slot_panel,id)
	{
		slot_panel.SetPanelEvent('onactivate', (function(){
			var other_panel = $("#slot_"+Selected_slot)
			if (other_panel != null){
			other_panel.SetHasClass( "slot_selected", false );
			other_panel.SetHasClass( "slot_unselected", true );
		}
			slot_panel.SetHasClass( "slot_selected", true );
			slot_panel.SetHasClass( "slot_unselected", false );
			Selected_slot = id
			update_selected_slot()
		}))
	}
	var panel = $("#parent")
	var selection_BG = $.CreatePanel( "Panel", panel , "background_slot" );
	selection_BG.SetHasClass( "background_slot", true );

	/* check number of slot he can have
	create the slot
	the selected slot is updated each time the player left click on a slot*/


	for (i = 1; i < panel_ammount+1; i++){
		var slot_panel = $.CreatePanel( "Panel", selection_BG , "slot_"+i );
		slot_panel.SetHasClass( "slot_unselected", true );
		set_click(slot_panel,i)
		slot_panel.style.position = "0px "+(149*(i-1)+29) +"px 1px";
	}
	GameEvents.SendCustomGameEventToServer( "get_save", {} );

	//create the Enter game panel

}
/*


*/
