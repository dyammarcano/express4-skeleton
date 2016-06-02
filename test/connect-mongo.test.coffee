getMongooseConnection = ->
    mongoose.createConnection connectionString

getDbPromise = ->
    new Promise((resolve, reject) ->
        mongo.MongoClient.connect connectionString, (err, db) ->
            if err
                return reject(err)
            resolve db
            return
        return
)

getNativeDbConnection = (options, done) ->
    if !done
        done = options
        options = {}
    mongo.MongoClient.connect connectionString, (err, db) ->
        if err
            return done(err)
        open_db _.assign(options, db: db), done
        return
    return

'use strict'

### jshint camelcase: false ###

###*
# Module dependencies.
###

expressSession = require 'express-session'
MongoStore     = require('connect-mongo')(expressSession)
assert         = require 'assert'
_              = require 'lodash'
mongo          = require 'mongodb'
mongoose       = require 'mongoose'

connectionString = 'mongodb://localhost/connect-mongo-test'

# Create a connect cookie instance
make_cookie = ->
    cookie = new (expressSession.Cookie)
    cookie.maxAge = 10000
    # This sets cookie.expire through a setter
    cookie.secure = true
    cookie.domain = 'cow.com'
    cookie

# Create session data
make_data = ->
    {
        foo: 'bar'
        baz:
            cow: 'moo'
            chicken: 'cluck'
        num: 1
        cookie: make_cookie()
    }

make_data_no_cookie = ->
    {
        foo: 'bar'
        baz:
            cow: 'moo'
            fish: 'blub'
            fox: 'nobody knows!'
        num: 2
    }

# Given a session id, input data, and session, make sure the stored data matches in the input data
assert_session_equals = (sid, data, session) ->
    if typeof session.session == 'string'
        # Compare stringified JSON
        assert.strictEqual session.session, JSON.stringify(data)
    else
        # Cannot do a deepEqual for the whole session as we need the toJSON() version of the cookie
        # Make sure the session data in intact
        for prop of session.session
            if prop == 'cookie'
                # Make sure the cookie is intact
                assert.deepEqual session.session.cookie, data.cookie.toJSON()
            else
                assert.deepEqual session.session[prop], data[prop]
    # Make sure the ID matches
    assert.strictEqual session._id, sid
    return

open_db = (options, callback) ->
    store = new MongoStore(options)
    store.once 'connected', ->
        callback this, @db, @collection
        return
    return

cleanup_store = (store) ->
    store.db.close()
    return

cleanup = (store, db, collection, callback) ->
    collection.drop ->
        db.close()
        cleanup_store store
        callback()
        return
    return

exports.test_set = (done) ->
    getNativeDbConnection (store, db, collection) ->
        sid = 'test_set-sid'
        data = make_data()
        store.set sid, data, (err) ->
            assert.equal err, null
            # Verify it was saved
            collection.findOne { _id: sid }, (err, session) ->
                assert_session_equals sid, data, session
                cleanup store, db, collection, ->
                    done()
                    return
                return
            return
        return
    return

exports.test_set_no_stringify = (done) ->
    getNativeDbConnection { stringify: false }, (store, db, collection) ->
        sid = 'test_set-sid'
        data = make_data()
        store.set sid, data, (err) ->
            assert.equal err, null
            # Verify it was saved
            collection.findOne { _id: sid }, (err, session) ->
                assert_session_equals sid, data, session
                cleanup store, db, collection, ->
                    done()
                    return
                return
            return
        return
    return

exports.test_session_cookie_overwrite_no_stringify = (done) ->
    origSession = make_data()
    cookie = origSession.cookie
    getNativeDbConnection { stringify: false }, (store, db, collection) ->
        sid = 'test_set-sid'
        store.set sid, origSession, (err) ->
            assert.equal err, null
            collection.findOne { _id: sid }, (err, session) ->
                # Make sure cookie came out intact
                assert.strictEqual origSession.cookie, cookie
                # Make sure the fields made it back intact
                assert.equal cookie.expires.toJSON(), session.session.cookie.expires.toJSON()
                assert.equal cookie.secure, session.session.cookie.secure
                cleanup store, db, collection, ->
                    done()
                    return
                return
            return
        return
    return

exports.test_set_expires = (done) ->
    getNativeDbConnection (store, db, collection) ->
        sid = 'test_set_expires-sid'
        data = make_data()
        store.set sid, data, (err) ->
            assert.equal err, null
            # Verify it was saved
            collection.findOne { _id: sid }, (err, session) ->
                assert_session_equals sid, data, session
                cleanup store, db, collection, ->
                    done()
                    return
                return
            return
        return
    return

exports.test_set_expires_no_stringify = (done) ->
    getNativeDbConnection { stringify: false }, (store, db, collection) ->
        sid = 'test_set_expires-sid'
        data = make_data()
        store.set sid, data, (err) ->
            assert.equal err, null
            # Verify it was saved
            collection.findOne { _id: sid }, (err, session) ->
                assert_session_equals sid, data, session
                cleanup store, db, collection, ->
                    done()
                    return
                return
            return
        return
    return

