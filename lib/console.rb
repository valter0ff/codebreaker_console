class Console
  include DatabaseLoader

  WIN_RESULT = '++++'.freeze
  attr_reader :state, :game

  def initialize(state)
    @state = state
    @game = Codebreaker::Game.new
  end

  def start_game
    game.create_game_params
    state.change_stage(:game)
    state.change_step(:player_name)
  end

  def take_hint
    game.hint_present? ? out_message(game.give_hint) : out_message(I18n.t('messages.no_more_hints'))
  end

  def save_result
    out_message(I18n.t('messages.result_saved'))
    state.change_step(:game_over)
  end

  def check_guess
    check = game.check_user_guess
    return user_win if check == WIN_RESULT
    return user_lose(check) if game.no_more_attempts?

    out_message(I18n.t('messages.result_of_guess', result: check))
  end

  private

  def out_message(msg)
    puts msg
    puts I18n.t('messages.dashes')
  end

  def user_win
    puts I18n.t('messages.win')
    out_message(I18n.t('messages.secret_code', code: game.secret_code.join))
    state.change_stage(:ended)
    state.change_step(:user_win)
  end

  def user_lose(check)
    out_message(I18n.t('messages.result_of_guess', result: check))
    puts I18n.t('messages.lose')
    out_message(I18n.t('messages.secret_code', code: game.secret_code.join))
    state.change_stage(:ended)
    state.change_step(:game_over)
  end
end
