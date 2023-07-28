#!/usr/bin/env ruby

require_relative '../server/config/environment'

question = Question.new
question.question = 'Test question'
question.embedding = nil
question.ask_count = 0

puts "Created question with id #{question.id}"
