#include <fstream>
#include <iostream>
#include <stdio.h>
#include <sstream>
#include <pcl/io/pcd_io.h>
#include <pcl/point_types.h>
#include <vector>
#include <ctime>
#include <bits/stdc++.h>
using namespace std;
int main (int argc, char** argv)
{
    string line;
        int row,col;
        float my_array[8163][3];
        ifstream pFile ("NPoint/04286d005.asc");
        if (pFile.is_open())
        {
            row=0;
            while(!pFile.eof())
            {
                getline(pFile, line);
                stringstream ss(line);
                cout<<row<<"\n";
                col=0;
                cout<<col<<"\n";
                while(ss >> my_array[row][col])
                {
                    col++;
                }
                row++;
            } 
            pFile.close();
        }
        else{
            cout << "Unable to open file"; 
        } 
            
  pcl::PointCloud<pcl::PointXYZ> cloud;

  // Fill in the cloud data
  cloud.width    = 8163;
  cloud.height   = 1;
  cloud.is_dense = false;
  cloud.points.resize (cloud.width * cloud.height);

  for (size_t i = 0; i < cloud.points.size (); ++i)
  {
    cloud.points[i].x = my_array[i][0];
    cloud.points[i].y = my_array[i][1];
    cloud.points[i].z = my_array[i][2];
  }

  pcl::io::savePCDFileASCII ("NPoint/PCD/04286d005.pcd", cloud);
  std::cerr << "Saved " << cloud.points.size () << " data points to test_pcd.pcd." << std::endl;
  return (0);
}