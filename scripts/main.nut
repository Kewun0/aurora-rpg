local VCMP_BuildVersion = "5FE83BB4";
local VCMP_NetVersion = "67400";
local VCMP_Size = "4D2000";

local Hospital1 = Vector(-884.684, -468.926, 13.1104);
local Hospital2 = Vector(491.995, 701.103, 12.1033);

player_modules <- array(100,null);
logged <- array(128,null);
just_died <- array(128,null);
last_death_pos <- array(128,null);
player_sphere <- array(128,null);

function CreateSphere(pos,size,colour)
{
	CreateCheckpoint(null,1,true,pos,colour,size);
}

function onCheckpointExited ( player, sphere )
{
	player_sphere[player.ID] = -1;
}

function onCheckpointEntered ( player, sphere )
{
	player_sphere[player.ID] = sphere.ID;
	switch ( sphere.ID )
	{
		case 0:
			MessagePlayer("[#ffff00]You can view bank commands by typing /help",player);
		break;

		case 1:
			MessagePlayer("[#ffff00]You can view ammu-nation commands by typing /help",player);
		break;
	}
}

function onScriptLoad()
{
	NewTimer("onServerTick",60000,0);
	SetKillDelay(9999999);
	CreateSphere(Vector(-906.728, -341.084, 13.3802),2.0,ARGB(100,0,255,0));
	CreateMarker(1, Vector(-906.728, -341.084, 13.3802), 1, RGBA(0,0,0,0), 24);
	CreateSphere(Vector(-676.757, 1204.6, 11.1091),2.0,ARGB(100,180,180,180));
	CreateMarker(1,Vector(-676.757, 1204.6, 11.1091),1,RGBA(0,0,0,0),16);
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
	local skin = ReadIniInteger("accounts/"+player.Name+".ini","account","skin");

	if ( x != 0 && y != 0 && z != 0 )
	{
		player.Pos = Vector(x,y,z);
	}

	if ( health != 0 ) player.Health = health;

	player.Cash = money;
	player.Armour = armour;
	player.Skin = skin;

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
		WriteIniString("accounts/"+player.Name+".ini","account","last_join",date().day+"/"+date().month+"/"+date().year+", "+date().hour+":"+date().min);
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

		case "help":

			MessagePlayer("[#ffffff]Account commands: /register, /login, /autologin",player);
			MessagePlayer("[#ffffff]Playeer commands: /skin",player);
			MessagePlayer("[#ffffff]Bank commands: /deposit, /withdraw, /balance",player);
			MessagePlayer("[#ffffff]Ammu-Nation commands: /buy, /pricelist",player);

		break;

		case "pricelist":

			if ( player_sphere[player.ID] == 1 )
			{
				MessagePlayer("[#ff8000]Ammu-Nation items:",player);
				MessagePlayer("[#ff4000][ID 1] Body Armour ($800)",player);
				MessagePlayer("[#ff4000][ID 2] Colt-45 ($250/17clips)",player);
				MessagePlayer("[#ff4000][ID 3] Ingram MAC ($600/30clips)",player);
				MessagePlayer("[#ff4000][ID 4] Stubby Shotgun ($800/10clips)",player);
				MessagePlayer("[#ff4000][ID 5] M4 ($1500/60clips)",player);
				
			}
			else MessagePlayer("[#ff0000]You must be at Ammu-Nation to use this command",player);

		break;
		
		case "skin":

			if ( logged[player.ID] )
			{ // 0 - 186
				if ( text )
				{
					if ( player.Health != 0 )
					{
						if ( IsNum(text) )
						{
							local skin = text.tointeger();
							if ( skin >= 0 && skin <= 186 )
							{
								player.Skin = skin;
							}
							else MessagePlayer("[#ff0000]Invalid Skin ID. /skin < 0 - 186 >",player);
						}
						else MessagePlayer("[#ff0000]Invalid Skin ID. /skin < 0 - 186 >",player);
					}
					else MessagePlayer("[#ff0000]You need to be alive to change your skin",player);
				}
				else MessagePlayer("[#ff0000]Incorrect Format. Usage: /skin < 0 - 186 >",player);
			}
			else MessagePlayer("[#ff0000]You must be logged in to use this command",player);

		break;

		case "buy":

			if ( player_sphere[player.ID] == 1 )
			{
				if ( text )
				{
					if ( IsNum(text) )
					{

						local item = text.tointeger();

						switch ( item )
						{
							case 1:

								if ( player.Armour < 100 )
								{
									if ( player.Cash >= 800 )
									{
										player.Cash -= 800;
										player.Armour = 100;
										MessagePlayer("[#ffff00]You have purchased body armour for $800",player);
									}
									else MessagePlayer("[#ff0000]You can't buy this item, it costs $800, you have $"+player.Cash,player);
								}
								else MessagePlayer("[#ff0000]Your armour is full!",player);

							break;

							case 2:

								if ( player.Cash >= 250 )
								{
									player.GiveWeapon(17,17);
									player.Cash -= 250;
									MessagePlayer("[#ffff00]You have purchased 17x Colt-45 for $250",player);
								}
								else MessagePlayer("[#ff0000]You can't buy this item, it costs $250, you have $"+player.Cash,player);

							break;

							case 3:

								if ( player.Cash >= 600 )
								{
									player.GiveWeapon(24,30);
									player.Cash -= 600;
									MessagePlayer("[#ffff00]You have purchased 30x Ingram MAC for $600",player);
								}
								else MessagePlayer("[#ff0000]You can't buy this item, it costs $600, you have $"+player.Cash,player);

							break;

							case 4:

								if ( player.Cash >= 800 )
								{
									player.GiveWeapon(21,10);
									player.Cash -= 800;
									MessagePlayer("[#ffff00]You have purchased 10x Stubby Shotgun for $800",player);
								}
								else MessagePlayer("[#ff0000]You can't buy this item, it costs $800, you have $"+player.Cash,player);

							break;

							case 5:

								if ( player.Cash >= 1500 )
								{
									player.GiveWeapon(26,60);
									player.Cash -= 1500;
									MessagePlayer("[#ffff00]You have purchased 60x M4 for $1500",player);
								}
								else MessagePlayer("[#ff0000]You can't buy this item, it costs $1500, you have $"+player.Cash,player);

							break;
							
							default:

								MessagePlayer("[#ff0000]Invalid item ID, check items at /pricelist",player);

							break;
						}
					}
					else MessagePlayer("[#ff0000]You need to specify item ID to buy, write /pricelist",player);
				}
				else MessagePlayer("[#ff0000]You need to specify item ID to buy, write /pricelist",player);
			}
			else MessagePlayer("[#ff0000]You must be at Ammu-Nation to use this command",player);

		break;

		case "deposit":

			if ( player_sphere[player.ID] == 0 )
			{
				if ( logged[player.ID] )
				{
					if ( player.Cash != 0 )
					{
						if ( text )
						{
							if ( IsNum(text) )
							{
								local amount = text.tointeger();
								if ( amount )
								{
									if ( amount >= 1 )
									{
										if ( amount <= player.Cash )
										{
											local bank = ReadIniInteger("accounts/"+player.Name+".ini","account","bank_money");
												player.Cash -= amount;
											WriteIniInteger("accounts/"+player.Name+".ini","account","bank_money",bank+amount);
											MessagePlayer("[#ff8000]You have deposited $"+amount+" to your bank account",player);
										}
										else MessagePlayer("[#ff0000]You dont have enough money to deposit",player);
									}
									else MessagePlayer("[#ff0000]You must deposit atleast $1",player);
								}
								else MessagePlayer("[#ff0000]You need to specify an amount to deposit",player);
							}
							else MessagePlayer("[#ff0000]Amount must be in numbers",player);
						}
						else MessagePlayer("[#ff0000]You need to specify an amount to deposit",player);
					}
					else MessagePlayer("[#ff0000]You don't have any money to deposit.",player);
				}
				else MessagePlayer("[#ff0000]You must be logged in to use this command.",player);
			}
			else MessagePlayer("[#ff0000]You must be in bank to deposit money.",player);

		break;

		case "balance":

			if ( player_sphere[player.ID] == 0 )
			{
				local bank = ReadIniInteger("accounts/"+player.Name+".ini","account","bank_money");
				MessagePlayer("[#ffff00]Your bank balance is $"+bank,player);
			}
			else MessagePlayer("[#ff0000]You must be in bank to view your balance",player);

		break;

		case "withdraw":

			if ( player_sphere[player.ID] == 0 )
			{
				if ( logged[player.ID] )
				{
					if ( text )
					{
						if ( IsNum(text) )
						{
							local amount = text.tointeger();
							if ( amount )
							{
								if ( amount >= 1 )
								{
									local bank = ReadIniInteger("accounts/"+player.Name+".ini","account","bank_money");
									if ( amount <= bank )
									{
										player.Cash += amount;
										WriteIniInteger("accounts/"+player.Name+".ini","account","bank_money",bank-amount);
										MessagePlayer("[#ff8000]You have withdrawn $"+amount+" from your bank account",player);
									}
									else MessagePlayer("[#ff0000]You dont have enough money in bank to withdraw",player);
								}
								else MessagePlayer("[#ff0000]You must withdraw atleast $1",player);
							}
							else MessagePlayer("[#ff0000]You need to specify an amount to withdraw",player);
						}
						else MessagePlayer("[#ff0000]Amount must be in numbers",player);
					}
					else MessagePlayer("[#ff0000]You need to specify an amount to deposit",player);
				}
				else MessagePlayer("[#ff0000]You must be logged in to use this command.",player);
			}
			else MessagePlayer("[#ff0000]You must be in bank to deposit money.",player);

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
							local last_j = ReadIniString("accounts/"+player.Name+".ini","account","last_join");
							MessagePlayer("[#00ff00]Your last session was on "+last_j,player);
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
	player_sphere[player.ID] = -1;
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
				local last_j = ReadIniString("accounts/"+player.Name+".ini","account","last_join");
				MessagePlayer("[#00ff00]You have been automatically logged in",player);
				MessagePlayer("[#00ff00]You were last active on the server on "+last_j,player);
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
	else
	{
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
	player.Score = player.Cash;
	player.RequestModuleList();
}