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
  Pixlib::FadeCandy *fc;
  GLFWwindow* window;
};

VALUE application_allocate(VALUE klass);

VALUE application_initialize(VALUE self);

VALUE application_tick(VALUE self, VALUE r_pattern);