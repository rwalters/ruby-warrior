class Player
  def play_turn(warrior)
    @last_move  ||= nil
    @health     ||= nil
    (@health, @last_move, action) = MyWarrior.new(warrior, @health, @last_move).call
    return action
  end

  private

  class MyWarrior
    def initialize(payload, health, last_move)
      configure
      @debug      = false
      @warrior    = payload
      @health     = health
      @last_move  = last_move
    end

    def configure(opts = {})
      @config ||= Hash.new([])
      @config[:run_health]  = opts.fetch(:run_health, 13)
      @config[:rest_health] = opts.fetch(:rest_health, 20)
      @config[:directions]  = [:forward, :left, :right, :backward]
      @config[:invert_move] = {backward: :forward, right: :left, left: :right, forward: :backward}
    end

    def call
      @level = caller.count
      log((["="]*11).join('*'))
      log(__callee__)
      log("Health: #{health.to_s}")
      log("Warrior Health: #{warrior.health.to_s}")
      log("\n")

      @health ||= health.to_i

      if is_safe? && warrior.health < config[:rest_health]
        return rest_here
      end

      if is_wall?
        return pivot_me
      end

      if warrior.health < config[:run_health]
        unless clear_direction.nil?
          return run_away
        end
      end

      if outnumbered?
        return bind_enemy
      end

      unless enemy_direction.nil?
        return attack
      end

      unless captive_direction.nil?
        return recover
      end

      return default_walk
    end
=begin
      if health.nil? && !all_clear?
        return think
      else
        @health = health.to_i
      end

      if is_safe? && warrior.health < config[:rest_health]
        return rest_here
      end

      if is_wall?
        return pivot_me
      end

      if warrior.health < config[:run_health]
        unless clear_direction.nil?
          return run_away
        end
      end

      unless enemy_direction.nil?
        return attack
      end

      unless shoot_direction.nil?
        return shoot
      end

      unless captive_direction.nil?
        return recover
      end

      return default_walk
    end
