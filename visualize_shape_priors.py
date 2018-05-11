import argparse
import scipy.io as sio
import sys
import pdb
import os
import cv2
from mpl_toolkits.mplot3d import Axes3D
import matplotlib.pyplot as plt
import numpy as np
from math import *

def show2dLandmarks(proj2d, image):
        for idx in range(proj2d.shape[1]/2):
                if proj2d[1][idx] >= image.shape[0] or proj2d[0][idx] >= image.shape[1] or proj2d[0][idx] < 0 or proj2d[1][idx] < 0:
                        continue

                cv2.circle(image, (int(proj2d[0][idx]), int(proj2d[1][idx])), 4, (0,0,255), -1)

        for idx in range(proj2d.shape[1]/2,proj2d.shape[1]):
                if proj2d[1][idx] >= image.shape[0] or proj2d[0][idx] >= image.shape[1] or proj2d[0][idx] < 0 or proj2d[1][idx] < 0:
                        continue

                cv2.circle(image, (int(proj2d[0][idx]), int(proj2d[1][idx])), 4, (0,255,0), -1)

def visualize_car(x3d, ax):
        ax.clear()

        ax.scatter(x3d[0, 0:16], x3d[1, 0:16], x3d[2, 0:16], c='r', marker='.', s=40)
        ax.scatter(x3d[0, 16:18], x3d[1, 16:18], x3d[2, 16:18], c='r', marker='.', s=800)
        ax.scatter(x3d[0, 18:34], x3d[1, 18:34], x3d[2, 18:34], c='g', marker='.', s=40)
        ax.scatter(x3d[0, 34:36], x3d[1, 34:36], x3d[2, 34:36], c='g', marker='.', s=800)
        ax.plot(x3d[0, 0:16], x3d[1, 0:16], x3d[2, 0:16], c='r')
        ax.plot([x3d[0,15], x3d[0,0]], [x3d[1,15],x3d[1,0]], [x3d[2,15],x3d[2,0]], c='r')
        ax.plot(x3d[0, 18:34], x3d[1, 18:34], x3d[2, 18:34], c='g')
        ax.plot([x3d[0,33], x3d[0,18]], [x3d[1,33],x3d[1,18]], [x3d[2,33],x3d[2,18]], c='g')
        for i in range(8):
                ax.plot([x3d[0,i], x3d[0,i+18]], [x3d[1,i],x3d[1,i+18]], [x3d[2,i],x3d[2,i+18]], c=(0,0,0))
                ax.set_xlabel('X Label')
                ax.set_ylabel('Y Label')
                ax.set_zlabel('Z Label')
                for direction in (-1, 1):
                        for point in np.diag(direction * np.array([0.5,0.3,0.3])):
                                ax.plot([point[0]], [point[1]], [point[2]], 'w')

        ax.view_init(elev=105, azim=270)
        plt.draw()
        plt.waitforbuttonpress()

def get_deformable_shapes(mean_shape,deformation_weight,deformations):

        #mean_shape: 3 X K, where K is the number of keypoints
        #deformation_weight: T X B, where B is the number of basis vectors and T is the total frames
        #deformations: B X K X 3

        _,K = mean_shape.shape
        T,B = deformation_weight.shape
        
        deformable_shape = []
        for i in xrange(T):
                weight = deformation_weight[i,:]
                #print weight
                for j in xrange(B):
                        deformations[j,:,:] = weight[j]*deformations[j,:,:]

                shape = mean_shape+np.sum(deformations,axis=0).T
                deformable_shape.append(shape)

        return deformable_shape

def main():
    parser = argparse.ArgumentParser(description='Visualize shape priors')
    parser.add_argument('input_file', help='Input .mat file containing the shape priors')
    parser.add_argument('mean_shape', help='This is the mean shape computed in the NRSfm pipeline')
    parser.add_argument('deformation_weight', help='This is the .mat file containing the deformable weights learnt from the NRSfm pipeline')
    
    args = parser.parse_args()

    shape_priors = sio.loadmat(args.input_file)['V']
    B,K = shape_priors.shape

    B = int(B/3)
    #print shape_priors.shape

    mean_shape = sio.loadmat(args.mean_shape)['S_hat']
    deformation_weight = sio.loadmat(args.deformation_weight)['Z'] # T X V, where T is the number of frames that were sent as input to NRSfm

    fig = plt.figure(1)
    ax = fig.add_subplot(111, projection='3d')

    x_coord = []
    y_coord = []
    z_coord = []
    for i in xrange(B):
            x_coord.append(shape_priors[3*i,:])
            y_coord.append(shape_priors[3*i+1,:])
            z_coord.append(shape_priors[3*i+2,:])


    x_coord = np.array(x_coord)
    y_coord = np.array(y_coord)
    z_coord = np.array(z_coord)
    deformations = np.stack((x_coord,y_coord,z_coord),axis=2)

    deformable_shapes = get_deformable_shapes(mean_shape,deformation_weight,deformations)
    #print deformable_shapes[3]
    #print deformations.shape
    for x in xrange(len(deformable_shapes)):
    #        deformation = np.vstack((x_coord[x],y_coord[x],z_coord[x]))

            #shape = shape_priors[3*x:3*x+3,:]
            #print deformable_shapes[x].shape
            visualize_car(deformable_shapes[x],ax)
    #        visualize_car(mean_shape,ax)

if __name__=='__main__':
    main()
