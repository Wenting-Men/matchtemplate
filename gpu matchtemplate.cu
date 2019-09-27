

#include <stdio.h>
#include <cuda_runtime.h>
#include <device_launch_parameters.h>
#include <device_functions.h>
#include <iostream>
#include <opencv2\opencv.hpp>
#include "highgui.h"
#include <stdlib.h>
#include <math.h>
#include <Windows.h>

using namespace std;
using namespace cv;


#define VALUE_MAX 1000000

struct match 
{

  int diffRow;
	int diffCol;
	int diff;

} pos;

// 定义CPU函数
void CPU_ImgFindDiff(int *host_result,int Width,int Height, int tWidth, int tHeight);
// 定义GPU
__global__ void GPU_Kernel_ImgMatching(unsigned char * d_ImgSrc ,unsigned char *d_pImgSrc,int *d_diffDst,int Width,int Height, int tWidth, int tHeight);


int main(int argc, char *argv[])
{
	
  //开始计时
  DWORD start_time = GetTickCount();     

	Mat srcImg = imread("C:\\Users\\xx.jpg", 0);
	Mat temImg = imread("C:\\Users\\template.jpg", 0);
  //定义宽高
  int Width = srcImg.cols;
  int Height = srcImg.rows;
	int tWidth = temImg.cols;
  int tHeight = temImg.rows;
  // 定义大小
	size_t d_sizeDiff = sizeof(int) * (Width - tWidth + 1) * (Height - tHeight + 1) ;
	size_t d_sizeImg  = sizeof(unsigned char) * Width * Height;
	size_t d_psizeImg = sizeof(unsigned char) * tWidth * tHeight;
	
  // CPU内存设置
	unsigned char *h_ImgSrc  = (unsigned char*)(srcImg.data);
	unsigned char *h_pImgSrc = (unsigned char*)(temImg.data);
	int *h_diffDst = (int *)malloc(d_sizeDiff);

  // GPU内存设置
	int *d_diffDst 			 = NULL;
	unsigned char *d_ImgSrc  = NULL;
	unsigned char *d_pImgSrc = NULL;

	cudaMalloc((void**)&d_diffDst, d_sizeDiff);
	cudaMalloc((void**)&d_ImgSrc , d_sizeImg);
	cudaMalloc((void**)&d_pImgSrc, d_psizeImg);

	cudaMemcpy(d_diffDst, h_diffDst, d_sizeDiff, cudaMemcpyHostToDevice);
	cudaMemcpy(d_pImgSrc, h_pImgSrc, d_psizeImg, cudaMemcpyHostToDevice);
	cudaMemcpy(d_ImgSrc , h_ImgSrc , d_sizeImg , cudaMemcpyHostToDevice);
	// 定义 block 和 thread
	dim3 threads(32);
  dim3 grid(256,256);
	// 调用kernel函数
  GPU_Kernel_ImgMatching<<<grid, threads>>>(d_ImgSrc, d_pImgSrc, d_diffDst, Width, Height, tWidth, tHeight);
  // 传回cpu 
  cudaMemcpy(h_diffDst, d_diffDst, d_sizeDiff, cudaMemcpyDeviceToHost);
  //找点

  DWORD end_time1 = GetTickCount();      
  cout << "gpu：" << (end_time1 - start_time) << "ms!" << endl;  
  CPU_ImgFindDiff( h_diffDst,Width, Height, tWidth, tHeight);
  CvPoint pt1, pt2;

	pt1.x = pos.diffCol;
	pt1.y = pos.diffRow;
	pt2.x = pt1.x + temImg.cols;
	pt2.y = pt1.y + temImg.rows;	
  
  
	DWORD end_time2 = GetTickCount();
	cout << "找点：" << (end_time2 - end_time1) << "ms!" << endl;  
	
  // 画图
	rectangle( srcImg, pt1, pt2, CV_RGB(255,0,0), 3, 8, 0 );
  imshow( "result", srcImg );


	//释放内存
	cudaFree(d_diffDst);
	cudaFree(d_pImgSrc);
	cudaFree(d_ImgSrc);

	DWORD end_time3 = GetTickCount();       
	cout << "全体：" << (end_time3 - start_time) << "ms!" << endl;  
	waitKey(0); 
	return 0;

}



__global__ void GPU_Kernel_ImgMatching(unsigned char * d_ImgSrc ,unsigned char *d_pImgSrc,int *d_diffDst,int Width,int Height, int tWidth, int tHeight)
{
	     
 	int diff;
 	int result_height = Height - tHeight + 1;
	int result_width  = Width  - tWidth  + 1;
   
  uchar p_srcImg, p_temImg;
  int tid = threadIdx.x + blockIdx.x * blockDim.x;
  	
  if(tid < Width ) 
  {
    for(int row = 0; row < result_height; row++ ) 
    {
      diff = 0;
			for(int i=0; i<tHeight; i++) 
      {            
         for(int j=0; j<tWidth; j++) 
         {    
					 p_srcImg = d_ImgSrc[(row + i) * Width + tid + j];
					 p_temImg = d_pImgSrc[i * tWidth + j];
					 diff += fabsf(p_srcImg - p_temImg);
					 //printf("debug:%d\n",diff);//利用输出debug
				  }       
    	} 
    	d_diffDst[row * result_width + tid] = diff;
    }
  }
}


void CPU_ImgFindDiff( int *host_result,int Width,int Height, int tWidth, int tHeight)
{
	
	int minDiff = VALUE_MAX;
	int result_height = Height - tHeight + 1;
	int result_width  = Width  - tWidth  + 1;

	for( int row = 0; row < result_height; row++ ) 
  {
		for( int col = 0; col < result_width; col++ ) 
    {
			if ( minDiff > host_result[row * result_width + col] ) 
      {
				minDiff = host_result[row * result_width + col];

				pos.diffRow = row;
				pos.diffCol = col;
				pos.diff = host_result[row * result_width + col];
			}
		}
	}

	//printf("minSAD:%d\n",minDiff);

	free(host_result);
}
