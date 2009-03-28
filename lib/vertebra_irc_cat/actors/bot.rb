require 'irc_cat'

module VertebraIrcCat
  module Actors
    class Bot < Vertebra::Actor
      def initialize(*args)
        super
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

        puts "Joining #{channel}"
        bot.join_channel(channel, key)
        @channels << channel

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
        unless @channels.include?(channel)
          irc_join(operation, "channel" => channel, "key" => key)
        end
        puts "Saying #{message.inspect} on #{channel}"
        bot.say(channel, message)
        true
      end

      def start_bot
        bot = IrcCat::Bot.new("irc.freenode.net", "6667", "vertebra-#{$$}", nil)
        Thread.new {
          begin
            puts "I am #{$$}"
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
