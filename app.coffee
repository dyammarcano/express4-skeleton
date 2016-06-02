express = require 'express'
path = require 'path'
favicon = require 'serve-favicon'
logger = require 'morgan'
cookieParser = require 'cookie-parser'
bodyParser = require 'body-parser'
minify = require 'express-minify'

stylus = require 'stylus'
favicon = require 'serve-favicon'
cookieSession = require 'cookie-session'
session = require 'express-session'
MongoStore = require('connect-mongo')(session)
mongoose = require 'mongoose'
passport = require 'passport'
LocalStrategy = require('passport-local').Strategy
flash = require 'express-flash'
compression = require 'compression'

routes = require './routes/index'
users = require './routes/users'

app = express()

# view engine setup
app.set 'views', path.join __dirname, 'views'
app.set 'view engine', 'pug'

app.use compression()
app.use minify()
app.use favicon "#{__dirname}/public_html/favicon.ico"
app.use logger 'dev'
app.use bodyParser.json()
app.use bodyParser.urlencoded
  extended: false
app.use cookieParser()
app.use express.static path.join __dirname, 'public_html'

app.use '/', routes
app.use '/users', users

# catch 404 and forward to error handler
app.use (req, res, next) ->
    err = new Error 'Not Found'
    err.status = 404
    next err

# error handlers

# development error handler
# will print stacktrace
if app.get('env') is 'development'
    app.use (err, req, res, next) ->
        res.status err.status or 500
        res.render 'error/error',
            message: err.message,
            error: err

# production error handler
# no stacktraces leaked to user
app.use (err, req, res, next) ->
    res.status err.status or 500
    res.render 'error/error',
        message: err.message,
        error: {}

module.exports = app
