express        = require 'express'
router         = express.Router()
passport       = require 'passport'
Account        = require '../models/account'
config         = require '../config/config'

# GET
router.get '/', (req, res, next) ->
    res.render 'homepage',
        title: config.title

router.get '/template', (req, res, next) ->
    res.render 'template'

router.get '/login', (req, res, next) ->
    res.render 'login/login',
        title: config.title

router.get '/register', (req, res, next) ->
    res.render 'login/register',
        title: config.title

# POST
router.post '/register', (req, res) ->
    Account.register new Account(username: req.body.username), req.body.password, (err, account) ->
        if err
            return res.render('register', account: account)

        passport.authenticate('local') req, res, ->
            res.redirect '/'
            return
        return
    return

router.post '/login', passport.authenticate('local'), (req, res) ->
    res.redirect '/'
    return

module.exports = router