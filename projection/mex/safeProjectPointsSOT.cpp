// Copyright 2014 The MathWorks, Inc.
//////////////////////////////////////////////////////////////////////////

#include "opencvmex.hpp"

#define _DO_NOT_EXPORT
#if defined(_DO_NOT_EXPORT)
#define DllExport  
#else
#define DllExport __declspec(dllexport)
#endif

///////////////////////////////////////////////////////////////////////////
// Check inputs
///////////////////////////////////////////////////////////////////////////
void checkInputs(int nrhs, const mxArray *prhs[])
{    
  // Check number of inputs
  if (nrhs != 6)
    {
      mexErrMsgTxt("Incorrect number of inputs. Function expects 6 inputs.");
    }
    
  // Check input dimensions
  const mwSize *pdims = mxGetDimensions(prhs[0]);
  const mwSize *rdims = mxGetDimensions(prhs[1]);
  const mwSize *tdims = mxGetDimensions(prhs[2]);
  const mwSize *cdims = mxGetDimensions(prhs[3]);
  const mwSize *ddims = mxGetDimensions(prhs[4]);
  const mwSize *udims = mxGetDimensions(prhs[5]);
    
  if (mxGetNumberOfDimensions(prhs[0])>2)
    {
      mexErrMsgTxt("Incorrect number of dimensions. 1st input must be a data matrix.");
    }
  
  if (mxGetNumberOfDimensions(prhs[1])>2)
    {
      mexErrMsgTxt("Incorrect number of dimensions. 2nd input must be a rmat matrix.");
    }
  
  if (mxGetNumberOfDimensions(prhs[2])>2)
    {
      mexErrMsgTxt("Incorrect number of dimensions. 3rd input must be a tvec matrix.");
    }
  
  if (mxGetNumberOfDimensions(prhs[3])>2)
    {
      mexErrMsgTxt("Incorrect number of dimensions. 4rd input must be a cam matrix.");
    }
  
  if (mxGetNumberOfDimensions(prhs[4])>2)
    {
      mexErrMsgTxt("Incorrect number of dimensions. 5th input must be a dist matrix.");
    }
  
  if (mxGetNumberOfDimensions(prhs[5])>2)
    {
      mexErrMsgTxt("Incorrect number of dimensions. 6th input must be a unmap matrix.");
    }
  
  if (pdims[0] != 3)
    {
      mexErrMsgTxt("Data matrix must be of 3D points.");
    }
  
  if (rdims[0] != 3 || rdims[1] != 3)
    {
      mexErrMsgTxt("rmat matrix must be 3x3 (orthonormal).");
    }    
  
  if (tdims[0] != 3 || tdims[1] != 1)
    {
      mexErrMsgTxt("tvec matrix must be 3x1.");
    }    
  
  if (cdims[0] != 3 || cdims[1] != 3)
    {
      mexErrMsgTxt("cam matrix must be 3x3.");
    }    
  
  if (ddims[0] != 5 || ddims[1] != 1)
    {
      mexErrMsgTxt("dist matrix must be 5x1.");
    }    
  
  /*
  // Check image data type
  if (!mxIsUint8(prhs[0]) || !mxIsUint8(prhs[1]))
  {
  mexErrMsgTxt("Template and image must be UINT8.");
  }
  */
}

void retainValid(std::vector<cv::Point2d>& pts0, std::vector<cv::Point3d>& pts3d, std::vector<cv::Point3d>& pts_valid, std::vector<int>& ptr_valid, cv::Mat& unmap) {

  const double minx = -181.033;
  const double miny = -135.237;
  
  for (int i = 0; i < pts0.size(); ++i) {
    int x = round(pts0[i].x - minx);
    int y = round(pts0[i].y - miny);
    if (!(0 <= x && x < unmap.cols)) continue;
    if (!(0 <= y && y < unmap.rows)) continue;
    if (unmap.at<uchar>(y,x) == 255) {
      ptr_valid.push_back(i);
      pts_valid.push_back(pts3d[i]);
    }
  }
}

void mat3vec(cv::Mat& ptr3d, std::vector<cv::Point3d>& pts3d) {
  pts3d.clear();
  for (int i = 0; i < ptr3d.cols; ++i)
    pts3d.push_back(cv::Point3d(ptr3d.at<double>(0,i),
				ptr3d.at<double>(1,i),
				ptr3d.at<double>(2,i)));
}

void vec2mat(std::vector<cv::Point2d>& pts, cv::Mat& ptr) {
  ptr.create(2, pts.size(), CV_64F);
  for (int i = 0; i < pts.size(); ++i) {
    ptr.at<double>(0,i) = pts[i].x;
    ptr.at<double>(1,i) = pts[i].y;
  }
}

void vec1mat(std::vector<int>& pts, cv::Mat& ptr) {
  ptr.create(1, pts.size(), CV_32SC1);
  for (int i = 0; i < pts.size(); ++i) {
    ptr.at<int>(0,i) = pts[i];
  }
}


///////////////////////////////////////////////////////////////////////////
// Main entry point to a MEX function
///////////////////////////////////////////////////////////////////////////
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{  
  // Check inputs to mex function
  checkInputs(nrhs, prhs);
  
  // Convert mxArray inputs into OpenCV types
  cv::Ptr<cv::Mat> ptr3d = ocvMxArrayToMat_double(prhs[0], true);
  cv::Ptr<cv::Mat> rmat  = ocvMxArrayToMat_double(prhs[1], true);
  cv::Ptr<cv::Mat> tvec  = ocvMxArrayToMat_double(prhs[2], true);
  cv::Ptr<cv::Mat> cam   = ocvMxArrayToMat_double(prhs[3], true);
  cv::Ptr<cv::Mat> dist  = ocvMxArrayToMat_double(prhs[4], true);
  cv::Ptr<cv::Mat> unmap = ocvMxArrayToImage_uint8(prhs[5], true);

  std::vector<cv::Point3d> pts3d;
  mat3vec(*ptr3d, pts3d);
  
  // do the stuff
  cv::Mat dist0 = cv::Mat(5,1,CV_64FC1, cv::Scalar::all(0));
  cv::Mat rvec;
  cv::Rodrigues(*rmat, rvec);
  
  // cv project
  std::vector<cv::Point2d> pts0;
  cv::projectPoints(pts3d, rvec, *tvec, *cam, dist0, pts0);
  
  // map check
  std::vector<int> ptr_valid;
  std::vector<cv::Point3d> pts_valid;
  retainValid(pts0, pts3d, pts_valid, ptr_valid, *unmap);

  // cv project distort
  std::vector<cv::Point2d> pts;
  if (ptr_valid.size())
    cv::projectPoints(pts_valid, rvec, *tvec, *cam, *dist, pts);

  // conversion
  cv::Mat ptr, ptv;
  vec2mat(pts, ptr);
  vec1mat(ptr_valid, ptv);
  
  // Put the data back into the output MATLAB array
  plhs[0] = ocvMxArrayFromMat_double(ptr);
  plhs[1] = ocvMxArrayFromMat_int32(ptv);
}

