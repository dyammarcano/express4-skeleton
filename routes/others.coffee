express        = require 'express'
router         = express.Router()
config         = require '../config/config'

##############################################################################################
# Route GET 
##############################################################################################

router.get '/dashboard', (request, response) ->
    if request.isAuthenticated()
        response.render 'template.pug',
        title: config.title
        user: request.user
        return
    else
        response.redirect '/'
    return

##############################################################################################
# Route GET 
##############################################################################################

router.get '/hello/:name', (request, response, next) ->
    response.send request.params.name

##############################################################################################
# Route GET 
##############################################################################################

router.get '/v1/:name(article|article2|article3)?', (request, response, next) ->
    response.send request.params.name

module.exports = router