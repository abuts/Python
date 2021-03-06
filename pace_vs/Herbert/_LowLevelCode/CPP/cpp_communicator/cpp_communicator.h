#pragma once
//
// $Revision:: 833 ($Date:: 2019-10-24 20:46:09 +0100 (Thu, 24 Oct 2019) $)" 
//
//
#include <memory>
#include <mex.h>
#include "MPI_wrapper.h"
#include "input_parser.h"

void set_numlab_and_nlabs(class_handle<MPI_wrapper> const *const pCommunicatorHolder, int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]);