should  = require('chai').should()
kingpin = require '../../'

describe 'kingpin', ->
  describe.skip '#getServers', ->
    it 'should list all instances', (done) ->
      kingpin.getServers (err, servers) ->
        for server in servers
          console.log server.name
        done()

  describe '#exec', ->
    it 'should run command on all instances', (done) ->
      kingpin
        .getServers()
        .filter((server) -> (server.name.indexOf 'adage') != -1)
        .exec 'echo hello', (err, out) ->
          console.log out
          done()
