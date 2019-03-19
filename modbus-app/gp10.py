# -*- coding: utf-8 -*-

"""
RPi-GP10制御ライブラリ
"""

import logging
import time
import smbus
import RPi.GPIO as GPIO

from gppower import GpPower

def get_module_logger(modname):
    logger = logging.getLogger(modname)
    handler = logging.StreamHandler()
    logger.addHandler(handler)
    return logger

logger = get_module_logger(__name__)

class Gp10:
    """RPi-GP10制御を行う
    """

    # TCA9635コントロールレジスタ
    TCA9535_INPUT_P0  = 0x00
    TCA9535_INPUT_P1  = 0x01
    TCA9535_OUTPUT_P0 = 0x02
    TCA9535_OUTPUT_P1 = 0x03
    TCA9535_POLINV_P0 = 0x04
    TCA9535_POLINV_P1 = 0x05
    TCA9535_CONFIG_P0 = 0x06
    TCA9535_CONFIG_P1 = 0x07

    def __init__(self, *, i2caddr = 0x20, strobe = 14, trigger = 15, debug = False):
        """GPIO初期化

        Args:
            i2caddr: RPi-GP10のI2Cスレーブアドレス
            strobe: RPi-GP10のストローブ信号のGPIOポート番号
            trigger: RPi-GP10のトリガー信号のGPIOポート番号
        """

        self.i2c     = smbus.SMBus(1)
        self.i2caddr = i2caddr
        self.strobe  = strobe
        self.trigger = trigger
        self.logger  = logger

        if debug is True:
            self.logger.setLevel(logging.DEBUG)

        # RPi-GP10の初期化
        self.__init_GP10()

    def __del__(self):
        GPIO.cleanup([self.strobe, self.trigger])
        self.gppower.off()

    def __init_GP10(self):
        self.gppower = GpPower()
        GPIO.setmode(GPIO.BCM)
        GPIO.setup(self.strobe, GPIO.OUT, initial = GPIO.LOW)
        GPIO.setup(self.trigger, GPIO.IN, pull_up_down = GPIO.PUD_OFF)

        try:
            self.i2c.write_byte_data(self.i2caddr, self.TCA9535_CONFIG_P0, 0x00)
            self.i2c.write_byte_data(self.i2caddr, self.TCA9535_POLINV_P0, 0x00)
            self.i2c.write_byte_data(self.i2caddr, self.TCA9535_CONFIG_P1, 0xFF)
            self.i2c.write_byte_data(self.i2caddr, self.TCA9535_POLINV_P1, 0xFF)
            time.sleep(0.1)
            self.logger.info("RPi-GP10: 初期化に成功しました")
        except:
            self.logger.exception("RPi-GP10: 初期化に失敗しました")

    def output(self, value):
        """デジタル出力へ指定した値を出力する

        Args:
            value: デジタル出力データ
        """
        try:
            self.i2c.write_byte_data(self.i2caddr, self.TCA9535_OUTPUT_P0, value)
            time.sleep(0.1)
        except:
            self.logger.exception("RPi-GP10: 信号出力に失敗")

    def input(self):
        """デジタル入力を取得する

        Returns:
            デジタル入力の値を返す
        """

        value = 0xFF
        try:
            value = self.i2c.read_byte_data(self.i2caddr, self.TCA9535_INPUT_P1)
        except:
            self.logger.exception("RPi-GP10: 入力信号の検知に失敗")

        return value

    def input_triger(self):
        """トリガー端子入力
        """
        return GPIO.input(self.trigger)

    def output_strobe(self, onoff):
        """ストローブ端子出力

        GPIOの設定は反転して出力される

        Args:
            onoff: Set True is Low, False is Hish.
        """
        GPIO.output(self.strobe, onoff)

    def set_event_trigger(self, mycallback):
        """トリガー端子の割り込み検知設定

        Args:
            mycallback: 検知時に呼ばれるコールバック関数
        """
        GPIO.add_event_detect(self.trigger, GPIO.FALLING, callback = mycallback, bouncetime = 200)

    def remove_event_trigger(self):
        """トリガー端子の割り込み検知を解除する
        """
        GPIO.remove_event_detect(self.trigger)

