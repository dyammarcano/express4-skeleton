express        = require 'express'
router         = express.Router()
config         = require '../config/config'
passport       = require 'passport'
Account        = require '../models/account'

##############################################################################################
# Route POST 
##############################################################################################

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

##############################################################################################
# Route POST 
##############################################################################################

router.post '/login', passport.authenticate('local'), (request, response) ->
    response.redirect '/'
    return

##############################################################################################
# Route GET 
##############################################################################################

router.get '/login', (request, response) ->
    response.render 'login/login',
        title: config.title

##############################################################################################
# Route GET 
##############################################################################################

router.get '/register', (request, response) ->
    response.render 'login/register',
        title: config.title

##############################################################################################
# Route GET 
##############################################################################################

router.get '/logout', (request, response) ->
    request.logout()
    delete request.session
    console.log request.user
    response.redirect '/'

module.exports = router