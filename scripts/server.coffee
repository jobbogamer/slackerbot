# Description:
#   Routes for the built-in Express server.
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   None
#
# URLS:
#   /
#   /version
#   /help

module.exports = (robot) ->

    pageContent = (name, commands, sbVersion, hbVersion, nodeVersion) ->
        """
<!DOCTYPE html>
<html>
  <head>
  <meta charset="utf-8">
  <title>#{name}</title>
  <style type="text/css">
    body {
      background: #d3d6d9;
      color: #636c75;
      text-shadow: 0 1px 1px rgba(255, 255, 255, .5);
      font-family: Helvetica, Arial, sans-serif;
    }
    h1 {
      margin: 8px 0;
      padding: 0;
    }
    .commands {
      font-size: 13px;
    }
    p {
      border-bottom: 1px solid #eee;
      margin: 6px 0 0 0;
      padding-bottom: 5px;
    }
    p:last-child {
      border: 0;
    }
  </style>
  </head>
  <body>
    <h1>#{name}</h1>
    <div class="commands">
      #{commands}
    </div>
    <div class="verison">
      <p>Slackerbot #{sbVersion}</p>
      <p>Hubot #{hbVersion}</p>
      <p>NodeJS #{nodeVersion}</p>
    </div>
  </body>
</html>
        """

    # Put a simple page at the root of the server which provides the same
    # output as `help` but formatted more nicely. Also display the version
    # number of Slackerbot, hubot, and node.
    robot.router.get '/', (req, res) ->
        res.end 'Hello, world!'


    # Page to get the current version number of both slackerbot and the
    # underlying version of hubot.
    robot.router.get '/version', (req, res) ->
        pkg = require('../package.json')
        res.end "Slackerbot v#{pkg.version}" + '\n' +
                "Hubot v#{robot.version}" + '\n' +
                "NodeJS #{process.version}"


    # Nicely formatted version of the help command, available on the web.
    robot.router.get '/help', (req, res) ->
        cmds = robot.helpCommands().map (cmd) ->
            cmd.replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;')

        emit = "<p>#{cmds.join '</p><p>'}</p>"

        emit = emit.replace /hubot/ig, "<b>#{robot.name}</b>"

        pkg = require('../package.json')
        slackerbotVersion = pkg.version

        res.setHeader 'content-type', 'text/html'
        res.end pageContent robot.name, emit, "v#{slackerbotVersion}", "v#{robot.version}", process.version
