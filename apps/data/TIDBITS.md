

# Detect Entities with missing tables


patch = Jetzy.DomainObject.Schema.domain_objects() 
|> Enum.map(fn(d) ->  d.__persistence__()[:schemas][JetzySchema.PG.Repo] end) 
|> Enum.filter(&(&1)) 
|> Enum.map(&(&1.table)) 
|> Enum.filter(&(!Code.ensure_compiled?(&1)))

patch = Jetzy.DomainObject.Schema.domain_objects()
        |> Enum.map(fn(d) ->  d.__persistence__()[:schemas][JetzySchema.Database] end)
        |> Enum.filter(&(&1))
        |> Enum.map(&(&1.table))
        |> Enum.filter(&(!Code.ensure_compiled?(&1)))