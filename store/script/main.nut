const MAX_PLAYERS = 100;
llplayer <- World.FindLocalPlayer();

const MAX_HOLES = 30;

local bulletTable = array( MAX_PLAYERS ),
	holes = array( MAX_PLAYERS ),
	last_hole_picked = array( MAX_PLAYERS );

bulletTable[ llplayer.ID ] = {};
holes[ llplayer.ID ] = 0;
last_hole_picked[ llplayer.ID ] = 0;

include("gui.nut");

class leHole
{
	inst = null;
	ID = null;
}

function move( pos, distance, angle )
{
	local  newx = pos.X - sin( angle ) * distance,
	newy = pos.Y + cos( angle ) * distance;
	return Vector( newx, newy, pos.Z );
}

function move2( pos, pangle, dis, angle )
{
	return move( pos, dis, pangle + angle )
}
function fixsprite( sp )
{
	local  x = sp.Position3D,
	rot = sp.Rotation3D,
 	size = sp.Size3D,
	newPos = move2( x, rot.Z, 1, PI );
	sp.Position3D = newPos;
}
function centersprite( sp )
{
	local  x = sp.Position3D,
	rot = sp.Rotation3D,
	size = sp.Size3D, 
	newPos = move2( x, rot.Z, size.X / 2, PI / 2 );
   	newPos.Z += 1.15;
	sp.Position3D = newPos;
}

function CreateBulletHole( player, pos )
{
	local ppos = player.Position;

	if( MAX_HOLES == 0 ) return 0;
	else if( !bulletTable[ player.ID ] )
	{
		bulletTable[ player.ID ] = null;
		bulletTable[ player.ID ] = {};
		holes[ player.ID ] = 0;
		last_hole_picked[ player.ID ] = 0;
	}
 
	local   hole,
	id = holes[ player.ID ],
	angle = atan2( pos.X - ppos.X, pos.Y - ppos.Y );
   
	if( MAX_HOLES != -1 && holes[ player.ID ] == MAX_HOLES ) 
	{
		if( bulletTable[ player.ID ].rawin( last_hole_picked[ player.ID ] ) )
		{
			id = last_hole_picked[ player.ID ];
			local lhp = id + 1;
   
			hole = bulletTable[ player.ID ].rawget( id );
			hole.inst = null;
			bulletTable[ player.ID ].rawdelete( id );
			holes[ player.ID ]--;
   
			if( last_hole_picked[ player.ID ] == MAX_HOLES-1 ) lhp = 0;
   
			last_hole_picked[ player.ID ] = lhp;
		}
	}
 
	bulletTable[ player.ID ].rawset( id, leHole() );
	hole = bulletTable[ player.ID ].rawget( id );
	hole.ID = id;
 
	hole.inst = GUISprite( "hole.png", VectorScreen( 0, 0 ) );
	hole.inst.Alpha = 90;
 
	hole.inst.AddFlags( GUI_FLAG_3D_ENTITY );
	hole.inst.Set3DTransform( Vector( pos.X, pos.Y, pos.Z ),  Vector( -PI/2, 0, -angle ), Vector( 0.35, 0.35, 0.0 ) );
	fixsprite( hole.inst );
	centersprite( hole.inst );
	holes[ player.ID ]++;
}

function Player::PlayerShoot( player, weapon, hitEntity, hitPosition )
{
	if( hitEntity && hitEntity.Type == OBJ_BUILDING )
	{
		CreateBulletHole( player, hitPosition );
	}
}