#pragma once
#include <ruby/ruby.h>

#include "holder.hpp"

#include <pixlib/pattern.hpp>


class PatternHolder : public Holder {
public:
  PatternHolder();

  virtual ~PatternHolder();

  Pixlib::Pattern *pattern;
};



VALUE pattern_allocate(VALUE klass);

VALUE pattern_initialize(VALUE self, VALUE rb_string);

VALUE pattern_reset_start(VALUE self);
VALUE pattern_elapsed(VALUE self);
