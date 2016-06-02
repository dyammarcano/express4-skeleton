mongoose       = require 'mongoose'
Schema         = mongoose.Schema
LocalMongoose  = require 'passport-local-mongoose'
config         = require '../config/config'

mongoose.connect config.db_name
Account = new Schema(
    role     : Number
    email    : String
    username : String
    password : String)
Account.plugin LocalMongoose
module.exports = mongoose.model 'Account', Account