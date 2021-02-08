#Importing required libraries
import cv2
import numpy as np
import imutils
from matplotlib import pyplot as plt
import glob
import os
import pandas as pd
from datetime import datetime

#Defining classes dictionary
classes = {0:"Safe Driving", 1:"Texting using the right hand",2:"Talking on the phone using the right hand",3:"Texting using the left hand",4:"Talking on the phone using the left hand",
5:"Operating the radio"}

#List and Dataframe initilization for calculating accuracy at the end
clmn_nme = ["class","total","predicted"]
df = pd.DataFrame(columns = clmn_nme)

#Before model execution timestamp 
print(datetime.now().time())

#Iteration over original images present inside six different class folders 
for tot in range(6):
	img_tot=0
	res=0

	#Iteration over original images present inside specific class folder 
	for i in glob.glob("analytical_dataset/c"+str(tot)+"/*.jpg"):
		img_tot+=1

		#Reading input image
		img = cv2.imread(i)

		#Creating masked image of same size as of input image
		mask = np.zeros(img.shape[:2],np.uint8)

		#Creating masked image of same size as of input image for background and foreground segregation
		bgdModel = np.zeros((1,65),np.float64)
		fgdModel = np.zeros((1,65),np.float64)

		#Setting relevant area of image to be checked for foreground and background segregation
		rect = (50,50,640,480)

		#Differentiating between foreground and background using grabCut
		cv2.grabCut(img,mask,rect,bgdModel,fgdModel,5,cv2.GC_INIT_WITH_RECT)

		#Extract all 1&3 pixel from masked image that represent foreground and probable foreground image
		maskn = np.where((mask==2)|(mask==0),0,1).astype('uint8')
		frame = img*maskn[:,:,np.newaxis]

		#Converting masked image to HSV format
		frame1 = cv2.cvtColor(frame, cv2.COLOR_RGB2HSV)

		#setting pixel value range for detecting skin colour in RGB image
		lower_1 = np.array([0,65,90])
		upper_1 = np.array([98,141,247])
		mask0 = cv2.inRange(frame, lower_1, upper_1)

		#setting pixel value range for detecting skin colour in HSV image
		lower_2 = np.array([77,0,55])
		upper_2 = np.array([255,255,255])
		mask1 = cv2.inRange(frame1, lower_2, upper_2)

		#Merging two different mask image obtained using OR operator
		mid = cv2.bitwise_or(mask0, mask1)

		#Setting two kernals of 3x3 and 5x5 for dilation and erosion purpose
		kernel_dil = cv2.getStructuringElement(cv2.MORPH_ELLIPSE, (3,3))
		kernel_erd = cv2.getStructuringElement(cv2.MORPH_ELLIPSE, (5,5))

		#Apply dilation on the image using kernal
		final = cv2.dilate(mid,kernel_dil,iterations=4)
		#Apply erosion on the image using kernal1
		final = cv2.erode(final,kernel_erd,iterations=3)

		#Applying final mask on the image obtained after background removal
		final_result = cv2.bitwise_and(frame, frame, mask=final)

		#Showing the final mask
		cv2.imshow("final_mask", final)
		#Showing the final image with driver's head and hands only
		cv2.imshow("mid", final_result)

		#Finding contours on the final masked image
		contours, hierarchy = cv2.findContours(final, cv2.RETR_TREE, cv2.CHAIN_APPROX_SIMPLE)

		#Sorting contours based on the area
		sorted_contour = sorted(contours,key=cv2.contourArea, reverse =True)

		index = -1
		thickness = 1
		color = (255, 0, 255)
		objects = np.zeros([frame.shape[0], frame.shape[1],3], 'uint8')
		flag = 0

		#Iterating over locator images one by one
		for j in (5,0,1,2,3,4):
			count=0

			#Reading the locator image in grayscale mode
			thres = cv2.imread("analytical_dataset/threshold_check/c"+str(j)+".jpg",cv2.IMREAD_GRAYSCALE)

			#Loop over top three contours based on the area
			for c in sorted_contour[:3]:

				#Drawing the contours
				cv2.drawContours(objects, [c], -1, color, 2)
				area=cv2.contourArea(c)
				
				#If area is less than 500, then do not proceed further and continue from top
				if area<500:
					continue

				M = cv2.moments(c)

				#Finding centroid location on image
				cx = int( M['m10']/(M['m00']))
				cy = int( M['m01']/(M['m00']))

				#Drawing a dot on the centriod location
				cv2.circle(img, (cx,cy), 3, (0,0,255), -1)

				#Checking if centroid lies on the boundary of the contour or not
				dist = cv2.pointPolygonTest(c,(cx,cy),True)

				#If centroid lie on the boundary of the contour, then shift the centroid in order to bring it inside the contour
				if dist<=0:
					print("centroid changed")
					if cv2.pointPolygonTest(c,(cx+3,cy),True)>0:
						cx=cx+3
					elif cv2.pointPolygonTest(c,(cx,cy+3),True)>0:
						cy=cy+3
					elif cv2.pointPolygonTest(c,(cx,cy-3),True)>0:
						cy=cy-3
					elif cv2.pointPolygonTest(c,(cx-3,cy),True)>0:
						cx=cx-3
					elif cv2.pointPolygonTest(c,(cx+3,cy+3),True)>0:
						cx=cx+3
						cy=cy+3
					elif cv2.pointPolygonTest(c,(cx-3,cy-3),True)>0:
						cx=cx-3
						cy=cy-3
					elif cv2.pointPolygonTest(c,(cx+3,cy-3),True)>0:
						cx=cx+3
						cy=cy-3
					elif cv2.pointPolygonTest(c,(cx-3,cy+3),True)>0:
						cx=cx-3
						cy=cy+3

				#FloodFill the image from the centroid position
				cv2.floodFill(objects, None, (cx,cy), 255)

				#Extracting pixel value of locator image while overlapping locator and masked image with centroid
				wb = thres[cy,cx]

				#Check if the pixel value extracted is 255 on the locator image i.e. white pixel, then increase the count variable value
				if wb==255:
					count+=1

				#Creating final mask for only extracting top three contours area of the image
				mask_t = cv2.inRange(objects, 200,255)
				show = cv2.bitwise_and(frame, frame, mask=mask_t)

				#Showing different images for intermediate and final result
				cv2.imshow('temp1',objects)
				cv2.imshow('Final result',show)
				cv2.imshow('Original Image',img)

			#Waiting for key press
			cv2.waitKey(0)

			#Checking if count value is greater tha or equal to 2, if yes then locator class name is the distraction type detected
			if count>=2:
				print("Type detected as :",classes[j])
				flag=1
				break
		#if flag value is 0 then no class detected
		if flag == 0:
			print("Type detected as : No class detected")

		#res value increment for final results computation
		if j==tot:
			res+=1
	#Printing results obtained on test dataset
	df.loc[tot] = ['c'+str(tot), img_tot, res]

#After model execution timestamp 
print(datetime.now().time())

#Printing the results
print(df)

#Destroy all the windows
cv2.destroyAllWindows()