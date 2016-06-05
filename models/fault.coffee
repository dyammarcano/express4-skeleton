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

Fault = new Schema(
    role      : String)

module.exports = mongoose.model 'Fault', Fault