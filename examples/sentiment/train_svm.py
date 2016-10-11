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
# seed random here

def get_items(E):
    items = []
    with open(sys.argv[1], 'r') as fjson:
        for img, data in json.load(fjson).iteritems():
            if E == data['e']:
                items.append((img, data))
    random.shuffle(items)
    count = len(items)
    print(u.E_to_emotion(E), 'count', count)
    train = items[:int(count * train_v_test)]
    test  = items[-int(count * (1 - train_v_test)):]
    return train, test

def make_sets():
    trainX, testX = [], []
    trainY, testY = [], []
    for E in xrange(0, 7+1):
        train, test = get_items(E)
        for (img, data) in train:
            trainX.append(u.polars(data['ls']))
            trainY.append(data['e'])
        for (img, data) in test:
            testX.append(u.polars(data['ls']))
            testY.append(data['e'])
    return trainX, trainY, testX, testY

# Set the classifier as a support vector machines with polynomial kernel
clf = SVC(kernel='linear', probability=True, tol=1e-3)#, verbose = True)

scores = []
for i in xrange(1, 10+1):
    print(i)
    trainX, trainY, testX, testY = make_sets()
    print('training')
    clf.fit(np.array(trainX), np.array(trainY))
    score = clf.score(np.array(testX), testY)
    print('accuracy:', score)
    scores.append(score)
print('mean accuracy:', np.mean(scores))


if viz:
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
            cv2.rectangle(img, (int(box.left()),int(box.top())), (int(box.right()),int(box.bottom())), (255,255,255), 1)
            shape = landmarker(img, box)
            Xs, Ys = [], []
            for part in shape.parts():
                p = (part.x, part.y)
                Xs.append(float(p[0]))
                Ys.append(float(p[1]))
                cv2.line(img, p, p, (0,0,255), 2)
            pMean, Normd = u.normalize(Xs, Ys)
            i, Ls = 0, []
            for part in xrange(0, len(Normd) // 4):
                p = (int(Normd[i+2]), int(Normd[i+3]))
                Ls.append({'m': int(Normd[i + 0]),
                           'a': int(Normd[i + 1]),
                           'x': int(Normd[i + 2]),
                           'y': int(Normd[i + 3])})
                cv2.line(img, p, p, (255,0,0), 2)
                i += 4
            [E] = clf.predict([u.polars(Ls)])
            print('predicted', E)
            loc = (int(box.left()), int(box.top()-20))
            cv2.putText(img, u.E_to_emotion(E), loc , cv2.FONT_HERSHEY_SIMPLEX, .5, (255,255,255), 1)

        cv2.imshow('sentiment', img)
        if cv2.waitKey(1) == ord('q'):
            break
