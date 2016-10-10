#!/usr/bin/python2

from __future__ import print_function
from skimage import io

import dlib
import sys
import os
import glob
import math
import json
import numpy as np

SMOOTHING = 1e-9

MARK_NOSE_TOP = 27
MARK_NOSE_TIP = 33

MARK_LEFT = 0
MARKS_LEFT = [MARK_LEFT, 1, 2, 3]

MARK_RIGHT = 16
MARKS_RIGHT = [MARK_RIGHT, 15, 14, 13]

MARK_TOP = 19
MARKS_TOP = [18, MARK_TOP, 20, 23, 24, 25]

MARKS_BOTTOM = [5, 6, 7, 8, 9, 10, 11]


def detectors():
    detector = dlib.get_frontal_face_detector()
    predictor = dlib.shape_predictor('../../data/ldmrks68.dat')
    return detector, predictor


def E_to_emotion(E):
    return {0: 'neutral',
            1: 'anger',
            2: 'contempt',
            3: 'disgust',
            4: 'fear',
            5: 'happy',
            6: 'sadness',
            7: 'surprise'
    }[E].upper()


def beta(xTop, yTop, xTip, yTip):
    b = math.atan((yTop - yTip) / (xTop - xTip + SMOOTHING))
    b += math.pi/2 if b < 0 else -math.pi/2
    print('delta to nose:', "{:.3f}".format(b * 180 / math.pi))
    return b


def normalize(Xs, Ys):
    xMean, yMean = np.mean(Xs), np.mean(Ys)
    # Center on middle of landmarks area
    xs, ys = [x - xMean for x in Xs], [y - yMean for y in Ys]
    # Align nose bridge with vertical
    delta = - beta(xs[MARK_NOSE_TOP], ys[MARK_NOSE_TOP],
                   xs[MARK_NOSE_TIP], ys[MARK_NOSE_TIP])
    Coords = []
    # xMin, xMax, yMin, yMax = 512, -512, 512, -512
    for x, y, part in zip(xs, ys, [part for part in xrange(0, len(Xs)+1)]):
        xx = x * math.cos(delta) - y * math.sin(delta)
        yy = x * math.sin(delta) + y * math.cos(delta)
        m = math.sqrt(xx ** 2 + yy ** 2)
        a = math.atan(yy / (xx + SMOOTHING)) * 180 / math.pi
        Coords.append(m)
        Coords.append(a)
        Coords.append(xx)
        Coords.append(yy)
        if part is MARK_NOSE_TIP:
            print('normalized nose tip:', 'x', xx, 'y', yy, 'm', m, 'a', a)
    #     if part in MARKS_LEFT:
    #         xMin = min(xMin, xx)
    #     if part in MARKS_RIGHT:
    #         xMax = max(xMax, xx)
    #     if part in MARKS_TOP:
    #         yMax = max(yMax, yy)
    #     if part in MARKS_BOTTOM:
    #         yMin = min(yMin, yy)
    # print('xMin', xMin, 'xMax', xMax, 'yMin', yMin, 'yMax', yMax)
    # sx = abs(xMax) + abs(xMin)
    # sy = abs(yMax) + abs(yMin)
    # print('|xMax|+|xMin|', sx, '|yMax|+|yMin|', sy)
    # print('sy/sx', sy / sx)
    # print('sx/sy', sx / sy)
    return (int(xMean), int(yMean)), Coords


def polars(Coords):
    L = []
    for coord in Coords:
        L.append(coord['m'])
        L.append(coord['a'])
    return L
