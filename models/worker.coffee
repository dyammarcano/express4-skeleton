mongoose       = require 'mongoose'
Schema         = mongoose.Schema
config         = require '../config/config'

##############################################################################################
# Conect to MongoDB .
##############################################################################################

mongoose.connect config.db_name

##############################################################################################
# Declare Schema.
##############################################################################################

Worker = new Schema(
    role      : String
    parent    : String)

module.exports = mongoose.model 'worker', Worker