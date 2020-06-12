#ifndef ENTITY_H
#define ENTITY_H

#include <vector>

#include "inttypes.h"
#include "core/hash_map.h"

#include "component/component.h"

namespace bestia
{

  class Entity
  {
  public:
    Entity(uint64_t id);
    ~Entity();

    const uint64_t id;

  private:
    std::vector<Component *> components;
  };

} // namespace bestia

#endif