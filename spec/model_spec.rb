require 'spec_helper'

RSpec.describe ShardHandler::Model do
  it { expect(described_class.abstract_class).to be true }

  describe '.connection_handler' do
    let(:handler) { double }

    context 'shard set' do
      it 'returns a connection handler for the current thread' do
        allow(ShardHandler).to receive(:current_connection_handler) { handler }
        expect(described_class.connection_handler).to be handler
      end
    end

    context 'no shard set' do
      it 'returns ActiveRecord\'s default connection handler' do
        allow(ShardHandler).to receive(:current_connection_handler) { nil }
        expect(described_class.connection_handler)
          .to be(ActiveRecord::Base.default_connection_handler)
      end
    end
  end

  describe '.establish_connection' do
    it 'raises an error' do
      expect {
        described_class.establish_connection
      }.to raise_error(NoMethodError)
    end
  end
end
