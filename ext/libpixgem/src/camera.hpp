#pragma once
#include <ruby/ruby.h>

#include "holder.hpp"

#include <pixlib/camera.hpp>


class CameraHolder : public Holder {
public:
  CameraHolder();

  virtual ~CameraHolder();

  Pixlib::IsoCamera *camera;
};



VALUE camera_allocate(VALUE klass);

VALUE camera_initialize(VALUE self);
