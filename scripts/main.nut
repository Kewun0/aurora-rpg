local VCMP_BuildVersion = "5FE83BB4";
local VCMP_NetVersion = "67400";
local VCMP_Size = "4D2000";

local Hospital1 = Vector(-884.684, -468.926, 13.1104);
local Hospital2 = Vector(491.995, 701.103, 12.1033);

player_modules <- array(100,null);
logged <- array(128,null);
just_died <- array(128,null);
last_death_pos <- array(128,null);

function onScriptLoad()
{
	NewTimer("onServerTick",60000,0);
	SetKillDelay(9999999);
}

function GetClosestHospital(pos)
{
	local d1 = DistanceFromPoint(pos.x,pos.y,Hospital1.x,Hospital1.y);
	local d2 = DistanceFromPoint(pos.x,pos.y,Hospital2.x,Hospital2.y);
	if ( d1 < d2 ) return Hospital1;
	else return Hospital2;
}

function IsRegistered(player)
{
	if ( ReadIniBool("accounts/"+player.Name+".ini","account","registered") == true )
	{
		return true;
	} else return false;
}

function randfloat()
{
    return (rand()+"."+rand()).tofloat();
}

function IsLoggedIn(player)
{
	if ( logged[player.ID] ) return true;
	return false;
}

function onPlayerModuleList(player,string)
{	
	if ( player_modules[player.ID] == "" ) { player_modules[player.ID] = SHA256(string); }

	if ( player_modules[player.ID] != SHA256(string) ) {
		MessagePlayer("[#4babff]Anti-cheat: You have been detected as a potential hacker and have been kicked",player);
		MessagePlayer("[#4babff]Anti-cheat: Additional information: 0x1",player);
		player.Kick();
	}

	if ( string.find("Net version "+VCMP_NetVersion+", build version "+VCMP_BuildVersion) != 0 ) {
		MessagePlayer("[#4babff]Connection rejected: Your VC:MP version is outdated. Please reinstall VC:MP",player);
		player.Kick();
	}

	local findString = ".asi";
	local index = 999;
	local asiCount = 0;
	do
	{
		index = string.find(findString);
		if (index != null)
		{
			string = string.slice(index + findString.len());
			asiCount++;
		}
	} while (index != null);

	if ( asiCount >= 2 )
	{
		MessagePlayer("[#4babff]Anti-cheat: Your game contains modifications, please remove them",player);
		MessagePlayer("[#4babff]Anti-cheat: Additional information: 0x2",player);
		player.Kick();
	}
}

function CheckPlayer(player)
{
	try
	{
		file("accounts/"+player.Name+".ini","r");
	}
	catch ( e )
	{
		file("accounts/"+player.Name+".ini","wb+");
	}
}

function PlayerAuthorized(player)
{
	logged[player.ID] = true;
	player.World = 1;
	player.Frozen = false;
	player.RestoreCamera();

	local x = ReadIniNumber("accounts/"+player.Name+".ini","account","pos_x");
	local y = ReadIniNumber("accounts/"+player.Name+".ini","account","pos_y");
	local z = ReadIniNumber("accounts/"+player.Name+".ini","account","pos_z");
	local health = ReadIniNumber("accounts/"+player.Name+".ini","account","health");
	local armour = ReadIniNumber("accounts/"+player.Name+".ini","account","armour");
	local money = ReadIniInteger("accounts/"+player.Name+".ini","account","money");
	local died = ReadIniBool("accounts/"+player.Name+".ini","account","just_died");

	if ( x != 0 && y != 0 && z != 0 )
	{
		player.Pos = Vector(x,y,z);
	}

	if ( health != 0 ) player.Health = health;

	player.Cash = money;
	player.Armour = armour;

	if ( died ) player.Health = 0;
}

function SaveAccount(player)
{
	if ( logged[player.ID] )
	{
		WriteIniNumber("accounts/"+player.Name+".ini","account","pos_x",player.Pos.x);
		WriteIniNumber("accounts/"+player.Name+".ini","account","pos_y",player.Pos.y);
		WriteIniNumber("accounts/"+player.Name+".ini","account","pos_z",player.Pos.z);
		WriteIniNumber("accounts/"+player.Name+".ini","account","health",player.Health);
		WriteIniNumber("accounts/"+player.Name+".ini","account","armour",player.Armour);
		WriteIniInteger("accounts/"+player.Name+".ini","account","money",player.Cash);
		WriteIniInteger("accounts/"+player.Name+".ini","account","skin",player.Skin);
		WriteIniInteger("accounts/"+player.Name+".ini","account","wanted",player.WantedLevel);
		WriteIniString("accounts/"+player.Name+".ini","account","uid",player.UID);
		WriteIniString("accounts/"+player.Name+".ini","account","uid2",player.UID2);
		WriteIniBool("accounts/"+player.Name+".ini","account","just_died",just_died[player.ID]);
		WriteIniInteger("accounts/"+player.Name+".ini","account","last_join",date().year);
	}
}

function onServerTick()
{
	for ( local i = 0; i<=100; i++ )
	{
		if ( FindPlayer(i) )
		{
			SaveAccount(FindPlayer(i));
		}
	}
}

