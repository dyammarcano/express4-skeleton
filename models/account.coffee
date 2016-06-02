mongoose       = require 'mongoose'
Schema         = mongoose.Schema
LocalMongoose  = require 'passport-local-mongoose'
config         = require '../config/config'

mongoose.connect config.dbname
Account = new Schema(
    username: String
    password: String)
Account.plugin LocalMongoose
module.exports = mongoose.model('Account', Account)