## Design Choices

1. Used `reactstrap` for the frontend, faster writing and light imlpementation for a nice UI.
2. Used `ruby-openai` for the integration with OpenAI. It's the most mature library.
3. There are a bunch of tokenizers, Ruby implementations look largely not nearly as vetted as Python (big surprise) and a product of this guy: https://github.com/ankane. To be honest, the tokens were largely being used for filtering text samples that were too long and didn't become relevant for my CSV parser, where I ended up using the pre-page-parsed CSV from the repo (couldn't find the book pdf).
  1. Implementations/integrations of HuggingFace tokenizers (what I used, used the one from Sahil's implementation as MVP): https://github.com/ankane/tokenizers-ruby
  2. A different one trained just for Bing: https://github.com/ankane/blingfire-ruby
  3. I actually tried this guy out: https://github.com/ankane/youtokentome-ruby, I think it required training (no pre-trains) so had to opt with the HuggingFace one.
4. Generally for models, using `-ada-`, the `-002` models for embeddings, and `gpt-turbo-3.5` for completions. Seems like original project was made before these alternatives were set as the defaults.

### Ideas

- Add sassy remark that dynamically updates
- Upload your own PDF
- Merge React into Rails (like how I think the project was supposed to be done)
- Cache that updates itself
- Multi-message conversations (https://platform.openai.com/docs/api-reference/chat/create#chat/create-messages)
- OpenAI integrated with generating a result (function calls? https://platform.openai.com/docs/api-reference/chat/create#chat/create-function_call)
  - Also, using OpenAI files instead of and/or alongside embeddings file (https://platform.openai.com/docs/api-reference/files)
- Consume as a stream (https://platform.openai.com/docs/api-reference/chat/create#chat/create-stream)
- Image creation
- Mess with Ruby Langchain (https://github.com/andreibondarev/langchainrb)