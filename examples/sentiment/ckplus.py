#!/usr/bin/python2

from __future__ import print_function

import dlib
import sys
import os
import glob
import cv2
import math
import numpy as np

from skimage import io


if len(sys.argv) != 2:
    print(sys.argv[0], "  <CK+ dataset's folder path>")
    exit()


viz = True
predictor_path = '../../data/ldmrks68.dat'
ckplus_root = sys.argv[1]
ckplus_emotion = 'Emotion'
ckplus_images = 'cohn-kanade-images'
ckplus_landmarks = 'Landmarks'
ckplus_csv = os.path.join(ckplus_root, 'ckplus.csv')
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
        E = float(ftxt.read().strip())
        return E, imgs


def landmarks_from_img(img):
    dir1, dir2, idxpng = img.split(os.sep)[-1].split('_')
    idx, _ = idxpng.split('.')
    name = dir1 + '_' + dir2 + '_' + idx + '_landmarks.txt'
    path = os.path.join(ckplus_root, ckplus_landmarks, dir1, dir2, name)
    Ls = []
    with open(path, 'r') as ftxt:
        for line in ftxt:
            x, y = line.split()
            Ls.append(float(x))
            Ls.append(float(y))
    return Ls


def beta(xTop, yTop, xTip, yTip):
    b = math.atan((yTop - yTip) / (xTop - xTip + SMOOTHING))
    b += math.pi/2 if b < 0 else -math.pi/2
    print('beta', "{:.3f}".format(b * 180 / math.pi))
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


ckplus_csv = open(ckplus_csv, 'wa')

# for txt in glob.glob(os.path.join(ckplus_root, ckplus_emotion, 'S071', '005', '*.txt')):
for txt in glob.glob(os.path.join(ckplus_root, ckplus_emotion, '*', '*', '*.txt')):
    E, imgs = e_and_imgs_from_txt(txt)
    print('\t', "E imgs", E, len(imgs))

    for j, f in enumerate(imgs):
        print("Processing file:", f)
        img = io.imread(f)

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

        Ls = landmarks_from_img(f)
        print('#landmarks', len(Ls))
        if len(Ls) != 2*68:
            exit()

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
                ptxt = (int(Ls[PLs]), int(Ls[PLs+1]))
                pdet = (part.x, part.y)
                # cv2.line(wLs, ptxt, ptxt, (0,255,255), 2)
                cv2.line(wLs, pdet, pdet, (255,255,0), 2)
            PLs += 2

        NormLs = normalize(Xs, Ys)
        print('#NormLs', len(NormLs))
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
            delta = beta(NormLs[2+4*MARK_NOSE_TOP], NormLs[3+4*MARK_NOSE_TOP],
                         NormLs[2+4*MARK_NOSE_TIP], NormLs[3+4*MARK_NOSE_TIP])
            delta_offset = abs(int(delta * 180 / math.pi))
            print('new beta offset', delta_offset)
            if delta_offset != 0:
                exit()

        if viz:
            win.add_overlay(shape)
            win.add_overlay(box)
            # dlib.hit_enter_to_continue()

        if viz:
            cv2.imshow("wLs", wLs)
            # cv2.waitKey(0)
        # exit()

        line = str(E)
        for part in shape.parts():
            line += ',' + str(part.x) + ',' + str(part.y)
        print(line, file=ckplus_csv)

ckplus_csv.close()

print('done')
