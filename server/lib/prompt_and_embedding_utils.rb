require "matrix"
require "csv"
require "openai"

EMBEDDING_MODEL = ENV.fetch("EMBEDDING_MODEL")
COMPLETIONS_MODEL = ENV.fetch("COMPLETIONS_MODEL")
PAGE_TEXT_FILE = Rails.root.join('lib', ENV.fetch("PAGE_TEXT_FILE"))
PAGE_EMBEDDDINGS_FILE = Rails.root.join('lib', ENV.fetch("PAGE_EMBEDDDINGS_FILE"))
MAX_INPUT_TOKENS = ENV.fetch("MAX_INPUT_TOKENS").to_i

PAGE_TEXT = {}
PAGE_TOKENS = {}
PAGE_EMBEDDINGS = {}

TOKENS_IN_HEADER = 837
SEPARATOR = "\n* "
SEPARATOR_LEN = 3

CSV.foreach(PAGE_EMBEDDDINGS_FILE, headers: true) do |row|
    PAGE_EMBEDDINGS[row['title']] = Vector.elements(row.to_a[1..-1].map{|x| x[1].to_f})
end

CSV.foreach(PAGE_TEXT_FILE, headers: true) do |row|
    PAGE_TEXT[row['title']] = row['content']
    PAGE_TOKENS[row['title']] = row['tokens'].to_i
end

module PromptAndEmbeddingUtils
    # @param vecA [Vector]
    # @param vecB [Vector]
    # @return [Float]
    def self.get_vector_cosine_similarity(vecA, vecB)
        return nil unless vecA.is_a? Vector
        return nil unless vecB.is_a? Vector
        return nil if vecA.size != vecB.size
        dot_product = vecA.inner_product(vecB)
        norm_product = vecA.r * vecB.r
        return dot_product / norm_product
    end

    # @param text [String]
    # @param open_ai [OpenAI::Client]
    # @return 
    def self.get_embedding(text, open_ai)
        result = open_ai.embeddings(
            parameters: {
                model: EMBEDDING_MODEL,
                input: text,
            }
        ).dig("data", 0, "embedding")
        if result.nil?
            return nil
        end
        return Vector.elements(result)
    end

    # @param question [String]
    # @param pages [Hash]
    # @param open_ai [OpenAI::Client]
    # @return [Hash]
    def self.get_pages_ordered_by_score(question, page_embeddings, open_ai)
        question_embedding = get_embedding(question, open_ai)
        page_scores = {}
        page_embeddings.each do |page, embedding|
            page_scores[get_vector_cosine_similarity(question_embedding, embedding)] = page
        end
        return page_scores.sort.reverse.to_h.values
    end

    def self.build_prompt(question, ordered_relevant_pages, open_ai)
        chosen_sections = []
        chosen_sections_len = 0
        max_input_tokens = MAX_INPUT_TOKENS - TOKENS_IN_HEADER - (question.length / 4)

        ordered_relevant_pages.each do |page|
            page_text = PAGE_TEXT[page]
            page_tokens = PAGE_TOKENS[page]
            if page_text.nil? || page_tokens.nil?
                next
            end

            chosen_sections_len += page_tokens + SEPARATOR_LEN
            if chosen_sections_len > MAX_INPUT_TOKENS - (chosen_sections_len - page_tokens)
                space_left = MAX_INPUT_TOKENS - (chosen_sections_len - page_tokens)
                chosen_sections.push(SEPARATOR + page_text[0..space_left])
                break
            end
            chosen_sections.push(SEPARATOR + page_text)
        end

        header = "Sahil Lavingia is the founder and CEO of Gumroad, and the author of the book The Minimalist Entrepreneur (also known as TME). These are questions and answers by him. Please keep your answers to three sentences maximum, and speak in complete sentences. Stop speaking once your point is made.\n\nContext that may be useful, pulled from The Minimalist Entrepreneur:\n Context: \"\"\"\n"

        question_1 = "\n\n\"\"\" \n\n\nQ: How to choose what business to start?\n\nA: First off don't be in a rush. Look around you, see what problems you or other people are facing, and solve one of these problems if you see some overlap with your passions or skills. Or, even if you don't see an overlap, imagine how you would solve that problem anyway. Start super, super small."
        question_2 = "\n\n\nQ: Q: Should we start the business on the side first or should we put full effort right from the start?\n\nA:   Always on the side. Things start small and get bigger from there, and I don't know if I would ever “fully” commit to something unless I had some semblance of customer traction. Like with this product I'm working on now!"
        question_3 = "\n\n\nQ: Should we sell first than build or the other way around?\n\nA: I would recommend building first. Building will teach you a lot, and too many people use “sales” as an excuse to never learn essential skills like building. You can't sell a house you can't build!"
        question_4 = "\n\n\nQ: Andrew Chen has a book on this so maybe touché, but how should founders think about the cold start problem? Businesses are hard to start, and even harder to sustain but the latter is somewhat defined and structured, whereas the former is the vast unknown. Not sure if it's worthy, but this is something I have personally struggled with\n\nA: Hey, this is about my book, not his! I would solve the problem from a single player perspective first. For example, Gumroad is useful to a creator looking to sell something even if no one is currently using the platform. Usage helps, but it's not necessary."
        question_5 = "\n\n\nQ: What is one business that you think is ripe for a minimalist Entrepreneur innovation that isn't currently being pursued by your community?\n\nA: I would move to a place outside of a big city and watch how broken, slow, and non-automated most things are. And of course the big categories like housing, transportation, toys, healthcare, supply chain, food, and more, are constantly being upturned. Go to an industry conference and it's all they talk about! Any industry…"
        question_6 = "\n\n\nQ: How can you tell if your pricing is right? If you are leaving money on the table\n\nA: I would work backwards from the kind of success you want, how many customers you think you can reasonably get to within a few years, and then reverse engineer how much it should be priced to make that work."
        question_7 = "\n\n\nQ: Why is the name of your book 'the minimalist entrepreneur' \n\nA: I think more people should start businesses, and was hoping that making it feel more “minimal” would make it feel more achievable and lead more people to starting-the hardest step."
        question_8 = "\n\n\nQ: How long it takes to write TME\n\nA: About 500 hours over the course of a year or two, including book proposal and outline."
        question_9 = "\n\n\nQ: What is the best way to distribute surveys to test my product idea\n\nA: I use Google Forms and my email list / Twitter account. Works great and is 100% free."
        question_10 = "\n\n\nQ: How do you know, when to quit\n\nA: When I'm bored, no longer learning, not earning enough, getting physically unhealthy, etc… loads of reasons. I think the default should be to “quit” and work on something new. Few things are worth holding your attention for a long period of time."

        return "#{header}#{chosen_sections.join}#{question_1}#{question_2}#{question_3}#{question_4}#{question_5}#{question_6}#{question_7}#{question_8}#{question_9}#{question_10}\n\n\nQ: #{question}\n\nA: "
    end

    def self.get_completion_for_question(question, open_ai)
        ordered_pages = get_pages_ordered_by_score(question, PAGE_EMBEDDINGS, open_ai)
        prompt = build_prompt(question, ordered_pages, open_ai)
        completion = open_ai.chat(
            parameters: {
                model: COMPLETIONS_MODEL,
                messages: [
                    { role: "user", content: prompt}
                ],
                max_tokens: 150,
                temperature: 0.0,
            }
        )
        return completion.dig("choices", 0, "message", "content")
    end
end