require 'jumpstart_auth'
require 'klout'
class TwitterClient
	attr_reader :client

	def initialize 
		puts "Initialising TwitterClien"
		@client = JumpstartAuth.twitter 
		@screen_names_follwers = @client.followers.collect {|follower| @client.user(follower).screen_name}
		@screen_names_friends = @client.following.collect {|friend| friend.screen_name}
		return nil
	end

	def tweet(msg)
		if valid_msg? msg
			@client.update(msg)
			puts "Tweeted!"
		else
			puts "Msg too long"
		end
	end

	def valid_msg? msg
		if msg.length > 140 
			false
		else
			true
		end
	end

	def dm(t,msg)
		if @screen_names_follwers.include? t
			message = "d @#{t} #{msg}"
			self.tweet(message)
		else
			puts "No such follower to dm.."
		end
	end

	def spam_followers msg
		@screen_names_follwers.each do |t|
			10.times do 
				dm(t,msg)
			end
		end
	end

	def everyones_last_tweet
		@client.following.each do |friend|
			timestamp = friend.status.created_at
			puts "#{friend.screen_name} (#{timestamp.strftime("%A, %b %d")}) said: #{friend.status.text}"
			puts ''
		end
		nil
	end

	def klout_score
		Klout.api_key = 'xu9ztgnacmjx3bu82warbr3h'
		klout_scores = Hash.new(0)
		@screen_names_friends.each do |name|
			identity = Klout::Identity.find_by_screen_name(name)
			user = Klout::User.new(identity.id)
			klout_scores[name] = user.score.score
		end
		klout_scores.sort_by {|name,score| score}.each do |name,score|
			puts "#{name}: #{score}"
		end
		nil 
	end

	def print_help
		puts "brackets highlight the command.."
		puts "Send a tweet: (t) your tweet here"
		puts "quit command line: (q)"
		puts "dm a target: (dm) target message"
		puts "spam your followers, default 10 times: (spam) your spam message"
		puts "get your follwings last tweet: (elt)"
		puts "find how socially activing your followings are with klout score, higher the number more socially acitive: (score)"
	end

	def run 
		puts "Welcome to twitter client, type 'help' for commands"
		command = ''
		while command != 'q'
			print "Enter command: "
			input = gets.chomp 
			parts = input.split
			command = parts.first
			case command
			when 'q' then puts 'quitting...'
			when 't' then self.tweet(parts[1..-1].join(' '))
			when 'dm' then self.dm(parts[1],parts[2..-1].join(' '))
			when 'spam' then self.spam_followers(parts[1..-1].join(' '))
			when 'elt' then everyones_last_tweet
			when 'score' then klout_score
			when 'help' then print_help
			else puts "Sorry don't know how to #{command}"
			end
		end
	end

end

TwitterClient.new.run 