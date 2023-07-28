require 'openai'
require 'dotenv/load'
require 'daru'
require 'csv'

OpenAI.configure do |config|
    config.access_token = ENV.fetch("OPENAI_ACCESS_TOKEN")
    config.request_timeout = 240
end

open_ai = OpenAI::Client.new()

if ARGV.length < 2
  puts "Usage: ruby scripts/create_embeddings_csv.rb <path_to_csv> <output_name> " +
    "<optional: embeddings_model> <optional: max_input_tokens> <optional: output_dimensions>"
  exit
end

if !ARGV[0].end_with?(".csv")
    puts "Argument is not a csv file."
    puts "Usage: ruby scripts/create_embeddings_csv.rb <path_to_csv> <output_name>" +
      "<optional: embeddings_model> <optional: max_input_tokens> <optional: output_dimensions>"
    exit
end

if ARGV[1].end_with?(".csv")
    puts "Argument has the csv extension alread, we just want a key name."
    puts "Usage: ruby scripts/create_embeddings_csv.rb <path_to_csv> <output_name>" +
      "<optional: embeddings_model> <optional: max_input_tokens> <optional: output_dimensions>"
    exit
end

filename = ARGV[0]
output_name = ARGV[1]
DOC_EMBEDDINGS_MODEL = ARGV[2] || "text-embedding-ada-002"
MAX_INPUT_TOKENS = ARGV[3] || 8191
OUTPUT_DIMENSIONS = ARGV[4] || 1536


df = Daru::DataFrame.from_csv(filename)

def get_embedding(text, open_ai, model)
    result = open_ai.embeddings(
        parameters: {
            model: model,
            input: text,
        }
    )
    return result.dig("data", 0, "embedding")
end

doc_embeddings = {}
df.map_rows do |row|
    doc_embeddings[row['title']] = get_embedding(row['content'], open_ai, DOC_EMBEDDINGS_MODEL)
end

CSV.open("./outputs/#{output_name}.embeddings.csv", 'w') do |csv|
  csv << ["title"] + (0...OUTPUT_DIMENSIONS).to_a
  doc_embeddings.each do |page, embedding|
    if embedding.nil?
        next
    end
    csv << [page] + embedding
  end
end
