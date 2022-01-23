class Router
  attr_reader :state, :asker

  def initialize
    @state = State.new
    @asker = :asker_class_instance #Asker.new(@state)
  end

  def call
    puts I18n.t('messages.welcome')
    puts I18n.t('messages.dashes')
    loop do
      router
    end
  end

  private

  def router
    case state.stage
    when :intro then asker.ask_intro
    when :game then game_case
    when :ended then finish_case
    end
  end

  def game_case
    case state.step
    when :player_name then asker.ask_player_name
    when :choice_diff then asker.ask_difficulty
    when :asking_guess then asker.ask_guess
    end
  end

  def finish_case
    case state.step
    when :user_win then asker.ask_save_result
    when :game_over then asker.ask_new_game
    end
  end
end
