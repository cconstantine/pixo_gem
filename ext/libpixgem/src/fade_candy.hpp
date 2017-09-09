#pragma once
#include <ruby/ruby.h>

#include "holder.hpp"

#include <pixlib/fade_candy.hpp>


class FadeCandyHolder : public Holder {
public:
  FadeCandyHolder();

  virtual ~FadeCandyHolder();

  Pixlib::FadeCandy *fade_candy;
};



VALUE fade_candy_allocate(VALUE klass);

VALUE fade_candy_initialize(VALUE self, VALUE hostname, VALUE num_leds);
