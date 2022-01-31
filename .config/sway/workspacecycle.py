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
                return monitor, workspace

monitor, workspace = setup()

def getNext(target_list, focus):

    if focus < len(target_list) - 1:
        return focus+1
    else:
        return 0

def getPrev(target_list, focus):

    if focus > 0:
        return focus-1
    else:
        return len(target_list)-1

def makelist_workspaces(workspaces, target_list = []):
    for workspace in monitor["nodes"]:
        target_list.append(workspace)
    
    return target_list

def focused_workspace(workspaces, current_workspace):
    for i in range(len(workspaces)):
        if workspaces[i]["name"] == current_workspace["name"]:
           return i

target_list = makelist_workspaces(monitor)
if len(target_list) > 1:
    focus = focused_workspace(target_list, workspace)

    if direction:
        attr = target_list[getNext(target_list, focus)]["name"]
    else:
        attr = target_list[getPrev(target_list, focus)]["name"]

    sway = subprocess.run(['swaymsg', 'workspace', attr])
    sys.exit(sway.returncode)
