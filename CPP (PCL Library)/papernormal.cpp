#include <pcl/point_types.h>
#include <pcl/features/normal_3d.h>
#include <pcl/io/pcd_io.h>
#include <pcl/features/pfh.h>
#include <vector>
#include <ctime>
#include <bits/stdc++.h>
using namespace std;
int main(int argc,char** argv ){
  pcl::PointCloud<pcl::PointXYZ>::Ptr cloud (new pcl::PointCloud<pcl::PointXYZ>);

  if (pcl::io::loadPCDFile<pcl::PointXYZ> ("Point/PCD/04286d003.pcd", *cloud) == -1) //* load the file
  {
      PCL_ERROR ("Couldn't read file testpoint_pcd.pcd \n");
      return (-1);
  }
  pcl::NormalEstimation<pcl::PointXYZ, pcl::Normal> ne;
  ne.setInputCloud (cloud);
  pcl::search::KdTree<pcl::PointXYZ>::Ptr tree (new pcl::search::KdTree<pcl::PointXYZ> ());
  ne.setSearchMethod (tree);
  pcl::PointCloud<pcl::Normal>::Ptr cloud_normals (new pcl::PointCloud<pcl::Normal>);
  ne.setRadiusSearch (6.5);
  ne.compute (*cloud_normals);
  pcl::io::savePCDFileASCII("Normal/N04286d003_pcd.pcd", *cloud_normals);
}