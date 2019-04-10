#!/usr/bin/env python
"""
Pymodbus Synchronous Client Examples
--------------------------------------------------------------------------

The following is an example of how to use the synchronous modbus client
implementation from pymodbus.

It should be noted that the client can also be used with
the guard construct that is available in python 2.5 and up::

    with ModbusClient('127.0.0.1') as client:
        result = client.read_coils(1,10)
        print result
"""
# --------------------------------------------------------------------------- #
# import the various server implementations
# --------------------------------------------------------------------------- #
from pymodbus.client.sync import ModbusTcpClient
from pymodbus.client.sync import ModbusSerialClient

import configparser

# --------------------------------------------------------------------------- #
# configure the client logging
# --------------------------------------------------------------------------- #
import logging
FORMAT = ('%(asctime)-15s %(threadName)-15s '
          '%(levelname)-8s %(module)-15s:%(lineno)-8s %(message)s')
logging.basicConfig(format=FORMAT)
log = logging.getLogger()
#log.setLevel(logging.DEBUG)

def request_coil(client, unit):
    print("")
    msg = "1: Read Coil Status\n" \
          "2: Force Single Coil\n" \
          "3: Force Multiple Coils\n" \
          "0: Quit"
    print(msg)
    c = input(">> ")
    sel = int(c)

    if 1 == sel:
        c = input("アドレス >> ")
        addr = int(c)
        c = input("カウント >> ")
        count = int(c)

        rr = client.read_coils(addr, count, unit=unit)
        print("ret => ")
        print(rr)
        if rr.isError() is False:
            res = []
            for i in range(count):
                res.append(rr.bits[i])
            print(res)

    elif 2 == sel:
        c = input("アドレス >> ")
        addr = int(c)
        c = input("ON(1)/OFF(0) >> ")
        data = int(c)

        rq = client.write_coil(addr, data, unit=unit)
        print("ret => ")
        print(rq)

    elif 3 == sel:
        c = input("アドレス >> ")
        addr = int(c)
        c = input("カウント >> ")
        count = int(c)
        c = input("ON(1)/OFF(0) (hex) >> ")
        data = int(c, 16)

        values = [False] * count
        for i in range(count):
            if 0x01 == ((data >> i) & 0x01):
                values[i] = True

        print(values)
        rq = client.write_coils(addr, values, unit=unit)
        print("ret => ")
        print(rq)


def request_input_status(client, unit):
    print("")

    c = input("アドレス >> ")
    addr = int(c)
    c = input("カウント >> ")
    count = int(c)

    rr = client.read_discrete_inputs(addr, count, unit=unit)
    print("ret => ")
    print(rr)
    if rr.isError() is False:
        res = []
        for i in range(count):
            res.append(rr.bits[i])
        print(res)


def request_input_register(client, unit):
    print("")

    c = input("アドレス >> ")
    addr = int(c)
    c = input("カウント >> ")
    count = int(c)

    rr = client.read_input_registers(addr, count, unit=unit)
    print("ret => ")
    print(rr)
    if rr.isError() is False:
        res = []
        for i in range(count):
            res.append(rr.registers[i])
        print(res)


def request_holding_register(client, unit):
    print("")
    msg = "1: Read Hoding Register\n" \
          "2: Preset Single Register\n" \
          "3: Preset Multiple Registers\n" \
          "0: Quit"
    print(msg)
    c = input(">> ")
    sel = int(c)

    if 1 == sel:
        c = input("アドレス >> ")
        addr = int(c)
        c = input("カウント >> ")
        count = int(c)

        rr = client.read_holding_registers(addr, count, unit=unit)
        print("ret => ")
        print(rr)
        if rr.isError() is False:
            res = []
            for i in range(count):
                res.append(rr.registers[i])
            print(res)

    elif 2 == sel:
        c = input("アドレス >> ")
        addr = int(c)
        c = input("Value (hex) >> ")
        data = int(c, 16)

        rq = client.write_register(addr, data, unit=unit)
        print("ret => ")
        print(rq)

    elif 3 == sel:
        c = input("アドレス >> ")
        addr = int(c)
        c = input("カウント >> ")
        count = int(c)
        values = []
        for i in range(count):
            print("Value[%d]" % i)
            c = input("(hex) >> ")
            values.append(int(c, 16))

        print(values)
        rq = client.write_registers(addr, values, unit=unit)
        print("ret => ")
        print(rq)


def console_loop(client):
    unit = 1

    while True:
        print("")
        print("1: Coil (0x)")
        print("2: Input Status (1x)")
        print("3: Input Register (3x)")
        print("4: Holding Register (4x)")
        print("9: Change Device ID")
        print("q: 終了")
        menu = input(">> ")

        if ('q' == menu):
            return

        elif ('1' == menu):
            request_coil(client, unit)

        elif ('2' == menu):
            request_input_status(client, unit)

        elif ('3' == menu):
            request_input_register(client, unit)

        elif ('4' == menu):
            request_holding_register(client, unit)

        elif ('9' == menu):
            c = input("ID >> ")
            unit = int(c)

def run_sync_client(opt):

    # ----------------------------------------------------------------------- #
    # connect the client
    # ----------------------------------------------------------------------- #
    if 'tcp' == opt['common']['protocol']:
        client = ModbusTcpClient(opt['tcp']['host'], port=opt['tcp']['port'])

    elif 'ascii' == opt['common']['protocol']:
        client = ModbusSerialClient(method='ascii', port=opt['serial']['device'], timeout=1, baudrate=opt['serial']['baudrate'])

    elif 'rtu' == opt['common']['protocol']:
        client = ModbusSerialClient(method='rtu', port=opt['serial']['device'], timeout=1, baudrate=opt['serial']['baudrate'])

    else:
        print("ERR: select protocol tcp, ascii or rtu")
        return

    client.connect()

    # ----------------------------------------------------------------------- #
    # console menu loop
    # ----------------------------------------------------------------------- #
    console_loop(client)

    # ----------------------------------------------------------------------- #
    # close the client
    # ----------------------------------------------------------------------- #
    client.close()


def load_config():
    config = configparser.ConfigParser()
    config.read('config.ini')

    opt = {}
    opt['common'] = {}
    opt['common']['protocol'] = config.get('COMMON', 'protocol', fallback='serial')
    opt['common']['debug']    = config.getboolean('COMMON', 'debug', fallback='False')

    opt['serial'] = {}
    opt['serial']['device']   = config.get('SERIAL', 'device', fallback='/dev/ttyUSB0')
    opt['serial']['baudrate'] = config.getint('SERIAL', 'baudrate', fallback='9600')

    opt['tcp'] = {}
    opt['tcp']['host'] = config.get('TCP', 'host', fallback='127.0.0.1')
    opt['tcp']['port'] = config.getint('TCP', 'port', fallback='5020')

    if opt['common']['debug'] is True:
        log.setLevel(logging.DEBUG)

    return opt


if __name__ == "__main__":
    opt = load_config()
    run_sync_client(opt)