exports.test_get = (done) ->
    getNativeDbConnection (store, db, collection) ->
        sid = 'test_get-sid'
        collection.insert {
            _id: sid
            session: JSON.stringify(
                key1: 1
                key2: 'two')
        }, ->
            store.get sid, (err, session) ->
                assert.deepEqual session,
                    key1: 1
                    key2: 'two'
                cleanup store, db, collection, ->
                    done()
                    return
                return
            return
        return
    return

exports.test_length = (done) ->
    getNativeDbConnection (store, db, collection) ->
        sid = 'test_length-sid'
        collection.insert {
            _id: sid
            session: JSON.stringify(
                key1: 1
                key2: 'two')
        }, ->
            store.length (err, length) ->
                assert.equal err, null
                assert.strictEqual length, 1
                cleanup store, db, collection, ->
                    done()
                    return
                return
            return
        return
    return

exports.test_destroy_ok = (done) ->
    getNativeDbConnection (store, db, collection) ->
        sid = 'test_destroy_ok-sid'
        collection.insert {
            _id: sid
            session: JSON.stringify(
                key1: 1
                key2: 'two')
        }, ->
            store.destroy sid, (err) ->
                assert.equal err, null
                cleanup store, db, collection, ->
                    done()
                    return
                return
            return
        return
    return

exports.test_clear = (done) ->
    getNativeDbConnection (store, db, collection) ->
        sid = 'test_length-sid'
        collection.insert {
            _id: sid
            key1: 1
            key2: 'two'
        }, ->
            store.clear ->
                collection.count (err, count) ->
                    assert.strictEqual count, 0
                    cleanup store, db, collection, ->
                        done()
                        return
                    return
                return
            return
        return
    return

exports.test_options_url = (done) ->
    store = new MongoStore(
        url: 'mongodb://localhost:27017/connect-mongo-test'
        collection: 'sessions-test')
    store.once 'connected', ->
        assert.strictEqual store.db.databaseName, 'connect-mongo-test'
        assert.strictEqual store.db.serverConfig.host, 'localhost'
        assert.equal store.db.serverConfig.port, 27017
        assert.equal store.collection.collectionName, 'sessions-test'
        cleanup_store store
        done()
        return
    return

exports.new_connection_failure = (done) ->
    originalException = process.listeners('uncaughtException').pop()
    process.removeListener 'uncaughtException', originalException
    new MongoStore(
        url: 'mongodb://localhost:27018/connect-mongo-test'
        collection: 'sessions-test')
    process.once 'uncaughtException', (err) ->
        process.listeners('uncaughtException').push originalException
        done()
        return
    return

exports.test_options_no_db = (done) ->
    assert.throws (->
        new MongoStore({})
        return
    ), Error
    done()
    return

### options.mongooseConnection tests ###

exports.test_set_with_mongoose_db = (done) ->
    open_db { mongooseConnection: getMongooseConnection() }, (store, db, collection) ->
        sid = 'test_set-sid'
        data = make_data()
        store.set sid, data, (err) ->
            assert.equal err, null
            # Verify it was saved
            collection.findOne { _id: sid }, (err, session) ->
                assert_session_equals sid, data, session
                cleanup store, db, collection, ->
                    done()
                    return
                return
            return
        return
    return

### options.dbPromise tests ###

exports.test_set_with_promise_db = (done) ->
    open_db { dbPromise: getDbPromise() }, (store, db, collection) ->
        sid = 'test_set-sid'
        data = make_data()
        store.set sid, data, (err) ->
            assert.equal err, null
            # Verify it was saved
            collection.findOne { _id: sid }, (err, session) ->
                assert_session_equals sid, data, session
                cleanup store, db, collection, ->
                    done()
                    return
                return
            return
        return
    return

### tests with existing mongodb native db object ###

exports.test_set_with_native_db = (done) ->
    getNativeDbConnection (store, db, collection) ->
        sid = 'test_set-sid'
        data = make_data()
        store.set sid, data, (err) ->
            assert.equal err, null
            # Verify it was saved
            collection.findOne { _id: sid }, (err, session) ->
                assert_session_equals sid, data, session
                cleanup store, db, collection, ->
                    done()
                    return
                return
            return
        return
    return

exports.test_set_default_expiration = (done) ->
    defaultTTL = 10
    getNativeDbConnection { ttl: defaultTTL }, (store, db, collection) ->
        sid = 'test_set_expires-sid'
        data = make_data_no_cookie()
        timeBeforeSet = (new Date).valueOf()
        store.set sid, data, (err) ->
            assert.equal err, null
            # Verify it was saved
            collection.findOne { _id: sid }, (err, session) ->
                assert.deepEqual session.session, JSON.stringify(data)
                assert.strictEqual session._id, sid
                assert.notEqual session.expires, null
                timeAfterSet = (new Date).valueOf()
                assert.ok timeBeforeSet + defaultTTL * 1000 <= session.expires.valueOf()
                assert.ok session.expires.valueOf() <= timeAfterSet + defaultTTL * 1000
                cleanup store, db, collection, ->
                    done()
                    return
                return
            return
        return
    return

