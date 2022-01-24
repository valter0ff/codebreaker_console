RSpec.describe Statistics do
  subject(:stats) { described_class.new }

  let(:console) { Console.new(state) }
  let(:state) { double }
  let(:data_file) { Console::DATA_FILE }

  before do
    console.game.create_game_params
    console.game.player.name = 'Heisenberg'
    console.game.setup_difficulty('hell')
    File.delete(data_file) if File.exist?(data_file)
    console.store_to_file(console.game.player)
    allow(stats).to receive(:print)
  end

  describe '#show_statistics' do
    context 'when database file not found' do
      it 'returns message about absence of statistics' do
        stats.instance_variable_set(:@data, nil)
        allow($stdout).to receive(:puts)
        expect($stdout).to receive(:puts).with(I18n.t('messages.no_rating'))
        stats.show_statistics
      end
    end

    context 'when database file is present' do
      it 'puts player rating to user console' do
        expect(stats).to receive(:print).with(Statistics::RATING_TITLE)
        stats.show_statistics
      end
    end
  end
end
