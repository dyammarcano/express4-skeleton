mongoose       = require 'mongoose'
Schema         = mongoose.Schema
config         = require '../config/config'

mongoose.connect config.db_name

Vacation = new Schema(
    role      : String)

module.exports = mongoose.model 'Vacation', Vacation