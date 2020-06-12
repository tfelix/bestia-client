#include "entity_registry.h"

namespace bestia
{
  EntityRegistry *g_entity_registry = nullptr;

  void EntityRegistry::create_singleton()
  {
    CRASH_COND(g_entity_registry != nullptr);
    g_entity_registry = memnew(EntityRegistry);
  }

  void EntityRegistry::destroy_singleton()
  {
    CRASH_COND(g_entity_registry == nullptr);
    EntityRegistry *registry = g_entity_registry;
    g_entity_registry = nullptr;
    memdelete(registry);
  }

  EntityRegistry *EntityRegistry::get_singleton()
  {
    CRASH_COND(g_entity_registry == nullptr);

    return g_entity_registry;
  }

  EntityRegistry::EntityRegistry()
  {
    mutex = Mutex::create();
  }

  EntityRegistry::~EntityRegistry()
  {
    clear();
    memdelete(mutex);
  }

  void EntityRegistry::clear()
  {
    MutexLock lock(mutex);
    entities.clear();
  }

  void EntityRegistry::remove_entity(uint64_t entity_id)
  {
    MutexLock lock(mutex);
    entities.erase(entity_id);
  }

  void EntityRegistry::add_entity(Entity *const entity)
  {
    MutexLock lock(mutex);
    entities.set(12L, entity);
  }

} // namespace bestia
