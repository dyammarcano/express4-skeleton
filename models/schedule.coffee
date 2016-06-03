mongoose       = require 'mongoose'
Schema         = mongoose.Schema
config         = require '../config/config'

mongoose.connect config.db_name

Schedule = new Schema(
    role      : String)

module.exports = mongoose.model 'Schedule', Schedule