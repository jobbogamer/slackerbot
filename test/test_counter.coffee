Helper = require('hubot-test-helper')
expect = require('chai').expect
mockery = require('mockery')

# Create a helper using the counters module.
helper = new Helper('../scripts/counter.coffee')

describe 'counter.coffee', ->
    beforeEach ->
        @room = helper.createRoom()

    afterEach ->
        @room.destroy()

    
    context 'when someone calls set', ->
        beforeEach ->
            # Clear out the counters in memory.
            @room.robot.brain.set 'counters', {}


        it 'should create a counter when counters is null', ->
            # Delete the counters object in memory.
            @room.robot.brain.remove 'counters'

            @room.user.say('alice', 'hubot set nuggets to 5').then =>
                # Counters object should have been created in memory and should
                # contain the new counter.
                counters = @room.robot.brain.get 'counters'
                expect(counters).to.exist
                expect(counters).to.include.keys 'nuggets'
                expect(counters.nuggets).to.eql 5

                # Bot should reply with the value of the new counter.
                expect(@room.messages).to.eql [
                    ['alice', 'hubot set nuggets to 5'],
                    ['hubot', 'nuggets is now set to 5.']
                ]
        

        it 'should create a counter that doesn\'t exist', ->
            # Ask to set the value of a counter when memory is empty.
            @room.user.say('alice', 'hubot set nuggets to 5').then =>
                # Counter should have been created in memory.
                counters = @room.robot.brain.get 'counters'
                expect(counters).to.exist
                expect(counters).to.include.keys 'nuggets'
                expect(counters.nuggets).to.eql 5

                # Bot should reply with the value of the new counter.
                expect(@room.messages).to.eql [
                    ['alice', 'hubot set nuggets to 5'],
                    ['hubot', 'nuggets is now set to 5.']
                ]


        it 'should update an existing counter', ->
            # Set a value for the nuggets counter.
            @room.robot.brain.data.counters = {
                nuggets: 3
            }

            # Ask to set the value of the counter.
            @room.user.say('alice', 'hubot set nuggets to 5').then =>
                # Counter should have been overwritten.
                counters = @room.robot.brain.get 'counters'
                expect(counters).to.exist
                expect(counters).to.include.keys 'nuggets'
                expect(counters.nuggets).to.eql 5

                # Bot should reply with the new value of the counter.
                expect(@room.messages).to.eql [
                    ['alice', 'hubot set nuggets to 5'],
                    ['hubot', 'nuggets is now set to 5.']
                ]


        it 'should accept negative values', ->
            # Set a value for the nuggets counter.
            @room.robot.brain.data.counters = {
                nuggets: 3
            }

            # Ask to set the value of the counter.
            @room.user.say('alice', 'hubot set nuggets to -5').then =>
                # Counter should have been overwritten.
                counters = @room.robot.brain.get 'counters'
                expect(counters).to.exist
                expect(counters).to.include.keys 'nuggets'
                expect(counters.nuggets).to.eql -5

                # Bot should reply with the new value of the counter.
                expect(@room.messages).to.eql [
                    ['alice', 'hubot set nuggets to -5'],
                    ['hubot', 'nuggets is now set to -5.']
                ]


        it 'should accept decimal values', ->
            # Set a value for the nuggets counter.
            @room.robot.brain.data.counters = {
                nuggets: 3
            }

            # Ask to set the value of the counter.
            @room.user.say('alice', 'hubot set nuggets to 5.5').then =>
                # Counter should have been overwritten.
                counters = @room.robot.brain.get 'counters'
                expect(counters).to.exist
                expect(counters).to.include.keys 'nuggets'
                expect(counters.nuggets).to.eql 5.5

                # Bot should reply with the new value of the counter.
                expect(@room.messages).to.eql [
                    ['alice', 'hubot set nuggets to 5.5'],
                    ['hubot', 'nuggets is now set to 5.5.']
                ]
