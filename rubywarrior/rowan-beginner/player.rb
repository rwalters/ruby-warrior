class Player
  def play_turn(warrior)
    @health ||= warrior.health
    injured = (warrior.health < @health)
    @health = warrior.health

    if warrior.health == 20
      @rest = false
    else
      return warrior.rest!
    end

    if warrior.health < 10
      if warrior.feel.empty?
        if injured
	  warrior.walk!
	else
	  @rest = true
	  warrior.rest!
	end
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

