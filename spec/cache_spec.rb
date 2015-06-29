require 'spec_helper'

RSpec.describe ShardHandler::Cache do
  it { expect(described_class).to respond_to(:connection_handlers) }
  it { expect(described_class).to respond_to(:connection_handlers=) }
end
