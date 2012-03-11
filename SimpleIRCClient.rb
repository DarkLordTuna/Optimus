require 'socket'
require_relative 'EchoHandler.rb'
require_relative 'QuitHandler.rb'
require_relative 'KickHandler.rb'
require_relative 'OPHandler.rb'

class SimpleIRCClient

  attr_accessor :host, :port

  def initialize(host, port, channel)
    @host = host
    @port = port
    @channel = channel
    @name ="Optimus_Prime"
    add_commands
  end

  def add_commands
    @commands = {}
    @commands["echo"] = EchoHandler.new
    @commands["quit"] = QuitHandler.new
    @commands["kick"] = KickHandler.new
    @commands["op"] = OPHandler.new
  end

  def run
    connect
    listen
    @listener.join
  end

  def connect
    @tcp_connection = TCPSocket.open(host, port)
    sleep(2)
    login
    sleep(2)
    join_channel
  end

  def login
    @tcp_connection.puts "NICK #{@name}"
    @tcp_connection.puts "USER paulie 8 * : Paul Buttz"
  end

  def join_channel
    @tcp_connection.puts "JOIN #{@channel}"
  end

  def quit(reason)
    say("Sam! Push the Cube into my chest, NOW!")
    @tcp_connection.puts "QUIT :#{reason}"
    disconnect
  end

  def disconnect
    @tcp_connection.close
  end

  def listen
    @listener = Thread.new do
      while(!@tcp_connection.closed?)
        begin
          message = @tcp_connection.gets
          puts message
          results = parse_message(message)
          if(!results.nil? && results[2][0] == "!")
            dispatch(results[2])
          end
        rescue IOError
          break
        end
      end
    end
    @listener.run
  end

  def parse_message(message)
    regex = /:(\S+)!(.*) PRIVMSG (\S+)\s*:(.*)/
    results = regex.match(message)
    return nil if results.nil?
    return [results[2], results[3], results[4]]
  end
  
  def dispatch(message)
   regex = /!(\S+)\s+(.*)/
   results = regex.match(message)
   puts results[0] if !results.nil?
   @commands[results[1]].handle(self, results[2]) if @commands.has_key?(results[1])
  end

  def say(message)
    @tcp_connection.puts "PRIVMSG #{@channel} :#{message}"
  end

  def whisper(user, message)
    @tcp_connection.puts "PRIVMSG #{user} :#{message}"
  end

  def write(message)
    @tcp_connection.puts message
  end

  def kick(user)
    @tcp_connection.puts "KICK #{@channel} #{user}"
  end
  
  def op(user)
    @tcp_connection.puts "MODE #{@channel} +o #{user}"
  end

end
blah = SimpleIRCClient.new("irc.synirc.net", 6667, "#lasercats")
blah.run
