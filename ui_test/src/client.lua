loadstring(exports.dgs:dgsImportFunction())()

addEvent( "onClientAddUser", true );
addEvent( "onClientEditUser", true );
addEvent( "onClientRemoveUser", true );
addEvent( "onClientReciveUsers", true );

local screenX, screenY = guiGetScreenSize();

-- Utils
function AttachToWindow( window, rootWindow )
	setElementParent( window, rootWindow );
	dgsSetVisible( rootWindow, false );
end

function DetachFromWindow( window, rootWindow )
	destroyElement( window );
	dgsSetVisible( rootWindow, true );
end

function ServerCall( event, args )
	triggerServerEvent( event, localPlayer, args or {} );
end

function ShowError( text )
	outputChatBox( text, 255, 0, 0 );
end

local events = {};

function AddRPCEvent( event, callback )
	addEventHandler( event, root, callback );
	
	table.insert( events, { event, root, callback } );
end

function RemoveRPCEvents()
	for i, v in ipairs( events ) do
		removeEventHandler( unpack( v ) );
	end
	
	events = {};
end

-- UI
function RemoveUserUI( rootWindow, userID )
	local window = dgsCreateWindow( screenX / 2 - 300 / 2, screenY / 2 - 200 / 2, 300, 120, "Вы уверены?", false );
	
	local buttonYes = dgsCreateButton( 30, 50, 100, 30, "Нет", false, window );
	
	addEventHandler ( "onDgsMouseClickUp", buttonYes, function( btn )
		if btn ~= "left" then
			return;
		end
		
		DetachFromWindow( window, rootWindow );
	end, false	);
	
	local buttonNo = dgsCreateButton( 300 - 30 - 100, 50, 100, 30, "Да", false, window );
	
	addEventHandler ( "onDgsMouseClickUp", buttonNo, function( btn )
		if btn ~= "left" then
			return;
		end
		
		DetachFromWindow( window, rootWindow );
		
		ServerCall( "onPlayerRemoveUser", { id = userID } );
	end, false	);
	
	AttachToWindow( window, rootWindow );
	
	return window;
end

function AddUserUI( rootWindow )
	local width = 200;
	local padding = 20;
	local editWidth = width - padding * 2;
	
	local window = dgsCreateWindow( screenX / 2 - 200 / 2, screenY / 2 - 250 / 2, 200, 250, "Добавление пользователя", false );
	
	addEventHandler( "onDgsWindowClose", window, function()
		cancelEvent();
		
		DetachFromWindow( window, rootWindow );
	end, false );
	
	local editName = dgsCreateEdit( padding, 20, editWidth, 30, "Имя", false, window );
	dgsSetProperty( editName, "maxLength", 32 );
	
	local editLastName = dgsCreateEdit( padding, 60, editWidth, 30, "Фамилия", false, window );
	dgsSetProperty( editLastName, "maxLength", 32 );
	
	local editAddress = dgsCreateEdit( padding, 100, editWidth, 30, "Адрес", false, window );
	dgsSetProperty( editAddress, "maxLength", 100 );
	
	local buttonAdd = dgsCreateButton( width / 2 - 100 / 2, 150, 100, 30, "Добавить", false, window );
	
	addEventHandler ( "onDgsMouseClickUp", buttonAdd, function( btn )
		if btn ~= "left" then
			return;
		end
		
		local name  = dgsGetText( editName );
		local lastName  = dgsGetText( editLastName );
		local address  = dgsGetText( editAddress );
		
		if ( utf8.len( name ) == 0 or utf8.len( lastName ) == 0 or utf8.len( address ) == 0 ) then
			ShowError( "Введите все данные пользователя!" );
			
			return;
		end
		
		DetachFromWindow( window, rootWindow );
		
		ServerCall( "onPlayerAddUser", { name = name, last_name = lastName, address = address } );
	end, false	);
	
	AttachToWindow( window, rootWindow );
	
	return window;
end

function EditUserUI( rootWindow, user )
	local window = dgsCreateWindow( screenX / 2 - 200 / 2, screenY / 2 - 200 / 2, 200, 220, "Редактировать пользователя", false );
	
	addEventHandler( "onDgsWindowClose", window, function()
		cancelEvent();
		
		DetachFromWindow( window, rootWindow );
	end, false );
	
	local editWidth = 200 - 20 * 2;
	
	local editName = dgsCreateEdit( 20, 20, editWidth, 30, user.name, false, window );
	local editLastName = dgsCreateEdit( 20, 60, editWidth, 30, user.last_name, false, window );
	local editAddress = dgsCreateEdit( 20, 100, editWidth, 30, user.address, false, window );
	
	local buttonAdd = dgsCreateButton( 200 / 2 - 100 / 2, 150, 100, 30, "Сохранить", false, window );
	
	addEventHandler ( "onDgsMouseClickUp", buttonAdd, function( btn )
		if btn ~= "left" then
			return;
		end
		
		local name  = dgsGetText( editName );
		local lastName  = dgsGetText( editLastName );
		local address  = dgsGetText( editAddress );
		
		if ( utf8.len( name ) == 0 or utf8.len( lastName ) == 0 or utf8.len( address ) == 0 ) then
			ShowError( "Введите все данные пользователя!" );
			
			return;
		end
		
		DetachFromWindow( window, rootWindow );
		
		ServerCall( "onPlayerEditUser", { id = user.id, name = name, last_name = lastName, address = address } );
	end, false	);
	
	AttachToWindow( window, rootWindow );
	
	return window;
