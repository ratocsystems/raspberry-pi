# -*- coding: utf-8 -*-

"""
Raspberry Pi Modbusサーバー (スレーブ) アプリケーション
--------------------------------------------------------------------------


"""

# --------------------------------------------------------------------------- #
# import the various server implementations
# --------------------------------------------------------------------------- #
from pymodbus.server.async import StartTcpServer
from pymodbus.server.async import StartUdpServer
from pymodbus.server.async import StartSerialServer

from pymodbus.device import ModbusDeviceIdentification
from pymodbus.datastore import ModbusSequentialDataBlock, ModbusSparseDataBlock
from pymodbus.datastore import ModbusSlaveContext, ModbusServerContext

from pymodbus.transaction import ModbusRtuFramer, ModbusBinaryFramer

# --------------------------------------------------------------------------- #
# import the twisted libraries we need
# --------------------------------------------------------------------------- #
from twisted.internet.task import LoopingCall

# --------------------------------------------------------------------------- #
# import for config file.
# --------------------------------------------------------------------------- #
import configparser

# --------------------------------------------------------------------------- #
# import the RPi-GPxx
# --------------------------------------------------------------------------- #
from gp10_modbus import Gp10ModbusSlave
from gp40_modbus import Gp40ModbusSlave

# --------------------------------------------------------------------------- #
# configure the service logging
# --------------------------------------------------------------------------- #
import logging
FORMAT = ('%(asctime)-15s %(threadName)-15s'
          ' %(levelname)-8s %(module)-15s:%(lineno)-8s %(message)s')
logging.basicConfig(format=FORMAT)
log = logging.getLogger()
#log.setLevel(logging.DEBUG)

# --------------------------------------------------------------------------- #
# define
# --------------------------------------------------------------------------- #
VERSION = 'v1.00'

# --------------------------------------------------------------------------- #
# define your callback process
# --------------------------------------------------------------------------- #
def write_context_500ms(a):
    global gp10block
    if gp10block is not None:
        gp10block.updater(a)

def write_context_1000ms(a):
    global gp40block
    if gp40block is not None:
        gp40block.updater(a)

def read_context(a):
    global gp10block
    global gp40block
    if gp10block is not None:
        gp10block.read_context(a)

    if gp40block is not None:
        gp40block.read_context(a)

def run_server(opt):
    global gp10block
    global gp40block

    store = {}
    if opt['gp10']['enable'] is True:
        gp10block = Gp10ModbusSlave(opt['gp10']['deviceid'], **opt['gp10'])
        store[opt['gp10']['deviceid']] = gp10block.store

    if opt['gp40']['enable'] is True:
        gp40block = Gp40ModbusSlave(opt['gp40']['deviceid'], **opt['gp40'])
        store[opt['gp40']['deviceid']] = gp40block.store

    if 0 == len(store):
        print("ERR: enable GP10 or GP40.")
        return

    context = ModbusServerContext(slaves=store, single=False)

    # ----------------------------------------------------------------------- #
    # initialize the server information
    # ----------------------------------------------------------------------- #
    # If you don't set this or any fields, they are defaulted to empty strings.
    # ----------------------------------------------------------------------- #
    identity = ModbusDeviceIdentification()
    identity.VendorName         = 'RatocSystems, Inc.'
    identity.ProductCode        = 'RPi-Modbus'
    identity.VendorUrl          = 'https://github.com/ratocsystems'
    identity.ProductName        = 'RasPi Modbus Server'
    identity.ModelName          = 'RasPi Modbus Server'
    identity.MajorMinorRevision = '1.0'

    # ----------------------------------------------------------------------- #
    # updater
    # ----------------------------------------------------------------------- #
    updater_500ms = LoopingCall(f=write_context_500ms, a=(context,))
    updater_500ms.start(.5)
    updater_1000ms = LoopingCall(f=write_context_1000ms, a=(context,))
    updater_1000ms.start(1)
    writer = LoopingCall(f=read_context, a=(context,))
    writer.start(.1)

    # ----------------------------------------------------------------------- #
    # run the server you want
    # ----------------------------------------------------------------------- #
    if 'tcp' == opt['common']['protocol']:
        # Tcp:
        StartTcpServer(context, identity=identity, address=(opt['tcp']['host'], opt['tcp']['port']))

    elif 'ascii' == opt['common']['protocol']:
        # Ascii:
        StartSerialServer(context, identity=identity, port=opt['serial']['device'], timeout=1, baudrate=opt['serial']['baudrate'])

    elif 'rtu' == opt['common']['protocol']:
        # RTU:
        StartSerialServer(context, framer=ModbusRtuFramer, identity=identity, port=opt['serial']['device'], timeout=.005, baudrate=opt['serial']['baudrate'])

    else:
        print("ERR: select protocol tcp, rtu or ascii")

    # ----------------------------------------------------------------------- #
    # end proc
    # ----------------------------------------------------------------------- #
    updater_500ms.stop()
    updater_1000ms.stop()
    writer.stop()

    if gp10block is not None:
        del gp10block
    if gp40block is not None:
        del gp40block

