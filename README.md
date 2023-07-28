Hosted here: https://main--comfy-kleicha-229087.netlify.app/
Backend here: https://nothing-to-see-here-backend-8de9e9907b73.herokuapp.com/ (though there really isn't anything to see here, the only endpoint on it is a POST).

## Design Choices

1. Used `reactstrap` for the frontend, faster writing and light imlpementation for a nice UI.
2. Used `ruby-openai` for the integration with OpenAI. It's the most mature library.
3. There are a bunch of tokenizers, Ruby implementations look largely not nearly as vetted as Python (big surprise) and a product of this guy: https://github.com/ankane. To be honest, the tokens were largely being used for filtering text samples that were too long and didn't become relevant for my CSV parser, where I ended up using the pre-page-parsed CSV from the repo (couldn't find the book pdf).
  1. Implementations/integrations of HuggingFace tokenizers (what I used, used the one from Sahil's implementation as MVP): https://github.com/ankane/tokenizers-ruby
  2. A different one trained just for Bing: https://github.com/ankane/blingfire-ruby
  3. I actually tried this guy out: https://github.com/ankane/youtokentome-ruby, I think it required training (no pre-trains) so had to opt with the HuggingFace one.
4. Generally for models, using `-ada-`, the `-002` models for embeddings, and `gpt-turbo-3.5` for completions. Seems like original project was made before these alternatives were set as the defaults.
5. Shifted to using the `/chat/completions` API instead of `/completions`. Completions was deprecated as newer models ideal for chat should also handle completions with correct prompt engineering. However, I've largely used the original prompt from Sahil's website, yet to see how effective it's going to be. So far looks good to me.
6. I modified the prompt to be a little more aligned with how OpenAI suggests identifying context.
7. For some sauce added the slow typing UI. I think the way that OpenAI returns the values as a stream relaying results to the frontend could be faster if we were doing server-side rendering, but I started with the split method because I was more used to it and that became a defining choice.
8. Heroku and Netlify deploys for speed.

The biggest things I wanted to explore after were:
- Adding vector search for looking up old questions in the cache. As you actually migrate to Postgres this may be possible in the Heroku deploy, but didn't have time. Seems like the biggest time saver.
- Multiple question conversations, enabled by the Chat API

One thing I improved on was handling of out there questions, this one crashed the original site:

<img width="1792" alt="Screen Shot 2023-07-28 at 6 11 16 PM" src="https://github.com/nkumarcc/nothing-to-see-here/assets/19844471/fa7e6cd5-afdf-490e-949e-f7c228f94798">
<img width="1792" alt="Screen Shot 2023-07-28 at 6 09 15 PM" src="https://github.com/nkumarcc/nothing-to-see-here/assets/19844471/d6102d61-d271-4f96-97d6-c39cd683aff3">

I think this is likely the Chat API vs Completion API. I also think while it's better that the chat actually responds to this question, I think we could do better guiding of how to respond to irrelevant questions like this in the prompt. We could also use the bigger prompt window models, though obv for this type of site not worth it.

I also tried making a nicer book and UI but decided not worth for sake of the project.

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
