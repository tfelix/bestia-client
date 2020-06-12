#include "entities_manager.h"

namespace bestia
{
  EntitiesManager::EntitiesManager() {}

  //Bind all your methods used in this class
  void EntitiesManager::_bind_methods()
  {
    ClassDB::bind_method(D_METHOD("ingest_message", "message"), &EntitiesManager::ingest_message);
  }

  void EntitiesManager::ingest_message(PoolByteArray message)
  {
    // Deserialize message into protobuf

    // check if there is already an entity with this component, if not create one

    // attach/update component to the entity

    // check if there is a godot node for this entity if there is none check if
    // we have the component with the info to spawn one.


    // emit component_updated if component data has changed.
  }

} // namespace bestia
