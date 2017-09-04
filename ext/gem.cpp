#include <ruby/ruby.h>
// Include standard headers
#include <stdlib.h>
#include <unistd.h>
#include <vector>

#include <iostream>

// Include GLEW
#include <GL/glew.h>

// Include GLFW
#include <GLFW/glfw3.h>
#include <fade_candy.hpp>

#include <app.hpp>

GLFWwindow* window;

// The business logic -- this is the function we're exposing to Ruby. It returns
// a Ruby VALUE, and takes three VALUE arguments: the receiver object, and the
// method parameters. Notes on APIs used here:
// 
// * RARRAY_LEN(VALUE) returns the length of a Ruby array object
// * rb_ary_new2(int) creates a new Ruby array with the given length
// * rb_ary_entry(VALUE, int) returns the nth element of a Ruby array
// * NUM2INT converts a Ruby Fixnum object to a C int
// * INT2NUM converts a C int to a Ruby Fixnum object
// * rb_ary_store(VALUE, int, VALUE) sets the nth element of a Ruby array
// 
extern "C" VALUE method_libpixgem_mask(VALUE self, VALUE payload, VALUE mask) {
  int n = RARRAY_LEN(payload), i, p, m;
  VALUE unmasked = rb_ary_new2(n);

  int mask_array[] = {
    NUM2INT(rb_ary_entry(mask, 0)),
    NUM2INT(rb_ary_entry(mask, 1)),
    NUM2INT(rb_ary_entry(mask, 2)),
    NUM2INT(rb_ary_entry(mask, 3))
  };

  for (i = 0; i < n; i++) {
    p = NUM2INT(rb_ary_entry(payload, i));
    m = mask_array[i % 4];
    rb_ary_store(unmasked, i, INT2NUM(p ^ m));
  }
  return unmasked;
}

// Allocate two VALUE variables to hold the modules we'll create. Ruby values
// are all of type VALUE. Qnil is the C representation of Ruby's nil.
VALUE Pixo = Qnil;
VALUE FayeWebSocket = Qnil;

// Declare a couple of functions. The first is initialization code that runs
// when this file is loaded, and the second is the actual business logic we're
// implementing.
extern "C" void Init_libpixgem();

// Initial setup function, takes no arguments and returns nothing. Some API
// notes:
// 
// * rb_define_module() creates and returns a top-level module by name
// 
// * rb_define_module_under() takes a module and a name, and creates a new
//   module within the given one
// 
// * rb_define_singleton_method() take a module, the method name, a reference to
//   a C function, and the method's arity, and exposes the C function as a
//   single method on the given module
// 
extern "C" void Init_libpixgem() {
  Pixo = rb_define_module("Pixo");
 rb_define_singleton_method(Pixo, "mask", method_libpixgem_mask, 2);

  // Initialise GLFW
  if( !glfwInit() )
  {
      fprintf( stderr, "Failed to initialize GLFW\n" );
      getchar();
  }  

  
  glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3);
  glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 3);
  glfwWindowHint(GLFW_OPENGL_FORWARD_COMPAT, GL_TRUE); // To make MacOS happy; should not be needed
  glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);
  glfwWindowHint(GLFW_DEPTH_BITS, 24 );

  // Open a window and create its OpenGL context
  window = glfwCreateWindow( 800, 800, "Pixo", NULL, NULL);
  if( window == NULL ){
      fprintf( stderr, "Failed to open GLFW window. If you have an Intel GPU, they are not 3.3 compatible. Try the 2.1 version of the tutorials.\n" );
      getchar();
      glfwTerminate();
      return;
  }
  glfwMakeContextCurrent(window);


  // Initialize GLEW
  glewExperimental = GL_TRUE; // Needed for core profile
  if (glewInit() != GLEW_OK) {
    fprintf(stderr, "Failed to initialize GLEW\n");
    getchar();
    glfwTerminate();
    return;
  }
  // Setup some OpenGL options
  // Enable depth test
  glEnable(GL_DEPTH_TEST);
  
  const int leds_per_side = 8;
  FadeCandy fc = FadeCandy("localhost", leds_per_side);

  App application(&fc);
  glfwSetWindowUserPointer(window, &application);

  application.add_pattern(new Pattern("basic",
R"(#version 330 core
out vec4 color_out;

// From http://mrdoob.com/lab/javascript/webgl/glsl/03/
uniform float time;
uniform vec2 resolution;

void main( void ) {

    vec2 position = gl_FragCoord.xy / resolution.xy;

    float color = 0.0;
    color += sin( position.x * cos( time / 15.0 ) * 80.0 ) + cos( position.y * cos( time / 15.0 ) * 10.0 );
    color += sin( position.y * sin( time / 10.0 ) * 40.0 ) + cos( position.x * sin( time / 25.0 ) * 40.0 );
    color += sin( position.x * sin( time / 5.0 ) * 10.0 ) + sin( position.y * sin( time / 35.0 ) * 80.0 );
    color *= sin( time / 10.0 ) * 0.5;

    color_out = vec4( vec3( color, color * 0.9, sin( color + time / 3.0 ) * 0.75 ), 1.0 );

}
)"));

  while(!glfwWindowShouldClose(window)) {

    glfwPollEvents();
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    int width, height;
    glfwGetFramebufferSize(window, &width, &height);

    application.tick(width, height);
    application.move_perspective_to_camera();


    glfwSwapBuffers(window);

    GLenum glErr = glGetError();
    while (glErr != GL_NO_ERROR)
    {
        ALOGV("glError %04x\n", glErr);
        glErr = glGetError();
    }

  }

  fc.clear();
  

  // Close OpenGL window and terminate GLFW
  glfwTerminate();

  return;
}
