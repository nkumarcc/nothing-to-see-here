require "openai"
require "prompt_and_embedding_utils"

class AskController < ApplicationController
    rescue_from ActionController::ParameterMissing do |exception|
        render json: { error: "Required parameter missing: #{exception.param}" }, status: :bad_request
    end

    def ask 
        question = params.require(:question)

        # Check if question previously asked / vector similarity to a recent previous question
        # If so, return the same answer

        response = PromptAndEmbeddingUtils.get_completion_for_question(question, openai_client)

        if !response.nil?
            return render json: { answer: response }
        end
        render json: { answer: 'No response.' }
    end

    private
    def openai_client
        @openai_client ||= OpenAI::Client.new()
    end
end
