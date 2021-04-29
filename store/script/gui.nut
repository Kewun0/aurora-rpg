function Script::ScriptLoad()
{Hud.RemoveFlags(HUD_FLAG_HEALTH); 

 CreateNameTag();
}

function Script::ScriptProcess( )
{
 if( NameTag.Spawned )
 {
  local plr = World.FindLocalPlayer();
  if ( plr.Health != NameTag.HPprogressBar.Value )
  {
   NameTag.HPprogressBar.Value = plr.Health.tointeger();
   NameTag.HP = plr.Health;
   NameTag.HPLabel.Text = plr.Health.tointeger()+"%";   
  }
  if( plr.Armour > 2 && (!(NameTag.ArmourprogressBar.Flags & GUI_FLAG_VISIBLE))) NameTag.ArmourprogressBar.AddFlags( GUI_FLAG_VISIBLE );
  if (NameTag.ArmourprogressBar.Flags & GUI_FLAG_VISIBLE)
  {
   if ( plr.Armour != NameTag.ArmourprogressBar.Value )
   {
    NameTag.ArmourLabel.Text = plr.Armour.tointeger()+"%";
    NameTag.ArmourprogressBar.Value = plr.Armour.tointeger();
    NameTag.Armour = plr.Armour;
    if( plr.Armour < 3 ) NameTag.ArmourprogressBar.RemoveFlags( GUI_FLAG_VISIBLE );
   }
  }
  else NameTag.ArmourprogressBar.RemoveFlags( GUI_FLAG_VISIBLE );
 }
}

NameTag <-
{
 HPprogressBar = null
 ArmourprogressBar = null
 HPLabel = null
 Spawned = false
 HP = 100
 Armour = 0
 ArmourLabel = null
}

function DelNameTag( )
{
 NameTag.HPprogressBar = null;
 NameTag.ArmourprogressBar = null;
 NameTag.HPLabel = null;
 NameTag.ArmourLabel = null;
 NameTag.Spawned = false;
 NameTag.HP = 100;
 NameTag.Armour = 0;
}

function CreateNameTag( )
{
 local plr = World.FindLocalPlayer(), scr = GUI.GetScreenSize();
 
 NameTag.HPprogressBar = GUIProgressBar();
 NameTag.HPprogressBar.Pos = VectorScreen( scr.X * 0.758, scr.Y * 0.148 );
 NameTag.HPprogressBar.Size = VectorScreen( scr.X * 0.07, scr.Y * 0.02 );
 NameTag.HPprogressBar.StartColour = Colour( 255,0,0 );
 NameTag.HPprogressBar.EndColour = Colour( 0,255,0 );
 NameTag.HPprogressBar.MaxValue = 100.0;
 NameTag.HPprogressBar.BackgroundShade = 0.5;
 NameTag.HPprogressBar.Thickness = 2;
 
 NameTag.ArmourprogressBar = GUIProgressBar();
 NameTag.ArmourprogressBar.Pos = VectorScreen( scr.X * 0.758, scr.Y * 0.168 );
 NameTag.ArmourprogressBar.Size = VectorScreen( scr.X * 0.07, scr.Y * 0.02);
 NameTag.ArmourprogressBar.StartColour = Colour( 150, 0, 0 );
 NameTag.ArmourprogressBar.EndColour = Colour( 150, 150, 150  );
 NameTag.ArmourprogressBar.MaxValue = 100;
 NameTag.ArmourprogressBar.BackgroundShade = 0.5;
 NameTag.ArmourprogressBar.Thickness = 2;
 
 NameTag.HPLabel = GUILabel( );
 NameTag.HPLabel.Text = "100%";
 NameTag.HPLabel.Pos = VectorScreen( scr.X * 0.007, scr.X * 0.005 );
 NameTag.HPLabel.FontSize = 0;
 NameTag.HPLabel.TextColour = Colour( 255, 255, 255 );
 
 NameTag.ArmourLabel = GUILabel( );
 NameTag.ArmourLabel.Text = "100%";
 NameTag.ArmourLabel.Pos = VectorScreen( scr.X * 0.007, scr.X * 0.005 );
 NameTag.ArmourLabel.FontSize = 0;
 NameTag.ArmourLabel.TextColour = Colour( 255, 255, 255 ); 
 
 //NameTag.HPprogressBar.AddChild( NameTag.HPLabel );
 //NameTag.ArmourprogressBar.AddChild( NameTag.ArmourLabel );
 
 if( plr.Armour <= 0 ) NameTag.ArmourprogressBar.RemoveFlags( GUI_FLAG_VISIBLE );
 NameTag.Spawned = true;
}

function GUI::GameResize(width, height)
{
  local scr = GUI.GetScreenSize();
  NameTag.HPprogressBar.Pos = VectorScreen( scr.X * 0.758, scr.Y * 0.148 );
  NameTag.HPprogressBar.Size = VectorScreen( scr.X * 0.07, scr.Y * 0.02 );
  NameTag.ArmourprogressBar.Pos = VectorScreen( scr.X * 0.758, scr.Y * 0.168 );
  NameTag.ArmourprogressBar.Size = VectorScreen( scr.X * 0.07, scr.Y * 0.02 );
  NameTag.HPLabel.FontSize = 0;
  NameTag.ArmourLabel.FontSize = 0;
  NameTag.HPLabel.Pos = VectorScreen( scr.X * 0.007, scr.X * 0.005 );
  NameTag.ArmourLabel.Pos = VectorScreen( scr.X * 0.007, scr.X * 0.005 );
}