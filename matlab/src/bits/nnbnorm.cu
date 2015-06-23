// @file nnbnorm.cu
// @brief Batch normalization block
// @author Sebastien Ehrhardt

/*
Copyright (C) 2015 Sebastien Ehrhardt
All rights reserved.

This file is part of the VLFeat library and is made available under
the terms of the BSD license (see the COPYING file).
*/

#include "nnbnorm.hpp"
#include "impl/bnorm.hpp"

#if ENABLE_GPU
#include "datacu.hpp"
#endif

#include <assert.h>

using namespace vl ;

/* ---------------------------------------------------------------- */
/*                                                   nnconv_forward */
/* ---------------------------------------------------------------- */

vl::Error
vl::nnbnorm_forward(vl::Context& context,
                    vl::Tensor output,
                    vl::Tensor data,
                    vl::Tensor filters,
                    vl::Tensor biaises,
                    float epsilon)
{
  vl::Error status = vlSuccess ;
  switch (output.getMemoryType()) {
    default:
      assert(false) ;
      status = vl::vlErrorUnknown ;
      break ;

    case vl::CPU:
      status = vl::impl::bnorm_forward<vl::CPU,float>
      (context, (float*)output.getMemory(), (float const*)data.getMemory(), (float*)filters.getMemory(),
       (float*)biaises.getMemory(), data.getWidth(), data.getHeight(), data.getDepth(), data.getSize(),epsilon);
      break ;

#if ENABLE_GPU
    case vl::GPU:
      status = vl::impl::bnorm_forward<vl::GPU,float>
      (context, (float*)output.getMemory(), (float const*)data.getMemory(), (float*)filters.getMemory(),
       (float*)biaises.getMemory(), data.getWidth(), data.getHeight(), data.getDepth(), data.getSize(), epsilon);
      if (status == vlErrorCuda) {
        context.setError(context.getCudaHelper().catchCudaError("nnbnorm_*_forward")) ;
      }
      break;
#endif
  }
  return context.passError(status, "nnbnorm_forward: ") ;
}

/* ---------------------------------------------------------------- */
/*                                                  nnconv_backward */
/* ---------------------------------------------------------------- */

vl::Error
vl::nnbnorm_backward(Context& context,
                     vl::Tensor derData,
                     vl::Tensor derFilters,
                     vl::Tensor derBiases,
                     vl::Tensor data,
                     vl::Tensor filters,
                     vl::Tensor biaises,
                     vl::Tensor derOutput,
                     float epsilon)
{
  vl::Error status = vl::vlSuccess ;
  switch (derOutput.getMemoryType()) {
    default:
      assert(false) ;
      status = vl::vlErrorUnknown ;
      break ;

    case vl::CPU:
      status = vl::impl::bnorm_backward<vl::CPU,float>
      (context,(float*)derData.getMemory(), (float*)derFilters.getMemory(), (float*)derBiases.getMemory(),
       (float const*)data.getMemory(), (float const*)filters.getMemory(),
       (float const*)biaises.getMemory(), data.getWidth(), data.getHeight(), data.getDepth(), data.getSize(),
       (float*)derOutput.getMemory(), epsilon);
      break ;

#if ENABLE_GPU
    case vl::GPU:
      status = vl::impl::bnorm_backward<vl::GPU,float>
      (context,(float*)derData.getMemory(), (float*)derFilters.getMemory(), (float*)derBiases.getMemory(),
       (float const*)data.getMemory(), (float const*)filters.getMemory(),
       (float const*)biaises.getMemory(), data.getWidth(), data.getHeight(), data.getDepth(), data.getSize(),
       (float*)derOutput.getMemory(), epsilon);

      if (status == vlErrorCuda) {
        context.setError(context.getCudaHelper().catchCudaError("bnorm_*_forward")) ;
      }
      break;
#endif
  }
  return context.passError(status, "nnbnorm_backward: ") ;
}
