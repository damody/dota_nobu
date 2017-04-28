
var slider = $.GetContextPanel().FindChildInLayoutFile( "Slider1" );
var lastValue = 0;

function OnValueChanged(slider)
{
	$.Msg(slider.value);
	GameUI.SetCameraDistance( slider.value );
}

function  Check()
{
	if (slider.value != lastValue)
		OnValueChanged(slider);
	lastValue = slider.value;
	$.Schedule(0.03, Check);
}

(function()
{
    slider.min = 500;
    slider.max = 1600;
	slider.value = 1100;
	lastValue = slider.value;
    $.Schedule(0.03, Check);
	
	 // 暫時先讓所有和天賦樹的UI都點不到
  $.Msg("Disable Talent Tree")
  var x = $.GetContextPanel().GetParent().GetParent().GetParent();
  x = x.FindChildTraverse('HUDElements')
  x = x.FindChildTraverse('lower_hud')
  //x = x.FindChildTraverse('GlyphScanContainer')
  //x = x.FindChildTraverse('GlyphButton')

  x = x.FindChildTraverse('center_with_stats')
  x = x.FindChildTraverse('center_block')
  var level_stats_frame = x.FindChildTraverse('level_stats_frame')
  level_stats_frame.RemoveClass('CanLevelStats')
  level_stats_frame.hittest = false
  level_stats_frame.hittestchildren = false
  level_stats_frame.FindChildTraverse('LevelUpBurstFX').visible = false
  var LevelUpTab = level_stats_frame.FindChildTraverse('LevelUpTab')
  var LevelUpButton = LevelUpTab.FindChildTraverse('LevelUpButton')
  var LevelUpIcon = LevelUpTab.FindChildTraverse('LevelUpIcon')
  LevelUpButton.visible = false
  LevelUpIcon.visible = false
  x = x.FindChildTraverse('AbilitiesAndStatBranch')
  x = x.FindChildTraverse('StatBranch')
  x.hittest = false
  x.hittestchildren = false
})();