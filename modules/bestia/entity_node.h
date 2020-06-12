#ifndef ENTITYNODE_H
#define ENTITYNODE_H

#include "scene/main/node.h"

namespace bestia
{

  class EntityNode : public Node
  {
    GDCLASS(EntityNode, Node);

  protected:
    static void _bind_methods();

  public:
    EntityNode();
  };

} // namespace bestia

#endif