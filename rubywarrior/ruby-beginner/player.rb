class Player
  def play_turn(warrior)
    @last_move  ||= nil
    @health     ||= warrior.health
    (@health, @last_move, action) = MyWarrior.new(warrior, @health, @last_move).call
    return action
  end

  private

  class MyWarrior
    RUN_HEALTH = 15
    ATK_HEALTH = 20
    DIRECTIONS = [:forward, :left, :right, :backward]
    INVERT_MOVE= {backward: :forward, right: :left, left: :right, forward: :backward}

    def initialize(payload, health, last_move)
      @debug      = true
      @warrior    = payload
      @health     = health
      @last_move  = last_move
    end

    def call
      @level = caller.count
      log((["="]*11).join('*'))
      log(__callee__)
      log("Health: #{health.to_s}")
      log("Warrior Health: #{warrior.health.to_s}")
      log("\n")

      if is_safe?
        if warrior.health < ATK_HEALTH
          log("in REST")
          return [warrior.health, nil, warrior.rest!]
        end
      end

      if is_wall?
        return pivot_me
      end

      if warrior.health < RUN_HEALTH
        unless clear_direction.nil?
          return run_away
        end
      end

      unless captive_direction.nil?
        return recover
      end

      unless enemy_direction.nil?
        return attack
      end

      unless shoot_direction.nil?
        return shoot
      end

      log("DEFAULT WALK FORWARD")
      return [warrior.health, nil, warrior.walk!]
    end

    private
    attr_reader :warrior, :health, :last_move

    def run_away
      log("RUN: #{clear_direction.to_s}")
      [warrior.health, INVERT_MOVE[clear_direction], warrior.walk!(clear_direction)]
    end

    def recover
      log("RECOVER: #{captive_direction.to_s}")
      [warrior.health, nil, warrior.rescue!(captive_direction)]
    end

    def pivot_me
      log("#{(__callee__).upcase}")
      [warrior.health, nil, warrior.pivot!(:right)]
    end

    def shoot
      log("#{(__callee__).upcase}: #{shoot_direction.to_s}")
      [warrior.health, shoot_direction, warrior.shoot!(shoot_direction)]
    end

    def attack
      log("ATTACK: #{enemy_direction.to_s}")
      [warrior.health, enemy_direction, warrior.attack!(enemy_direction)]
    end

    def is_wall?
      t = warrior.feel.wall?
      log("#{__callee__.upcase}: #{t.to_s}")
      t
    end

    def is_safe?
      t = (health <= warrior.health) && shoot_directions.count.zero?
      log("#{__callee__}: #{t.to_s}")
      t
    end

    def captive_direction
      @enemy ||= captive_directions.sample
    end

    def shoot_direction
      @shoot_dir ||= shoot_directions.sample
    end

    def enemy_direction
      @enemy ||= enemy_directions.sample
    end

    def clear_direction
      @safe ||= clear_directions.sample
    end

    def captive_directions
      dirs = DIRECTIONS.select{|d| warrior.feel(d).captive? }
      log("#{__callee__.upcase}: #{dirs.join(', ')}")
      dirs
    end

    def shoot_directions
      dirs = DIRECTIONS.select{|d| warrior.look(d).count(&:enemy?) > 0 }
      log("#{__callee__.upcase}: #{dirs.join(', ')}")
      dirs
    end

    def enemy_directions
      dirs = DIRECTIONS.select{|d| warrior.feel(d).enemy? }
      log("#{__callee__.upcase}: #{dirs.join(', ')}")
      dirs
    end

    def clear_directions
      dirs = DIRECTIONS.reject{|u| u == last_move}.select{|d| warrior.feel(d).empty? }
      log("#{__callee__.upcase}: #{dirs.join(', ')}")
      dirs
    end

    def log(msg)
      return unless @debug
      tabs = "  "*(caller.count - @level)
      puts "%s %s"%[tabs, msg.to_s]
    end
  end
end
