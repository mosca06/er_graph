require 'set'

module ErGraph
  class Generator
    def initialize
      @path = Rails.root.join("app", "models").to_s
      @nships = Set.new
      @oneships = Set.new
    end

    def call
      run
    end

    private

    def run
      populate_relationships
      create_graph_file
    end

    def populate_relationships
      Dir.foreach(@path) do |file|
        next if unused_directories(file)
        full_path = File.join(@path, file)

        next unless verify_ruby_file(file, full_path)

        File.foreach(full_path) do |line|
          if line.include?('has_many')
            match = line.match(/has_many\s+:(\w+),\s+through:\s+:([\w_]+)/)
            if match
              @nships << [match[1].singularize, match[2].singularize]
            else
              @nships << [model_name(file), line_symbol_name(line)]
            end
          elsif line.include?('has_one')
            @oneships << [model_name(file), line_symbol_name(line)]
          end
        end
      end
    end

    def unused_directories(file)
      file == '.' || file == '..'
    end

    def verify_ruby_file(file, full_path)
      File.file?(full_path) && file.end_with?('.rb')
    end

    def create_graph_file
      File.open("digraph.dot", "w") do |file|
        file.puts "digraph models {"
        @nships.each do |pair|
          file.puts "#{pair[0]} -> #{pair[1]};"
        end
        file.puts "}"
      end
    end

    def model_name(file)
      File.basename(file, '.rb').singularize
    end

    def line_symbol_name(line)
      line.match(/:(\w+)/)[1].singularize
    end
  end
end
