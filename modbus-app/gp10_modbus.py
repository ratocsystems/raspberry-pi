# -*- coding: utf-8 -*-

"""
RPi-GP10 Modbusスレーブ制御ライブラリ
"""

from pymodbus.device import ModbusDeviceIdentification
from pymodbus.datastore import ModbusSequentialDataBlock, ModbusSparseDataBlock
from pymodbus.datastore import ModbusSlaveContext, ModbusServerContext

from threading import Lock
from gp10 import Gp10

class Gp10ModbusSlave:
    """RPi-GP10をModbusスレーブとして動作させる
    """

    gp10_lock = Lock()
    gp10_trigger = {"gp10": None, "detect": False, "input": 0x00}

    def __init__(self, slave_id, **kwargs):
        """Modbusスレーブの初期化

        Args:
            slave_id: RPi-GP10のスレーブデバイスID
            slave:    i2cスレーブアドレス
            strobe:   ストローブピン番号
            trigger:  トリガーピン番号
        """

        d = {}
        d['i2caddr'] = kwargs.get('slave', 0x20)
        d['strobe']  = kwargs.get('strobe', 14)
        d['trigger'] = kwargs.get('trigger', 15)

        self._gp10     = Gp10(**d)
        self._output   = 0xFF
        self._slave_id = slave_id
        self._polarity = {"output": 0x00, "input": 0x00}
        self._strobe   = {"enable": False, "time": 1, "remain": -1}
        self._trigger  = {"enable": False, "values": [False] * 8}

        Gp10ModbusSlave.gp10_trigger["gp10"] = self._gp10

        # Modbus データストア
        self._store = ModbusSlaveContext(
            di=ModbusSequentialDataBlock(0, [False]*17),
            co=ModbusSequentialDataBlock(0, [False]*27),
            hr=ModbusSequentialDataBlock(0, [0, self._strobe["time"]]),
            ir=ModbusSequentialDataBlock(9999, [0]*2))

    def __del__(self):
        if self._trigger["enable"] is True:
            self._gp10.remove_event_trigger()

        del self._gp10

    def updater(self, a):
        """読み出しステータスの更新

        定期的に呼び出してデバイス側の更新を反映する

        Args:
            a: Modbusスレーブのコンテキスト
        """

        # トリガー検知時の入力値更新チェック
        with Gp10ModbusSlave.gp10_lock:
            if Gp10ModbusSlave.gp10_trigger["detect"] is True:
                Gp10ModbusSlave.gp10_trigger["detect"] = False
                for i in range(8):
                    if 0x01 == ((Gp10ModbusSlave.gp10_trigger["input"] >> i) & 0x01):
                        self._trigger["values"][i] = True
                    else:
                        self._trigger["values"][i] = False

        # ---------------------------
        # Input Status更新処理
        context  = a[0]
        register = 2
        slave_id = self._slave_id
        address  = 0x00
        values = context[slave_id].getValues(register, address, count=16)

        data = self._gp10.input()
        data = data ^ self._polarity["input"]
        for i in range(8):
            # 現在の値
            if 0x01 == ((data >> i) & 0x01):
                values[i] = True
            else:
                values[i] = False

            # トリガー端子割り込みの取得値
            values[i + 8] = self._trigger["values"][i]

        # 値更新
        context[slave_id].setValues(register, address, values)

    def read_context(self, a):
        """データ更新をデバイスへ反映

        定期的に呼び出してModbusにより更新された値をデバイスへ反映する

        Args:
            a: Modbusスレーブのコンテキスト
        """

        if 0 < self._strobe["remain"]:
            self._strobe["remain"] -= 1
            if 0 == self._strobe["remain"]:
                self._strobe["remain"] = -1
                self._gp10.output_strobe(False)

        # ---------------------------
        # 保持レジスタ更新処理
        context  = a[0]
        register = 3
        slave_id = self._slave_id
        address  = 0x00
        values = context[slave_id].getValues(register, address, count=1)

        # 設定値が範囲外なら戻す
        if not 0 < values[0] <= 100:
            values[0] = self._strobe["time"]
            context[slave_id].setValues(register, address, values)

        if values[0] != self._strobe["time"]:
            self._strobe["time"] = values[0]

        # ---------------------------
        # Coil更新処理
        context  = a[0]
        register = 1
        slave_id = self._slave_id
        address  = 0x00
        values = context[slave_id].getValues(register, address, count=26)

        do = 0
        pol_out = 0
        pol_in  = 0
        for i in range(8):
            if values[i] is True:
                do = do | (0x01 << i)
            if values[i + 8] is True:
                pol_out = pol_out | (0x01 << i)
            if values[i + 16] is True:
                pol_in = pol_in | (0x01 << i)

        # ストローブ出力機能
        if values[25] != self._strobe["enable"]:
            self._strobe["enable"] = values[25]

        # トリガー入力機能
        if values[24] != self._trigger["enable"]:
            self._trigger["enable"] = values[24]
            if self._trigger["enable"] is True:
                self._gp10.set_event_trigger(Gp10ModbusSlave.event_trigger_callback)
            else:
                self._gp10.remove_event_trigger()

        # デジタル出力極性設定の更新
        if (pol_out != self._polarity["output"]):
            self._polarity["output"] = pol_out

        # デジタル入力極性設定の更新
        if (pol_in != self._polarity["input"]):
            self._polarity["input"] = pol_in

        # デジタル出力設定の更新
        do = do ^ self._polarity["output"]
        if (do != self._output):
            self._output = do
            self._gp10.output(do)
            if self._strobe["enable"] is True:
                self._strobe["remain"] = self._strobe["time"]
                self._gp10.output_strobe(True)

    @staticmethod
    def event_trigger_callback(pin):
        """トリガー入力検知のコールバック

        トリガー入力検知したときにデジタル入力を取得する
        """
        if Gp10ModbusSlave.gp10_trigger["gp10"] is not None:
            data = Gp10ModbusSlave.gp10_trigger["gp10"].input()
            with Gp10ModbusSlave.gp10_lock:
                Gp10ModbusSlave.gp10_trigger["input"]  = data
                Gp10ModbusSlave.gp10_trigger["detect"] = True

    @property
    def store(self):
        """Modbusバッファ
        """
        return self._store

