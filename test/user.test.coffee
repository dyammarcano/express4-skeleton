should         = require 'should'
mongoose       = require 'mongoose'
Account        = require '../models/account'
db = undefined

describe 'Account', ->
    before (done) ->
        db = mongoose.connect('mongodb://localhost/test')
        done()
        return
    after (done) ->
        mongoose.connection.close()
        done()
        return
    beforeEach (done) ->
        account = new Account(
            username: '12345'
            password: 'testy')
        account.save (error) ->
            if error
                console.log 'error' + error.message
            else
                console.log 'no error'
            done()
            return
        return
    it 'find a user by username', (done) ->
        Account.findOne { username: '12345' }, (err, account) ->
            account.username.should.eql '12345'
            console.log '     username: ', account.username
            done()
            return
        return
    afterEach (done) ->
        Account.remove {}, ->
            done()
            return
        return
    return
    