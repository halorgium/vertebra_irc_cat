require 'irc_cat'

module VertebraIrcCat
  module Actors
    class Bot < Vertebra::Actor
      def initialize(*args)
        super

        @server, @port, @nick, @pass = args.first
        @channels = []
      end

      def bot
        @bot ||= start_bot
      end

      bind_op "/irc/join", :irc_join
      desc "/irc/join", "Join a channel on IRC"
      def irc_join(operation, args)
        unless channel = args["channel"]
          raise "no channel!"
        end
        key = args["key"]

        channel_name = "##{channel.last}"
        puts "Joining #{channel_name}"
        bot.join_channel(channel_name, key)
        @channels << channel_name

        true
      end

      bind_op "/irc/push", :irc_push
      desc "/irc/push", "Send something on IRC"
      def irc_push(operation, args)
        unless message = args["message"]
          raise "no message!"
        end
        unless channel = args["channel"]
          raise "no channel!"
        end
        key = args["key"]
        channel_name = "##{channel.last}"
        unless @channels.include?(channel_name)
          irc_join(operation, "channel" => channel, "key" => key)
        end
        puts "Saying #{message.inspect} on #{channel_name}"
        bot.say(channel_name, message)
        true
      end

      def start_bot
        bot = IrcCat::Bot.new(@server, @port, @nick, @pass)
        Thread.new {
          begin
            bot.run
          rescue
            puts "irccat fail: #{Vertebra.exception($!)}"
          end
        }
        sleep 0.1 until bot.online?
        bot
      end
    end
  end
end
