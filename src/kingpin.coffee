async     = require 'async'
chainable = require 'chainable'
shh       = require 'shh'

aws = require('pkgcloud').compute.createClient
  provider: 'amazon'
  keyId: process.env.AWS_ACCESS_KEY
  key: process.env.AWS_SECRET_KEY

getHost = (server) ->
  server.amazon.dnsName

getName = (server) ->
  tags = server.amazon.tagSet.item
  unless Array.isArray tags
    tags = [tags]

  for tag in tags
    if tag.key == 'Name'
      return tag.value

class Kingpin extends chainable
  getServers: chainable (callback) ->
    aws.getServers (err, servers) =>
      return callback err if err?

      for server in servers
        server.name = getName server
        server.host = getHost server

      @servers = servers
      callback null

  filter: chainable (fn, callback) ->
    @servers = @servers.filter fn
    callback null

  exec: chainable (cmd, callback) ->
    async.map @servers, (server, callback) ->
      client = new shh.Client
        host: server.host
        username: 'ubuntu'
        privateKey: process.env.AWS_SSH_KEY

      client.connect (err, stream) ->
        throw err if err?

        client.exec cmd, (err, out) ->
          client.close()
          callback err, out

    , callback

module.exports = Kingpin
