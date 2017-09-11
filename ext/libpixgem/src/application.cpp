#include "application.hpp"
#include "pattern.hpp"
#include "fade_candy.hpp"

using namespace Pixlib;

ApplicationHolder::ApplicationHolder() :
 app(nullptr),
 window(nullptr)
{ }

ApplicationHolder::~ApplicationHolder() {
  if(app) {
    delete app;
    app = nullptr;
  }
}

VALUE application_close(VALUE self)
{
  ApplicationHolder * holder;

  Data_Get_Struct(self, ApplicationHolder, holder);
  if(holder->window) {

    for(VALUE fc : holder->fade_candies) {

      FadeCandyHolder * holder;

      Data_Get_Struct(fc, FadeCandyHolder, holder);
      if(holder->fade_candy) {
        holder->fade_candy->clear();
      }
    }


    glfwMakeContextCurrent(holder->window);

    glfwSetWindowShouldClose(holder->window, true);
    glfwPollEvents();
    // Close OpenGL window and terminate GLFW
    glfwDestroyWindow(holder->window);
    holder->window = nullptr;
    return Qtrue;
  }
  return Qfalse;
}


void application_mark(ApplicationHolder * holder)
{
  for(VALUE fc : holder->fade_candies) {
    rb_gc_mark(fc);
  }
}


VALUE application_allocate(VALUE klass)
{
  ApplicationHolder * holder = new ApplicationHolder();

  return Data_Wrap_Struct(klass, application_mark, deallocate, holder);
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

  holder->app = new App();
  return self;
}

VALUE application_tick(VALUE self, VALUE r_pattern)
{
  GLenum glErr;
  ApplicationHolder * app_holder;
  Data_Get_Struct(self, ApplicationHolder, app_holder);

  PatternHolder * pattern_holder;
  Data_Get_Struct(r_pattern, PatternHolder, pattern_holder);

  if (app_holder->window) {
    glfwMakeContextCurrent(app_holder->window);

    glfwPollEvents();

    if (glfwWindowShouldClose(app_holder->window)) {

      // Close OpenGL window and terminate GLFW
      glfwDestroyWindow(app_holder->window);
      app_holder->window = nullptr;

      return Qfalse;
    }
    glEnable(GL_DEPTH_TEST);
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

    return Qtrue;
  }
  return Qfalse;
}


VALUE application_add_fadecandy(VALUE self, VALUE fc)
{
  ApplicationHolder * app_holder;
  Data_Get_Struct(self, ApplicationHolder, app_holder);

  FadeCandyHolder * fadecandy_holder;
  Data_Get_Struct(fc, FadeCandyHolder, fadecandy_holder);


  app_holder->fade_candies.push_back(fc);
  app_holder->app->addFadeCandy(fadecandy_holder->fade_candy);

  return self;
}
