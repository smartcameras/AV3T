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
  if (nrhs != 5)
    {
      mexErrMsgTxt("Incorrect number of inputs. Function expects 5 inputs.");
    }
    
  // Check input dimensions
  const mwSize *pdims = mxGetDimensions(prhs[0]);
  const mwSize *rdims = mxGetDimensions(prhs[1]);
  const mwSize *tdims = mxGetDimensions(prhs[2]);
  const mwSize *cdims = mxGetDimensions(prhs[3]);
  const mwSize *ddims = mxGetDimensions(prhs[4]);
    
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
  
  if (pdims[0] != 2)
    {
      mexErrMsgTxt("Data matrix must be of 2D points.");
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

void mat2vec(cv::Mat& ptr, std::vector<cv::Point2d>& pts) {
  pts.clear();
  for (int i = 0; i < ptr.cols; ++i)
    pts.push_back(cv::Point2d(ptr.at<double>(0,i),
			      ptr.at<double>(1,i)));
}

void vec3mat(std::vector<cv::Point3d>& pts3d, cv::Mat& ptr3d) {
  ptr3d.create(3, pts3d.size(), CV_64F);
  for (int i = 0; i < pts3d.size(); ++i) {
    ptr3d.at<double>(0,i) = pts3d[i].x;
    ptr3d.at<double>(1,i) = pts3d[i].y;
    ptr3d.at<double>(2,i) = pts3d[i].z;
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
  cv::Ptr<cv::Mat> ptr  = ocvMxArrayToMat_double(prhs[0], true);
  cv::Ptr<cv::Mat> rmat = ocvMxArrayToMat_double(prhs[1], true);
  cv::Ptr<cv::Mat> tvec = ocvMxArrayToMat_double(prhs[2], true);
  cv::Ptr<cv::Mat> cam  = ocvMxArrayToMat_double(prhs[3], true);
  cv::Ptr<cv::Mat> dist = ocvMxArrayToMat_double(prhs[4], true);

  std::vector<cv::Point2d> pts;
  mat2vec(*ptr, pts);
  
  std::vector<cv::Point2d> unpts;
  cv::undistortPoints(pts, unpts, *cam, *dist);

  std::vector<cv::Point3d> pts3d;
  for (int i = 0; i < unpts.size(); ++i) {
    cv::Mat x = cv::Mat(cv::Point3d(unpts[i].x, unpts[i].y, 1.));
    x = (*rmat)*(x-*tvec);
    pts3d.push_back(cv::Point3d(x));
  }

  cv::Mat ptr3d;
  vec3mat(pts3d, ptr3d);

  // Put the data back into the output MATLAB array
  plhs[0] = ocvMxArrayFromMat_double(ptr3d);
}
