#include "entity.h"

namespace bestia
{
  Entity::Entity(uint64_t id)
      : id(id) {}

  Entity::~Entity()
  {
    for (auto const &component : components)
    {
      delete component;
    }
    components.clear();
  }

} // namespace bestia