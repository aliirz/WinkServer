require 'sinatra'
require 'sinatra-websocket'

set :server, 'thin'
set :sockets, []

get '/' do
  if !request.websocket?
    erb :index
  else
    request.websocket do |ws|
      ws.onopen do
        ws.send("Hello World!")
        settings.sockets << ws
      end
      ws.onmessage do |msg|
        EM.next_tick { settings.sockets.each{|s| s.send(msg) } }
      end
      ws.onclose do
        warn("websocket closed")
        settings.sockets.delete(ws)
      end
    end
  end
end



# require "em-websocket"
#
# EventMachine.run do
#   @channel = EM::Channel.new
#
#   EventMachine::WebSocket.start(host: "0.0.0.0", port: 8080, debug: true) do |ws|
#     ws.onopen do
#       sid = @channel.subscribe { |msg| ws.send(msg) }
#       @channel.push("#{sid} connected")
#
#       ws.onmessage { |msg| @channel.push("<#{sid}> #{msg}") }
#
#       ws.onclose { @channel.unsubscribe(sid) }
#     end
#   end
# end
