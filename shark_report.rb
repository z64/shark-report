module ProbeReport
  # Regex for parsing data
  module Regex
    # Cycle number
    CYCLE = /CYCLE\s\K\d+/

    # Feature name
    NAME = /FEATURE\s\K\w+/

    # Feature nominal value
    NOMINAL = /NOMINAL\s\K-?\d+\.\d+/

    # Feature tolerance
    TOLERANCE = /TOL\s\K\d+\.\d+/

    # Feature measured value
    ACTUAL = /ACTUAL\s\K-?\d+\.\d+/
  end

  # Report
  class Report
    # Raw report data
    attr_reader :data

    # Cycles
    attr_reader :cycles

    def initialize(file)
      @data = parse(File.read(file))
      @cycles = []
      make_cycles!
    end

    def to_hash
      {
        cycles: cycles.map(&:to_hash)
      }
    end

    # Export's a reports data as a tsv
    def to_tsv
      data = []
      cycles.each do |c|
        c.features.each do |f|
          data << "#{c.number}\t"\
            "#{f.name}\t"\
            "#{f.nominal}\t"\
            "#{f.tolerance}\t"\
            "#{f.actual}\t"\
            "#{f.deviation}\t"\
            "#{f.out_tol}"
        end
      end
      data.join("\n")
    end

    private

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

    # Scans data and creates features with
    # their associated cycle
    def make_cycles!
      data.each do |d|
        number = d.scan(Regex::CYCLE).first.to_i
        cycle = @cycles.find { |c| c.number == number }
        if cycle.nil?
          cycle = Cycle.new(number: number)
          @cycles << cycle
        end
        cycle.add_feature(
          Feature.new(
            data:      d,
            name:      d.scan(Regex::NAME).first,
            nominal:   d.scan(Regex::NOMINAL).first.to_f,
            tolerance: d.scan(Regex::TOLERANCE).first.to_f,
            actual:    d.scan(Regex::ACTUAL).first.to_f
          )
        )
      end
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

    # Exports a cycle's data as a hash
    def to_hash
      {
        cycle: number,
        features: features.map(&:to_hash)
      }
    end
  end

  # A feature
  class Feature
    # The raw data the feature
    # was created with
    attr_reader :data

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

    def initialize(data: nil,
                   name: nil,
                   nominal: 0.0,
                   tolerance: 0.0,
                   actual: 0.0)
      @data = data
      @name = name
      @nominal = nominal
      @tolerance = tolerance
      @actual = actual
      @deviation = actual - nominal
      @out_tol = @deviation.abs > tolerance ? @deviation.abs - tolerance : 0.0
    end

    def to_hash
      {
        data: data,
        name: name,
        nominal: nominal,
        tolerance: tolerance,
        actual: actual,
        deviation: deviation,
        out_tol: out_tol
      }
    end
  end
end