end

local window;
local events = {};

function CreateUI()
	if ( window and isElement( window ) ) then
		destroyElement( window );
	end
	
	-- Удаляем события.
	RemoveRPCEvents();
	
	local listPlayers = {};

	window = dgsCreateWindow( screenX / 2 - 500 / 2, screenY / 2 - 500 / 2, 500, 500, "Авторизация", false );
	
	addEventHandler( "onDgsWindowClose", window, function()
		cancelEvent();
		
		showCursor( false );
		
		destroyElement( window );
		
		-- Удаляем события.
		RemoveRPCEvents();
	end, false );
	
	local gridListWidth = 500 - 30 * 2;
	
	local gridList = dgsCreateGridList( 30, 30, gridListWidth, 250, false, window );
	
	dgsGridListAddColumn( gridList, "Имя", 0.3 );
	dgsGridListAddColumn( gridList, "Фамилия", 0.3 );
	dgsGridListAddColumn( gridList, "Адрес", 0.3 );
	
	-- Взаимодействие со спиком.
	local function AddUser( user )
		local row = dgsGridListAddRow( gridList );
	
		dgsGridListSetItemText( gridList, row, 1, user.name );
		dgsGridListSetItemText( gridList, row, 2, user.last_name );
		dgsGridListSetItemText( gridList, row, 3, user.address );
		
		user.row_id = row;
		
		listPlayers[ user.id ] = user;
	end
	
	local function RemoveUser( user )
		for i, v in pairs( listPlayers ) do
			if ( v.id == user.id ) then
				listPlayers[ i ] = nil;
				
				dgsGridListRemoveRow( gridList, v.row_id );
				
				break;
			end
		end
	end
	
	local function EditUser( newUserData )
		for i, v in pairs( listPlayers ) do
			if ( v.id == newUserData.id ) then
				local row = v.row_id;
				
				dgsGridListSetItemText( gridList, row, 1, newUserData.name );
				dgsGridListSetItemText( gridList, row, 2, newUserData.last_name );
				dgsGridListSetItemText( gridList, row, 3, newUserData.address );
				
				for k, value in pairs( newUserData ) do
					listPlayers[ i ][ k ] = value;
				end
		
				break;
			end
		end
	end
	
	local function GetUserIdByRow( id )
		for i, v in pairs( listPlayers ) do
			if ( v.row_id == id ) then
				return v.id;
			end
		end
		
		return nil;
	end
	
	local function GetUserIdSelected()
		local rowSelected = dgsGridListGetSelectedItem( gridList );
		
		if ( rowSelected == - 1 ) then
			return false;
		end
		
		local userID = GetUserIdByRow( rowSelected );
		
		if ( not userID ) then
			return false;
		end
		
		return userID;
	end
	
	local function GetSelectedUser()
		local userID = GetUserIdSelected();
		
		if ( not userID ) then
			return;
		end
		
		for i, v in pairs( listPlayers ) do
			if ( v.id == userID ) then
				return v;
			end
		end
		
		return;
	end
	
	-- редактировать
	local buttonEdit = dgsCreateButton( 30, 350, 100, 30, "Редактировать", false, window );
	
	addEventHandler ( "onDgsMouseClickUp", buttonEdit, function( btn )
		if btn ~= "left" then
			return;
		end
		
		local user = GetSelectedUser();
		
		if ( not user ) then
			ShowError( "Выберите пользователя!" );
			
			return;
		end
		
		EditUserUI( window, user );
	end, false	);
	
	-- удалить
	local buttonRemove = dgsCreateButton( 30 + gridListWidth / 2 - 100 / 2, 350, 100, 30, "Удалить", false, window );
	
	addEventHandler ( "onDgsMouseClickUp", buttonRemove, function( btn )
		if btn ~= "left" then
			return;
		end
		
		local userID = GetUserIdSelected();
		
		if ( not userID ) then
			ShowError( "Выберите пользователя!" );
			
			return;
		end
		
		RemoveUserUI( window, userID );
	end, false	);
	
	-- добавить
	local buttonAdd = dgsCreateButton( 30 + gridListWidth - 100, 350, 100, 30, "Добавить", false, window );
	
	addEventHandler ( "onDgsMouseClickUp", buttonAdd, function( btn )
		if btn ~= "left" then
			return;
		end
		
		AddUserUI( window );
	end, false	);
	
	-- Обработка всех событий из сервера.
	AddRPCEvent( "onClientAddUser", AddUser );
	AddRPCEvent( "onClientRemoveUser", RemoveUser );
	AddRPCEvent( "onClientEditUser", EditUser );
	AddRPCEvent( "onClientReciveUsers", function( list ) 
		for i, v in ipairs( list ) do
			AddUser( v );
		end
	end );
	
	ServerCall( "onPlayerRequestListUsers" );
	
	showCursor( true );
end

addCommandHandler( "ui_create", CreateUI );
