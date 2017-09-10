#include <ruby/ruby.h>
// Include standard headers
#include <stdlib.h>
#include <thread>
#include <unistd.h>
#include <vector>

#include <iostream>

// Include GLEW
#include <GL/glew.h>

// Include GLFW
#include <GLFW/glfw3.h>

#include <pixlib.hpp>

#include "pattern.hpp"
#include "application.hpp"
#include "fade_candy.hpp"
#include "camera.hpp"

using namespace Pixlib;


// std::thread *background;
extern "C" void Init_libpixgem() {
  VALUE Pixo = rb_define_module("Pixo");
  VALUE Native = rb_define_module_under(Pixo, "Native");

  // Initialise GLFW
  if( !glfwInit() )
  {
      ALOGV( "Failed to initialize GLFW\n" );
      getchar();
  }  

  VALUE PatternClass = rb_define_class_under(Native, "Pattern", rb_cObject);
  rb_define_alloc_func(PatternClass, pattern_allocate);
  rb_define_method(PatternClass, "initialize", (VALUE(*)(ANYARGS))pattern_initialize, 2);


  VALUE ApplicationClass = rb_define_class_under(Native, "Application", rb_cObject);
  rb_define_alloc_func(ApplicationClass, application_allocate);
  rb_define_method(ApplicationClass, "initialize", (VALUE(*)(ANYARGS))application_initialize, 0);
  rb_define_method(ApplicationClass, "tick", (VALUE(*)(ANYARGS))application_tick, 1);
  rb_define_method(ApplicationClass, "add_fadecandy", (VALUE(*)(ANYARGS))application_add_fadecandy, 1);

  VALUE FadeCandyClass = rb_define_class_under(Native, "FadeCandy", rb_cObject);
  rb_define_alloc_func(FadeCandyClass, fade_candy_allocate);
  rb_define_method(FadeCandyClass, "initialize", (VALUE(*)(ANYARGS))fade_candy_initialize, 2);

  VALUE CameraClass = rb_define_class_under(Native, "Camera", rb_cObject);
  rb_define_alloc_func(CameraClass, camera_allocate);
  rb_define_method(CameraClass, "initialize", (VALUE(*)(ANYARGS))camera_initialize, 0 );
}
