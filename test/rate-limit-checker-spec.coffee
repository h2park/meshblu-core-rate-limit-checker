_                = require 'lodash'
redis            = require 'fakeredis'
uuid             = require 'uuid'
RateLimitChecker = require '../'

describe 'RateLimitChecker', ->
  beforeEach ->
    @clientKey = uuid.v1()
    @client = redis.createClient @clientKey
    startTime = Date.now()
    FakeDate = now: -> return startTime
    @sut = new RateLimitChecker {@client, Date: FakeDate}
    @request =
      metadata:
        responseId: 'its-electric'
        auth:
          uuid: 'electric-eels'
        messageType: 'received'
        options: {}
      rawData: '{}'

  describe '->isLimited', ->
    context 'when under the limit', ->
      beforeEach (done) ->
        @sut.isLimited uuid: 'electric-eels', (error, @result) => done error

      it 'should yield false', ->
        expect(@result).to.be.false

    context 'when above the limit', ->
      beforeEach (done) ->
        @client.hset @sut.getMinuteKey(), 'electric-eels', @sut.msgRateLimit, done

      beforeEach (done) ->
        @sut.isLimited uuid: 'electric-eels', (error, @result) => done error

      it 'should yield true', ->
        expect(@result).to.be.true
