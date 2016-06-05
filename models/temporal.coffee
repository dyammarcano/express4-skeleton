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

Temporal = new Schema(
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

Temporal.plugin LocalMongoose

module.exports = mongoose.model 'Temporal', Temporal