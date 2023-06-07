#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2021 JetzyApp. All rights reserved.
#-------------------------------------------------------------------------------

require JetzySchema.EnumTableBehaviour
JetzySchema.EnumTableBehaviour.table(:vnext_price_point, Jetzy.Business.PricePoint.Enum)