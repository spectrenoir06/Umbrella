socket = require "socket"
copas = require "copas"

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

    Clients["tcp:"..tcpIp..":"..tcpPort] = {ip = tcpIp, port = tcpPort, skt = skt}
    print("new client:\t\t"..tcpIp..":"..tcpPort)
    local me = Clients["tcp:"..tcpIp..":"..tcpPort]

    cl = cl +1
    while true do
        nb=nb+1
        local data, status, partial = skt:receive()

        if data then
            --print(tcpIp..":"..tcpPort.. " :\t"..data)
            if(root) then
                if (data == "cmd:client") then
                    me.skt:send(tostring(cl).." Clients:".."\n")
                    for k,v in pairs(Clients) do
                        me.skt:send("tcp : "..v.ip..":"..v.port.."\n")
                    end
                elseif (data == "cmd:admin") then
                    me.skt:send(tostring(ad).." Admin:".."\n")
                    for k,v in pairs(Admins) do
                        me.skt:send("tcp : "..v.ip..":"..v.port.."\n")
                    end
                else
                    for k,v in pairs(Clients) do
                        v.skt:send(data.."\n")
                    end
                end
            elseif (data == "cmd:root") then
                Admins["tcp:"..tcpIp..":"..tcpPort] = {ip = tcpIp, port = tcpPort, skt = skt}
                ad = ad + 1
                cl = cl -1
                root = true
                print("root")
                for k,v in pairs(Admins) do
                    v.skt:send(v.ip..":"..v.port.." new admin\n")
                end
                Clients["tcp:"..tcpIp..':'..tcpPort] = nil
            else  --print(data)
                for k,v in pairs(Admins) do
                    v.skt:send(data.."\n")
                end
            end
        end
        if status=="closed" then
            print(status..":\t\t\t"..tcpIp..":"..tcpPort)
            if (root) then
                ad = ad -1
                Admins["tcp:"..tcpIp..':'..tcpPort] = nil
                break
            else
                cl = cl - 1
                Clients["tcp:"..tcpIp..':'..tcpPort] = nil
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
