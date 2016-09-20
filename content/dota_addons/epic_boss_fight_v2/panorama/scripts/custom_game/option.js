GameEvents.Subscribe( "Start_Vote", Display_Vote_For_Diff)
GameEvents.Subscribe( "Update_Difficulty_HUD", update_difficulty)
GameUI.CustomUIConfig().Events.SubscribeEvent( "CLOSE_ALL", Close_Option)

Game.AddCommand( "+Option_Key", option_key, "", 0 );

$("#Label_Option").text =  $.Localize("#Option")

function option_key(){

 if ($("#Panel") != null) {
	Close_Option()
 }else{
	Open_Option()
 }

}

var difficulty = 0
var Local_ID = Players.GetLocalPlayer()
var music_state = false;

function Open_Option(){
	if ($("#Panel")!=null){
		Close_Option()
	}
	$("#Open_Option").visible = false
	var Parent = $.GetContextPanel()
	var Panel = $.CreatePanel( "Panel", Parent , "Panel");
	var Active_Custom_Music_Panel = $.CreatePanel( "ToggleButton", Panel , "Music_Active");
	Active_Custom_Music_Panel.SetHasClass( "CheckBox", true );
	Active_Custom_Music_Panel.SetHasClass( "CheckBox_pos", true );
	Active_Custom_Music_Panel.checked = music_state;
	Active_Custom_Music_Panel.SetPanelEvent("onactivate", function(){
		$.Msg(Active_Custom_Music_Panel.checked)
    music_state = Active_Custom_Music_Panel.checked;
		GameUI.CustomUIConfig().Events.FireEvent( "Mute_Music", { state : Active_Custom_Music_Panel.checked})
	})

	var check_text = $.CreatePanel( "Label", Panel , "check_text");
	check_text.text = $.Localize("#mute_music")
	check_text.SetHasClass( "text_BIG", true )
	check_text.SetHasClass( "CheckBox_text_pos", true )

	var Difficulty_Entry = $.CreatePanel( "TextEntry", Panel , "Difficulty_Entry");
	Difficulty_Entry.text = difficulty
	Difficulty_Entry.SetHasClass( "Difficulty_Entry", true )

	var Change_Difficulty = $.CreatePanel( "Panel", Panel , "Change_Difficulty");
	Change_Difficulty.SetHasClass( "Difficulty_Vote_Button", true );
	Change_Difficulty.SetPanelEvent("onactivate", function(){
		if (Difficulty_Entry.text >= 0){
			GameEvents.SendCustomGameEventToServer( "Change_Difficulty_Vote", { difficulty : Difficulty_Entry.text} )
		}
	})

	var Difficulty_Text = $.CreatePanel( "Label", Change_Difficulty , "Difficulty_Text");
	Difficulty_Text.text = $.Localize("#Change_Difficulty")
	Difficulty_Text.SetHasClass( "text", true )

	var Close = $.CreatePanel( "Panel", Panel , "Close");
	Close.SetHasClass( "Close_Button", true );
	Close.SetPanelEvent("onactivate", function(){
		 Close_Option()
	})
}

function Display_Vote_For_Diff(data) {
	if (data.voter_ID != Local_ID){
		var Parent = $.GetContextPanel()
		var player_name = Players.GetPlayerName( data.voter_ID )
		var Panel = $.CreatePanel( "Panel", Parent , "Vote_Panel");
		var Yes_Button = $.CreatePanel( "Panel", Parent , "Yes_Button");
		var No_Button = $.CreatePanel( "Panel", Parent , "No_Button");
		var Vote_Text = $.CreatePanel( "Label", Parent , "Vote_Text");

		Yes_Button.SetPanelEvent("onactivate", function(){
			GameEvents.SendCustomGameEventToServer( "Get_Diff_Vote", { Vote : 1} )

		})

		No_Button.SetPanelEvent("onactivate", function(){
			GameEvents.SendCustomGameEventToServer( "Get_Diff_Vote", { Vote : -1} )
		})
		Vote_Text = player_name + $.Localize("#"+Want_change_Diff) + data.difficulty
	}
}

function Close_Option(){
	var Panel = $("#Panel")
	Panel.RemoveAndDeleteChildren()
	Panel.DeleteAsync(0)
	$("#Open_Option").visible = true
}

function update_difficulty(data){
	difficulty = data.difficulty
	if ($("#Panel")!= null){
		Difficulty_Entry.Text = difficulty
	}
}
