# -*- coding: utf-8 -*-

"""
RPi-GP40 Modbusスレーブ制御ライブラリ
"""

from pymodbus.device import ModbusDeviceIdentification
from pymodbus.datastore import ModbusSequentialDataBlock, ModbusSparseDataBlock
from pymodbus.datastore import ModbusSlaveContext, ModbusServerContext

from threading import Lock
from gp40 import Gp40

class Gp40ModbusSlave:
    """RPi-GP40をModbusスレーブとして動作させる
    """

    gp40_lock = Lock()
    gp40_alarm = {"gp40": None, "detect": False, "result": [{"value": 0, "high": False, "True": False} for i in Gp40.Channel]}

    Range = [Gp40.Range.PM_10V, \
             Gp40.Range.PM_5V, \
             Gp40.Range.PM_2_5V, \
             Gp40.Range.PM_1_25V, \
             Gp40.Range.PM_0_5V, \
             Gp40.Range.ZERO_10V, \
             Gp40.Range.ZERO_5V, \
             Gp40.Range.ZERO_2_5V, \
             Gp40.Range.ZERO_1_25V]

    def __init__(self, slave_id, **kwargs):
        """Modbusスレーブの初期化

        Args:
            slave_id:   RPi-GP40のスレーブデバイスID
            pin_output: デジタル出力ピン番号
            pin_input:  デジタル入力ピン番号
        """

        d = {}
        d['do'] = kwargs.get('pin_output', 12)
        d['di'] = kwargs.get('pin_input', 13)

        self._gp40     = Gp40(**d)
        self._slave_id = slave_id
        self._range    = [0] * 8
        self._alarm_en = False
        self._alarm_de = False
        self._alarm    = []

        Gp40ModbusSlave.gp40_alarm["gp40"] = self._gp40

        # アラームしきい値初期値を取得
        for i in Gp40.Channel:
            param = self._gp40.get_alarm_param(i)
            self._alarm.append({"result": {"value": 0, "high": False, "low": False}, "threshold": {"hist": param[0], "high": param[1], "low": param[2]}})

        # 保持レジスタの初期値作成
        hr_init = [0] * (1 + 8)
        for i in Gp40.Channel:
            hr_init.append(self._alarm[i]["threshold"]["hist"])
            hr_init.append(self._alarm[i]["threshold"]["low"])
            hr_init.append(self._alarm[i]["threshold"]["high"])

        # Modbus データストア
        self._store = ModbusSlaveContext(
            di=ModbusSequentialDataBlock(0, [False]*18),
            co=ModbusSequentialDataBlock(0, [False]*2),
            hr=ModbusSequentialDataBlock(0, hr_init),
            ir=ModbusSequentialDataBlock(0, [0]*17))

    def __del__(self):
        if self._alarm_en is True:
            self._gp40.remove_event_alarm()

        del self._gp40

    def updater(self, a):
        """読み出しステータスの更新

        定期的に呼び出してデバイス側の更新を反映する

        Args:
            a: Modbusスレーブのコンテキスト
        """

        # ---------------------------
        # Input Status更新処理
        context  = a[0]
        register = 2
        slave_id = self._slave_id
        address  = 0x00
        values = context[slave_id].getValues(register, address, count=17)

        # アラーム検知ステータス
        values[0] = self._alarm_de

        # 各チャンネルのアラーム検知結果
        for i in Gp40.Channel:
            index = 1 + i * 2
            values[index + 0] = self._alarm[i]["result"]["low"]
            values[index + 1] = self._alarm[i]["result"]["high"]

        # 値更新
        context[slave_id].setValues(register, address, values)

        # ---------------------------
        # 入力レジスタ更新処理
        context  = a[0]
        register = 4
        slave_id = self._slave_id
        address  = 0x00
        values = context[slave_id].getValues(register, address, count=16)

        data = self._gp40.get_addata_lump([True] * 8)
        for i in Gp40.Channel:
            values[i + 0] = data[i]
            values[i + 8] = self._alarm[i]["result"]["value"]

        # 値更新
        context[slave_id].setValues(register, address, values)

    def read_context(self, a):
        """データ更新をデバイスへ反映

        定期的に呼び出してModbusにより更新された値をデバイスへ反映する

        Args:
            a: Modbusスレーブのコンテキスト
        """

        alarm_detect = False

        # アラーム検知結果取得
        with Gp40ModbusSlave.gp40_lock:
            if Gp40ModbusSlave.gp40_alarm["detect"] is True:
                Gp40ModbusSlave.gp40_alarm["detect"] = False
                self._alarm_de = True
                self._alarm_en = False
                alarm_detect   = True
                for i in Gp40.Channel:
                    self._alarm[i]["result"]["value"] = Gp40ModbusSlave.gp40_alarm["result"][i]["value"]
                    self._alarm[i]["result"]["high"]  = Gp40ModbusSlave.gp40_alarm["result"][i]["high"]
                    self._alarm[i]["result"]["low"]   = Gp40ModbusSlave.gp40_alarm["result"][i]["low"]

        # ---------------------------
        # 保持レジスタ更新処理
        context  = a[0]
        register = 3
        slave_id = self._slave_id
        address  = 0x00
        values = context[slave_id].getValues(register, address, count=32)

        update = False
        for i in Gp40.Channel:
            # 設定値が範囲外なら戻す
            if not 0 <= values[i] < len(Gp40ModbusSlave.Range):
                values[i] = self._range[i]
                update = True

            # 入力レンジの更新
            if self._range[i] != values[i]:
                self._range[i] = values[i]
                self._gp40.set_range(Gp40.Channel(i), Gp40ModbusSlave.Range[self._range[i]])

            index = 8 + 3 * i
            # アラームしきい値のヒステリシスが範囲外なら戻す
            if not 0 <= values[index + 0] <= 15:
                values[index + 0] = self._alarm[i]["threshold"]["hist"]
                update = True

            # アラームしきい値の更新
            ap_up = False
            if values[index + 0] != self._alarm[i]["threshold"]["hist"]:
                self._alarm[i]["threshold"]["hist"] = values[index + 0]
                ap_up = True

            if values[index + 1] != self._alarm[i]["threshold"]["low"]:
                self._alarm[i]["threshold"]["low"] = values[index + 1]
                ap_up = True

            if values[index + 2] != self._alarm[i]["threshold"]["high"]:
                self._alarm[i]["threshold"]["high"] = values[index + 2]
                ap_up = True

            if ap_up is True:
                self._gp40.set_alarm_param(Gp40.Channel(i),
                        self._alarm[i]["threshold"]["hist"],
                        self._alarm[i]["threshold"]["high"],
                        self._alarm[i]["threshold"]["low"])

        if update is True:
            context[slave_id].setValues(register, address, values)

        # ---------------------------
        # Coil更新処理
        context  = a[0]
        register = 1
        slave_id = self._slave_id
        address  = 0x00
        values = context[slave_id].getValues(register, address, count=1)

        # アラーム検知したため無効に変更
        if alarm_detect is True:
            values[0] = False
            context[slave_id].setValues(register, address, values)

        # アラーム検知機能設定
        if values[0] != self._alarm_en:
            self._alarm_en = values[0]
            self.__enable_alarm(self._alarm_en)

    def __enable_alarm(self, enable):
        """アラームの有効設定

        アラームの有効無効を設定する
        アラーム有効前に結果取得領域を初期化する
        """
        if self._alarm_en is True:
            # デジタル出力クリア
            self._gp40.set_digital_out(False)

            # 取得結果のクリア
            Gp40ModbusSlave.gp40_alarm["enable"] = False
            self._alarm_de                       = False
            for i in Gp40.Channel:
                Gp40ModbusSlave.gp40_alarm["result"][i]["value"] = 0
                Gp40ModbusSlave.gp40_alarm["result"][i]["high"]  = False
                Gp40ModbusSlave.gp40_alarm["result"][i]["low"]   = False
                self._alarm[i]["result"]["value"]                = 0
                self._alarm[i]["result"]["high"]                 = 0
                self._alarm[i]["result"]["low"]                  = 0

            self._gp40.set_event_alarm(Gp40ModbusSlave.event_trigger_callback)
            self._gp40.enable_alarm(True)
        else:
            self._gp40.remove_event_alarm()
            self._gp40.enable_alarm(False)

    @staticmethod
    def event_trigger_callback(pin):
        """アラーム検知のコールバック

        アラーム検知したときにAD値を取得
        """
        if Gp40ModbusSlave.gp40_alarm["gp40"] is not None:
            # デジタル出力
            Gp40ModbusSlave.gp40_alarm["gp40"].set_digital_out(True)

            # 結果取得
            result = Gp40ModbusSlave.gp40_alarm["gp40"].get_alarm_status()
            data   = Gp40ModbusSlave.gp40_alarm["gp40"].get_addata_lump([True] * 8)

            # アラーム無効
            Gp40ModbusSlave.gp40_alarm["gp40"].remove_event_alarm()
            Gp40ModbusSlave.gp40_alarm["gp40"].enable_alarm(False)

            with Gp40ModbusSlave.gp40_lock:
                for i in Gp40.Channel:
                    Gp40ModbusSlave.gp40_alarm["result"][i]["value"] = data[i]
                    Gp40ModbusSlave.gp40_alarm["result"][i]["high"]  = result[i]["trip"]["high"]
                    Gp40ModbusSlave.gp40_alarm["result"][i]["low"]   = result[i]["trip"]["low"]

                Gp40ModbusSlave.gp40_alarm["detect"] = True

    @property
    def store(self):
        """Modbusバッファ
        """
        return self._store

