#ifndef ENTITYREGISTRY_H
#define ENTITYREGISTRY_H

#include "core/hash_map.h"
#include "core/os/mutex.h"

#include "entity.h"

namespace bestia
{
  /**
   * This is a singelton which registers all existing entities so we are able to
   * redirect incoming messages to them to allow updates of the components.
   */
  class EntityRegistry
  {
  public:
    static void create_singleton();
    static void destroy_singleton();
    static EntityRegistry *get_singleton();

    EntityRegistry();
    ~EntityRegistry();

    void clear();
    void add_entity(Entity *const entity);
    void remove_entity(uint64_t entity_id);
    Entity *get_entity(uint64_t entity_id) const;

  private:
    HashMap<uint64_t, Entity *> entities;
    Mutex *mutex = nullptr;
  };
} // namespace bestia

#endif // ENTITYREGISTRY_H