def load_config():
    config = configparser.ConfigParser()
    config.read('config.ini')

    opt = {}
    opt['common'] = {}
    opt['common']['protocol'] = config.get('COMMON', 'protocol', fallback='serial').lower()
    opt['common']['debug']    = config.getboolean('COMMON', 'debug', fallback='False')

    opt['serial'] = {}
    opt['serial']['device']   = config.get('SERIAL', 'device', fallback='/dev/ttyUSB0')
    opt['serial']['baudrate'] = config.getint('SERIAL', 'baudrate', fallback='9600')

    opt['tcp'] = {}
    opt['tcp']['host'] = config.get('TCP', 'host', fallback='127.0.0.1')
    opt['tcp']['port'] = config.getint('TCP', 'port', fallback='5020')

    opt['gp10'] = {}
    opt['gp10']['enable']   = config.getboolean('GP10', 'enable', fallback='True')
    opt['gp10']['deviceid'] = config.getint('GP10', 'deviceid', fallback='1')
    opt['gp10']['slave']    = int(config.get('GP10', 'slave', fallback='0x20'), 16)
    opt['gp10']['strobe']   = config.getint('GP10', 'strobe', fallback='14')
    opt['gp10']['trigger']  = config.getint('GP10', 'trigger', fallback='15')

    opt['gp40'] = {}
    opt['gp40']['enable']     = config.getboolean('GP40', 'enable', fallback='False')
    opt['gp40']['deviceid']   = config.getint('GP40', 'deviceid', fallback='2')
    opt['gp40']['pin_output'] = config.getint('GP40', 'pin_output', fallback='12')
    opt['gp40']['pin_input']  = config.getint('GP40', 'pin_input', fallback='13')

    if opt['common']['debug'] is True:
        log.setLevel(logging.DEBUG)

    return opt


gp10block = None
gp40block = None

def boot_message(opt):
    print("Protocol: %s" % opt['common']['protocol'].upper())

    if 'tcp' == opt['common']['protocol']:
        print("Host: %s" % opt['tcp']['host'])
        print("Port: %d" % opt['tcp']['port'])

    else:
        print("Device: %s" % opt['serial']['device'])
        print("Baudrate: %d" % opt['serial']['baudrate'])

    print("RPi-GP10 : %s" % opt['gp10']['enable'])
    if opt['gp10']['enable'] is True:
        print("  ID: %d" % opt['gp10']['deviceid'])

    print("RPi-GP40 : %s" % opt['gp40']['enable'])
    if opt['gp10']['enable'] is True:
        print("  ID: %d" % opt['gp40']['deviceid'])


if __name__ == "__main__":
    print("Modbus Slave Application for Raspberry Pi %s" % VERSION)
    opt = load_config()
    boot_message(opt)
    run_server(opt)

    print("exit")

