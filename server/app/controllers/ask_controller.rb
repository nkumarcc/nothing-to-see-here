require "openai"
require "prompt_and_embedding_utils"


class AskController < ApplicationController
    rescue_from ActionController::ParameterMissing do |exception|
        render json: { error: "Required parameter missing: #{exception.param}" }, status: :bad_request
    end

    def ask 
        question = params.require(:question)

        question_answer = Question.where(question: question)
        if question_answer.length > 0
            return render json: { answer: question_answer[0].answer }
        end

        response = PromptAndEmbeddingUtils.get_completion_for_question(question, openai_client)

        if !response.nil?
            Question.create(question: question, answer: response)
            return render json: { answer: response }
        end
        render json: { answer: 'No response.' }
    end

    private
    def openai_client
        @openai_client ||= OpenAI::Client.new()
    end
end
