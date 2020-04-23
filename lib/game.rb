class Game
  attr_accessor :case_played ,:board, :user, :count_O_victory, :count_X_victory, :count_ex_aequo_victory 
  #TO DO : la classe a plusieurs attr_accessor: le current_player (égal à un objet Player), le status (en cours, nul ou un objet Player s'il gagne), le Board et un array contenant les 2 joueurs.
  @@count_O_victory=0
  @@count_X_victory=0
  @@count_ex_victory=0
  def initialize
    system("clear")
    @user=[]
    #TO DO : créé 2 joueurs, créé un board, met le status à "on going", défini un current_player
    puts "entrer le nom du joueur 1"
    print ">"
    user1 = Player.new(gets.chomp)
    @user << user1.name
    puts "entrer le nom du joueur 2"
    print ">"
    user2 = Player.new(gets.chomp)
    @user << user2.name

    return user
    
  end

  def turn(game)
    tab_sign=[]
    board=Board.new
    @board=board
    # pp "board = #{@board.sign}"


    # @board.board.each do |element|
    #   pp element.sign
    #   tab_sign << element.sign
    # end
    system("clear")
    show=Show.new
    show.show_board(@board.sign)
    #TO DO : méthode faisant appelle aux méthodes des autres classes (notamment à l'instance de Board). Elle affiche le plateau, demande au joueur ce qu'il joue, vérifie si un joueur a gagné, passe au joueur suivant si la partie n'est pas finie.

    while game.board.victory=="0"
      game.board.play_turn(game.user)
    end
    if game.board.victory.to_s.include?("O")
      @@count_O_victory+=1
    elsif game.board.victory.to_s.include?("X")
      @@count_X_victory+=1
    elsif game.board.victory.to_s.include?("ex-aequo")
      @@count_ex_victory+=1
    end

    puts "#{user[0]} with X won #{@@count_X_victory} times"
    puts "#{user[1]} with O won #{@@count_O_victory} times"
    puts "ex-aequo #{@@count_ex_victory} times"
    puts 

  end
end