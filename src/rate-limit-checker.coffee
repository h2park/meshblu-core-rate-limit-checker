class RateLimitChecker
  constructor: (options={}) ->
    {@client, @Date, @msgRateLimit} = options
    throw new Error "RateLimitChecker requires client" unless @client?
    @Date ?= Date
    @msgRateLimit ?= 20*60 # messages per minute

  isLimited: ({uuid}, callback) =>
    minuteKey = @getMinuteKey()
    @client.hget minuteKey, uuid, (error, msgRate) =>
      return error if error?
      msgRate = parseInt msgRate
      return callback null, msgRate >= @msgRateLimit

  getMinuteKey: ()=>
    time = @Date.now()
    @startMinute = Math.floor(time / (1000*60))
    return "message-rate:minute-#{@startMinute}"

module.exports = RateLimitChecker
