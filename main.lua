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


local tcpSocket = assert(socket.bind(ServerIp, ServerTcpPort))

function handler(skt)

  skt = copas.wrap(skt)

  local tcpIp, tcpPort 	= skt.socket:getpeername()

  Clients["tcp:"..tcpIp..":"..tcpPort] = {ip = tcpIp, port = tcpPort, skt = skt}

  local me = Clients["tcp:"..tcpIp..":"..tcpPort]

  cl = cl +1
  while true do
    nb=nb+1
    local data, status, partial = skt:receive()

    if data then
      print(data)
      if status=="closed" then
          print(status.." "..tcpIp..":"..tcpPort)
          cl=cl-1
          Clients["tcp:"..tcpIp..':'..tcpPort] = nil
          break
      end
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
