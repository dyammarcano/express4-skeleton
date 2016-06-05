#!/usr/bin/env coffee

require('dotenv').config()

app            = require '../app'
config         = require '../config/config'
debug          = require('debug') config.app + ':server'
http           = require 'http'

##############################################################################################
# Event listener for HTTP server "error" event.
##############################################################################################

onError = (error) ->
    if error.syscall isnt 'listen'
        throw error

    bind = if typeof port is 'string' then "Pipe #{port}" else "Port #{port}"

    # handle specific listen errors with friendly messages
    switch error.code
        when 'EACCES'
            console.error "#{bind} requires elevated privileges"
            process.exit 1
        when 'EADDRINUSE'
            console.error "#{bind} is already in use"
            process.exit 1
        else
            throw error

##############################################################################################
# Event listener for HTTP server "listening" event.
##############################################################################################

onListening = ->
    addr = server.address()
    bind = if typeof addr is 'string' then "pipe #{addr}" else "port #{addr.port}"
    debug "Listening on #{bind}"

##############################################################################################
# Get port from .env and store in Express.
##############################################################################################

port = process.env.PORT
app.set 'port', port

##############################################################################################
# Create HTTP server.
##############################################################################################

server = http.createServer(app).listen port

##############################################################################################
# Listen on provided port, on all network interfaces.
##############################################################################################

server.on 'error', onError
server.on 'listening', onListening

##############################################################################################
# Print console information.
##############################################################################################

console.log 'Express server ready in (' + process.env.MODE + ') mode http://localhost:' + process.env.PORT
