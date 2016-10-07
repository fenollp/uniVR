#!/usr/bin/python2

from __future__ import print_function
from skimage import io

import dlib
import sys
import os
import glob
import cv2
import math
import json
import numpy as np


if len(sys.argv) != 2:
    print(sys.argv[0], "  <CK+ dataset's folder path>")
    exit()


viz = False  # :: boolean

predictor_path = '../../data/ldmrks68.dat'
ckplus_root = sys.argv[1]
ckplus_emotion = 'Emotion'
ckplus_images = 'cohn-kanade-images'
ckplus_landmarks = 'Landmarks'
ckplus_json = os.path.join(ckplus_root, 'ckplus.json')
MARK_NOSE_TOP = 27
MARK_NOSE_TIP = 33
SMOOTHING = 0.000000001


detector = dlib.get_frontal_face_detector()
predictor = dlib.shape_predictor(predictor_path)
if viz:
    win = dlib.image_window()


def e_and_imgs_from_txt(txt):
    txt_filename = txt.split(os.sep)[-1]
    dir1, dir2, last, _constdottxt = txt_filename.split('_')
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


def beta(xTop, yTop, xTip, yTip):
    b = math.atan((yTop - yTip) / (xTop - xTip + SMOOTHING))
    b += math.pi/2 if b < 0 else -math.pi/2
    print('delta to nose:', "{:.3f}".format(b * 180 / math.pi))
    return b

def normalize(Xs, Ys):
    delta = - beta(Xs[MARK_NOSE_TOP], Ys[MARK_NOSE_TOP],
                   Xs[MARK_NOSE_TIP], Ys[MARK_NOSE_TIP])
    Xmean, Ymean = np.mean(Xs), np.mean(Ys)
    X, Y = [x - Xmean for x in Xs], [y - Ymean for y in Ys]
    landmarks = []
    for x, y in zip(X, Y):
        landmarks.append(x)
        landmarks.append(y)
        landmarks.append(x * math.cos(delta) - y * math.sin(delta))
        landmarks.append(x * math.sin(delta) + y * math.cos(delta))
    return landmarks


JSON = []

for txt in glob.glob(os.path.join(ckplus_root, ckplus_emotion, '*', '*', '*.txt')):
    E, imgs = e_and_imgs_from_txt(txt)
    print('\t', 'E', E_to_emotion(E), 'imgs', len(imgs))

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
        # print("#faces:", len(dets))
        box = sorted(dets, key=lambda rect: rect.area(), reverse=True)[0]
        shape = predictor(img, box)

        if True:
            xLs, yLs = landmarks_from_img(fimg)
            assert len(xLs) == 68 and 68 == len(yLs)

        xTip = shape.part(MARK_NOSE_TIP).x
        yTip = shape.part(MARK_NOSE_TIP).y
        if viz:
            wLs = np.zeros((512, 512, 3), np.uint8)
            cv2.line(wLs, (xTip,0), (xTip,512), (255,255,255), 1)
            cv2.line(wLs, (0,yTip), (512,yTip), (255,255,255), 1)

        PLs = 0
        Xs, Ys = [], []
        for part in shape.parts():
            Xs.append(float(part.x))
            Ys.append(float(part.y))
            if viz:
                # ptxt = (int(Ls[PLs]), int(Ls[PLs+1]))
                # cv2.line(wLs, ptxt, ptxt, (0,255,255), 2)
                pdet = (part.x, part.y)
                cv2.line(wLs, pdet, pdet, (255,255,0), 2)
            PLs += 2
        assert len(Xs) == 68 and 68 == len(Ys)

        NormLs = normalize(Xs, Ys)
        assert len(NormLs) == 2 * 2 * 68
        delta = beta(NormLs[2+4*MARK_NOSE_TOP], NormLs[3+4*MARK_NOSE_TOP],
                     NormLs[2+4*MARK_NOSE_TIP], NormLs[3+4*MARK_NOSE_TIP])
        assert 0 == abs(int(delta * 180 / math.pi))
        if viz:
            pTip = (int(Xs[MARK_NOSE_TIP]), int(Ys[MARK_NOSE_TIP]))
            pTop = (int(Xs[MARK_NOSE_TOP]), int(Ys[MARK_NOSE_TOP]))
            cv2.line(wLs, pTip, pTop, (255,255,255), 2)
            # pTip = (int(Ls[2*MARK_NOSE_TIP]), int(Ls[1+2*MARK_NOSE_TIP]))
            # pTop = (int(Ls[2*MARK_NOSE_TOP]), int(Ls[1+2*MARK_NOSE_TOP]))
            # cv2.line(wLs, pTip, pTop, (255,255,255), 1)
            PLs = 0
            for part in xrange(0, len(NormLs) // 4):
                # p = (xTip + int(NormLs[PLs+0]), int(yTip + NormLs[PLs+1]))
                # cv2.line(wLs, p, p, (255,127,255), 4)
                p = (xTip + int(NormLs[PLs+2]), int(yTip + NormLs[PLs+3]))
                cv2.line(wLs, p, p, (255,255,255), 4)
                PLs += 4
            cv2.line(wLs, (pTip[0],0), (pTip[0],512), (255,255,255), 1)
            cv2.line(wLs, (0,pTip[1]), (512,pTip[1]), (255,255,255), 1)

        if viz:
            win.add_overlay(shape)
            win.add_overlay(box)
            # dlib.hit_enter_to_continue()

        if viz:
            cv2.imshow("wLs", wLs)
            cv2.waitKey(0)

        Ls = []
        PLs = 0
        for part in xrange(0, len(NormLs) // 4):
            # MIGHT loose interesting precision! (float -> int)
            Ls.append({'x': int(NormLs[PLs+2]), 'y': int(NormLs[PLs+3])})
            PLs += 4
        assert 68 == len(Ls)
        fn = fimg.split(os.sep)[-1]
        assert 0 != len(fn)
        JSON.append({'fn': fn,
                     'ls': Ls,
                     'e': E})


with open(ckplus_json, 'w') as jout:
    json.dump(JSON, jout)

print('done')
