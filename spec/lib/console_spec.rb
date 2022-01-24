RSpec.describe Console do
  subject(:console) { described_class.new(state) }

  let(:state) { State.new }

  RSpec.shared_examples 'change state' do
    it 'changes state variable' do
      allow($stdout).to receive(:puts)
      expect { console.check_guess }.to change(state, arg).to(value)
    end
  end

  describe '#take_hint' do
    context 'when hint present' do
      it 'calls #out_message with message from game.give_hint' do
        is_hint = double
        allow(console.game).to receive(:hint_present?).and_return(true)
        allow(console.game).to receive(:give_hint).and_return(is_hint)
        expect(console).to receive(:out_message).with(is_hint)
        console.take_hint
      end
    end

    context 'when hint is not present' do
      let(:message) { I18n.t('messages.no_more_hints') }

      it 'calls #out_message with message about no hints' do
        allow(console.game).to receive(:hint_present?).and_return(false)
        expect(console).to receive(:out_message).with(message)
        console.take_hint
      end
    end
  end

  describe '#save_result' do
    before { console.game.create_game_params }

    let(:player_object) { console.game.player }
    let(:message) { I18n.t('messages.result_saved') }

    #     it 'calls #store_to_file with player object' do
    #       allow(console).to receive(:out_message).with(message)
    #       expect(console).to receive(:store_to_file).with(player_object)
    #       console.save_result
    #     end

    it 'calls #out_message with message result saved' do
      expect(console).to receive(:out_message).with(message)
      console.save_result
    end

    it 'changes state.step' do
      allow(console).to receive(:out_message).with(message)
      expect { console.save_result }.to change(state, :step).to(:game_over)
    end
  end

  describe '#check_guess' do
    before do
      console.start_game
      console.game.setup_user_guess(input)
      console.game.setup_difficulty('easy')
    end

    context 'when user guess is valid' do
      let(:input) { console.game.secret_code.join }

      it 'calls #user_win' do
        expect(console).to receive(:user_win)
        console.check_guess
      end

      it 'puts message to console' do
        allow(console).to receive(:out_message)
        expect($stdout).to receive(:puts).with(I18n.t('messages.win'))
        console.check_guess
      end

      include_examples 'change state' do
        let(:arg) { :stage }
        let(:value) { :ended }
      end

      include_examples 'change state' do
        let(:arg) { :step }
        let(:value) { :user_win }
      end
    end

    context 'when user guess is invalid' do
      let(:message) { I18n.t('messages.result_of_guess', result: check) }
      let(:input) { console.game.secret_code.shuffle.join }
      let(:check) { console.game.check_user_guess }

      it 'puts message to console' do
        allow(console).to receive(:out_message)
        expect(console).to receive(:out_message).with(message)
        console.check_guess
      end
    end

    context 'when user does not have attempts and guess is invalid' do
      let(:input) { console.game.secret_code.shuffle.join }

      before do
        allow(console.game).to receive(:no_more_attempts?).and_return(true)
        allow(console).to receive(:out_message)
      end

      it 'calls #user_lose' do
        expect(console).to receive(:user_lose)
        console.check_guess
      end

      it 'puts message to console' do
        expect($stdout).to receive(:puts).with(I18n.t('messages.lose'))
        console.check_guess
      end

      include_examples 'change state' do
        let(:arg) { :stage }
        let(:value) { :ended }
      end

      include_examples 'change state' do
        let(:arg) { :step }
        let(:value) { :game_over }
      end
    end
  end
end
