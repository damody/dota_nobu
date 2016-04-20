"use strict";

var CameraCurrent = 0
var CameraTarget = 0
function Init_Game_UI() {
        GameUI.SetCameraPitchMin( 45 );
        GameUI.SetCameraPitchMax( 75 );
       
        GameUI.SetCameraDistance( 0 );
        GameUI.SetCameraLookAtPositionHeightOffset( 0 );
		
        GameUI.SetRenderBottomInsetOverride( 0 );
        GameUI.SetRenderTopInsetOverride( 0 );
       
                                       
        GameUI.SetMouseCallback( MouseCall );
}
 
function MouseCall(args) {
        if (args == "pressed"){
        var hero_ent_index = Players.GetPlayerHeroEntityIndex( Players.GetLocalPlayer() );
        var hero_pos = Entities.GetAbsOrigin( hero_ent_index );
        var cursor_screen_pos = GameUI.GetCursorPosition( Players.GetLocalPlayer());
        var cursor_pos = Game.ScreenXYToWorld( cursor_screen_pos[0], cursor_screen_pos[1]  );
        var vO = new Vector( hero_pos[0], hero_pos[1], hero_pos[2] );
        var vP = new Vector( cursor_pos[0], cursor_pos[1], cursor_pos[2] );
        var vDif = vP.minus( vO );
        var vDif = vDif.normalize();
        var rAng = Math.atan2(vDif.y,vDif.x);
        //GameUI.SetCameraYaw( rAng*180 )
        var TempCT = CameraTarget
        CameraTarget = Math.floor((rAng*60)/10)*10
        $.Msg(CameraTarget);
                $.Schedule( 0.2, CameraTurnSlow );
		}
        return
}
 
function CameraTurnSlow(){
        if(CameraCurrent > CameraTarget + 10 || CameraCurrent < CameraTarget - 10){
        while(CameraCurrent > 180) {
                CameraCurrent = CameraCurrent - 360
        }
        while(CameraCurrent < (-180)) {
                CameraCurrent = CameraCurrent + 360
        }
       
        $.Msg(CameraCurrent);
        if (CameraCurrent > CameraTarget && CameraCurrent - 181 >  CameraTarget) {
                CameraCurrent = CameraCurrent + 5;
                $.Schedule( 0.025, CameraTurnSlow );
        } else if (CameraCurrent < CameraTarget && CameraCurrent + 181 <  CameraTarget) {
                CameraCurrent = CameraCurrent - 5;
                $.Schedule( 0.025, CameraTurnSlow );
        } else if (CameraCurrent > CameraTarget) {
                CameraCurrent = CameraCurrent - 5;
                $.Schedule( 0.025, CameraTurnSlow );
        } else if (CameraCurrent < CameraTarget) {
                CameraCurrent = CameraCurrent + 5;
                $.Schedule( 0.025, CameraTurnSlow );
        }
        GameUI.SetCameraYaw( CameraCurrent - 90 )
        }
}


(function()
{
	Init_Game_UI();
})();

