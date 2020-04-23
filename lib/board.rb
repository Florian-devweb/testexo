class Board
  
  attr_accessor :board ,:sign, :boardcase
  #TO DO : la classe a 1 attr_accessor : un array/hash qui contient les BoardCases.
  #Optionnellement on peut aussi lui rajouter un autre sous le nom @count_turn pour compter le nombre de coups joué
  @@count=1
  @@mouse = ""
  def initialize()
    @board=[]
    @boardcase=[]
    9.times do |i|
      @boardcase[i]=BoardCase.new(i)
      @board[i]=@boardcase[i].array
    end
    #TO DO :
    #Quand la classe s'initialize, elle doit créer 9 instances BoardCases
    #Ces instances sont rangées dans un array/hash qui est l'attr_accessor de la classe

    return @board

  end

  def sign
    @board.each do |element|
        element.to_s
        # tab_sign << element
      end
    # self.sign = @sign
  end



  def play_turn(user)



    
    if @@count%2 == 0
      puts "c'est le tour du #{user[0]}"
      @case_played=gets.chomp
      sign="X"
    else
      puts "c'est le tour du #{user[1]}"
      @case_played=gets.chomp
      sign="O"
    end
    @case_played=@case_played.split('')
    index_of_played_case=0
    correct=true
      case @case_played[0]
        when "A"
          index_of_played_case=0
        when "B"
          index_of_played_case+=3
        when "C"
          index_of_played_case+=6
        else 
        puts "NON CORRECT VALUE"
        correct=false
        # puts correct
      end

    if correct=true && @case_played[1].to_i <=3 && @case_played[1].to_i >=1 
      index_of_played_case+=(@case_played[1].to_i)-1
      if @boardcase[index_of_played_case].array ==" "
        @@count +=1
        @boardcase[index_of_played_case].update(index_of_played_case,sign)
        show=Show.new
        out=[]
        boardcase.each do |element|
          out << element.sign
        end
        system("clear")
        show.show_board(out)
        
        else 
        puts "case non vide"
      end

    end
  end


  def victory
    state="0"
    col=""
    3.times do |i|
      #LIGNES
      if ((@boardcase[0+(i*3)].array == "X" || @boardcase[0+(i*3)].array == "O") && @boardcase[0+(i*3)].array == @boardcase[1+(i*3)].array && @boardcase[0+(i*3)].array == @boardcase[2+(i*3)].array)
        state="victory of #{@boardcase[0+(i*3)].array} ligne : #{i+1}"
        break
      else 
        state="0"
      end

      #COLONNE
      if ((@boardcase[0+i].array == "X" || @boardcase[0+i].array == "O") && @boardcase[0+i].array == @boardcase[3+i].array && @boardcase[0+i].array == @boardcase[6+i].array)
        if i==0
          col="A"
        elsif i ==1
          col="B"
        elsif i ==2
          col="C"
        end

        state="victory of #{@boardcase[0+1].array} colonne : #{col}"
        break
      else 
        state="0"
      end

      if ((@boardcase[0].array == "X" || @boardcase[0].array == "O") && @boardcase[0].array == @boardcase[4].array && @boardcase[0].array == @boardcase[8].array)
        state="victory of #{@boardcase[0].array} diagonale 0 4 8"
        break
      else 
        state="0"
      end

      if ((@boardcase[6].array == "X" || @boardcase[6].array == "O") && @boardcase[6].array == @boardcase[4].array && @boardcase[6].array == @boardcase[2].array)
        state="victory of #{@boardcase[6].array} diagonale 6 4 2"
        break
      else 
        state="0"
      end
      remaining_played_times=0
      @boardcase.each do |element|
        remaining_played_times+=element.array.count(" ")
      end
      if remaining_played_times==0
        state="ex-aequo"
        break
      end
    end
    return state
  end
end


