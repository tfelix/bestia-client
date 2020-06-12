#include "register_types.h"
#include "core/class_db.h"

#include "entities_manager.h"
#include "entity_registry.h"
#include "entity_node.h"

void register_bestia_types()
{
  ClassDB::register_class<bestia::EntitiesManager>();
  ClassDB::register_class<bestia::EntityNode>();

  bestia::EntityRegistry::create_singleton();
}

void unregister_bestia_types()
{
  bestia::EntityRegistry::destroy_singleton();
}
