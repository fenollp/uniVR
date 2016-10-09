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

viz = False  # :: boolean
if viz:
    import cv2

if len(sys.argv) != 2:
    print(sys.argv[0], "  <CK+ dataset's folder path>")
    exit()


predictor_path = '../../data/ldmrks68.dat'
ckplus_root = sys.argv[1]
ckplus_emotion = 'Emotion'
ckplus_images = 'cohn-kanade-images'
ckplus_landmarks = 'Landmarks'
ckplus_facs = 'FACS'
ckplus_json = os.path.join(ckplus_root, 'ckplus.json')

MARK_NOSE_TOP = 27
MARK_NOSE_TIP = 33
SMOOTHING = 0.000000001
MARK_LEFT = 0
MARKS_LEFT = [MARK_LEFT, 1, 2, 3]
MARK_RIGHT = 16
MARKS_RIGHT = [MARK_RIGHT, 15, 14, 13]
MARK_TOP = 19
MARKS_TOP = [18, MARK_TOP, 20, 23, 24, 25]
MARKS_BOTTOM = [5, 6, 7, 8, 9, 10, 11]

detector = dlib.get_frontal_face_detector()
predictor = dlib.shape_predictor(predictor_path)
if viz:
    win = dlib.image_window()


def e_and_imgs_from_txt(txt):
    dir1, dir2, last, _constdottxt = txt.split(os.sep)[-1].split('_')
    imgs_root = os.path.join(ckplus_root, ckplus_images, dir1, dir2)
    pad = len(last)
    name = lambda idx: dir1 + '_' + dir2 + '_' + str(idx).zfill(pad) + '.png'
    ## Take the last images of the sequence. MIGHT fix too much on face!
    imgs = [os.path.join(imgs_root, name(i)) for i in range(int(last) // 2, int(last) + 1)]
    with open(txt, 'r') as ftxt:
        E = int(float(ftxt.read().strip()))
        return E, imgs

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

def landmarks_from_img(img):
    dir1, dir2, idxpng = img.split(os.sep)[-1].split('_')
    idx, _ = idxpng.split('.')
    name = dir1 + '_' + dir2 + '_' + idx + '_landmarks.txt'
    path = os.path.join(ckplus_root, ckplus_landmarks, dir1, dir2, name)
    xLs, yLs = [], []
    with open(path, 'r') as ftxt:
        for line in ftxt:
            x, y = line.split()
            xLs.append(float(x))
            yLs.append(float(y))
    return xLs, yLs

def facs_from_txt(txt):
    dir1, dir2, last, _constdottxt = txt.split(os.sep)[-1].split('_')
    fname = '_'.join([dir1, dir2, last, 'facs']) + '.txt'
    path = os.path.join(ckplus_root, ckplus_facs, dir1, dir2, fname)
    with open(path, 'r') as ftxt:
        AUs = []
        for line in ftxt:
            au = 10 * float(line.strip().split()[0])
            assert au == int(au)
            au = int(au)
            AUs.append(au)
        return AUs

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


JSON = {}

for txt in glob.glob(os.path.join(ckplus_root, ckplus_emotion, '*', '*', '*.txt')):
    print(txt)
    E, imgs = e_and_imgs_from_txt(txt)
    print('\t', 'E', E_to_emotion(E), 'imgs', len(imgs))
    FACS = facs_from_txt(txt)
    print('\t', 'FACS', len(FACS), FACS)

    for fimg in imgs:
        print('Processing', fimg)
        img = io.imread(fimg)

        if viz:
            win.clear_overlay()
            win.set_image(img)

        # Ask the detector to find the bounding boxes of each face. The 1 in the
        # second argument indicates that we should upsample the image 1 time. This
        # will make everything bigger and allow us to detect more faces.
        dets = detector(img, 1)
        assert len(dets) > 0
        box = sorted(dets, key=lambda rect: rect.area(), reverse=True)[0]
        shape = predictor(img, box)

        if True:
            xLs, yLs = landmarks_from_img(fimg)
            assert len(xLs) == 68 and 68 == len(yLs)

        if viz:
            wLs = np.zeros((512, 512, 3), np.uint8)
            xTip = shape.part(MARK_NOSE_TIP).x
            yTip = shape.part(MARK_NOSE_TIP).y
            cv2.line(wLs, (xTip,0), (xTip,512), (255,255,255), 1)
            cv2.line(wLs, (0,yTip), (512,yTip), (255,255,255), 1)

        PLs = 0
        Xs, Ys = [], []
        for part in shape.parts():
            Xs.append(float(part.x))
            Ys.append(float(part.y))
            if viz:
                # ptxt = (int(xLs[PLs]), int(yLs[PLs]))
                # cv2.line(wLs, ptxt, ptxt, (0,255,255), 2)
                pdet = (part.x, part.y)
                cv2.line(wLs, pdet, pdet, (0,0,255), 2)
            PLs += 2
        assert len(Xs) == 68 and 68 == len(Ys)

        pMean, Normd = normalize(Xs, Ys)
        assert len(Normd) == 2 * 2 * 68
        delta = beta(Normd[2+4*MARK_NOSE_TOP], Normd[3+4*MARK_NOSE_TOP],
                     Normd[2+4*MARK_NOSE_TIP], Normd[3+4*MARK_NOSE_TIP])
        assert 0 == abs(int(delta * 180 / math.pi))
        if viz:
            pTip = (int(Xs[MARK_NOSE_TIP]), int(Ys[MARK_NOSE_TIP]))
            pTop = (int(Xs[MARK_NOSE_TOP]), int(Ys[MARK_NOSE_TOP]))
            cv2.line(wLs, pTip, pTop, (255,255,255), 2)
            cv2.line(wLs, (pTip[0],0), (pTip[0],512), (0,0,255), 1)
            cv2.line(wLs, (0,pTip[1]), (512,pTip[1]), (0,0,255), 1)
            cv2.line(wLs, (pMean[0],0), (pMean[0],512), (255,255,255), 1)
            cv2.line(wLs, (0,pMean[1]), (512,pMean[1]), (255,255,255), 1)
            PLs = 0
            for part in xrange(0, len(Normd) // 4):
                xx, yy = int(Normd[PLs+2]), int(Normd[PLs+3])
                p = (pMean[0] + xx, pMean[1] + yy)
                if part is MARK_NOSE_TIP or part is MARK_NOSE_TOP:
                    cv2.line(wLs, p, p, (255,0,0), 4)
                else:
                    cv2.line(wLs, p, p, (255,255,255), 2)
                if part is MARK_LEFT:
                    cv2.line(wLs, pMean, (pMean[0]+xx, pMean[1]+yy), (255,0,0), 2)
                    print('B left:', 'x', xx, 'y', yy, 'm', Normd[PLs], 'a', Normd[PLs+1])
                if part is MARK_RIGHT:
                    cv2.line(wLs, pMean, (pMean[0]+xx, pMean[1]+yy), (0,255,0), 2)
                    print('G right:', 'x', xx, 'y', yy, 'm', Normd[PLs], 'a', Normd[PLs+1])
                if part is MARK_TOP:
                    cv2.line(wLs, pMean, (pMean[0]+xx, pMean[1]+yy), (0,0,255), 2)
                    print('R top:', 'x', xx, 'y', yy, 'm', Normd[PLs], 'a', Normd[PLs+1])
                PLs += 4

        if viz:
            win.add_overlay(shape)
            win.add_overlay(box)
            # dlib.hit_enter_to_continue()

        if viz:
            cv2.imshow("wLs", wLs)
            cv2.waitKey(0)

        Ls = []
        PLs = 0
        for part in xrange(0, len(Normd) // 4):
            # MIGHT loose interesting precision! (float -> int)
            Ls.append({'m': int(Normd[PLs + 0]),
                       'a': int(Normd[PLs + 1]),
                       'x': int(Normd[PLs + 2]),
                       'y': int(Normd[PLs + 3])})
            PLs += 4
        assert 68 == len(Ls)
        fn = fimg.split(os.sep)[-1]
        assert 0 != len(fn)
        JSON[fn] = {'ls': Ls, 'e': E, 'facs': FACS}


with open(ckplus_json, 'w') as jout:
    json.dump(JSON, jout)

print('done')
