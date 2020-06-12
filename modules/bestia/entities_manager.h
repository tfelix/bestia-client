#ifndef ENTITIESMANAGER_H
#define ENTITIESMANAGER_H

#include "scene/main/node.h"

namespace bestia
{
  class EntitiesManager : public Node
  {
    GDCLASS(EntitiesManager, Node);

  protected:
    static void _bind_methods();

  public:
    EntitiesManager();
    /**
     * The incoming data is de-serialized with protobuf and then a special check appears, we can only spawn
     * a Godot Node when we retrieved the ClientNodeComponent data. As long as this data is not there we will not
     * spawn the Godot node.
     */
    void ingest_message(PoolByteArray message);
  };
} // namespace bestia

#endif
