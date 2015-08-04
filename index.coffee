class PixSpy
  constructor: (@req, @res)->
    @generatedId = false
    @ip = @req.headers['x-forwarded-for'] || @req.connection.remoteAddress;
    @id = @req.params["id"] || @_generateId()
    @ip = '122.161.157.158'
    if(global.mongoose == undefined )
      global.mongoose = require('mongoose')
      global.mongoose.connect('mongodb://localhost/' + database)
      global.schema = new global.mongoose.Schema({
        ip: String,
        id: {type: String, index: true},
        geo: Object,
        hitHistory:
          "type": Array,
          "default": new Array()
        hitCount: {type: Number, default: 0},
        lastHit: Date
        updated_at: Date
        created_at: {type: Date, default: Date.now}
      })
      global.Ps = global.mongoose.model('Ps', global.schema);
      global.schema.pre('save', (next)->
        this.created_at = new Date()

        #        this.hitCount = this.hitCount || -1
        #        this.hitCount = this.hitCount + 1
        #        $setOnInsert: {
        #          hitCount: this.hitCount
        #          updated_at: new Date()
        #        }


        next()
      )

    #      global.schema.pre('update', ->
    #        this.update({},{ $set: { updated_at: new Date() } });
    #      )


    @Ps = global.Ps

    @q = @Ps.findOne({
      id: @id
    }).exec();

  _generateId: ->
    @generatedId = true
    Math.random().toString(36).substr(2, 12)

  _trackSave: (entry) ->
    trackedInformation = {
      ip: @ip
      geo: @getGeoLocation(@ip)
    }

    hitCount = entry.hitCount + 1
    @Ps.update({id: entry.id}, {
        lastHit: new Date()
        hitCount: hitCount
        updated_at: new Date()
        $push:
          hitHistory: trackedInformation
      }, {upsert: true}, (err)->
      if err
        console.log(err)
    )


  track: (entry) ->
    entry = entry || false
    if(entry)
      @_trackSave(entry)
    else
      @Ps.findOne({
          id: @id
        }, (err, entry)->
        if(err)
          console.log(err)
        @trackSave(entry)
      )
  list: ->
    self = @
    @q.then((entry) ->
      console.log(entry)
      if (!entry)
        self.res.send({image:false})
      else
        entry = entry.toObject()
        delete entry['_id']
        delete entry['__v']
        self.res.send(entry)
    )


  create: ->
    entry = new @Ps()
    entry.id = @id
    entry.ip = @ip
    entry.geo = @getGeoLocation(@ip)
    entry.save()
    if(@generatedId)
      @list(entry)

  _generateImage: (@id = @_generateId())->
  getGeoLocation: (ip)->
    geoip = require('geoip-lite')
    @geo = geoip.lookup(ip);

#Express app stars here
cluster = require('cluster')
numCPUs = require('os').cpus().length
argv = require('minimist')(process.argv.slice(2))
argv['c'] = argv['c'] or false
if argv['c'] and parseInt(argv['c']) <= numCPUs
  numCPUs = argv['c'] or numCPUs
fs = require('fs')
localConfig = JSON.parse(fs.readFileSync('config.json', 'utf8'))
database = localConfig.database
trackGeo = localConfig.geo or false
if cluster.isMaster
  # Fork workers.
  i = 0
  while i < numCPUs
    cluster.fork()
    console.log 'Starting Process app ' + i
    i++
  cluster.on 'exit', (worker, code, signal) ->
    console.log 'worker ' + worker.process.pid + ' died, restarting'
    cluster.fork()
    return
else
  express = require('express')
  app = express()
  emptygif = require('emptygif');
  create = (req, res) ->
    process.nextTick(->
      pixSpy = new PixSpy(req, res)
      pixSpy.q.then((entry) ->
        if (entry == null)
          pixSpy.create()
        else
          pixSpy.track(entry)
      )
    )

    emptygif.sendEmptyGif(req, res, {
      'Content-Type': 'image/gif',
      'Content-Length': emptygif.emptyGifBufferLength,
      'Cache-Control': 'public, max-age=0'
    });

  list = (req, res) ->
    pixSpy = new PixSpy(req, res)
    pixSpy.list()

  #source url friendly
  app.get '/create', (req, res) ->
    #create with random id and returns url of the image
    create(req, res)
  app.get '/create/:id.gif', (req, res) ->
    create(req, res)
  app.get '/list/:id.gif', (req, res) ->
    list(req, res)

  # REST Based
  app.get '/:id.gif', (req, res) ->
    create(req, res)
  app.post '/gif', (req, res) ->
    create(req, res)
  app.post '/:id.gif', (req, res) ->
    create(req, res)

  server = app.listen(3000, ->
    host = server.address().address
    port = server.address().port
    console.log 'App listening at http://%s:%s', host, port
    return
  )