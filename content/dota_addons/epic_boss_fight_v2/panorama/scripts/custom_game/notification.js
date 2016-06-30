
GameEvents.Subscribe( "inventory_notification", notification_top)

GameEvents.Subscribe( "Player_interaction_notification", function(table){
table.text = ( Players.GetPlayerName( table.PID ) + $.Localize(table.text)) 
notification_top(table)
}
)

GameEvents.Subscribe( "save_notification", notification_top)
GameEvents.Subscribe( "custom_notification", notification_top_right)
GameEvents.Subscribe( "clean_notification", notification_clean)

function notification_top(table){
	not_label = $.CreatePanel( "Label", $("#main_panel") , "notification" );
	not_label.style.position = "0px 50px 1px";
	not_label.text = $.Localize(table.text)
	if (typeof table.color != 'undefined' ){
		not_label.style.color = "#"+table.color
	}
	not_label.SetHasClass( "top_label", true ) 
	$.Schedule((table.duration+1), function(){$("#main_panel").RemoveAndDeleteChildren()});

}

function notification_bot(table){
	not_label = $.CreatePanel( "Label", $("#main_panel") , "notification" );
	not_label.style.position = "0px 50px 1px";
	not_label.text = $.Localize(table.text)
	if (typeof table.color != 'undefined' ){
		not_label.style.color = "#"+table.color
	}
	not_label.SetHasClass( "bot_label", true ) 
	$.Schedule(table.duration, function(){$("#main_panel").RemoveAndDeleteChildren()});

}

function notification_top_right(table){
	not_label = $.CreatePanel( "Label", $("#main_panel") , "notification" );
	not_label.style.position = "0px 50px 1px";
	not_label.text = $.Localize(table.text)
	if (typeof table.color != 'undefined' ){
		not_label.style.color = "#"+table.color
	}
	not_label.SetHasClass( "bot_label", true ) 
	$.Schedule(table.duration, function(){$("#main_panel").RemoveAndDeleteChildren()});

}

function notification_clean(){
	$.Schedule(table.duration, function(){$("#main_panel").RemoveAndDeleteChildren()});

}