require 'rspec'
require 'byebug'
require 'matrix'
require "#{ Dir.pwd }/app"

def measure_x_times(times, &block)
  dist = []

  dist << Benchmark.measure do
    block.call
  end

  dist
end