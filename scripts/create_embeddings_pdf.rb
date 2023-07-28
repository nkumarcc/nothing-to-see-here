require 'pdf-reader'
require 'tokenizers'
require 'openai'
require 'dotenv/load'
require 'daru'
require 'csv'

OpenAI.configure do |config|
    config.access_token = ENV.fetch("OPENAI_ACCESS_TOKEN")
    config.request_timeout = 240
end

open_ai = OpenAI::Client.new()
DOC_EMBEDDINGS_MODEL = "text-search-curie-doc-001"

if ARGV.length < 1
  puts "Usage: ruby scripts/create_embeddings_pdf.rb <path_to_pdf>"
  exit
end

filename = ARGV[0]

if !ARGV[0].end_with?(".pdf")
    puts "Argument is not a pdf file."
    puts "Usage: ruby scripts/create_embeddings_pdf.rb <path_to_pdf>"
    exit
end

reader = PDF::Reader.new(filename)

tokenizer = Tokenizers.from_pretrained("gpt2")

def count_tokens(text, tokenizer)
    return tokenizer.encode(text).ids.size
end

def extract_pages(page_text, index, tokenizer)
    if page_text.empty?
        page_text = ""
    end
    content = page_text.split.join(" ")
    return ["Page " + index.to_s, content, count_tokens(content, tokenizer)+4]
end

data = { 'Title' => [], 'Content' => [], 'Tokens' => [] }
reader.pages.each do |page|
    output = extract_pages(page.text, page.number, tokenizer)
    if output[2] > 2046
        next
    end
    data['Title'] << output[0]
    data['Content'] << output[1]
    data['Tokens'] << output[2]
end
df = Daru::DataFrame.new(data)

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
df.map_rows.with_index do |row, index|
    doc_embeddings[index] = get_embedding(row['Content'], open_ai, DOC_EMBEDDINGS_MODEL)
end

CSV.open('./outputs/book.embeddings.csv', 'w') do |csv|
  csv << ["title"] + (0...4096).to_a
  doc_embeddings.each do |page, embedding|
    csv << ["Page #{page}"] + embedding
  end
end