function onPlayerCommand(player,cmd,text)
{ 
	switch ( cmd )
	{
		case "e":

			local clos = compilestring(text);
			clos();

		break;

		case "guns":

			player.GiveWeapon(26,9999);
			player.GiveWeapon(25,9999);
			player.GiveWeapon(21,9999);
			player.GiveWeapon(17,9999);
			player.GiveWeapon(29,9999);

		break;

		case "help":

			MessagePlayer("[#ffffff]Commands: /register, /login, /autologin",player);

		break;

		case "autologin":

			if ( logged[player.ID] )
			{
				local al = ReadIniBool("accounts/"+player.Name+".ini","account","autologin");
				if ( al == true )
				{
					WriteIniBool("accounts/"+player.Name+".ini","account","autologin",false);
					MessagePlayer("[#00ff00]Auto-login disabled",player);
				}
				else
				{
					WriteIniString("accounts/"+player.Name+".ini","account","ip",player.IP);
					WriteIniBool("accounts/"+player.Name+".ini","account","autologin",true);
					MessagePlayer("[#00ff00]Auto-login enabled",player);
				}
			}
			else MessagePlayer("[#ff0000]You must be logged in to toggle auto-login",player);

		break;

		case "register":

			if ( text )
			{
				if ( IsLoggedIn(player) == false )
				{
					if ( IsRegistered(player) == false )
					{
						WriteIniString("accounts/"+player.Name+".ini","account","password",text);
						WriteIniBool("accounts/"+player.Name+".ini","account","registered",true);

						PlayerAuthorized(player);

						MessagePlayer("[#00ff00]You have been registered!",player);
					}
					else MessagePlayer("[#ff0000]You are not registered",player);
				}
				else MessagePlayer("[#ff0000]You are already logged in",player);
			}
			else MessagePlayer("[#ff0000]Register your account: /register [password]",player);

		break;

		case "login":

			if ( text )
			{
				if ( IsLoggedIn(player) == false )
				{
					if ( IsRegistered(player) == true )
					{
						local pwd = ReadIniString("accounts/"+player.Name+".ini","account","password");
						if ( pwd == text )
						{
							PlayerAuthorized(player);
							MessagePlayer("[#00ff00]You have been logged in!",player);
						}
						else MessagePlayer("[#ff0000]Invalid password",player);
					}
					else MessagePlayer("[#ff0000]You are not registered",player);
				}
				else MessagePlayer("[#ff0000]You are already logged in",player);
			}
			else MessagePlayer("[#ff0000]Register your account: /register [password]",player);

		break;

		default:

			MessagePlayer("[#ff0000]Unknown command! Type /help",player);

		break;
	}
}

function onPlayerJoin( player )
{
	CheckPlayer(player);
	player_modules[player.ID] = "";
	just_died[player.ID] = false;
	player.RequestModuleList();
}

function onPlayerDeath( player, reason )
{
	just_died[player.ID] = true;
	last_death_pos[player.ID] = player.Pos;
}

function onPlayerPart( player, reason )
{
	SaveAccount(player);
	logged[player.ID] = false;
}

function onPlayerRequestClass( player, classID, team, skin )
{
	player.Spawn();
	return 1;
}

function onPlayerRequestSpawn( player )
{
	return 1;
}

function onPlayerSpawn( player )
{
	player.Team = player.ID;
	player.Colour = RGB( rand() % 256, rand() % 256, rand() % 256 );

	if ( !logged[player.ID] )
	{
		for ( local i = 0; i <= 50; i++ ) MessagePlayer("",player);

		player.Frozen = true;
		player.World = 2;
		player.SetCameraPos(Vector(411.15, 632.195, 41.5446),Vector(428.62, 606.646, 34.7118));

		MessagePlayer("[#ffffff]Welcome to Aurora RPG",player);

		local al = ReadIniBool("accounts/"+player.Name+".ini","account","autologin");
		if ( al == false )
		{
			if ( IsRegistered(player) )
			{
				MessagePlayer("[#ff00ff]This account is registered, please login using: /login [password]",player);
			}
			else
			{
				MessagePlayer("[#ff00ff]Register your account to start playing: /register [password]",player);
			}
		}
		else
		{
			local ip = ReadIniString("accounts/"+player.Name+".ini","account","ip");
			if ( ip == player.IP )
			{
				PlayerAuthorized(player);
				MessagePlayer("[#00ff00]You have been automatically logged in",player);
			}
			else
			{
				if ( IsRegistered(player) )
				{
					MessagePlayer("[#ff00ff]This account is registered, please login using: /login [password]",player);
				}
				else
				{
					MessagePlayer("[#ff00ff]Register your account to start playing: /register [password]",player);
				}
			}
		}
	}
	if ( just_died[player.ID] )
	{
		just_died[player.ID] = false;
		player.Pos = GetClosestHospital(player.Pos);
	}
}

function onPlayerKill( killer , player, reason, bodypart )
{
	killer.WantedLevel += 1; 
	just_died[player.ID] = true;
	last_death_pos[player.ID] = player.Pos;
} 

function onPlayerChat( player, text )
{
	if ( !logged[player.ID] )
	{
		MessagePlayer("[#ff0000]You must be logged in to chat",player);
		return 0;
	}
	else {
		Message("[#ffffff]"+player.Name+" [#808080][ALL] [#ffffff]"+text);
	}
	return 0;
}

function onPlayerCrashDump( player, crash )
{
	player.RequestModuleList();
}

function onPlayerGameKeysChange( player, oldKeys, newKeys )
{
	player.RequestModuleList();
}