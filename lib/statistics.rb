class Statistics
  include DatabaseLoader
  attr_reader :data, :longest_name

  RATING_TITLE = 'Rating '.freeze
  NAME_TITLE = '| Name'.freeze
  OTHER_TITLE = '| Difficulty | Attempts Total | Attempts Used  |  Hints Total   |   Hints Used'.freeze
  DIFF = %w[hell medium easy].freeze
  KEYS = %i[attempts attempts_used hints hints_used].freeze

  def initialize
    @data = load_from_file
    @longest_name = calc_longest_name
  end

  def show_statistics
    return no_rating_yet unless data

    print_table_title
    print_table_data
  end

  private

  def print_table_title
    print RATING_TITLE
    print NAME_TITLE.ljust(longest_name + 3)
    print OTHER_TITLE
    puts
  end

  def print_table_data
    sorted_database.each_with_index do |player, i|
      print (i + 1).to_s.rjust(4).ljust(7)
      print_player_name(player)
      print_difficulty(player)
      print_stats(player)
      puts
    end
  end

  def sorted_database
    data.sort_by do |obj|
      [DIFF.index(obj.difficulty), obj.attempts_used, obj.hints_used]
    end
  end

  def print_player_name(player)
    print "| #{player.name.ljust(longest_name + 1)}"
  end

  def print_difficulty(player)
    print "| #{player.difficulty.ljust(8).rjust(11)}"
  end

  def print_stats(player)
    KEYS.each { |key| print "| #{player.public_send(key).to_s.ljust(8).rjust(15)}" }
  end

  def calc_longest_name
    return unless data

    data.inject(0) do |longest, obj|
      longest >= obj.name.size ? longest : obj.name.size
    end
  end

  def no_rating_yet
    puts I18n.t('messages.no_rating')
    puts I18n.t('messages.dashes')
  end
end
