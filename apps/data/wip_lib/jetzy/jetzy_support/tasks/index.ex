#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2021 JetzyApp All rights reserved.
#-------------------------------------------------------------------------------

defmodule Mix.Tasks.Index do
  use Mix.Task
  @default_file "sphinx/sphinx.conf.new"
  @generated_code_header """
  #========[ GENERATED CODE BELOW. DO NOT EDIT BY HAND ]========

  """

  @base_configuration """

  #############################################################################
  ## indexer settings
  #############################################################################
  indexer
  {
  # memory limit, in bytes, kiloytes (16384K) or megabytes (256M)
  # optional, default is 128M, max is 2047M, recommended is 256M to 1024M
  mem_limit		= 512M
  }

  #############################################################################
  ## searchd settings
  #############################################################################
  searchd
  {
  # [hostname:]port[:protocol], or /unix/socket/path to listen on
  # known protocols are 'sphinx' (SphinxAPI) and 'mysql41' (SphinxQL)
  #
  # multi-value, multiple listen points are allowed
  # optional, defaults are 9312:sphinx and 9306:mysql41, as below
  listen			= 9312
  listen			= 9307:mysql41

  # log file, searchd run info is logged here
  # optional, default is 'searchd.log'
  log			= /sphinx/log/searchd.log
  binlog_path = /sphinx/data/

  # query log file, all search queries are logged here
  # optional, default is empty (do not log queries)
  query_log		= /sphinx/log/query.log

  # client read timeout, seconds
  # optional, default is 5
  read_timeout		= 5

  # request timeout, seconds
  # optional, default is 5 minutes
  client_timeout		= 300

  # maximum amount of children to fork (concurrent searches to run)
  # optional, default is 0 (unlimited)
  max_children		= 30

    max_matches = 1000000

  # maximum amount of persistent connections from this master to each agent host
  # optional, but necessary if you use agent_persistent. It is reasonable to set the value
  # as max_children, or less on the agent's hosts.
  persistent_connections_limit	= 30

  # PID file, searchd process ID file name
  # mandatory
  pid_file		= /sphinx/log/searchd.pid

  # seamless rotate, prevents rotate stalls if precaching huge datasets
  # optional, default is 1
  seamless_rotate		= 1

  # whether to forcibly preopen all indexes on startup
  # optional, default is 1 (preopen everything)
  preopen_indexes		= 1

  # whether to unlink .old index copies on succesful rotation.
  # optional, default is 1 (do unlink)
  unlink_old		= 1

  # MVA updates pool size
  # shared between all instances of searchd, disables attr flushes!
  # optional, default size is 1M
  mva_updates_pool	= 1M

  # max allowed network packet size
  # limits both query packets from clients, and responses from agents
  # optional, default size is 8M
  max_packet_size		= 8M

  # max allowed per-query filter count
  # optional, default is 256
  max_filters		= 256

  # max allowed per-filter values count
  # optional, default is 4096
  max_filter_values	= 4096

  # max allowed per-batch query count (aka multi-query count)
  # optional, default is 32
  max_batch_queries	= 32

  # multi-processing mode (MPM)
  # known values are none, fork, prefork, and threads
  # threads is required for RT backend to work
  # optional, default is threads
  workers			= threads # for RT to work
  }

  #############################################################################
  ## common settings
  #############################################################################
  common
  {

  }



  ########################################################################################################################
  ########################################################################################################################
  ## data source definition
  ########################################################################################################################
  ########################################################################################################################


  #---------------------------------------------------
  # Primary
  #---------------------------------------------------
  source primary_source__base
  {
    type			= xmlpipe2
  }

  #---------------------------------------------------
  # Delta
  #---------------------------------------------------
  source delta_source__base
  {
    type			= xmlpipe2
  }

  ########################################################################################################################
  ########################################################################################################################
  ## Index Definitions
  ########################################################################################################################
  ########################################################################################################################

  #---------------------------------------------------
  # Primary
  #---------------------------------------------------
  index index__base
  {
  # index type
  # optional, default is 'plain'
  # known values are 'plain', 'distributed', and 'rt' (see samples below)
  type			= plain

  # document attribute values (docinfo) storage mode
  # optional, default is 'extern'
  # known values are 'none', 'extern' and 'inline'
  docinfo			= extern

  # dictionary type, 'crc' or 'keywords'
  # crc is faster to index when no substring/wildcards searches are needed
  # crc with substrings might be faster to search but is much slower to index
  # (because all substrings are pre-extracted as individual keywords)
  # keywords is much faster to index with substrings, and index is much (3-10x) smaller
  # keywords supports wildcards, crc does not, and never will
  # optional, default is 'keywords'
  dict			= keywords

  # memory locking for cached data (.spa and .spi), to prevent swapping
  # optional, default is 0 (do not mlock)
  # requires searchd to be run from root
  mlock			= 0

  # a list of morphology preprocessors to apply
  # optional, default is empty
  #
  # builtin preprocessors are 'none', 'stem_en', 'stem_ru', 'stem_enru',
  # morphology		= stem_en, stem_ru, soundex
  morphology		= stem_en

  # minimum word length at which to enable stemming
  # optional, default is 1 (stem everything)
  min_stemming_len	= 3

  # minimum indexed word length
  # default is 1 (index everything)
  min_word_len		= 3

  # whether to strip HTML tags from incoming documents
  # known values are 0 (do not strip) and 1 (do strip)
  # optional, default is 0
  html_strip		= 1

  }


  #{@generated_code_header}
  """

  def run() do
    IO.puts "Running Mix.Tasks.Index.run([\"generate\"])"
    run(["update"])
  end

  def run([]) do
    IO.puts "Usage: mix index generate [file]"
    IO.puts "Usage: mix index update [file]"
  end

  def run(["generate"]) do
    generate()
  end
  def run(["generate", file]) do
    generate(file)
  end

  def run(["update"]) do
    update()
  end
  def run(["update", file]) do
    update(file)
  end

  def generate(file \\ @default_file) do
    cond do
      File.exists?(file) -> IO.puts "Can not generate over existing file #{file}"
      :else ->
        context = Noizu.ElixirCore.CallingContext.admin()
        output = Jetzy.DomainObject.Schema.indexes
                 |> Enum.sort()
                 |> Enum.map(&(&1.__config__(context, nil)))
                 |> Enum.join(@generated_code_header)
        File.write!(file,  @base_configuration <> output)

    end
  end

  def update(file \\ @default_file) do
    context = Noizu.ElixirCore.CallingContext.admin()

    cond do
      File.exists?(file) ->
        file_in = File.read!(file)
        case :binary.match(file_in, @generated_code_header) do
          :nomatch -> IO.puts "Unable to find generated section"
          {line_pos, char_pos} ->
            f = String.slice(file_in, 0 .. (line_pos + char_pos - 1))
            output = Jetzy.DomainObject.Schema.indexes
                     |> Enum.sort()
                     |> Enum.map(&(&1.__config__(context, nil)))
                     |> Enum.join(@generated_code_header)
            File.write!(file,  f <> output)
            _ -> IO.puts "Unable to find generated section"
        end
      :else -> generate(file)
    end
  end

end
