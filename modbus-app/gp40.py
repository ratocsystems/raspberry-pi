# -*- coding: utf-8 -*-

"""
RPi-GP40制御ライブラリ
"""

from enum import IntEnum
import spidev
import RPi.GPIO as GPIO

from gppower import GpPower

class Gp40:
    """RPi-GP40制御を行う
    """

    # ADS8668レジスタ一覧
    ADS8668_CMD_NO_OP    = 0x00
    ADS8668_CMD_AUTO_RST = 0xA0
    ADS8668_CMD_MAN_CH0  = 0xC0

    ADS8668_PRG_AUTO_SEQ_EN = 0x01
    ADS8668_PRG_FEATURE_SEL = 0x03
    ADS8668_PRG_RANGE_CH0   = 0x05
    ADS8668_PRG_TRIP_ALL    = 0x10
    ADS8668_PRG_TRIP0       = 0x11
    ADS8668_PRG_ACTIVE0     = 0x12
    ADS8668_PRG_TRIP1       = 0x13
    ADS8668_PRG_ACTIVE1     = 0x14
    ADS8668_PRG_ALARM_CH0   = 0x15

    class Channel(IntEnum):
        """ADS8668のチャネル一覧
        """
        CH0 = 0x00
        CH1 = 0x01
        CH2 = 0x02
        CH3 = 0x03
        CH4 = 0x04
        CH5 = 0x05
        CH6 = 0x06
        CH7 = 0x07

    class Range(IntEnum):
        """ADS8668のRANGE設定一覧

        PM_xxV:   ±xxV
        ZERO_xxV: 0 - xxV
        """
        PM_10V     = 0x00
        PM_5V      = 0x01
        PM_2_5V    = 0x02
        PM_1_25V   = 0x03
        PM_0_5V    = 0x0B
        ZERO_10V   = 0x05
        ZERO_5V    = 0x06
        ZERO_2_5V  = 0x07
        ZERO_1_25V = 0x0F

    def __init__(self, *, do = 12, di = 13):
        """GPIO初期化

        Args:
            do: RPi-GP40のデジタル出力のGPIOポート番号
            di: RPi-GP10のデジタル/アラーム入力のGPIOポート番号
        """

        self.spi    = spidev.SpiDev()
        self.do     = do
        self.di     = di

        # SPI初期化
        self.spi.open(0, 0)                 # SPI0, CEN0
        self.spi.mode = 1                   # SPIクロック設定 CPOL=0, CPHA=1
        self.spi.max_speed_hz = 17000000    # SPIクロック最大周波数 (17MHz)

        # RPi-GP40の初期化
        self.__init_GP40()

        # ADS8668の初期化
        self.__init_ADS8668()

    def __del__(self):
        GPIO.cleanup([self.do, self.di])
        self.gppower.off()

    def __init_GP40(self):
        self.gppower = GpPower()
        GPIO.setmode(GPIO.BCM)
        GPIO.setup(self.do, GPIO.OUT, initial = GPIO.LOW)
        GPIO.setup(self.di, GPIO.IN, pull_up_down = GPIO.PUD_OFF)

    def __init_ADS8668(self):
        for i in self.Channel:
            self.set_range(i, self.Range.PM_10V)

    def write_register(self, addr, value):
        addr = (addr << 1) | 1
        wdat = [addr, value, 0x00]
        rdat = self.spi.xfer2(wdat)
        return rdat[2]

    def read_register(self, addr):
        addr = (addr << 1) | 0
        wdat = [addr, 0x00, 0x00]
        rdat = self.spi.xfer2(wdat)
        return rdat[2]

    def transfer_data(self, addr):
        wdat = [addr, 0x00, 0x00, 0x00]
        rdat = self.spi.xfer2(wdat)
        return rdat

    def set_range(self, ch, r):
        """入力レンジの設定
        Args:
            ch: 設定チャネル (Gp40.Channel)
            r:  入力レンジ (Gp40.Range)

        Returns:
            設定した入力レンジ設定 (Gp40.Range)
        """
        if type(ch) is not self.Channel:
            raise TypeError('Invalid parameter')

        if type(r) is not self.Range:
            raise TypeError('Invalid parameter')

        return self.Range(self.write_register(self.ADS8668_PRG_RANGE_CH0 + ch, r))

    def get_range(self, ch):
        """入力レンジの設定取得
        Args:
            ch: 設定チャネル (Gp40.Channel)

        Returns:
            入力レンジ設定 (Gp40.Range)
        """
        if type(ch) is not self.Channel:
            raise TypeError('Invalid parameter')

        return self.Range(self.read_register(self.ADS8668_PRG_RANGE_CH0 + ch))

    def get_addata_lump(self, ch_list):
        """AD変換値の一括取得
        Args:
            ch_list: サイズ8のリスト、取得するチャネルはTrueを設定する

        Returns:
            8ch分のAD変換値(12bit)のリスト
        """
        if len(self.Channel) != len(ch_list):
            raise TypeError('Invalid parameter')

        # 取得対象のチャンネル設定
        enable = 0
        for i in self.Channel:
            if ch_list[i] is True:
                enable = enable | (1 << i)

        self.write_register(self.ADS8668_PRG_AUTO_SEQ_EN, enable)

        # AUTO RST開始
        self.transfer_data(self.ADS8668_CMD_AUTO_RST)

        results = [0] * 8
        for i in self.Channel:
            if ch_list[i] is True:
                rdat = self.transfer_data(self.ADS8668_CMD_NO_OP)
                adat = (rdat[2] << 4) | (rdat[3] >> 4)
                results[i] = adat

        return results

    def get_addata(self, ch):
        """AD変換値の取得
        Args:
            ch: 対象チャネル (Gp40.Channel)

        Returns:
            AD変換値(12bit)
        """
        if type(ch) is not self.Channel:
            raise TypeError('Invalid parameter')

        self.transfer_data(self.ADS8668_CMD_MAN_CH0 + (ch << 2))
        rdat = self.transfer_data(self.ADS8668_CMD_NO_OP)
        adat = (rdat[2] << 4) | (rdat[3] >> 4)
        return adat

    def set_alarm_param(self, ch, hist, hth, lth):
        """アラームのしきい値更新
        Args:
            ch: 対象チャネル (Gp40.Channel)
            hist: ヒステリシス (0 - 15)
            hth: しきい値上限 (000h - FFFh)
            lth: しきい値下限 (000h - FFFh)
        """
        if type(ch) is not self.Channel:
            raise TypeError('Invalid parameter')

        reg = self.ADS8668_PRG_ALARM_CH0 + (ch * 5)
        param = [hist << 4, (hth >> 4) & 0xFF, (hth << 4) & 0xF0, (lth >> 4) & 0xFF, (lth << 4) & 0xF0]

        for i in range(5):
            self.write_register(reg + i, param[i])

    def get_alarm_param(self, ch):
        """アラームのしきい値設定の取得
        Args:
            ch: 対象チャネル (Gp40.Channel)

        Returns:
            [ヒステリシス、しきい値上限、しきい値下限]を格納したリスト
        """
        if type(ch) is not self.Channel:
            raise TypeError('Invalid parameter')

        reg = self.ADS8668_PRG_ALARM_CH0 + (ch * 5)

        values = [0] * 5;
        for i in range(5):
            values[i] = self.read_register(reg + i)

        results = [0] * 3
        results[0] = (values[0] >> 4) & 0x0F
        results[1] = ((values[1] << 4) & 0xFF0) | ((values[2] >> 4) & 0x00F)
        results[2] = ((values[3] << 4) & 0xFF0) | ((values[4] >> 4) & 0x00F)

        return results

    def enable_alarm(self, enable):
        """アラームの有効化
        Args:
            enable: True 有効、False 無効
        """
        en = 0
        if enable is True:
            en = 1

        value = self.read_register(self.ADS8668_PRG_FEATURE_SEL)
        value = (value & 0xEF) | ((en << 4) & 0x10)
        self.write_register(self.ADS8668_PRG_FEATURE_SEL, value)

    def get_is_alarm(self):
        """アラームの有効状態取得

        Returns:
            True 有効状態
            False 無効状態
        """
        value = self.read_register(self.ADS8668_PRG_FEATURE_SEL)

        status = False
        if 0x10 == (value & 0x10):
            status = True

        return status

    def get_alarm_status(self):
        """アラーム検出状態の取得

        Returns:
            チャネル毎にトリップアラームフラグとアクティブアラームフラグの辞書型リスト
        """
        value = [0] * 4
        value[0] = self.read_register(self.ADS8668_PRG_TRIP0)
        value[1] = self.read_register(self.ADS8668_PRG_ACTIVE0)
        value[2] = self.read_register(self.ADS8668_PRG_TRIP1)
        value[3] = self.read_register(self.ADS8668_PRG_ACTIVE1)

        results = [0] * 8
        results[0] = {"active": {"high": 0x40 == (value[1] & 0x40), "low": 0x80 == (value[1] & 0x80) }, "trip": {"high": 0x40 == (value[0] & 0x40), "low": 0x80 == (value[0] & 0x80) }}
        results[1] = {"active": {"high": 0x10 == (value[1] & 0x10), "low": 0x20 == (value[1] & 0x20) }, "trip": {"high": 0x10 == (value[0] & 0x10), "low": 0x20 == (value[0] & 0x20) }}
        results[2] = {"active": {"high": 0x04 == (value[1] & 0x04), "low": 0x08 == (value[1] & 0x08) }, "trip": {"high": 0x04 == (value[0] & 0x04), "low": 0x08 == (value[0] & 0x08) }}
        results[3] = {"active": {"high": 0x01 == (value[1] & 0x01), "low": 0x02 == (value[1] & 0x02) }, "trip": {"high": 0x01 == (value[0] & 0x01), "low": 0x02 == (value[0] & 0x02) }}
        results[4] = {"active": {"high": 0x40 == (value[3] & 0x40), "low": 0x80 == (value[3] & 0x80) }, "trip": {"high": 0x40 == (value[2] & 0x40), "low": 0x80 == (value[2] & 0x80) }}
        results[5] = {"active": {"high": 0x10 == (value[3] & 0x10), "low": 0x20 == (value[3] & 0x20) }, "trip": {"high": 0x10 == (value[2] & 0x10), "low": 0x20 == (value[2] & 0x20) }}
        results[6] = {"active": {"high": 0x04 == (value[3] & 0x04), "low": 0x08 == (value[3] & 0x08) }, "trip": {"high": 0x04 == (value[2] & 0x04), "low": 0x08 == (value[2] & 0x08) }}
        results[7] = {"active": {"high": 0x01 == (value[3] & 0x01), "low": 0x02 == (value[3] & 0x02) }, "trip": {"high": 0x01 == (value[2] & 0x01), "low": 0x02 == (value[2] & 0x02) }}

        return results

    def set_digital_out(self, onoff):
        """デジタルアウトの制御

        GPIOの設定は反転して出力される

        Args:
            onoff: Set True is Low, False is Hish.
        """
        GPIO.output(self.do, onoff)

    def set_event_alarm(self, mycallback):
        """アラーム端子の割り込み検知設定

        Args:
            mycallback: 検知時に呼ばれるコールバック関数
        """
        GPIO.add_event_detect(self.di, GPIO.FALLING, callback = mycallback, bouncetime = 200)

    def remove_event_alarm(self):
        """トリガー端子の割り込み検知を解除する
        """
        GPIO.remove_event_detect(self.di)

