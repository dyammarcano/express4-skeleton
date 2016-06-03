express        = require 'express'
router         = express.Router()
passport       = require 'passport'
Account        = require '../models/account'
config         = require '../config/config'

# GET
router.get '/', (request, response) ->
    if request.user
        response.redirect '/dashboard'
        return

    request.session.ip = request.headers['x-forwarded-for']

    response.render 'homepage',
        title: config.title
        user: request.user

router.get '/dashboard', (request, response) ->
    if request.user
        response.render 'template.pug',
        title: config.title
        user: request.user
        return
    else
        response.redirect '/'
    return

router.get '/login', (request, response) ->
    response.render 'login/login',
        title: config.title

router.get '/register', (request, response) ->
    response.render 'login/register',
        title: config.title

router.get '/logout', (request, response) ->
    request.logout()
    delete request.session
    console.log request.user
    response.redirect '/'

# POST
router.post '/register', (request, response) ->
    data =
        role      : request.body.role.trim().toLowerCase()
        email     : request.body.email.trim().toLowerCase()
        username  : request.body.username.trim().toLowerCase()
        username2 : request.body.username2.trim().toLowerCase()
        surname1  : request.body.surname1.trim().toLowerCase()
        surname2  : request.body.surname2.trim().toLowerCase()

    console.log data

    Account.register new Account(data), request.body.password.trim(), (err, account) ->
        if err
            return response.render 'login/register', account: account

        passport.authenticate('local') (request, response) ->
            request.user.username = request.body.username.trim().toLowerCase()
            response.redirect '/'
            return
        return
    return

router.post '/login', passport.authenticate('local'), (request, response) ->
    response.redirect '/'
    return

module.exports = router