local getTickCount = getTickCount;
local floor = math.floor;
local random = math.random;
local dxDrawImage = dxDrawImage;
local dxDrawRectangle = dxDrawRectangle;
local tocolor = tocolor;

local screenX, screenY = guiGetScreenSize();

local start = false;

local posX = screenX / 2;
local posY = screenY / 2;

local width = 100;
local height = 45;

local texture;

local speedX = 0.0001;
local speedY = 0.0001;

local items = {
	[ 1 ] = { x = 0, y = 0, speed_x = speedX, speed_y = speedY, color = 0xFFFFFFFF, min_pos_x = 0, 			max_pos_x = screenX / 2 };
	[ 2 ] = { x = 0, y = 0, speed_x = speedX, speed_y = speedY, color = 0xFFFFFFFF, min_pos_x = screenX / 2, max_pos_x = screenX };
};

local function OnPreRender( dt )
	dxDrawRectangle( 0, 0, screenX, screenY, tocolor( 0, 0, 0 ) );
	
	local dt = dt / 1000;
	
	for i, v in ipairs( items ) do
		local posX = v.x;
		local posY = v.y;
		local speedX = v.speed_x;
		local speedY = v.speed_y;
		local color = v.color;
		local minPosX = v.min_pos_x;
		local maxPosX = v.max_pos_x;
	
		posX = posX + speedX * dt * getTickCount();
		posY = posY + speedY * dt * getTickCount();
		
		local hit = false;
		
		if ( posX + width > maxPosX or posX < minPosX ) then
			if ( posX < 0 ) then
				posX = 0;
			end
			
			speedX = - speedX;
			
			hit = true;
		end
		
		if ( posY + height > screenY or posY < 0 ) then
			if ( posY < 0 ) then
				posY = 0;
			end
			
			speedY = - speedY;
			
			hit = true;
		end
		
		if ( hit ) then
			color = tocolor( random( 0, 255 ), random( 0, 255 ), random( 0, 255 ) );
		end
		
		v.x = posX;
		v.y = posY;
		v.speed_x = speedX;
		v.speed_y = speedY;
		v.color = color;
		
		dxDrawImage( 
			floor( posX ), floor( posY ), 
			width, height,
			texture,
			0, 0, 0,
			color
		);
	end
end

addEventHandler( "onClientResourceStart", resourceRoot,
	function()
		texture = dxCreateTexture( "assets/logo.png" );
	end
);

addCommandHandler( "toggle_anim",
	function()
		start = not start;
		
		if ( start ) then
			for i, v in ipairs( items ) do
				v.x = v.min_pos_x + math.random( 150, 300 );
				v.y = math.random( 150, 300 );
			end
		
			addEventHandler( "onClientPreRender", root, OnPreRender );
		else
			removeEventHandler( "onClientPreRender", root, OnPreRender );
		end
	end
);