exports.test_set_without_default_expiration = (done) ->
    defaultExpirationTime = 1000 * 60 * 60 * 24 * 14
    getNativeDbConnection (store, db, collection) ->
        sid = 'test_set_expires-sid'
        data = make_data_no_cookie()
        timeBeforeSet = (new Date).valueOf()
        store.set sid, data, (err) ->
            assert.equal err, null
            # Verify it was saved
            collection.findOne { _id: sid }, (err, session) ->
                assert.deepEqual session.session, JSON.stringify(data)
                assert.strictEqual session._id, sid
                assert.notEqual session.expires, null
                timeAfterSet = (new Date).valueOf()
                assert.ok timeBeforeSet + defaultExpirationTime <= session.expires.valueOf()
                assert.ok session.expires.valueOf() <= timeAfterSet + defaultExpirationTime
                cleanup store, db, collection, ->
                    done()
                    return
                return
            return
        return
    return

exports.test_set_custom_serializer = (done) ->
    getNativeDbConnection { serialize: (obj) ->
        obj.ice = 'test-1'
        JSON.stringify obj
 }, (store, db, collection) ->
        sid = 'test_set_custom_serializer-sid'
        data = make_data()
        dataWithIce = JSON.parse(JSON.stringify(data))
        dataWithIce.ice = 'test-1'
        store.set sid, data, (err) ->
            assert.equal err, null
            collection.findOne { _id: sid }, (err, session) ->
                assert.deepEqual session.session, JSON.stringify(dataWithIce)
                assert.strictEqual session._id, sid
                cleanup store, db, collection, done
                return
            return
        return
    return

exports.test_get_custom_unserializer = (done) ->
    getNativeDbConnection { unserialize: (obj) ->
        obj.ice = 'test-2'
        obj
 }, (store, db, collection) ->
        sid = 'test_get_custom_unserializer-sid'
        data = make_data()
        store.set sid, data, (err) ->
            assert.equal err, null
            store.get sid, (err, session) ->
                data.ice = 'test-2'
                data.cookie = data.cookie.toJSON()
                assert.equal err, null
                assert.deepEqual session, data
                cleanup store, db, collection, done
                return
            return
        return
    return

exports.test_session_touch = (done) ->
    getNativeDbConnection (store, db, collection) ->
        sid = 'test_touch-sid'
        data = make_data()
        store.set sid, data, (err) ->
            assert.equal err, null
            # Verify it was saved
            collection.findOne { _id: sid }, (err, session) ->
                assert.equal err, null
                assert_session_equals sid, data, session
                # touch the session
                store.touch sid, session.session, (err) ->
                    assert.equal err, null
                    # find the touched session
                    collection.findOne { _id: sid }, (err, session2) ->
                        assert.equal err, null
                        # check if both expiry date are different
                        assert.ok session2.expires.getTime() > session.expires.getTime()
                        cleanup store, db, collection, ->
                            done()
                            return
                        return
                    return
                return
            return
        return
    return

exports.test_session_lazy_touch_sync = (done) ->
    getNativeDbConnection { touchAfter: 2 }, (store, db, collection) ->
        sid = 'test_lazy_touch-sid-sync'
        data = make_data()
        lastModifiedBeforeTouch = undefined
        lastModifiedAfterTouch = undefined
        store.set sid, data, (err) ->
            assert.equal err, null
            # Verify it was saved
            collection.findOne { _id: sid }, (err, session) ->
                assert.equal err, null
                lastModifiedBeforeTouch = session.lastModified.getTime()
                # touch the session
                store.touch sid, session, (err) ->
                    assert.equal err, null
                    collection.findOne { _id: sid }, (err, session2) ->
                        assert.equal err, null
                        lastModifiedAfterTouch = session2.lastModified.getTime()
                        assert.strictEqual lastModifiedBeforeTouch, lastModifiedAfterTouch
                        cleanup store, db, collection, ->
                            done()
                            return
                        return
                    return
                return
            return
        return
    return

exports.test_session_lazy_touch_async = (done) ->
    getNativeDbConnection { touchAfter: 2 }, (store, db, collection) ->
        sid = 'test_lazy_touch-sid'
        data = make_data()
        lastModifiedBeforeTouch = undefined
        lastModifiedAfterTouch = undefined
        store.set sid, data, (err) ->
            assert.equal err, null
            # Verify it was saved
            collection.findOne { _id: sid }, (err, session) ->
                assert.equal err, null
                lastModifiedBeforeTouch = session.lastModified.getTime()
                setTimeout (->
                    # touch the session
                    store.touch sid, session, (err) ->
                        assert.equal err, null
                        collection.findOne { _id: sid }, (err, session2) ->
                            assert.equal err, null
                            lastModifiedAfterTouch = session2.lastModified.getTime()
                            assert.ok lastModifiedAfterTouch > lastModifiedBeforeTouch
                            cleanup store, db, collection, ->
                                done()
                                return
                            return
                        return
                    return
                ), 3000
                return
            return
        return
    return