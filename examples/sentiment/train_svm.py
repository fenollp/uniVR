#!/usr/bin/python2

from __future__ import print_function
from sklearn.svm import SVC

import utils as u
import numpy as np

import sys
import os
import json
import random
import itertools

if len(sys.argv) != 2:
    print(sys.argv[0], "  <landmarks data.json>")
    exit(1)

viz = True
train_v_test = 0.8
# Es = [0, 1, 2, 3, 4, 5, 6, 7]
Es = [1, 3, 5, 7]
ckplus_use_only_last_from_each_sequence = False
# seed random here

def get_items(E, whole):
    items0 = []
    for (img, data) in whole:
        if E == data['e']:
            items0.append((img, data))
    if ckplus_use_only_last_from_each_sequence:
        h = {} # CK+ specific: get only most expressive of CK+ sequence.
        for (img, data) in items0:
            key = '_'.join(img.split('_')[:2])
            val = h.get(key, None)
            if val == None or val[0] < img:
                h[key] = (img, data)
        items = h.values()
    else:
        items = items0
    random.shuffle(items)
    count = len(items)
    print(E, u.E_to_emotion(E), 'count', count)
    train = items[:int(count * train_v_test)]
    test  = items[-int(count * (1 - train_v_test)):]
    return train, test

def make_sets():
    whole = []
    with open(sys.argv[1], 'r') as fjson:
        for img, data in json.load(fjson).iteritems():
            whole.append((img, data))
    trainX, testX = [], []
    trainY, testY = [], []
    for E in Es:
        train, test = get_items(E, whole)
        for (img, data) in train:
            trainX.append(u.polars(data['ls']))
            trainY.append(data['e'])
        for (img, data) in test:
            testX.append(u.polars(data['ls']))
            testY.append(data['e'])
    return trainX, trainY, testX, testY

# Set the classifier as a support vector machines with polynomial kernel
clf = SVC(kernel='linear', probability=True)#, verbose = True)
scores = []
for i in [1]:
# for i in xrange(1, 10+1):
    print(i)
    trainX, trainY, testX, testY = make_sets()
    print('training')
    clf.fit(np.array(trainX), np.array(trainY))
    score = clf.score(np.array(testX), testY)
    print('accuracy:', score)
    scores.append(score)
print('mean accuracy:', np.mean(scores))


if not viz: exit()
import cv2
facer, landmarker = u.detectors()
cam = cv2.VideoCapture(0)
if not cam.isOpened():
    print('!cam')
    exit()
while True:
    err, img = cam.read()
    if not err:
        print('!err')
        exit()

    for box in facer(img, 1):
        # cv2.rectangle(img, (int(box.left()),int(box.top())), (int(box.right()),int(box.bottom())), (255,255,255), 1)
        shape = landmarker(img, box)
        Xs, Ys = [], []
        for part in shape.parts():
            p = (part.x, part.y)
            Xs.append(float(p[0]))
            Ys.append(float(p[1]))
            cv2.line(img, p, p, (0,0,255), 2)
        _newDelta, pMean, Normd = u.normalize(Xs, Ys)
        i, Ls = 0, []
        for part in xrange(0, len(Normd) // 4):
            p = (int(pMean[0] + Normd[i+2]), int(pMean[1] + Normd[i+3]))
            Ls.append({'m': int(Normd[i + 0]),
                       'a': int(Normd[i + 1]),
                       'x': int(Normd[i + 2]),
                       'y': int(Normd[i + 3])})
            cv2.line(img, p, p, (255,0,0), 2)
            i += 4
        # [E] = clf.predict([u.polars(Ls)])
        # print('predicted', E, u.E_to_emotion(E))
        # cv2.putText(img, u.E_to_emotion(E), (0,0), cv2.FONT_HERSHEY_SIMPLEX, .5, (255,255,255), 1)
        [preds] = clf.predict_log_proba([u.polars(Ls)])
        Preds = [(i, pred) for i, pred in enumerate(preds)]
        p = (0, 0)
        for (j, pred) in sorted(Preds, key=lambda (_,x): x, reverse=True):
            E = Es[j]
            p = (p[0], p[1] + 20)
            s = u.E_to_emotion(E) + ': ' + str(pred)
            cv2.putText(img, s, p, cv2.FONT_HERSHEY_SIMPLEX, .5, (255,255,255), 1)

    cv2.imshow('sentiment', img)
    if cv2.waitKey(1) == ord('q'):
        break
