GameEvents.Subscribe( "Ready_Votes", ready_votes)
GameEvents.Subscribe( "Stop_Vote", clean_all)
GameEvents.Subscribe( "next_votes", next_votes)

$("#Vote_Menu").visible = false

Game.AddCommand( "+Ready", Ready_Vote_Key, "", 0 );

function Ready_Vote_Key(){
	if ($("#Vote_Menu").visible == true && $("#vote_text") != null && $("#vote_Button_ready") != null){
		$("#vote_Button_ready").DeleteAsync(0)
		$("#vote_text").DeleteAsync(0)
		GameEvents.SendCustomGameEventToServer( "Vote_Round", { context: "lobby"} );
	}
}

function ready_votes(){
	$("#Vote_Menu").visible = true
	var vote_time = $.CreatePanel("Label",$("#Vote_Menu"), "vote_time" );
	vote_time.text = $.Localize("#Time") + " : 60 "+ $.Localize("#seconds")
	vote_time.SetHasClass( "time", true )

	var Button = $.CreatePanel("Button",$("#Vote_Menu"), "vote_Button_ready" );
	Button.style.position = "65px 120px 0px"
	Button.SetHasClass( "button2", true );

	var vote_text = $.CreatePanel("Label",Button, "vote_text" );
	vote_text.text = $.Localize("#Ready")
	vote_text.SetHasClass( "normal_label", true );

	Button.SetPanelEvent('onactivate', (function(){
		Button.DeleteAsync(0)
		vote_text.DeleteAsync(0)
		GameEvents.SendCustomGameEventToServer( "Vote_Round", { context: "lobby"} );
	}))
	refresh_time()
}


function next_votes(){
	$("#Vote_Menu").visible = true
	var vote_time = $.CreatePanel("Label",$("#Vote_Menu"), "vote_time" );
	vote_time.text = $.Localize("#Time") + " : 40 "+ $.Localize("#seconds")
	vote_time.SetHasClass( "time", true );

	var Button_1 = $.CreatePanel("Button",$("#Vote_Menu"), "vote_Button_lobby" );
	Button_1.SetHasClass( "button", true );
	Button_1.style.position = "15px 120px 0px"

	var vote_text_1 = $.CreatePanel("Label",Button_1, "vote_text" );
	vote_text_1.text = $.Localize("#ToLobby")
	vote_text_1.SetHasClass( "normal_label", true );

	Button_1.SetPanelEvent('onactivate', (function(){
		clean_all()
		GameEvents.SendCustomGameEventToServer( "Vote_Round", { context: "reward",vote: "lobby"} );
	}))

	var Button_2 = $.CreatePanel("Button",$("#Vote_Menu"), "vote_Button_next" );
	Button_2.SetHasClass( "button", true );
	Button_2.style.position = "180px 120px 0px"

	var vote_text_2 = $.CreatePanel("Label",Button_2, "vote_text" );
	vote_text_2.text = $.Localize("#Next_Round")
	vote_text_2.SetHasClass( "normal_label", true );

	Button_2.SetPanelEvent('onactivate', (function(){
		clean_all()
		GameEvents.SendCustomGameEventToServer( "Vote_Round", { context: "reward",vote: "next"} );
	}))
	refresh_time()
}

function clean_all(){
	$("#Vote_Menu").visible = false
	$("#Vote_Menu").RemoveAndDeleteChildren()
}

function refresh_time(){
	if ($("#vote_time") != null){
		$.Schedule(0.25,refresh_time);
		if (typeof CustomNetTables.GetTableValue( "KVFILE", "time") != "undefined"){
			if (typeof CustomNetTables.GetTableValue( "KVFILE", "time").vote_time != "undefined" ){
				if ($("#vote_time").visible == false){
					$("#vote_time").visible = true
				}
				$("#vote_time").text = $.Localize("#Time") + " : " + Number((CustomNetTables.GetTableValue( "KVFILE", "time").vote_time).toFixed(2)) + " " + $.Localize("#seconds")
			}else{
				$("#vote_time").text = $.Localize("#No_One_Ready")
			}
		}else{
			$("#vote_time").text = $.Localize("#No_One_Ready")
		}
	}
}
