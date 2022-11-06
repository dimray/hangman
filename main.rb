require "json"

class Hangman

  def initialize(name, secret_word = "", lives="", letters_guessed="", display="")

    @name = name

    if secret_word == ""
      dict = File.open("google-10000-english-no-swears.txt")
      dict_array = []
      while !dict.eof?
        line = dict.readline
        if line.length >= 6 && line.length <= 12
          dict_array.push(line)
        end
      end
      dict.close
      @secret_word = dict_array.sample.delete("\n")
      @lives = 7
      @letters_guessed = []
      @display = @secret_word.split("").map {|letter| letter = "_"}
    else
      @secret_word = secret_word
      @lives = lives
      @letters_guessed = letters_guessed
      @display = display

    end

    check_guess
  end

  def check_guess

    while @lives > 0 && @display.join('') != @secret_word
      puts "Guess a letter or type 'save' to save game."      
      puts "You have #{@lives} lives remaining."
      puts @display.join(' ')
      if @letters_guessed.length > 0
        puts "Previous guesses: #{@letters_guessed}"
      end
      guess = gets.chomp.downcase
      if guess == "save"
        save_game
        break
      elsif @secret_word.include?(guess)
        for i in 0..@secret_word.length-1
          if @secret_word[i] == guess
            @display[i] = guess
          end
        end 
      else 
        if @letters_guessed.include?(guess)
          puts "You have already guessed '#{guess}'. Try a different letter."
        elsif guess =~/[^a-z]/ || guess.length > 1
          puts "Try again, your guess must be a letter."
        else
          puts "'#{guess}' is not in the word."
          @lives -= 1
          @letters_guessed.push(guess)
        end
      end      
    end 

    if @lives == 0
      puts "You died. The word was #{@secret_word}."
      puts "Press enter to play again, or type 'exit' to end"
      play_again = gets.chomp
      initialize(@name) if play_again == ""
    end

    if @display.join('') == @secret_word
      puts "You got it! The word was #{@secret_word}."
      puts "Press enter to play again, or type 'exit' to end"
      play_again = gets.chomp
      initialize(@name) if play_again == ""
    end
  end

  def save_game 
    filename = @name + ".json"
    
    @name= {   
    "secret_word" => @secret_word,
    "lives" => @lives,
    "letters_guessed" => @letters_guessed,
    "display" => @display,    
    }
    File.open(filename, "w") do |f|
      f.write(@name.to_json)
    end  
    puts "Game saved.\nTo load a game, input the name of the game. Press enter to exit"
    puts "Your saved games are:"
    puts Dir["*.json"]
    name_of_game = gets.chomp.downcase

    load_game (name_of_game)  
  end
end


def load_game(name="")
  filename = name
  saved_games = Dir.entries(".")
  if saved_games.index(filename) 
    file = File.read(filename)
    data_hash = JSON.parse(file)
    name = name[0...-5]
    p name
    game = Hangman.new(name, data_hash["secret_word"], data_hash["lives"], data_hash["letters_guessed"], data_hash["display"])
  else
    puts "Game ended."
    exit
  end    
end

puts "Type the name of a previous game to load it, or press Enter to start a new game"
puts "Your saved games are:"
puts Dir["*.json"]
game_name = gets.chomp

saved_games = Dir.entries(".")

if saved_games.index(game_name)  
  load_game(saved_games[saved_games.index(game_name)])
else
  game = Hangman.new("game"+ (Dir['*.json'].count + 1).to_s)
end









