#include "fade_candy.hpp"

using namespace Pixlib;

FadeCandyHolder::FadeCandyHolder() : fade_candy(nullptr) { }

FadeCandyHolder::~FadeCandyHolder() {
  if(fade_candy) {
    delete fade_candy;
  }
}

VALUE fade_candy_allocate(VALUE klass)
{
  FadeCandyHolder * holder = new FadeCandyHolder();

  return Data_Wrap_Struct(klass, NULL, deallocate, holder);
}

VALUE fade_candy_initialize(VALUE self, VALUE rb_hostname, VALUE r_num_leds)
{
  FadeCandyHolder * holder;

  Check_Type(rb_hostname, T_STRING);
  std::string hostname(StringValuePtr(rb_hostname));
  Data_Get_Struct(self, FadeCandyHolder, holder);
  holder->fade_candy = new FadeCandy(hostname, NUM2UINT(r_num_leds));

  return self;
}
