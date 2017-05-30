class Player
  def play_turn(warrior)
    if warrior.health < 10
      if warrior.feel.empty?
        warrior.rest!
      else
        warrior.attack!
      end
    else
      if warrior.feel.empty?
        warrior.walk!
      else
        warrior.attack!
      end
    end
  end
end
