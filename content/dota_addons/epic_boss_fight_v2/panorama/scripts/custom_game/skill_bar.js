var skill;
var ID = Players.GetLocalPlayer()
var Ent_ID;

$("#main_skill_bar").visible = false;

GameEvents.Subscribe( "Display_Bar", display_bar)
function display_bar()
{
$("#main_skill_bar").visible = true;
}

$.Schedule(0.3,update_skill_list);
	function update_skill_list()
	{
		$.Schedule(0.075, update_skill_list);
		CustomNetTables.SubscribeNetTableListener
		key = "player_" + ID.toString()
		if (typeof CustomNetTables.GetTableValue( "skill", key) != 'undefined'){
			skill = CustomNetTables.GetTableValue( "skill", key).active_skill
		}
		Ent_ID = Players.GetPlayerHeroEntityIndex( ID )
		if (typeof skill != 'undefined'){
				update_skill_bar(skill)
			}
	}
create_skill_bar()
function create_skill_bar()
{
	for (i = 1; i < 6; i++) {
		var Panel = $.CreatePanel( "DOTAAbilityImage", $("#main_skill_bar") , "skill_panel"+i.toString() );
		Panel.SetHasClass( "skill_image", true );
		Panel.style.position = ((-60) + i*70)+"px 6px 0px";
		if (i == 5) {
			Panel.style.position = (330)+"px 6px 0px";
			Panel.SetPanelEvent("onmouseover", function(){
				$.DispatchEvent('DOTAShowAbilityTooltipForEntityIndex', Panel,'empty5',Ent_ID)
			})
		}
		Panel.abilityname = "empty"+i.toString()
		change_ability_tooltip("empty"+i,Panel)
		Panel.SetPanelEvent("onmouseout", function(){
			$.DispatchEvent('DOTAHideAbilityTooltip')
		})
		var mask = $.CreatePanel( "Image", Panel , "mask"+i.toString() );
		var Button = $.CreatePanel( "Label", Panel , "button"+i.toString() );
		var Label = $.CreatePanel( "Label", Panel , "skill_CD"+i.toString() );
		mask.SetHasClass( "mask", true );
		mask.SetImage("file://{images}/custom_game/CD_Mask.png")
		Label.SetHasClass( "Label_CD", true );
		Label.text = ""
		Button.SetHasClass( "button", true );
		Button.text = ""
	}
}

function change_ability_tooltip(name,panel)
{
	panel.SetPanelEvent("onmouseover", function(){
		$.DispatchEvent('DOTAShowAbilityTooltipForEntityIndex', panel,name,Ent_ID)
	})
}


function update_skill_bar()
{
	for (i = 1; i < 6; i++) {
		var panel = $("#skill_panel"+i.toString())
		change_ability_tooltip(skill[i].name,panel)
		panel.abilityname = skill[i].name
		var ability = Entities.GetAbility( Ent_ID, i-1)
		var level = Abilities.GetLevel(ability)
		var CD = Number((Abilities.GetCooldownTimeRemaining (ability)).toFixed(1));
		var Max_CD = Number((Abilities.GetCooldown (ability)).toFixed(1));
		if (Max_CD > 0) {
			$("#mask"+i).style.clip = "rect( 0% ," + ((CD/Max_CD)*100) + "%" + ", 100% ,0% )";
		}
		else{
		$("#mask"+i).style.clip = "rect( 0% ,0%, 100% ,0% )";
		}
		var KeyBind =  	Abilities.GetKeybind(ability)
		$("#button"+i).text = KeyBind
		if (CD == 0){ $("#skill_CD"+i).text = ""}
		else {$("#skill_CD"+i).text = CD}


		//$.Msg("ability Number : ",i," ability ID : ", ability , "level : ",level,"  CD : ",CD,"  KeyBind : ",KeyBind)

	}
}
