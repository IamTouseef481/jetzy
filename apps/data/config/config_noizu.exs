import Config

#-------------------------------------------------------------------------------
# ElixirScaffolding
#-------------------------------------------------------------------------------
config :noizu_advanced_scaffolding,
       default_audit_engine: Jetzy.AuditEngine,
       default_nmid_generator: Noizu.AdvancedScaffolding.NmidGenerator,
       node_nmid_index: 1,
       domain_object_schema: Jetzy.DomainObject.Schema,
       default_ecto_database: JetzySchema.PG.Repo
