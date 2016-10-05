#!/usr/bin/python2

from __future__ import print_function

import dlib
import sys
import os
import glob

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



ckplus_csv = open(ckplus_csv, 'wa')

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
        # DiffLs = []
        # PLs = 0
        # for part in shape.parts():
        #     DiffLs.append(Ls[PLs+0] - part.x)
        #     DiffLs.append(Ls[PLs+1] - part.y)
        #     PLs += 2
        # print('DiffLs', DiffLs)

        line = str(E)
        for part in shape.parts():
            line += ',' + str(part.x) + ',' + str(part.y)
        print(line, file=ckplus_csv)

        if viz:
            win.add_overlay(shape)
            win.add_overlay(box)
            dlib.hit_enter_to_continue()


ckplus_csv.close()
print('done')
