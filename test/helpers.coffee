# Stuff to use in tests, like common mocks.

mockery = require('mockery')


module.exports = {
    useMock: (module, mock) ->
        mockery.deregisterAll()
        mockery.resetCache()
        mockery.registerMock(module, mock)
}
