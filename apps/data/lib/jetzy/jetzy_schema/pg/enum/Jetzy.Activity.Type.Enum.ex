#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2021 JetzyApp. All rights reserved.
#-------------------------------------------------------------------------------

require JetzySchema.EnumTableBehaviour
JetzySchema.EnumTableBehaviour.table(:vnext_activity_type, Jetzy.Activity.Type.Enum)