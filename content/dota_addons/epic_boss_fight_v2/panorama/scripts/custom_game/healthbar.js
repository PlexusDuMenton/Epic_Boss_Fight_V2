var ID = Players.GetLocalPlayer()

Create_HealthBar()
Update()

function Update(){
	$.Schedule(0.25, Update);
	CustomNetTables.SubscribeNetTableListener
	data = CustomNetTables.GetTableValue( "info", "boss")
	if (typeof data != 'undefined') {
		if (data.HP > 0) {
			$("#main_panel").visible = true
			HealthBar(data)
		}else{
			$("#main_panel").visible = false
		}
	}
}

function HealthBar(data) {
	$("#Health_Bar").style.clip = "rect( 0% ," + ((data.HP/data.MAXHP)*98.77+0.54) + "%" + ", 100% ,0% )";
	$("#hp_text").text = "Health : " + Number((data.HP).toFixed(2)) +" / "+Number((data.MAXHP).toFixed(2));
	$("#name").text = $.Localize("#" + data.name)
	if (data.CAT == "second") {
		$("#overlay").SetHasClass("overlay",false)
		$("#overlay").SetHasClass( "second", true )
		$("#overlay").SetHasClass( "main", false )
	}else{
		if (data.CAT == "main"){
			$("#overlay").SetHasClass("overlay",false)
			$("#overlay").SetHasClass( "second", false )
			$("#overlay").SetHasClass( "main", true )
		}
		else{
			$("#overlay").SetHasClass("overlay",true)
			$("#overlay").SetHasClass( "second", false )
			$("#overlay").SetHasClass( "main", false )
		}
	}
	

}

function Create_HealthBar(){
	var BG = $.CreatePanel( "Panel", $("#main_panel"), "BG");
	BG.SetHasClass("BG",true)
	BG.hittest = false
	
	var HB = $.CreatePanel( "Panel", $("#main_panel"), "Health_Bar");
	HB.SetHasClass("HB",true)
	HB.hittest = false
	
	var overlay = $.CreatePanel( "Panel", $("#main_panel"), "overlay");
	overlay.SetHasClass("overlay",true)
	overlay.hittest = false
	
	var hp_text = $.CreatePanel( "Label", $("#main_panel"), "hp_text");
	hp_text.SetHasClass("hp_text",true)
	hp_text.style.position = "300px 5px 0px";
	hp_text.hittest = false
	
	var name = $.CreatePanel( "Label", $("#main_panel"), "name");
	name.SetHasClass("name",true)
	name.style.position = "300px 75px 0px";
	name.hittest = false
	
	
	
	

}