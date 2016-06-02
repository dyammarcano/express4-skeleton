# node modules
express        = require 'express'
connect        = require 'connect'
path           = require 'path'
favicon        = require 'serve-favicon'
logger         = require 'morgan'
cookieParser   = require 'cookie-parser'
bodyParser     = require 'body-parser'
minify         = require 'express-minify'
favicon        = require 'serve-favicon'
csurf          = require 'csurf'
expressSession = require 'express-session'
MongoStore     = require('connect-mongo')(expressSession)
mongoose       = require 'mongoose'
passport       = require 'passport'
LocalStrategy  = require('passport-local').Strategy
flash          = require 'express-flash'
compression    = require 'compression'

# locals
routes         = require './routes/index'
users          = require './routes/users'
config         = require './config/config'

app = express()
app.use cookieParser()

app.enable 'trust proxy'

# view engine setup
app.set 'views', path.join __dirname, 'views'
app.set 'view engine', 'pug'

# setup session
app.use expressSession(
    name: config.app
    saveUninitialized: true
    resave: true
    secret: config.session_secret
    store: new MongoStore(
        url: config.db_name)
    cookie:
        _expires: null
        httpOnly: true
        secure: false
        maxAge: 60 * 60 * 24 * 7)

app.use compression()
app.use minify()
app.use favicon "#{__dirname}/public_html/node-icon.png"
app.use logger 'dev'
app.use bodyParser.json()
app.use bodyParser.urlencoded
    extended: false
app.use express.static path.join __dirname, 'public_html'

app.use '/', routes
app.use '/users', users

# login section passport mongoose
Account = require './models/account'

# csurf section
# https://github.com/pillarjs/understanding-csrf
app.use csurf(cookie: true)

passport.use new LocalStrategy(Account.authenticate())
passport.serializeUser Account.serializeUser()
passport.deserializeUser Account.deserializeUser()

# catch 404 and forward to error handler
app.use (req, res, next) ->
    err = new Error 'Not Found'
    err.status = 404
    next err

# development error handler
# will print stacktrace
if app.get('env') is 'development'
    app.use (err, req, res, next) ->
        res.status err.status or 500
        res.render 'error/' + err.status,
            message: err.message,
            error: err

# production error handler
# no stacktraces leaked to user
app.use (err, req, res, next) ->
    res.status err.status or 500
    res.render 'error/' + err.status,
        message: err.message,
        error: {}

module.exports = app
