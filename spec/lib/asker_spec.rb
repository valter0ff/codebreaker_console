RSpec.describe Asker do
  subject(:asker) { described_class.new(state) }

  let(:state) { State.new }
  let(:invalid_input) { 'nn' }
  let(:valid_name) { 'Kostya' }
  let(:valid_guess) { '1111' }
  let(:name_error_message) { Codebreaker::Validations::NAME_ERROR }

  before do
    asker.console.start_game
  end

  RSpec.shared_examples 'raise error' do
    it 'raises error' do
      allow(asker).to receive(:ask_wrapper).and_yield(invalid_input)
      allow(asker).to receive(:gets).and_return(invalid_input)
      expect { receiver }.to raise_error(Codebreaker::ValidationError)
    end
  end

  RSpec.shared_examples 'output message' do
    it 'calls #out_message with message' do
      allow(asker).to receive(:gets).and_return(invalid_input)
      allow(asker.console.game).to receive(method_name)
      expect(asker).to receive(:out_message).with(message)
      receiver
    end
  end

  RSpec.shared_examples 'change @step' do
    it 'changes @step variable of state' do
      allow(asker).to receive(:ask_wrapper)
      expect { receiver }.to change(state, :step).to(step_after)
    end
  end

  RSpec.shared_context 'with provided input' do
    before do
      allow(asker).to receive(:ask_wrapper).and_yield(command)
    end
  end

  describe 'ask_intro' do
    context 'when got command "stats"' do
      include_context 'with provided input' do
        let(:command) { I18n.t('commands.stats') }
        let(:stats) { double }
      end
      it 'calls #show_statistics from Statistics class' do
        allow(Statistics).to receive(:new).and_return(stats)
        allow(stats).to receive(:show_statistics)
        expect(stats).to receive(:show_statistics)
        asker.ask_intro
      end
    end

    context 'when got command "rules"' do
      include_context 'with provided input' do
        let(:command) { I18n.t('commands.rules') }
      end
      it 'calls #out_message with rules of game' do
        expect(asker).to receive(:out_message).with(I18n.t('rules_of_game'))
        asker.ask_intro
      end
    end

    context 'when got command "start"' do
      include_context 'with provided input' do
        let(:command) { I18n.t('commands.start') }
      end
      it 'calls #start_game' do
        expect(asker.console).to receive(:start_game)
        asker.ask_intro
      end
    end

    context 'when got invalid command' do
      include_context 'with provided input' do
        let(:command) { invalid_input }
      end
      it 'calls #out_message with error of input' do
        expect(asker).to receive(:out_message).with(I18n.t('messages.error_command'))
        asker.ask_intro
      end
    end

    context 'when got command exit' do
      it 'calls #check_exit_command' do
        allow(asker).to receive(:out_message)
        allow(asker).to receive(:gets).and_return(I18n.t('commands.exit'))
        expect(asker).to receive(:check_exit_command)
        asker.ask_intro
      end
    end
  end

  describe '#ask_player_name' do
    let(:receiver) { asker.ask_player_name }

    it 'calls #out_message with error validation message' do
      allow($stdout).to receive(:puts).with(I18n.t('asking.name'))
      allow($stdout).to receive(:puts).with(I18n.t('messages.dashes'))
      allow(asker).to receive(:gets).and_return(invalid_input, valid_name)
      expect($stdout).to receive(:puts).with(name_error_message)
      receiver
    end

    include_examples 'raise error'

    include_examples 'output message' do
      let(:message) { I18n.t('asking.name') }
      let(:method_name) { :setup_name }
    end

    include_examples 'change @step' do
      let(:step_after) { :choice_diff }
    end
  end

  describe '#ask_difficulty' do
    let(:receiver) { asker.ask_difficulty }

    include_examples 'raise error'

    include_examples 'output message' do
      let(:message) { I18n.t('asking.difficulty') }
      let(:method_name) { :setup_difficulty }
    end

    include_examples 'change @step' do
      let(:step_after) { :asking_guess }
    end
  end

  describe '#ask_guess' do
    let(:receiver) { asker.ask_guess }
    let(:message) { I18n.t('asking.guess') }

    include_examples 'raise error'

    it 'calls #take_hint' do
      allow(asker).to receive(:out_message)
      allow(asker).to receive(:gets).and_return(I18n.t('commands.hint'))
      expect(asker.console).to receive(:take_hint)
      receiver
    end

    it 'calls #check_guess' do
      allow(asker).to receive(:out_message)
      asker.console.game.setup_difficulty('easy')
      allow(asker).to receive(:gets).and_return(valid_guess)
      expect(asker.console).to receive(:check_guess)
      receiver
    end
  end

  describe '#ask_new_game' do
    let(:receiver) { asker.ask_new_game }
    let(:message) { I18n.t('asking.play_again') }
    let(:new_game) { I18n.t('commands.new_game') }

    before { allow(asker).to receive(:out_message).with(message) }

    it 'changes state.stage' do
      allow(asker).to receive(:gets).and_return(new_game)
      expect { receiver }.to change(state, :stage).to(:intro)
    end

    it 'changes state.step' do
      allow(asker).to receive(:gets).and_return(new_game)
      expect { receiver }.to change(state, :step).to(:intro)
    end

    it 'calls #out_message about invalid answer' do
      allow(asker).to receive(:gets).and_return(invalid_input)
      expect(asker).to receive(:out_message).with(I18n.t('messages.invalid_answer'))
      receiver
    end
  end

  describe '#ask_save_result' do
    let(:receiver) { asker.ask_save_result }
    let(:message) { I18n.t('asking.saving') }

    context 'when got command "save game"' do
      include_context 'with provided input' do
        let(:command) { I18n.t('commands.save_game') }
      end
      it 'calls console.save_result' do
        expect(asker.console).to receive(:save_result)
        receiver
      end
    end

    context 'when got command "no save"' do
      include_context 'with provided input' do
        let(:command) { I18n.t('commands.no_save_game') }
      end
      it 'changes state.step' do
        expect { receiver }.to change(state, :step).to(:game_over)
      end
    end

    context 'when got invalid command' do
      include_context 'with provided input' do
        let(:command) { invalid_input }
      end
      it 'calls #out_message with error of input' do
        expect(asker).to receive(:out_message).with(I18n.t('messages.invalid_answer'))
        receiver
      end
    end
  end
end
