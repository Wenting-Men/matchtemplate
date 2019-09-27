#include "stdafx.h"
#include "iostream"
#include "opencv2/opencv.hpp"
#include <opencv2/core.hpp>
#include <opencv2/highgui.hpp>
#include <opencv2/imgproc.hpp>
#include <Windows.h>

using namespace std;
using namespace cv;

Mat srcImage, templateImage, dstImg;
string sFile;

int main()
{   DWORD start_time = GetTickCount();
	//输入图片
	srcImage = imread("C:\\Users\\xx.png");
	for (int nImgIdx = 1; nImgIdx <= 20; nImgIdx++)
	{
		
		sFile = "C:\\Users\\" + to_string(nImgIdx) + ".png";
		srcImage = imread(sFile, 0);
		templateImage = imread("C:\\Users\\Template.png",0);
		matchTemplate(srcImage, templateImage, dstImg, 0);
		normalize(dstImg, dstImg, 0, 1, 32);
	
		Point minPoint;
		Point maxPoint;
		double *minVal = 0;
		double *maxVal = 0;
		minMaxLoc(dstImg, minVal, maxVal, &minPoint, &maxPoint);


		rectangle(srcImage, minPoint, cv::Point(minPoint.x + templateImage.cols, minPoint.y + templateImage.rows), cv::Scalar(0, 255, 0), 2, 8);
		imshow("匹配后的图像", srcImage);
	}

	waitKey(0);
	DWORD end_time1 = GetTickCount();       //结束计时
	cout << "总耗时:" << (end_time1 - start_time) << "ms!" << endl;  //输出时间
	return 0;
}