=end

    private
    attr_reader :warrior, :health, :last_move, :config

    def outnumbered?
      log("#{(__callee__).upcase}")
      enemy_directions.count > 1
    end

    def bind_enemy
      log("#{(__callee__).upcase}")
      [warrior.health, nil, warrior.bind!(enemy_direction)]
    end

    def stairs_direction
      warrior.direction_of_stairs
    end

    def all_clear?
      t = shoot_directions.count.zero?
      log("#{__callee__.upcase}: '#{t.to_s}'")
      t
    end

    def think
      log("#{(__callee__).upcase}")
      if shoot_direction.nil?
        pivot_me
      else
        shoot
      end
    end

    def rest_here
      log("#{(__callee__).upcase}")
      [warrior.health, nil, warrior.rest!]
    end

    def default_walk
      log("#{(__callee__).upcase}")

      if stairs_direction.nil?
        if is_wall?
          pivot_me
        else
          [warrior.health, nil, warrior.walk!]
        end
      else
        [warrior.health, nil, warrior.walk!(stairs_direction)]
      end
    end

    def run_away
      log("#{(__callee__).upcase}: #{clear_direction.to_s}")
      [warrior.health, config[:invert_move][clear_direction], warrior.walk!(clear_direction)]
    end

    def recover
      log("#{(__callee__).upcase}: #{captive_direction.to_s}")
      if warrior.feel(captive_direction).captive?
        action = warrior.rescue!(captive_direction)
      else
        action = warrior.walk!(captive_direction)
      end
      [warrior.health, nil, action]
    end

    def pivot_me(dir = :backward)
      log("#{(__callee__).upcase}")
      [warrior.health, nil, warrior.pivot!(dir)]
    end

    def shoot
      log("#{(__callee__).upcase}: #{shoot_direction.to_s}")
      [warrior.health, shoot_direction, warrior.shoot!(shoot_direction)]
    end

    def approach_enemy
      log("#{(__callee__).upcase}")
      nearest_enemy = shoot_directions.first
      if nearest_enemy == :forward
        [warrior.health, nil, warrior.walk!]
      else
        pivot_me(nearest_enemy)
      end
    end

    def attack
      log("#{__callee__.upcase}: #{enemy_direction.to_s}")
      [warrior.health, enemy_direction, warrior.attack!(enemy_direction)]
    end

    def wall_ahead?
      t = !first_non_empty.nil? && first_non_empty.wall?

      log("#{__callee__.upcase}: #{t.to_s}")
      t
    end

    def first_non_empty(direction = :forward)
      @first_non_empty ||= Hash.new

      #dir_array = warrior.look(direction)
      dir_array = []
      #@first_non_empty[direction] = dir_array.detect{|space| space.stairs? || !space.empty? }
      @first_non_empty[direction] = warrior.feel(direction)
      log("#{__callee__.upcase}: DIR_ARRAY [#{dir_array.map(&:to_s).join(', ')}], FIRST '#{@first_non_empty[direction].to_s}'")
      @first_non_empty[direction]
    end

    def is_wall?
      t = warrior.feel.wall?
      log("#{__callee__.upcase}: #{t.to_s}")
      t
    end

    def is_safe?
      t = health <= warrior.health
      log("#{__callee__.upcase}: #{t.to_s}")
      t
    end

    def captive_direction
      log("#{(__callee__).upcase}")
      @cap_dir ||= captive_directions.sample
    end

    def shoot_direction
      log("#{(__callee__).upcase}")
      @shoot_dir ||= shoot_directions.last
    end

    def enemy_direction
      log("#{(__callee__).upcase}")
      @enemy ||= enemy_directions.first
    end

    def clear_direction
      log("#{(__callee__).upcase}")
      @safe ||= clear_directions.first
    end

    def captive_directions
      return @captive_dirs if defined?(@captive_dirs)
      @captive_dirs = config[:directions].select{|d| captive_first?(d) }
      log("#{__callee__.upcase}: #{@captive_dirs.join(', ')}")
      @captive_dirs
    end

    def shoot_directions
      return @shoot_dirs if defined?(@shoot_dirs)
      @shoot_dirs = enemy_sort(config[:directions].select{|d| enemy_first?(d) })
      log("#{__callee__.upcase}: '#{@shoot_dirs.join(', ')}'")
      @shoot_dirs
    end

    def enemy_sort(dirs)
      return @sorted_enemy_dirs if defined?(@sorted_enemy_dirs)
      @sorted_enemy_dirs = dirs.sort_by{|dir| warrior.look(dir).index{|s| s.enemy? } || 3 }
      log("#{__callee__.upcase}: RAW '#{dirs.join(', ')}', SORTED '#{@sorted_enemy_dirs.join(', ')}'")
      @sorted_enemy_dirs
    end

    def enemy_first?(direction)
      t = !first_non_empty(direction).nil? && first_non_empty(direction).enemy?

      log("#{__callee__.upcase}: Direction #{direction.to_s}, #{t}")
      t
    end

    def captive_first?(direction)
      t = !first_non_empty(direction).nil? && first_non_empty(direction).captive?

      log("#{__callee__.upcase}: Direction #{direction.to_s}, #{t}")
      t
    end

    def enemy_directions
      return @enemy_dirs if defined?(@enemy_dirs)
      @enemy_dirs = config[:directions].select{|d| warrior.feel(d).enemy? }
      log("#{__callee__.upcase}: '#{@enemy_dirs.join(', ')}'")
      @enemy_dirs
    end

    def clear_directions
      return @clear_dirs if defined?(@clear_dirs)
      dirs = config[:directions].reject{|u| u == last_move}.select{|d| warrior.feel(d).empty? }

      @clear_dirs = dirs #- shoot_directions
      log("#{__callee__.upcase}: '#{@clear_dirs.join(', ')}'")
      @clear_dirs
    end

    def log(msg)
      return unless @debug
      tabs = "  "*(caller.count - @level)
      puts "%s %s"%[tabs, msg.to_s]
    end
  end
end
