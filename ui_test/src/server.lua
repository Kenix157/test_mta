
addEvent( "onPlayerRequestListUsers", true );
addEvent( "onPlayerAddUser", true );
addEvent( "onPlayerRemoveUser", true );
addEvent( "onPlayerEditUser", true );

local connection;

addEventHandler( "onResourceStart", resourceRoot,
	function()
		connection = dbConnect ( "mysql", "dbname=dev_test;host=127.0.0.1;charset=utf8", "Kenix", "secret" );
		
		dbExec( connection, 
			"CREATE TABLE IF NOT EXISTS users ( \
				id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,  \
				name VARCHAR(32),  \
				last_name VARCHAR(32), \
				address VARCHAR(100) \
			)"
		);
	end
);

addEventHandler( "onPlayerRequestListUsers", root,
	function()
		dbQuery( function( query, source )
			local result = dbPoll( query, 0 );
			
			dbFree( query );
			
			triggerClientEvent( source, "onClientReciveUsers", source, result );
		end, { source }, connection, "SELECT id, name, last_name, address FROM users" );
	end
);

addEventHandler( "onPlayerAddUser", root,
	function( user )
		dbQuery( function( query, source )
			local _, _, id = dbPoll( query, 0 );
			
			user.id = id;
			
			dbFree( query );
			
			triggerClientEvent( source, "onClientAddUser", source, user );
		end, { source }, connection, "INSERT INTO users (name, last_name, address) VALUES ( ?, ?, ? )", user.name, user.last_name, user.address );
	end
);

addEventHandler( "onPlayerRemoveUser", root,
	function( user )
		dbQuery( function( query, source )
			dbFree( query );
			
			triggerClientEvent( source, "onClientRemoveUser", source, user );
		end, { source }, connection, "DELETE FROM users WHERE id = ? LIMIT 1", user.id );
	end
);

addEventHandler( "onPlayerEditUser", root,
	function( user )
		dbQuery( function( query, source )
			dbFree( query );
			
			triggerClientEvent( source, "onClientEditUser", source, user );
		end, { source }, connection, "UPDATE users SET name = ?, last_name = ?, address = ? WHERE id = ?", user.name, user.last_name, user.address, user.id );
	end
);
