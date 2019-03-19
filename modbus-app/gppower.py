# -*- coding: utf-8 -*-

"""
RPi-GP電源制御
"""

import time
import RPi.GPIO as GPIO

class GpPower:
    _instance = None
    _count = 0

    def __init__(self):
        if 0 == self._count:
            GPIO.setmode(GPIO.BCM)
            GPIO.setup(27, GPIO.OUT, initial = GPIO.HIGH)
            time.sleep(0.5)

        self._count += 1

    def __new__(cls):
        if cls._instance is None:
            cls._instance = super().__new__(cls)

        return cls._instance

    def off(self):
        self._count -= 1

        if 0 == self._count:
            GPIO.output(27, False)
            GPIO.cleanup()

