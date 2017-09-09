#pragma once

class Holder {
public:
  virtual ~Holder();
};

void deallocate(void * holder);
