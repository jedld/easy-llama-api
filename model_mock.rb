class FakeModel
end

class FakeContext
  def initialize(model: nil)
    @model = model
  end
end