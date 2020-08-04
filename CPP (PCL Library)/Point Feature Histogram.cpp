#include <pcl/io/pcd_io.h>
#include <pcl/point_types.h>
#include <pcl/features/pfh.h>
#include <vector>
#include <ctime>
#include <bits/stdc++.h>
using namespace std;
int main(int argc,char** argv )
{
    string line;
    pcl::PointCloud<pcl::PointXYZ>::Ptr cloud (new pcl::PointCloud<pcl::PointXYZ>);
    pcl::PointCloud<pcl::Normal>::Ptr normals (new pcl::PointCloud<pcl::Normal> ());
    if (pcl::io::loadPCDFile<pcl::PointXYZ> ("NPoint/PCD/04286d005.pcd", *cloud) == -1) //* load the file
    {
        PCL_ERROR ("Couldn't read file testpoint_pcd.pcd \n");
        return (-1);
    }
    if (pcl::io::loadPCDFile<pcl::Normal> ("NPoint/Normal/N04286d005.pcd", *normals) == -1) //* load the file
    {
        PCL_ERROR ("Couldn't read file testnormal_pcd.pcd \n");
        return (-1);
    }
    int row,col;
        float my_array[1][1749];
        ifstream pFile ("NPoint/ftr_pts04286d005.asc");
        if (pFile.is_open())
        {
            row=0;
            while(!pFile.eof())
            {
                getline(pFile, line);
                stringstream ss(line);
                col=0;
                while(ss >> my_array[row][col])
                {
                    col++;
                }
                row++;
            } 
            pFile.close();
        }
        else {
            cout << "Unable to open file"; 
        }
        cout<<"HI";
        row=1;col=1749;
        cout<<"0"<<endl;
    pcl::PFHEstimation<pcl::PointXYZ, pcl::Normal, pcl::PFHSignature125> pfh;
    pfh.setInputCloud (cloud);
    pfh.setInputNormals (normals);
    pcl::search::KdTree<pcl::PointXYZ>::Ptr tree (new pcl::search::KdTree<pcl::PointXYZ> ());
    pfh.setSearchMethod (tree);
    pcl::PointCloud<pcl::PFHSignature125>::Ptr pfhs (new pcl::PointCloud<pcl::PFHSignature125> ());
    pfh.setRadiusSearch (10.0);
    cout<<"0.25"<<endl;
    pfh.compute (*pfhs);
    cout<<"0.75"<<endl;
    size_t k=0;
    pcl::PointCloud<pcl::PFHSignature125>::Ptr fipfhs (new pcl::PointCloud<pcl::PFHSignature125> );
    fipfhs->width= col;
    fipfhs->height= 1;
    fipfhs->is_dense=false ;
    fipfhs->points.resize(fipfhs->width*fipfhs->height);
    cout<<"1"<<endl;
    for(size_t i=0;i<col;i++){
        k=my_array[0][i]-1;
        for(int j=0;j<125;j++){
            fipfhs->points[i].histogram[j]=pfhs->points[k].histogram[j];
        }
    }
    cout<<"2"<<endl;
    pcl::io::savePCDFileASCII ("NPoint/pfh/ftr_pt04286d005.pcd", *fipfhs);
    ofstream outdata;
    outdata.open("NPoint/pfh/asc/ftr_pt04286d005.asc");
    if( !outdata ) { // file couldn't be opened
      cerr << "Error: file could not be opened" << endl;
      exit(1);
    }
    for(int i=0;i<col;i++){
      for(int j=0;j<125;j++){
        outdata << fipfhs->points[i].histogram[j] <<"\t";
      }
      outdata << endl;
    }
    cout<<"3"<<endl;
    outdata.close();
    return 0;
}