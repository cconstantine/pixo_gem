#include "holder.hpp"

Holder::~Holder() {}

void deallocate(void * holder)
{
  Holder* h = (Holder*)holder;
  delete h;
}
