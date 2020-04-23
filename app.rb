require 'bundler'
require 'colorize'
system("sudo apt-get install xdotool")

# Bundler.require

$:.unshift File.expand_path("./../lib", __FILE__)

# require 'application'
require 'board'
require 'boardcase'
require 'game'
require 'player'
require 'show'
# require 'test'


class Application
  def perform

    # TO DO : méthode qui initialise le jeu puis contient des boucles while pour faire tourner le jeu tant que la partie n'est pas terminée.
    val="yes"
    game=Game.new
    while val != "no"
      system("xdotool key Ctrl+plus")
      system("xdotool key Ctrl+plus")
      system("xdotool key Ctrl+plus")
      system("xdotool key Ctrl+plus")
      system("xdotool key Ctrl+plus")
      system("xdotool key Ctrl+plus")
      system("xdotool key Ctrl+plus")
      game.turn(game)
      val=""
      puts "voulez vous continuer ? "
      system("xdotool key Ctrl+0")
      val=gets.chomp
      
    end
    

  end
end










Application.new.perform