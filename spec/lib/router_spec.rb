RSpec.describe Router do
  subject(:router) { described_class.new }

  let(:asker) { double }

  before { router.instance_variable_set(:@asker, asker) }

  after { router.call }

  RSpec.shared_context 'with stubbed loop' do
    before do
      allow(router).to receive(:loop).and_yield
      allow(router).to receive(:gets)
    end
  end

  describe '#call' do
    context 'when application have started' do
      before { allow(router).to receive(:puts) }

      it 'calls #loop' do
        expect(router).to receive(:loop)
      end

      it 'calls #router inside loop' do
        allow(router).to receive(:loop).and_yield
        expect(router).to receive(:router)
      end

      it 'calls #ask_intro' do
        allow(router).to receive(:loop).and_yield
        allow(router.asker).to receive(:ask_intro)
        expect(router.asker).to receive(:ask_intro)
      end
    end

    it 'output welcome message' do
      allow(router).to receive(:loop)
      allow($stdout).to receive(:puts).with(I18n.t('messages.dashes'))
      expect($stdout).to receive(:puts).with(I18n.t('messages.welcome'))
    end
  end

  describe 'when state.stage is :game' do
    include_context 'with stubbed loop'
    before do
      router.state.change_stage(:game)
      allow(router).to receive(:puts)
    end

    it 'calls #game_case method' do
      expect(router).to receive(:game_case)
    end

    context 'when state.step is :player_name' do
      before { router.state.change_step(:player_name) }

      it 'calls #ask_player_name' do
        expect(router.asker).to receive(:ask_player_name)
      end
    end

    context 'when state.step is :choice_diff' do
      before { router.state.change_step(:choice_diff) }

      it 'calls #ask_difficulty' do
        expect(router.asker).to receive(:ask_difficulty)
      end
    end

    context 'when state.step is :asking_guess' do
      before { router.state.change_step(:asking_guess) }

      it 'calls #ask_guess' do
        expect(router.asker).to receive(:ask_guess)
      end
    end
  end

  describe '#call when state.stage is :ended' do
    include_context 'with stubbed loop'
    before do
      router.state.change_stage(:ended)
      allow(router).to receive(:puts)
    end

    it 'calls #finish_case method' do
      expect(router).to receive(:finish_case)
    end

    context 'when state.step is :user_win' do
      before { router.state.change_step(:user_win) }

      it 'calls #ask_save_result' do
        expect(router.asker).to receive(:ask_save_result)
      end
    end

    context 'when state.step is :game_over' do
      before { router.state.change_step(:game_over) }

      it 'calls #ask_new_game' do
        expect(router.asker).to receive(:ask_new_game)
      end
    end
  end
end
