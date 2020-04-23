class Show

  def show_board(board)
    @board=board
    #TO DO : affiche sur le terminal l'objet de classe Board en entrée. S'active avec un Show.new.show_board(instance_de_Board)
    @board.each_with_index do |element,i|
      if element == "X"
        @board[i]="X".colorize(:red)
      end
    end
    @board.each_with_index do |element,i|
      if element == "O"
        @board[i]="O".colorize(:blue)
      end
    end

    sep="|".colorize(:green)
    ligne="-----------".colorize(:green)

    puts " #{@board[0]} #{sep} #{@board[1]} #{sep} #{@board[2]} "
    puts ligne
    puts " #{@board[3]} #{sep} #{@board[4]} #{sep} #{@board[5]} "
    puts ligne
    puts " #{@board[6]} #{sep} #{@board[7]} #{sep} #{@board[8]} "
  end

end