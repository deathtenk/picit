require 'sinatra'
require 'sinatra-websocket'
require 'thin'
require 'pry'

set :server, 'thin'
set :sockets, []

get '/' do
  if !request.websocket?
    erb :index
  else
    request.websocket do |ws|
      ws.onopen do
        ws.signature = random_identifier
        settings.sockets << ws
        EM.next_tick{settings.sockets.each{|s| s.send("user #{ws.signature} has connected")}}
      end
      ws.onmessage do |msg|
        EM.next_tick { settings.sockets.each{|s| s.send("#{ws.signature}: #{msg}") } }
      end
      ws.onclose do
        warn("websocket closed")
        settings.sockets.delete(ws)
      end
    end
  end
end



def random_identifier
  Array.new(16){[*'0'..'9', *'a'..'z', *'A'..'Z'].sample}.join
end