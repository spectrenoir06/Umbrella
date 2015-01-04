socket = require "socket"
copas = require "copas"

local ServerIp = "*"
local ServerTcpPort = 1234

i		  = 0
nb		= 0
cl		= 0
s 	= 0
dt 		= 0
Clients = {}


function log(str)
    print(str)

end

local tcpSocket = assert(socket.bind(ServerIp, ServerTcpPort))

function handler(skt)

  skt = copas.wrap(skt)

  local tcpIp, tcpPort 	= skt.socket:getpeername()

  Clients["tcp:"..tcpIp..":"..tcpPort] = {ip = tcpIp, port = tcpPort, skt = skt}
  print("new client:\t\t"..tcpIp..":"..tcpPort)
  local me = Clients["tcp:"..tcpIp..":"..tcpPort]

  cl = cl +1
  while true do
    nb=nb+1
    local data, status, partial = skt:receive()

    if data then
      print(tcpIp..":"..tcpPort.. " :\t"..data)
      if (data:sub(0,4) == "cmd:") then
        for k,v in pairs(Clients) do
          if (v ~= me) then
            v.skt:send(data:sub(5).."\n")
          end
          me.skt:send("tcp : "..v.ip..":"..v.port.."\n")
        end
      end
    end
    if status=="closed" then
      print(status..":\t\t\t"..tcpIp..":"..tcpPort)
          cl=cl-1
          Clients["tcp:"..tcpIp..':'..tcpPort] = nil
          break
    end
  end
end

copas.addserver(tcpSocket, handler)


while 1 do
  copas.step(0) -- rajoute client
    --os.execute( "clear" )
    --print("\nboucle : "..i..", client : "..cl..", handler : "..nb)
    --for k,v in pairs(Clients) do
    --  print("tcp : "..v.ip..":"..v.port)
    --end
    socket.sleep(0.2)
end
