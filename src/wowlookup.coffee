global.wf ||= {}

require "./store"
require './init_logger'
portcheck = require 'portchecker'


store = new wf.Store()

class wf.WowLookup

  armory_instance = null
  armory_calls = 
    guild: "guild"
    member: "character"
    character: "character"

  armory_fields = 
    guild: ["members","achievements","news","challenge"]
    member: ["achievements","guild","feed","hunterPets","professions","progression","pvp","quests","reputation","stats","talents","titles","items"]
    character: ["achievements","guild","feed","hunterPets","professions","progression","pvp","quests","reputation","stats","talents","titles","items"]

  constructor: ->
    wf.info "WowLookup constructor"

  get_armory: (callback) ->
    if process.env.NODE_ENV == "production"
      wf.info "Its production - dont use a proxy to the armory"
      armory = require('armory')
      callback(armory)
    else
      try
        portcheck.isOpen 8888,"localhost", (is_open)->
          wf.info "Port is open? #{is_open}"
          if is_open
            wf.info "Found the proxy, so use it:#{is_open}"
            armory = require('armory').defaults(request:{proxy:"http://localhost:8888"})
            callback(armory)
          else
            wf.info "Proxy not found, so connecting to armory direct"
            armory = require('armory')
            callback(armory)
      catch e
        wf.info "Proxy not found, so connecting to armory direct:#{e}"
        armory = require('armory')
        callback(armory)

  with_armory: (armory_handler) ->
    if armory_instance?
      armory_handler?(armory_instance)
    else
      @get_armory (armory) ->
        armory_instance = armory
        armory_handler?(armory_instance)

  get: (type, region, realm, name, lastModified, result_handler) ->
    wf.debug "Armory lookup #{type} info for #{region}, #{realm}, #{name}, last mod:#{new Date(lastModified)}"
    @with_armory (armory) ->
      armory[armory_calls[type]] {region, realm, name, fields: armory_fields[type], lastModified}, (err,thing) ->
        if err is null and thing is undefined # no changes
          wf.debug "wowlookup #{name} - not modified"
          result_handler?(undefined)          
        else if err
          wf.error("wowlookup error looking for #{name},#{realm},#{region},#{type}:#{err.message} : #{JSON.stringify(err)}")
          result_handler?(
            type: type
            region: region
            realm: realm
            name: name
            error: err.message
            lastModified: 0
            info: "Armory lookup #{type} info for #{region}, #{realm}, #{name}")
        else
          wf.debug "wowlookup #{name}/#{thing?.name}, err:#{JSON.stringify(err)}, result:#{JSON.stringify(thing)}"
          thing?.type = type
          thing?.region = region
          result_handler?(thing)

  get_static: (static_load_method, region = "eu", callback) ->
    @with_armory (armory) ->
      armory[static_load_method] {region}, (err, things) ->
        if err
          wf.error("wowlookup get_static(#{static_load_method}) error:#{err.message} : #{JSON.stringify(err)}")
          callback?(null)
        else
          wf.debug "wowlookup get_static(#{static_load_method}) result:[#{things.length}]#{JSON.stringify(things)}"
          callback?(things)

