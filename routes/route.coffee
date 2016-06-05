express        = require 'express'
router         = express.Router()
config         = require '../config/config'

router.use require './auth'
router.use require './others'

##############################################################################################
# Route GET 
##############################################################################################

router.get '/', (request, response) ->
    if request.isAuthenticated()
        response.redirect '/dashboard'
        return

    request.session.ip = request.headers['x-forwarded-for']

    response.render 'homepage',
        title: config.title
        user: request.user

module.exports = router