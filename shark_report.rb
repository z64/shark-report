module ProbeReport
  # Report
  class Report
    # Raw report data
    attr_reader :data

    # Cycles
    attr_reader :cycles

    def initialize(file)
      @data = parse(File.read(file))
    end

    # Parses a dataset into an actually
    # useful format
    def parse(data)
      # Only take CYCLE lines
      data = data.split("\n").select do |d|
        d.include? 'CYCLE'
      end

      # Remove excess spaces
      data.map! { |d| d.gsub(/\s+/, ' ') }

      # Append leading zeroes
      data.map! { |d| d.gsub(/\s\./, ' 0.') }

      # Remove spaces between negative symbols and numbers
      data.map! { |d| d.gsub(/-\s/, '-') }
    end
  end

  # Cycle
  class Cycle
    # Cycle number
    attr_reader :number

    # Feature
    attr_reader :features

    def initialize(number: 0,
                   features: [])
      @number = number
      @features = features
    end

    # Adds a feature to a Cycle
    def add_feature(feature)
      @features << feature
    end
  end

  # A feature
  class Feature
    # Name of feature
    attr_reader :name

    # Nominal value
    attr_reader :nominal

    # Symmetric tolerance
    attr_reader :tolerance

    # Reported value
    attr_reader :actual

    # Deviation from nominal
    attr_reader :deviation

    # Amount a value is out of tolerance
    attr_reader :out_tol

    def initialize(name: nil,
                   nominal: 0.0,
                   tolerance: 0.0,
                   actual: 0.0)
      @name = name
      @nominal = nominal
      @tolerance = tolerance
      @actual = actual
      @deviation = actual - nominal
      @out_tol = @deviation.abs > tolerance ? @deviation.abs - tolerance : 0.0
    end
  end
end
