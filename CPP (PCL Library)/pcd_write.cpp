#include <pcl/io/pcd_io.h>
#include <pcl/point_cloud.h>
#include <pcl/point_types.h>
#include <pcl/kdtree/kdtree_flann.h>
#include <vector>
#include <ctime>
#include <bits/stdc++.h>
using namespace std;
int main(int argc,char** argv )
{
    srand (time (NULL));
    pcl::PointCloud<pcl::PFHSignature125>::Ptr pointfh (new pcl::PointCloud<pcl::PFHSignature125> ());
	if (pcl::io::loadPCDFile<pcl::PFHSignature125> ("pfhs/04286d004c.pcd", *pointfh) == -1) //* load the file
    {
        PCL_ERROR ("Couldn't read file 04286d004c.pcd \n");
        return (-1);
    }
    ofstream outdata;
    outdata.open("pfhs/asc/04286d004c.asc");
    if( !outdata ) { // file couldn't be opened
      cerr << "Error: file could not be opened" << endl;
      exit(1);
    }
    for(int i=0;i<120;i++){
    	for(int j=0;j<125;j++){
            outdata << pointfh->points[i].histogram[j] <<"\t";
        }
        outdata << endl;
    }
    outdata.close();
	return 0;
}