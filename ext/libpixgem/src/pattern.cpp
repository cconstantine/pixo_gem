#include "pattern.hpp"

using namespace Pixlib;

PatternHolder::PatternHolder() : pattern(nullptr) { }

PatternHolder::~PatternHolder() {
  if(pattern) {
    delete pattern;
  }
}

VALUE pattern_allocate(VALUE klass)
{
  PatternHolder * holder = new PatternHolder();

  return Data_Wrap_Struct(klass, NULL, deallocate, holder);
}

VALUE pattern_initialize(VALUE self, VALUE rb_string)
{
  PatternHolder * holder;

  Check_Type(rb_string, T_STRING);

  Data_Get_Struct(self, PatternHolder, holder);
  holder->pattern = new Pattern(StringValuePtr(rb_string));

  return self;
}


VALUE pattern_reset_start(VALUE self)
{
  PatternHolder * holder;

  Data_Get_Struct(self, PatternHolder, holder);

  if(holder->pattern) {
    holder->pattern->resetStart();
  }
  return Qtrue;
}


VALUE pattern_elapsed(VALUE self) 
{
  PatternHolder * holder;

  Data_Get_Struct(self, PatternHolder, holder);

  if(holder->pattern) {
    return DBL2NUM(holder->pattern->getTimeElapsed());
  }

  return Qnil;
}