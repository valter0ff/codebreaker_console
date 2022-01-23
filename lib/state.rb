class State
  attr_reader :stage, :step

  def initialize
    @stage = :intro
    @step = :intro
  end

  def change_stage(arg)
    @stage = arg
  end

  def change_step(arg)
    @step = arg
  end
end
