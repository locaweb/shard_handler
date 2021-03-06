require 'spec_helper'

RSpec.describe ShardHandler::Model do
  before do
    # Clean up handler to avoid issues with mocks
    described_class.class_variable_set(:@@handler, nil)
  end

  it { expect(described_class.abstract_class).to be true }

  describe '.setup' do
    it 'initializes connection handlers cache' do
      config = double
      handler = double

      expect(ShardHandler::Handler)
        .to receive(:new).with(ShardHandler::Model, config) { handler }
      expect(handler).to receive(:setup)

      described_class.setup(config)
    end
  end

  describe '.current_shard=' do
    it 'sets the shard name for the current thread' do
      described_class.current_shard = :shard1
      expect(ShardHandler::ThreadRegistry.current_shard).to be :shard1
    end

    context 'passing nil' do
      it 'sets the current shard name to nil' do
        described_class.current_shard = nil
        expect(ShardHandler::ThreadRegistry.current_shard).to be nil
      end
    end

    context 'passing a string' do
      it 'casts the value to symbol' do
        described_class.current_shard = 'shard1'
        expect(ShardHandler::ThreadRegistry.current_shard).to be :shard1
      end
    end
  end

  describe '.current_shard' do
    it 'returns the current shard name' do
      described_class.current_shard = 'shard1'
      expect(described_class.current_shard).to be :shard1
    end
  end

  describe '.connection_handler' do
    before do
      described_class.setup('shard1' => { 'adapter' => 'postgresql' })
    end

    context 'model was not setup' do
      it 'raises an error' do
        described_class.remove_class_variable(:@@handler)
        described_class.current_shard = :foobar

        expect do
          described_class.connection_handler
        end.to raise_error(ShardHandler::SetupError,
                           'the model was not setup')
      end
    end

    context 'current shard is nil' do
      it 'returns the default connection handler' do
        expect_any_instance_of(ShardHandler::Handler)
          .to_not receive(:connection_handler_for)

        expect(described_class.connection_handler)
          .to be(ActiveRecord::Base.default_connection_handler)
      end
    end

    context 'current_shard is present' do
      it 'returns a connection handler for the current thread' do
        conn_handler = double
        expect_any_instance_of(ShardHandler::Handler)
          .to receive(:connection_handler_for).with(:shard1) { conn_handler }

        described_class.current_shard = :shard1
        expect(described_class.connection_handler).to be conn_handler
      end
    end
  end

  describe '.using' do
    before do
      described_class.setup('shard1' => { 'adapter' => 'postgresql' })
    end

    it 'yields a block' do
      expect do |b|
        described_class.using(:shard1, &b)
      end.to yield_with_no_args
    end

    it 'changes the current shard name when executing the block' do
      expect(described_class.current_shard).to be nil

      described_class.using(:shard1) do
        expect(described_class.current_shard).to be :shard1
      end
    end

    it 'changes current shard name back to its value before block execution' do
      described_class.current_shard = :shard2

      described_class.using(:shard1) do
        expect(described_class.current_shard).to be :shard1
      end

      expect(described_class.current_shard).to be :shard2
    end

    it 'returns any connections back to the pool' do
      expect(described_class).to receive(:clear_active_connections!)
      described_class.using(:shard1) {}
    end

    context 'chain with the same shard name' do
      it 'returns connections back only once' do
        expect(described_class).to receive(:clear_active_connections!).once

        described_class.using(:shard1) do
          described_class.using(:shard1) do
          end
        end
      end
    end

    context 'chain with different shard names' do
      it 'returns connections back to the pool' do
        expect(described_class).to receive(:clear_active_connections!).twice

        described_class.using(:shard1) do
          described_class.using(:shard2) do
          end
        end
      end
    end
  end

  describe '.establish_connection' do
    it 'raises an error' do
      expect do
        described_class.establish_connection
      end.to raise_error(NoMethodError)
    end
  end
end
