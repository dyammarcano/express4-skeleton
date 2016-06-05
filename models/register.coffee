mongoose       = require 'mongoose'
Schema         = mongoose.Schema
LocalMongoose  = require 'passport-local-mongoose'
config         = require '../config/config'

##############################################################################################
# Conect to MongoDB .
##############################################################################################

mongoose.connect config.db_name

##############################################################################################
# Declare Schema.
##############################################################################################

Account = new Schema(
    role      : String
    parent    : String
    email     : 
        type: String
        unique: true
        required: true
    username  : String
    username2 : String
    surname1  : String
    surname2  : String
    password  : 
        type: String
        required: true
    created   : 
        type: Date
        default: Date.now)

Account.plugin LocalMongoose

module.exports = mongoose.model 'Account', Account