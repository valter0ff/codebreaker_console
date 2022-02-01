class Asker
  attr_reader :state, :console

  def initialize(state)
    @state = state
    @console = Console.new(@state)
  end

  def ask_intro
    ask_wrapper(I18n.t('possible_commands')) do |input|
      case input
      when I18n.t('commands.stats') then show_statistics
      when I18n.t('commands.rules') then out_message(I18n.t('rules_of_game'))
      when I18n.t('commands.start') then console.start_game
      else out_message(I18n.t('messages.error_command'))
      end
    end
  end

  def ask_player_name
    ask_wrapper(I18n.t('asking.name')) do |input|
      console.game.setup_name(input)
    end
    state.change_step(:choice_diff)
  end

  def ask_difficulty
    ask_wrapper(I18n.t('asking.difficulty')) do |input|
      console.game.setup_difficulty(input)
    end
    state.change_step(:asking_guess)
  end

  def ask_guess
    ask_wrapper(I18n.t('asking.guess')) do |input|
      if input == I18n.t('commands.hint')
        console.take_hint
      else
        console.game.setup_user_guess(input)
        console.check_guess
      end
    end
  end

  def ask_new_game
    ask_wrapper(I18n.t('asking.play_again')) do |input|
      if input == I18n.t('commands.new_game')
        state.change_stage(:intro)
        state.change_step(:intro)
      else
        out_message(I18n.t('messages.invalid_answer'))
      end
    end
  end

  def ask_save_result
    ask_wrapper(I18n.t('asking.saving')) do |input|
      case input
      when I18n.t('commands.save_game') then console.save_result
      when I18n.t('commands.no_save_game') then state.change_step(:game_over)
      else
        out_message(I18n.t('messages.invalid_answer'))
      end
    end
  end

  private

  def ask_wrapper(msg)
    out_message(msg)
    input = gets.chomp
    check_exit_command(input)
    yield(input)
    input
  rescue Codebreaker::ValidationError => e
    out_message(e.message)
    retry
  end

  def out_message(msg)
    puts msg
    puts I18n.t('messages.dashes')
  end

  def check_exit_command(input)
    return unless input == I18n.t('commands.exit')

    out_message(I18n.t('messages.goodbye'))
    exit
  end

  def show_statistics
    raise NotImplementedError
  end
end
