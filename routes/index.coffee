express = require 'express'
router = express.Router()

# GET home page.
router.get '/', (req, res, next) ->
    res.render 'homepage',
        title: 'New Express App'

router.get '/template', (req, res, next) ->
    res.render 'template'

module.exports = router