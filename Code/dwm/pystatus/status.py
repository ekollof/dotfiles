#!/usr/bin/env python3

import os
import os.path
import sys
import time
import datetime
import psutil

from Xlib.display import Display


def getbatterypct():
    try:
        bat = open("/sys/class/power_supply/BAT1/capacity")
    except FileNotFoundError:
        return "-1"
    pct = bat.read()
    pct = pct.strip()
    return pct


def getbatstatus():
    try:
        bstat = open("/sys/class/power_supply/BAT1/status")
    except FileNotFoundError:
        return -1
    ret = bstat.read()
    ret = ret.strip()
    return ret


def main():

    display = Display()
    root = display.screen().root

    while(True):

        if os.path.isfile('/tmp/statquit'):
            sys.exit()

        cpuload = psutil.cpu_percent()
        memused = psutil.virtual_memory().used // 1024 // 1024
        memtotal = psutil.virtual_memory().total // 1024 // 1024
        swapused = psutil.swap_memory().used // 1024 // 1024
        swaptotal = psutil.swap_memory().total // 1024 // 1024
#       batpct = getbatterypct()
#       batstatus = getbatstatus()
        now = datetime.datetime.now()
        curtime = now.strftime("%d-%m-%Y %H:%M:%S")


# Add below line to status if you have a battery
# f"BAT: {batpct: >3}% ({batstatus: <11}) :" + \
        status = f"MEM: {memused: >6}/{memtotal: >6} MB : " + \
            f"SWAP {swapused: >6}/{swaptotal: >6}: " + \
            f"CPU: {cpuload: >5}% :" +\
            f" {curtime}"

        root.set_wm_name(status)
        display.sync()
        time.sleep(1)


if __name__ == "__main__":
    main()
