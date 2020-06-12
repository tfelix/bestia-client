#include "component.h"

namespace bestia
{
  class Component
  {
  public:
    Component(uint64_t id);

    const uint64_t id;

    virtual String get_name() = 0;
  };

} // namespace bestia
