#pragma once
#include "holder.hpp"

#include <pixlib/app.hpp>
#include <pixlib/fade_candy.hpp>

#include <GLFW/glfw3.h>
#include <ruby/ruby.h>

class ApplicationHolder : public Holder {
public:
  ApplicationHolder();

  virtual ~ApplicationHolder();

  Pixlib::App *app;
  GLFWwindow* window;

  std::vector<VALUE> fade_candies;

  VALUE self;
};

VALUE application_allocate(VALUE klass);

VALUE application_key_callback(VALUE self, VALUE key, VALUE scancode, VALUE action, VALUE mods);

VALUE application_close(VALUE self);

VALUE application_initialize(VALUE self, VALUE rb_full_screen);

VALUE application_add_fadecandy(VALUE self, VALUE fc);

VALUE application_tick(VALUE self, VALUE r_pattern, VALUE r_brightness);