class Result
  attr_reader :errors, :data

  def initialize(success:, errors: [], data: nil)
    @success = success
    @errors = Array(errors)
    @data = data
  end

  def success?
    @success
  end

  def failure?
    !@success
  end

  def add_error(error)
    @errors << error
    @success = false
  end

  def self.success(data = nil)
    new(success: true, data: data)
  end

  def self.failure(errors = [])
    new(success: false, errors: errors)
  end
end
