require 'llama_cpp'

params = LLaMACpp::ContextParams.new
params.seed = 42

def build_prompt(instruction, input)
    "Below is an instruction that describes a task, paired with an input that provides further context. Write a response that appropriately completes the request.\n" +
    "### Instruction:\n" + instruction + "\n### Input:\n" + input + "\n### Response:\n"
end

model = LLaMACpp::Model.new(model_path: '/home/jedld/workspace/llama.cpp/models/13B-chat/ggml-model-q4_0.bin', params: params)
context = LLaMACpp::Context.new(model: model)
query = build_prompt("Pretend that I am aShedrak of the Eyes
The beholder’s favorite slave is a human named Shedrak of the Eyes. As Karazikar’s “high priest,” he leads other slaves in worship of their master and carries out the beholder’s commands.

Formerly an adventurer from the surface world, Shedrak and his companions delved too deeply into the Wormwrithings. His companions became Karazikar’s playthings for a time, but Shedrak alone was able to resist and withstand all ten of the beholder’s eye rays. Impressed by this feat of extraordinary luck, Karazikar made the human his acolyte after breaking his mind and his will. Shedrak is completely mad, considers Karazikar a god, and brooks no defiance or disrespect toward his divine master.", "what should I say when I see surface dweller adventurers?")
puts "query is: #{query}"
puts LLaMACpp.generate(context, query, n_threads: 4)