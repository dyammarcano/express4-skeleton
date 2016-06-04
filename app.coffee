# node modules
express        = require 'express'
path           = require 'path'
favicon        = require 'serve-favicon'
logger         = require 'morgan'
cookieParser   = require 'cookie-parser'
bodyParser     = require 'body-parser'
favicon        = require 'serve-favicon'
expressSession = require 'express-session'
MongoStore     = require('connect-mongo')(expressSession)
passport       = require 'passport'
LocalStrategy  = require('passport-local').Strategy
compression    = require 'compression'

# locals
routes         = require './routes/route'
config         = require './config/config'

app = express()
app.use cookieParser()

app.all '*', (request, response, next) ->
    if request.headers['x-nginx-proxy'] is true
        app.enable 'trust proxy'

    next()
    return

# view engine setup
app.set 'views', path.join __dirname, 'views'
app.set 'view engine', 'pug'

# setup session
app.use expressSession(
    name: config.app
    saveUninitialized: false
    resave: false
    unset: 'destroy'
    secret: config.session_secret
    store: new MongoStore(
        url: config.db_name
        ttl: 14 * 24 * 60 * 60
        autoRemove: 'native'
        stringify: true
        collection: 'sessions')
    cookie:
        _expires: null
        httpOnly: true
        secure: false
        maxAge: 60 * 60 * 24 * 7)

app.use compression()
app.use favicon "#{__dirname}/public_html/precomposed.png"
app.use logger 'dev'
app.use bodyParser.json()
app.use bodyParser.urlencoded
    extended: false
app.use express.static path.join __dirname, 'public_html'

app.use passport.initialize()
app.use passport.session()

app.use '/', routes

# login section passport mongoose
Account = require './models/account'

passport.use new LocalStrategy(Account.authenticate())
passport.serializeUser Account.serializeUser()
passport.deserializeUser Account.deserializeUser()

# catch 404 and forward to error handler
app.use (request, res, next) ->
    err = new Error 'Not Found'
    err.status = 404
    next err

# development error handler
# will print stacktrace
if app.get('env') is 'development'
    app.use (err, request, response, next) ->
        response.status err.status or 500
        response.render 'error/error',
            message: err.message,
            error: err

# production error handler
# no stacktraces leaked to user
app.use (err, request, response, next) ->
    response.status err.status or 500
    response.render 'error/error',
        message: err.message,
        error: {}

module.exports = app
