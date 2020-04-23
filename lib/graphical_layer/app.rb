require 'bundler'
require 'pp'
require 'matrix'

# Bundler.require

$:.unshift File.expand_path("./../lib/app", __FILE__)

x = Matrix[[" "," "," "],
           [" "," "," "],
           [" "," "," "]]




def display_board(board)
    separator = "|"
    lines = "-----------"
    
    puts " #{board[0,0]} #{separator} #{board[0,1]} #{separator} #{board[0,2]} "
    puts "#{lines}"
    puts " #{board[1,0]} #{separator} #{board[1,1]} #{separator} #{board[1,2]} "
    puts "#{lines}"
    puts " #{board[2,0]} #{separator} #{board[2,1]} #{separator} #{board[2,2]} "
    end


display_board(x)
system("display image.png")


Text.new(  'Hello',  x: 150, y: 470,  font: 'vera.ttf',  size: 20,  color: 'blue',  rotate: 90,  z: 10)


