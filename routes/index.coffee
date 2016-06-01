express = require 'express'
router = express.Router()

# GET home page.
router.get '/', (req, res, next) ->
    res.render 'homepage',
        title: 'New Express App'

module.exports = router