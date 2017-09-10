#include "camera.hpp"

using namespace Pixlib;

CameraHolder::CameraHolder() : camera(nullptr) { }

CameraHolder::~CameraHolder() {
  if(camera) {
    delete camera;
  }
}

VALUE camera_allocate(VALUE klass)
{
  CameraHolder * holder = new CameraHolder();

  return Data_Wrap_Struct(klass, NULL, deallocate, holder);
}

VALUE camera_initialize(VALUE self)
{
  CameraHolder * holder;

  Data_Get_Struct(self, CameraHolder, holder);
  holder->camera = new IsoCamera();

  return self;
}
