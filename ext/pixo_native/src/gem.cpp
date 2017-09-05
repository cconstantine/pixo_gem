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
#include <fade_candy.hpp>

#include <app.hpp>

class Holder {
public:
  virtual ~Holder() { }
};

class PatternHolder : public Holder {
public:
  PatternHolder() : pattern(nullptr) { }
  
  virtual ~PatternHolder() {
    fprintf(stderr, "Destroy PatternHolder\n");
 
    if(pattern) {
      delete pattern;
    }
  }

  Pattern *pattern;

};



class ApplicationHolder : public Holder {
public:
  ApplicationHolder() :app(nullptr), window(nullptr), fc(nullptr) {}

  virtual ~ApplicationHolder() {
    fprintf(stderr, "Destroy ApplicationHolder\n");
    if (fc) {
      fc->clear();

      delete fc;
      fc = nullptr;
    }

    if(app) {
      delete app;
      app = nullptr;
    }

    if (window) {
      glfwMakeContextCurrent(window);

      
      // Close OpenGL window and terminate GLFW
      glfwDestroyWindow(window);
      window = nullptr;
    }

  }

  App *app;
  GLFWwindow* window;
  FadeCandy *fc;
};


extern "C" void Init_libpixgem();

void deallocate(void * holder)
{
  Holder* h = (Holder*)holder;
  delete h;
}

VALUE pattern_allocate(VALUE klass)
{
  PatternHolder * holder = new PatternHolder();

  return Data_Wrap_Struct(klass, NULL, deallocate, holder);
}

VALUE pattern_initialize(VALUE self, VALUE rb_name, VALUE rb_string)
{
  PatternHolder * holder;

  Check_Type(rb_string, T_STRING);

  Data_Get_Struct(self, PatternHolder, holder);
  holder->pattern = new Pattern(StringValuePtr(rb_name), StringValuePtr(rb_string));

  return self;
}

VALUE application_allocate(VALUE klass)
{
  ApplicationHolder * holder = new ApplicationHolder();

  return Data_Wrap_Struct(klass, NULL, deallocate, holder);
}

VALUE application_initialize(VALUE self)
{
  ApplicationHolder * holder;

  Data_Get_Struct(self, ApplicationHolder, holder);
 
  glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3);
  glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 3);
  glfwWindowHint(GLFW_OPENGL_FORWARD_COMPAT, GL_TRUE); // To make MacOS happy; should not be needed
  glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);
  glfwWindowHint(GLFW_DEPTH_BITS, 24 );

  // Open a window and create its OpenGL context
  holder->window = glfwCreateWindow( 800, 800, "Pixo", NULL, NULL);
  if( holder->window == NULL ){
      ALOGV( "Failed to open GLFW window. If you have an Intel GPU, they are not 3.3 compatible. Try the 2.1 version of the tutorials.\n" );
      getchar();
  }
  glfwMakeContextCurrent(holder->window);

  // Initialize GLEW
  glewExperimental = GL_TRUE; // Needed for core profile
  if (glewInit() != GLEW_OK) {
    ALOGV( "Failed to initialize GLEW\n");
    getchar();
  }
  glEnable(GL_DEPTH_TEST);

  holder->fc = new FadeCandy("localhost", 8);
  holder->app = new App(holder->fc); 

  return self;
}

VALUE application_tick(VALUE self, VALUE r_pattern)
{
  GLenum glErr;
  ApplicationHolder * app_holder;
  Data_Get_Struct(self, ApplicationHolder, app_holder);

  PatternHolder * pattern_holder;
  Data_Get_Struct(r_pattern, PatternHolder, pattern_holder);
 

  if(!glfwWindowShouldClose(app_holder->window)) {
    glfwMakeContextCurrent(app_holder->window);
    glEnable(GL_DEPTH_TEST);
    glfwPollEvents();


    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    int width, height;
    glfwGetFramebufferSize(app_holder->window, &width, &height);

    app_holder->app->tick(pattern_holder->pattern, width, height);

    app_holder->app->move_perspective_to_camera();

    glfwSwapBuffers(app_holder->window);

    glErr = glGetError();
    while (glErr != GL_NO_ERROR)
    {
        ALOGV("tick glError %04x\n", glErr);
        glErr = glGetError();
    }

  }


  return self;
}

// std::thread *background;
void Init_libpixgem() {
  VALUE Pixo = rb_define_module("Pixo");

  // Initialise GLFW
  if( !glfwInit() )
  {
      ALOGV( "Failed to initialize GLFW\n" );
      getchar();

  }  

  VALUE PatternClass = rb_define_class_under(Pixo, "Pattern", rb_cObject);

  rb_define_alloc_func(PatternClass, pattern_allocate);
  rb_define_method(PatternClass, "initialize", (VALUE(*)(ANYARGS))pattern_initialize, 2);


  VALUE ApplicationClass = rb_define_class_under(Pixo, "Application", rb_cObject);

  rb_define_alloc_func(ApplicationClass, application_allocate);
  rb_define_method(ApplicationClass, "initialize", (VALUE(*)(ANYARGS))application_initialize, 0);
  rb_define_method(ApplicationClass, "tick", (VALUE(*)(ANYARGS))application_tick, 1);
}
