# frozen_string_literal: true

class Jsonl
  class << self
    def create_jsonl_file(file, lines)
      jsonl = lines_to_jsonl(lines)
      File.write(file, jsonl)
    end

    def text_file_to_jsonl_file(text_file, jsonl_file)
      lines = File.readlines(text_file)
      create_jsonl_file(jsonl_file, lines)
    end

    def lines_to_jsonl(lines)
      lines.map do |line|
        prompt, completion = line.split('|')
        { prompt: prompt, completion: completion }.to_json
      end.join("\n")
    end
  end
end
