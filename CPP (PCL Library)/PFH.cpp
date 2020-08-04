#include <pcl/io/pcd_io.h>
#include <pcl/point_types.h>
#include <pcl/features/pfh.h>
#include <vector>
#include <ctime>
#include <bits/stdc++.h>
using namespace std;
int main(int argc,char** argv )
{
    pcl::PointCloud<pcl::PointXYZ>::Ptr ccloud (new pcl::PointCloud<pcl::PointXYZ>);
    pcl::PointCloud<pcl::Normal>::Ptr nnormals (new pcl::PointCloud<pcl::Normal> ());
    if (pcl::io::loadPCDFile<pcl::PointXYZ> ("Point/PCD/04286d004.pcd", *ccloud) == -1) //* load the file
    {
        PCL_ERROR ("Couldn't read file testpoint_pcd.pcd \n");
        return (-1);
    }
    if (pcl::io::loadPCDFile<pcl::Normal> ("Point/Normal/N04286d004.pcd", *nnormals) == -1) //* load the file
    {
        PCL_ERROR ("Couldn't read file testnormal_pcd.pcd \n");
        return (-1);
    }
    int n,k;
    n=ccloud->points.size();
    map<long long,long long> arr;
    k=120;
    int i=0;
    int a[k];
    long long rrand;
    srand(time(0));
    while(i!=k){
        rrand=rand();
        rrand=rrand%n;
        if(arr[rrand]==0){
            arr[rrand]++;
            a[i]=rrand;
            i++;
        }
    }
    sort(a,a+k);
    pcl::PointCloud<pcl::PointXYZ>::Ptr cloud (new pcl::PointCloud<pcl::PointXYZ>);
    pcl::PointCloud<pcl::Normal>::Ptr normals (new pcl::PointCloud<pcl::Normal> ());
    size_t l=k;
    normals->width= l;
    normals->height= 1;
    normals->is_dense=true ;
    normals->points.resize(normals->width*normals->height);
    cloud->width= l;
    cloud->height= 1;
    cloud->is_dense=false ;
    cloud->points.resize(cloud->width*cloud->height);
    for(size_t i=0;i<l;i++){
        cloud->points[i].x=ccloud->points[a[i]].x;
        cloud->points[i].y=ccloud->points[a[i]].y;
        cloud->points[i].z=ccloud->points[a[i]].z;
        normals->points[i].normal[0]=nnormals->points[a[i]].normal[0];
        normals->points[i].normal[1]=nnormals->points[a[i]].normal[1];
        normals->points[i].normal[2]=nnormals->points[a[i]].normal[2];
    }
    pcl::PFHEstimation<pcl::PointXYZ, pcl::Normal, pcl::PFHSignature125> pfh;
    pfh.setInputCloud (cloud);
    pfh.setInputNormals (normals);
    pcl::search::KdTree<pcl::PointXYZ>::Ptr tree (new pcl::search::KdTree<pcl::PointXYZ> ());
    pfh.setSearchMethod (tree);
    pcl::PointCloud<pcl::PFHSignature125>::Ptr pfhs (new pcl::PointCloud<pcl::PFHSignature125> ());
    pfh.setRadiusSearch (10);
    pfh.compute (*pfhs);
    pcl::io::savePCDFileASCII ("pfhs/04286d004c.pcd", *pfhs);
    return 0;
}