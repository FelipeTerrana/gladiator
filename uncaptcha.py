import sys
import numpy as np
import cv2 as cv
import captcha_character as cc

text = cc.uncaptcha(sys.argv[-1])

if text != None:
    print(text)
