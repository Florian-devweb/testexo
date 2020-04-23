class BoardCase
  #TO DO : la classe a 2 attr_accessor, sa valeur en string (X, O, ou vide), ainsi que son identifiant de case

  attr_accessor :position, :sign

  def initialize(position)
    #TO DO : doit régler son nom et sa valeur
    @sign = " "
    @position = position
  end

  def array
    self.sign = @sign
  end

  def update(position, sign)
    self.sign = sign
    self.position = position
    # @sign = sign
    # @position = position
  end

end