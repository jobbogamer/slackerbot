Helper = require('hubot-test-helper')
expect = require('chai').expect
mockery = require('mockery')
testHelpers = require('./helpers')

module = '../scripts/whats-new.coffee'
mockedModule = 'github'
room = null

# Mock that always returns a valid release with the current version number as
# the tag name.
githubMockWorks = (options) ->
    return {
        releases: {
            listReleases: (options, callback) ->
                version = require('../package.json').version
                releases = [
                    {
                        id: 123,
                        tag_name: "v#{version}",
                        body: "These are some release notes!"
                    }
                ]

                callback null, releases
        }
    }


# Mock that always returns an error.
githubMockErrors = (options) ->
    return {
        releases: {
            listReleases: (options, callback) ->
                callback {error: "An error occurred."}
        }
    }


# Mock that always returns a valid release where the tag name does not match
# the current version number.
githubMockWrongVersion = (options) ->
    return {
        releases: {
            listReleases: (options, callback) ->
                version = require('../package.json').version
                releases = [
                    {
                        id: 123,
                        tag_name: "v#{version}xyz",
                        body: "These are some release notes!"
                    }
                ]

                callback null, releases
        }
    }


# Mock that returns a list of releases but with the property names changed, as
# if the API changed.
githubMockAPIChanged = (options) ->
    return {
        releases: {
            listReleases: (options, callback) ->
                version = require('../package.json').version
                releases = [
                    {
                        id: 123,
                        tag: "v#{version}",
                        description: "These are some release notes!"
                    }
                ]

                callback null, releases
        }
    }


describe 'whats-new.coffee', ->
    # Using a mock makes this test slower (~100ms) so redefine "slow" in mocha.js.
    this.slow 1000

    before ->
        mockery.enable {
            useCleanCache: true,
            warnOnUnregistered: false
        }

    after ->
        mockery.disable()

    afterEach ->
        room.destroy()


    context 'when someone asks what\'s new', ->
        it 'should reply with release notes', ->
            testHelpers.useMock mockedModule, githubMockWorks
            helper = new Helper(module)
            room = helper.createRoom()

            room.user.say('alice', 'hubot what\'s new').then =>
                # Expect hubot to reply with the contents of the release from
                # the working mock.
                expect(room.messages).to.eql [
                    ['alice', 'hubot what\'s new'],
                    ['hubot', 'These are some release notes!']
                ]


        it 'should handle errors gracefully', ->
            testHelpers.useMock mockedModule, githubMockErrors
            helper = new Helper(module)
            room = helper.createRoom()

            room.user.say('alice', 'hubot what\'s new').then =>
                # Expect hubot to reply with an error message.
                expect(room.messages).to.eql [
                    ['alice', 'hubot what\'s new'],
                    ['hubot', 'I couldn\'t fetch the latest release notes.']
                ]


        it 'should handle none of the releases matching the version number', ->
            testHelpers.useMock mockedModule, githubMockWrongVersion
            helper = new Helper(module)
            room = helper.createRoom()

            room.user.say('alice', 'hubot what\'s new').then =>
                # Expect hubot to reply with an error message.
                expect(room.messages).to.eql [
                    ['alice', 'hubot what\'s new'],
                    ['hubot', 'I couldn\'t fetch the latest release notes.']
                ]


        it 'should fail gracefully if GitHub returns an object with different properties', ->
            testHelpers.useMock mockedModule, githubMockAPIChanged
            helper = new Helper(module)
            room = helper.createRoom()

            room.user.say('alice', 'hubot what\'s new').then =>
                # Expect hubot to reply with an error message.
                expect(room.messages).to.eql [
                    ['alice', 'hubot what\'s new'],
                    ['hubot', 'I couldn\'t fetch the latest release notes.']
                ]
