Helper = require('hubot-test-helper')
expect = require('chai').expect
mockery = require('mockery')

# Create a helper using the calculator module.
helper = new Helper('../modules/hubot-calculator/src/calculator.coffee')

# Current conversion rate between hours and pounds.
hourConversionRate = 7.93

# Current conversion rate between pounds and nuggets.
convertToNuggets = (pounds) ->
    return Math.floor(pounds / 4.49) * 20


describe 'calculator.coffee', ->
    beforeEach ->
        @room = helper.createRoom()

    afterEach ->
        @room.destroy()


    context 'when someone calls convert from hours to pounds', ->
        it 'should successfully convert', ->
            @room.user.say('alice', 'hubot convert 8 hours to pounds').then =>
                # Calculate expected result, rounded to 2 decimal places.
                expectedResult = 8 * hourConversionRate
                expectedResult = expectedResult.toFixed(2)

                # Bot should reply with the result of the conversion.
                expect(@room.messages).to.eql [
                    ['alice', 'hubot convert 8 hours to pounds'],
                    ['hubot', "#{expectedResult}"]
                ]


        it 'should cope with decimal hours', ->
            @room.user.say('alice', 'hubot convert 8.5 hours to pounds').then =>
                # Calculate expected result, rounded to 2 decimal places.
                expectedResult = 8.5 * hourConversionRate
                expectedResult = expectedResult.toFixed(2)

                # Bot should reply with the result of the conversion.
                expect(@room.messages).to.eql [
                    ['alice', 'hubot convert 8.5 hours to pounds'],
                    ['hubot', "#{expectedResult}"]
                ]


    context 'when someone calls convert from hours to nuggets', ->
        it 'should successfully convert', ->
            @room.user.say('alice', 'hubot convert 8 hours to nuggets').then =>
                # Calculate expected result.
                expectedResult = convertToNuggets(8 * hourConversionRate)

                # Bot should reply with the result of the conversion.
                expect(@room.messages).to.eql [
                    ['alice', 'hubot convert 8 hours to nuggets'],
                    ['hubot', "#{expectedResult}"]
                ]


        it 'should cope with decimal hours', ->
            @room.user.say('alice', 'hubot convert 12.5 hours to nuggets').then =>
                # Calculate expected result.
                expectedResult = convertToNuggets(12.5 * hourConversionRate)

                # Bot should reply with the result of the conversion.
                expect(@room.messages).to.eql [
                    ['alice', 'hubot convert 12.5 hours to nuggets'],
                    ['hubot', "#{expectedResult}"]
                ]
