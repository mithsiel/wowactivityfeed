global.wf ||= {}

cronJob = require('cron').CronJob

wf.armory_load_requested = false

create_cron = (cron_schedule, cron_task) ->
  try 
    new_cron_job = new cronJob cron_schedule, cron_task,
      null, 
      true, #/* Start the job right now */,
      null #/* Time zone of this job. */
  catch e
    wf.error e


# wf.hourlyjob = create_cron '00 00 * * * *', (-> 
#   wf.info "cronjob tick...hourly, on the hour load"
#   wf.armory_load_requested = true
#   )

wf.hourlyjob = create_cron '00 00 0-21/3 * * *', (-> 
  wf.info "cronjob tick...3 hourly, on the hour load"
  wf.armory_load_requested = true
  )

wf.hourlyjob = create_cron '00 30 1-22/3 * * *', (-> 
  wf.info "cronjob tick...3 hourly, on the half hour load"
  wf.armory_load_requested = true
  )

wf.loadjob = create_cron '*/10 * * * * *', (-> 
  wf.debug "cronjob tick...check if armory load requested (running now? #{wf.wow.get_job_running_lock()})"
  if wf.armory_load_requested
    wf.armory_load_requested = false
    wf.info "time for armory_load..."
    wf.wow_loader.armory_load()
  )

wf.loadjob = create_cron '00 47 * * * *', (-> 
  wf.info "Reloading realms"
  # wf.wow.realms_loader ->
  wf.wow_loader.static_loader ->
    wf.info "Static load complete"
  )

# wf.staticjob = new cronJob '00 00 00 * * *', (-> 
#   wf.debug "cronjob tick...load armory static"
#   wf.wow.static_load()
#   ),
#   null, 
#   true, #/* Start the job right now */,
#   null #/* Time zone of this job. */

