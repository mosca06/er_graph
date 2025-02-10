require "er_graph/version"
require "er_graph/generator"

module ErGraph
  def self.call
    Generator.new.call
  end
end
