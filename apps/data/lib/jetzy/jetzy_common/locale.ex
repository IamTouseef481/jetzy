#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2020 JetzyApp. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Jetzy.Locale do
  use Noizu.SimpleObject
  @vsn 1.0
  @kind "Locale"
  Noizu.SimpleObject.noizu_struct() do
    @json {[:mobile, :verbose], :suppress_meta}
    public_field :locale_language, nil, JetzySchema.Types.Locale.Language.Enum
    public_field :locale_country, nil, JetzySchema.Types.Locale.Country.Enum
    public_field :localized
  end

  defmodule TypeHandler do
    require  Noizu.DomainObject
    Noizu.DomainObject.noizu_type_handler()
  end

end # end defmodule Jetzy.ModerationDetails
