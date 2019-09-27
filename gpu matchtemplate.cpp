#include "stdafx.h"
#include <iostream>
#include "opencv2/opencv_modules.hpp"
#include "opencv2/core.hpp"
#include "opencv2/features2d.hpp"
#include "opencv2/highgui.hpp"
#include "opencv2/cudaarithm.hpp"
#include "opencv2/opencv.hpp"
#include <opencv2/imgproc.hpp>
#include "cuda_runtime.h"
#include <Windows.h>
#include <opencv2/cudawarping.hpp>
#include "opencv2/cudaimgproc.hpp"



using namespace cv; 
using namespace std; 

int main()
{
	//初始化
	cudaSetDevice(0);
	cudaFree(0);
  //开始计时
	DWORD start_time = GetTickCount();     
  //遍历文件夹内所有图片
  for (int nImgIdx = 1; nImgIdx <= 10; nImgIdx++)
	{
		DWORD start_time = GetTickCount();
		//读取图片
		string sFile = "C:\\Users\\" + to_string(nImgIdx) + ".png";
		//Mat Src = imread("C:\\Users\xx.png", 0);
		Mat Src = imread(sFile, 0);
		Mat m_matTemplate = imread("C:\\Users\\Template.png", 0);
		//结束计时
		DWORD end_time1 = GetTickCount();       
    //输出时间
		cout << "读取" << nImgIdx << ":" << (end_time1 - start_time) << "ms!" << endl;  
		//upload给gpu
		cuda::GpuMat CSrc, CTemplate, Cresult;
		CSrc.upload(Src);
		CTemplate.upload(m_matTemplate);

    DWORD end_time2 = GetTickCount();       
		cout << "上传" << nImgIdx << ":" << (end_time2 - end_time1) << "ms!" << endl;  
		
		//cuda::TemplateMatching *b;
		cv::Ptr<cv::cuda::TemplateMatching> b;
		b = cuda::createTemplateMatching(CV_8U, CV_TM_CCOEFF_NORMED);
		//b->match(img, templ, result);
		b->match(CSrc,CTemplate, Cresult);
		Mat resultImag;
    //传回
		Cresult.download(resultImag);
	}

	DWORD end_time1 = GetTickCount();       
	cout << "全体：" << (end_time1 - start_time) << "ms!" << endl;  

	return 0;

}

