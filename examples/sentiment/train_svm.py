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

# seed random here

def get_items(E):
    items = []
    with open(sys.argv[1], 'r') as fjson:
        for img, data in json.load(fjson).iteritems():
            items.append((img, data))
    random.shuffle(items)
    count = len(items)
    train_v_test = 0.4
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
