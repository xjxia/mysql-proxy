
function connect_server() 
	print("--> a client really wants to talk to a server")
end

function read_handshake( auth )
	print("<-- let's send him some information about us")
	print("    mysqld-version: " .. auth.mysqld_version)
	print("    thread-id     : " .. auth.thread_id)
	print("    scramble-buf  : " .. string.format("%q", auth.scramble))
	print("    server-addr   : " .. auth.server_addr)
	print("    client-addr   : " .. auth.client_addr)

	-- lets deny clients from !127.0.0.1
	if not auth.client_addr:match("^127.0.0.1:") then
		proxy.response.type = proxy.MYSQLD_PACKET_ERR
		proxy.response.errmsg = "only local connects are allowed"

		print("we don't like this client");

		return proxy.PROXY_SEND_QUERY
	end
end


function read_auth( auth )
	print("--> there, look, the client is responding to the server auth packet")
	print("    username      : " .. auth.username)
	print("    password      : " .. string.format("%q", auth.password))
	print("    default_db    : " .. auth.default_db)

	if auth.username == "evil" then
		proxy.response.type = proxy.MYSQLD_PACKET_ERR
		proxy.response.errmsg = "evil logins are not allowed"
		
		return proxy.PROXY_SEND_RESULT
	end
end

function read_query( packet ) 
	print("--> someone sent us a query")
	if packet:byte() == proxy.COM_QUERY then
		print("    query: " .. packet:sub(2))
	end
end

function read_query_result( inj ) 
	print("<-- ... ok, this only gets called when read_query() told us")
end
