mongoose = require('mongoose')
Schema = mongoose.Schema
passportLocalMongoose = require('passport-local-mongoose')
mongoose.connect 'mongodb://localhost/app001-test'
Account = new Schema(
    username: String
    password: String)
Account.plugin passportLocalMongoose
module.exports = mongoose.model('Account', Account)