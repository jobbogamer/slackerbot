Helper = require('hubot-test-helper')
expect = require('chai').expect
mockery = require('mockery')

# Create a helper using the counters module.
helper = new Helper('../scripts/counter.coffee')

describe 'counter.coffee', ->
    beforeEach ->
        @room = helper.createRoom()
        @room.robot.brain.set 'counters', {}

    afterEach ->
        @room.destroy()

    
    context 'when someone calls set', ->
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
            @room.robot.brain.set 'counters', {
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
            @room.robot.brain.set 'counters', {
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
            @room.robot.brain.set 'counters', {
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


    context 'when someone calls get', ->
        it 'should show the value of a counter', ->
            # Set a value for the counter in memory.
            @room.robot.brain.set 'counters', {
                nuggets: 5
            }

            # Ask for the value of the counter.
            @room.user.say('alice', 'hubot get nuggets').then =>
                # Bot should reply with the value of the counter.
                expect(@room.messages).to.eql [
                    ['alice', 'hubot get nuggets'],
                    ['hubot', 'nuggets is currently set to 5.']
                ]


        it 'should not fail when counters is null', ->
            @room.robot.brain.remove 'counters'

            @room.user.say('alice', 'hubot get nuggets').then =>
                # Bot should reply with an error message.
                expect(@room.messages).to.eql [
                    ['alice', 'hubot get nuggets'],
                    ['hubot', 'nuggets is not defined.']
                ]


        it 'should not fail when the counter does not exist', ->
            # Ask for the value of a counter without creating one first.
            @room.user.say('alice', 'hubot get nuggets').then =>
                # Bot should reply with an error message.
                expect(@room.messages).to.eql [
                    ['alice', 'hubot get nuggets'],
                    ['hubot', 'nuggets is not defined.']
                ]


    context 'when someone calls add', ->
        it 'should add to an existing counter', ->
            # Set a value for the counter in memory.
            @room.robot.brain.set 'counters', {
                nuggets: 3
            }

            # Ask to add two to the value.
            @room.user.say('alice', 'hubot add 2 to nuggets').then =>
                # Counter should have been updated.
                counters = @room.robot.brain.get 'counters'
                expect(counters).to.exist
                expect(counters).to.include.keys 'nuggets'
                expect(counters.nuggets).to.eql 5

                # Bot should reply with the new value of the counter.
                expect(@room.messages).to.eql [
                    ['alice', 'hubot add 2 to nuggets'],
                    ['hubot', 'nuggets is now set to 5.']
                ]


        it 'should refuse to add a negative number', ->
            # Set a value for the counter in memory.
            @room.robot.brain.set 'counters', {
                nuggets: 7
            }

            # Ask to add two to the value.
            @room.user.say('alice', 'hubot add -2 to nuggets').then =>
                # Counter should not have changed.
                counters = @room.robot.brain.get 'counters'
                expect(counters).to.exist
                expect(counters).to.include.keys 'nuggets'
                expect(counters.nuggets).to.eql 7

                # Bot should reply with an error message.
                expect(@room.messages).to.eql [
                    ['alice', 'hubot add -2 to nuggets'],
                    ['hubot', 'I can\'t add a negative value to a counter. Use `hubot subtract 2 from nuggets` instead.']
                ]


        it 'should add a decimal value', ->
            # Set a value for the counter in memory.
            @room.robot.brain.set 'counters', {
                nuggets: 3.5
            }

            # Ask to add to the value.
            @room.user.say('alice', 'hubot add 1.5 to nuggets').then =>
                # Counter should have been updated.
                counters = @room.robot.brain.get 'counters'
                expect(counters).to.exist
                expect(counters).to.include.keys 'nuggets'
                expect(counters.nuggets).to.eql 5

                # Bot should reply with the new value of the counter.
                expect(@room.messages).to.eql [
                    ['alice', 'hubot add 1.5 to nuggets'],
                    ['hubot', 'nuggets is now set to 5.']
                ]


        it 'should show a message when a counter is not defined', ->
            # Ask to add two to the value.
            @room.user.say('alice', 'hubot add 2 to nuggets').then =>
                # Bot should reply with a message.
                expect(@room.messages).to.eql [
                    ['alice', 'hubot add 2 to nuggets'],
                    ['hubot', 'nuggets is not defined.']
                ]


        it 'should not fail when counters is null', ->
            @room.robot.brain.remove 'counters'

            # Ask to add two to the value.
            @room.user.say('alice', 'hubot add 2 to nuggets').then =>
                # Bot should reply with a message.
                expect(@room.messages).to.eql [
                    ['alice', 'hubot add 2 to nuggets'],
                    ['hubot', 'nuggets is not defined.']
                ]


    context 'when someone calls subtract', ->
        it 'should subtract from an existing counter', ->
            # Set a value for the counter in memory.
            @room.robot.brain.set 'counters', {
                nuggets: 7
            }

            # Ask to add two to the value.
            @room.user.say('alice', 'hubot subtract 2 from nuggets').then =>
                # Counter should have been updated.
                counters = @room.robot.brain.get 'counters'
                expect(counters).to.exist
                expect(counters).to.include.keys 'nuggets'
                expect(counters.nuggets).to.eql 5

                # Bot should reply with the new value of the counter.
                expect(@room.messages).to.eql [
                    ['alice', 'hubot subtract 2 from nuggets'],
                    ['hubot', 'nuggets is now set to 5.']
                ]


        it 'should refuse to subtract a negative number', ->
            # Set a value for the counter in memory.
            @room.robot.brain.set 'counters', {
                nuggets: 3
            }

            # Ask to add two to the value.
            @room.user.say('alice', 'hubot subtract -2 from nuggets').then =>
                # Counter should not have changed.
                counters = @room.robot.brain.get 'counters'
                expect(counters).to.exist
                expect(counters).to.include.keys 'nuggets'
                expect(counters.nuggets).to.eql 3

                # Bot should reply with an error message.
                expect(@room.messages).to.eql [
                    ['alice', 'hubot subtract -2 from nuggets'],
                    ['hubot', 'I can\'t subtract a negative value from a counter. Use `hubot add 2 to nuggets` instead.']
                ]


        it 'should subtract a decimal value', ->
            # Set a value for the counter in memory.
            @room.robot.brain.set 'counters', {
                nuggets: 6.5
            }

            # Ask to add to the value.
            @room.user.say('alice', 'hubot subtract 1.5 from nuggets').then =>
                # Counter should have been updated.
                counters = @room.robot.brain.get 'counters'
                expect(counters).to.exist
                expect(counters).to.include.keys 'nuggets'
                expect(counters.nuggets).to.eql 5

                # Bot should reply with the new value of the counter.
                expect(@room.messages).to.eql [
                    ['alice', 'hubot subtract 1.5 from nuggets'],
                    ['hubot', 'nuggets is now set to 5.']
                ]


        it 'should show a message when a counter is not defined', ->
            # Ask to add two to the value.
            @room.user.say('alice', 'hubot subtract 2 from nuggets').then =>
                # Bot should reply with a message.
                expect(@room.messages).to.eql [
                    ['alice', 'hubot subtract 2 from nuggets'],
                    ['hubot', 'nuggets is not defined.']
                ]


        it 'should not fail when counters is null', ->
            @room.robot.brain.remove 'counters'

            # Ask to add two to the value.
            @room.user.say('alice', 'hubot subtract 2 from nuggets').then =>
                # Bot should reply with a message.
                expect(@room.messages).to.eql [
                    ['alice', 'hubot subtract 2 from nuggets'],
                    ['hubot', 'nuggets is not defined.']
                ]
