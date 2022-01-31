#!/usr/bin/env python3
# Original: https://gist.github.com/SidharthArya/f4d80c246793eb61be0ae928c9184406

import sys
import json
import subprocess

direction=bool(sys.argv[1] == 'next')
swaymsg = subprocess.run(['swaymsg', '-t', 'get_tree'], stdout=subprocess.PIPE)
data = json.loads(swaymsg.stdout)

def setup():
    def dig(nodes):
        if nodes["focused"]:
            return True

        for node_type in "nodes", "floating_nodes":
                if node_type in nodes:
                    for node in nodes[node_type]:
                        if node["focused"] or dig(node):
                            return True

        return False

    for monitor in data["nodes"]:
        for workspace in monitor["nodes"]:

            if workspace["focused"] or dig(workspace):
                return workspace

workspace = setup()
temp = workspace
windows = list()

def getNextWindow():

    if focus < len(windows) - 1:
        return focus+1
    else:
        return 0

def getPrevWindow():

    if focus > 0:
        return focus-1
    else:
        return len(windows)-1

def makelist(temp):
    for nodes in "floating_nodes", "nodes":
        for i in range(len(temp[nodes])):
            if temp[nodes][i]["name"] is None:
               makelist(temp[nodes][i])
            else:
               windows.append(temp[nodes][i])


def focused(temp_win):

    for i in range(len(temp_win)):
        if temp_win[i]["focused"] == True:
           return i
    
    return 9

makelist(temp)
focus = focused(windows)

if direction:
    attr = "[con_id="+str(windows[getNextWindow()]["id"])+"]"
else:
    attr = "[con_id="+str(windows[getPrevWindow()]["id"])+"]"

sway = subprocess.run(['swaymsg', attr, 'focus'])
sys.exit(sway.returncode)
