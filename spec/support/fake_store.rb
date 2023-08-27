# frozen_string_literal: true

class FakeStore < KPlaygroundGpt::Storage::BaseStore
  attr_reader :internal_data

  def read
    internal_data
  end

  def write(data)
    @internal_data = data
  end
end
