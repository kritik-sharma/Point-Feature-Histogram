#include <pcl/io/pcd_io.h>
#include <pcl/point_cloud.h>
#include <pcl/point_types.h>
#include <pcl/kdtree/kdtree_flann.h>
#include <vector>
#include <ctime>
#include <bits/stdc++.h>
using namespace std;

#define n 3

void crossProduct(float vect_A[], float vect_B[], float cross_P[]) 
{ 
  
    cross_P[0] = vect_A[1] * vect_B[2] - vect_A[2] * vect_B[1]; 
    cross_P[1] = vect_A[0] * vect_B[2] - vect_A[2] * vect_B[0]; 
    cross_P[2] = vect_A[0] * vect_B[1] - vect_A[1] * vect_B[0]; 
}

float dotProduct(float vect_A[], float vect_B[]) 
{ 
  
    float product = 0; 
  
    // Loop for calculate cot product 
    for (int i = 0; i < n; i++) 
  
        product = product + vect_A[i] * vect_B[i]; 
    return product; 
} 

float mag(float x, float y, float z){
    float temp = sqrt(pow(x,2) + pow(y,2) + pow(z,2));
    return temp;
}

int main(int argc,char** argv )
{
    srand (time (NULL));
    pcl::PointCloud<pcl::PointXYZ>::Ptr cloud (new pcl::PointCloud<pcl::PointXYZ>);
    if (pcl::io::loadPCDFile<pcl::PointXYZ> ("04201d003.pcd", *cloud) == -1) //* load the file
    {
        PCL_ERROR ("Couldn't read file test_pcd.pcd \n");
        return (-1);
    }
    pcl::KdTreeFLANN<pcl::PointXYZ> kdtree;
    kdtree.setInputCloud (cloud);
    pcl::PointXYZ searchPoint;
    int temp=0;
    float nor_mal[cloud->points.size()][3];
    for(size_t j=0;j<cloud->points.size();++j){
        searchPoint.x = cloud->points[j].x;
        searchPoint.y = cloud->points[j].y;
        searchPoint.z = cloud->points[j].z;
        int K = 20;
        std::vector<int> pointIdxNKNSearch(K);
        std::vector<float> pointNKNSquaredDistance(K);
        float weight = 0;
        float weightedSum = 0;
        float cross_P_Sum[3] = {0,0,0};
        size_t l=0;
        if ( kdtree.nearestKSearch (searchPoint, K, pointIdxNKNSearch, pointNKNSquaredDistance) > 0 )
        {
            pcl::PointXYZ point0;
            point0.x=cloud->points[ pointIdxNKNSearch[l]].x;
            point0.y=cloud->points[ pointIdxNKNSearch[l]].y;
            point0.z=cloud->points[ pointIdxNKNSearch[l]].z;
          for (size_t i = 1; i < pointIdxNKNSearch.size (); ++i){
            pcl::PointXYZ pointA = cloud->points[  pointIdxNKNSearch[i] ];
            pcl::PointXYZ pointB;
            if(i == pointIdxNKNSearch.size() - 1){
                pointB = cloud->points[ pointIdxNKNSearch[1]];
            }
            else{    
                pointB = cloud->points[  pointIdxNKNSearch[i+1] ];
            }
            float vect_A[3] = {pointA.x - point0.x, pointA.y - point0.y, pointA.z - point0.z};
            float vect_B[3] = {pointB.x - point0.x, pointB.y - point0.y, pointB.z - point0.z};
            float cross_P[3];
            crossProduct(vect_A, vect_B, cross_P);
            float dot_product = dotProduct(vect_A, vect_B);
            float magnitudeA = mag(vect_A[0], vect_A[1], vect_A[2]);
            float magnitudeB = mag(vect_B[0], vect_B[1], vect_B[2]);
            float cosThita = dot_product / (magnitudeA * magnitudeB);
            float sinThita = sqrt(1 - pow(cosThita, 2));
            weight = sinThita / (magnitudeB * magnitudeA);
            weightedSum += weight;
            cross_P_Sum[0] += weight * cross_P[0];
            cross_P_Sum[1] += weight * cross_P[1];
            cross_P_Sum[2] += weight * cross_P[2];
        }
        float magnitudeNormal = mag(cross_P_Sum[0] / weightedSum, cross_P_Sum[1] / weightedSum, cross_P_Sum[2] / weightedSum);
        weightedSum=weightedSum*magnitudeNormal;
        nor_mal[j][0] = cross_P_Sum[0] / weightedSum ;
        nor_mal[j][1] = cross_P_Sum[1] / weightedSum ;
        nor_mal[j][2] = cross_P_Sum[2] / weightedSum ;
        cout<<nor_mal[j][0]<<""<<nor_mal[j][1]<<""<<nor_mal[j][2]<<endl;
        }
    }
    pcl::PointCloud<pcl::Normal>::Ptr normals (new pcl::PointCloud<pcl::Normal> ());
    size_t l=cloud->points.size();
    normals->width= l;
    normals->height= 1;
    normals->is_dense=true ;
    normals->points.resize(normals->width*normals->height);
    cout<<"HI";
    for(size_t i=0;i<normals->points.size();++i)
    {   
        normals->points[i].normal[0]=nor_mal[i][0];
        normals->points[i].normal[1]=nor_mal[i][1];
        normals->points[i].normal[2]=nor_mal[i][2];
        cout<<normals->points[i].normal[0]<<""<<normals->points[i].normal[1]<<""<<normals->points[i].normal[2]<<endl;
    }
    cout<<"HI";
    pcl::io::savePCDFileASCII ("testnormal_pcd.pcd", *normals);
    return 0;
}