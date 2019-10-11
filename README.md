# matchtemplate

三种方法实现模板匹配
（1）opencv 实现模板匹配
（2）opencv&cuda 实现模板匹配
（3）cuda 实现模板匹配

配置：CUDA7.5 + VS2013 + CMAKE3.5.1 + OPENCV3.0.0


安装步骤：


安装TBB：下载tbb2019_20181203oss后设置环境变量：在系统-> 高级系统设置->环境变量->path 地址tbb2019_20181203oss\bin\intel64\vc12
安装CUDA：
(1)把Openv3.0.0和对应的opencv_contrib-3.0.0存放在同一个文件夹内后，打开Cmake3.5.1，设置源码路径和目标路径，点击Configure。
(2)第一次Configure后Cmake中会出现红色部分，其中BUILD_opencv_world不勾选，WITH_TBB和WITH_CUDA要勾选，并填写TBB的路径。
(3)OPENCV_EXTRA_MODULES_PATH的路径要填写opencv_contrib-3.0.0/modules的地址。再点击Configure更新，每次更改完一些配置或者参数之后都要点击Configure更新一下。
(4)直到没有红色部分，点Generate，会在目标文件夹中生成项目文件。
(5)在目标文件中找到OpenCV.sln 文件，并用VS打开，然后找到install右键生成，等待编译完成。
(6)编译完成后，可以在目标文件夹中找到一个install文件夹，之后的配置会用到。



配置编译好的OpenCV_cuda：
配置环境变量：在Path中添加：(6)中生成的install\x64\vc12\bin。
配置VS的项目属性：
包含目录添加以下内容：
install\include
include\opencv
include\opencv2
库目录添加以下内容：
install\x64\vc12\lib
在链接器下：
输入->附加依赖项 添加install\x64\vc12\lib内所有.lib。




完成上述操作即可使用方法2，方法3项目属性配置同方法1（正常的opencv配置方法），注意方法3新建项目时选择NVIDIA下的CUDA7.5
