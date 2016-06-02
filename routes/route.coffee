express        = require 'express'
router         = express.Router()
passport       = require 'passport'
Account        = require '../models/account'
config         = require '../config/config'

# GET
router.get '/', (request, response, next) ->
    request.session.ip = request.headers['x-forwarded-for']

    if typeof request.cookies.myapp != 'undefined'
        request.session.cookie = request.cookies.myapp

    if !request.session.views
        request.session.views = 0
    
    request.session.views += 1

    response.render 'homepage',
        title: config.title
        user: request.user
        console.log request.user

router.get '/template', (request, response, next) ->
    response.render 'template'

router.get '/status', (request, response, next) ->
    status = {time: new Date()}
    response.jsonp status

router.get '/login', (request, response, next) ->
    response.render 'login/login',
        title: config.title

router.get '/register', (request, response, next) ->
    response.render 'login/register',
        title: config.title

router.get '/logout', (request, response, next) ->
    request.logout()
    delete request.session
    response.redirect '/'

# POST
router.post '/register', (request, response) ->
    data =
        role     : request.body.role
        email    : request.body.email
        username : request.body.username

    Account.register new Account(data), request.body.password, (err, account) ->
        if err
            return response.render 'register', account: account

        passport.authenticate('local') request, response, ->
            request.user.username = request.body.username
            response.redirect '/'
            return
        return
    return

router.post '/login', passport.authenticate('local'), (request, response) ->
    response.redirect '/'
    return

module.exports = router