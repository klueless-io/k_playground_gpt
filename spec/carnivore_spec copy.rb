# frozen_string_literal: true

CB = KPlaygroundGpt::Chatbot

def parse_data(data)
  lines = data.split("\n").map(&:strip)
  comments = []
  
  while lines.any?
    author = lines.shift
    lines.shift if lines.first == '·'
    content = []
    while lines.any? && !lines.first.match?(/^(Reply|Edited|Author)?\d{1,2}w$/)
      content << lines.shift
    end
    timestamp = lines.shift
    comments << {
      author: author,
      content: content.join("\n"),
      timestamp: timestamp,
      type: timestamp.match?(/^Reply/) ? 'reply' : 'comment'
    }
  end
  
  comments
end

RSpec.describe 'Carnivore', :openai do
  let(:output_folder) { 'spec/sample_files/carnivore/conversations' }


  it 'a' do
    data = <<~DATA

    Gina DiTrapani
    · 
    Ok I'm trying to cut back on milk because of the carbs. I keep seeing 'heavy cream' mentioned for coffee but is that just the American way of saying 'cream'? I'd like to use Pauls Pure Cream because it pours. I don't want the kind that leaves a big oil slick on the coffee. I eat lots of fat already.
    That said, if I start making bulletproof coffee, I can just use unsalted butter, right? No need for MCT oil on Carnivore, I guess. (But I still want to know about the heavy vs pouring cream.)
    92 comments
    Russell Searle
    They’re the same. I use the Pauls cream. Blue carton. It’s pure cream skimmed off the top.
    Thickened cream is 50% cream 50% crap (gums and rubbish to thicken the goop)
    Reply
    33w
    Norbert Kiraly
    Russell Searle how do you figure 50%? How would something 50% gums etc be liquid and fairly viscous at fridge temps, and still min 35% milk fats?
    Reply
    33w
    Edited
    Brittany Ramsay
    I use harvey fresh pure whipping cream. It pours but still leaves a bit of the oily residue.
    Reply
    33w
    Edited
    Russell Searle
    They say MCT goes straight to the brain. So it’s good brain food and the caffeine gives you a jump start
    I have my coffee black most days as I fast till lunchtime.
    Reply
    33w
    Gina DiTrapani
    Author
    Russell Searle I actually only ever drink decaf. I prefer to avoid caffeine peaks and crashes. I just really enjoy coffee.
    Reply
    33w
    Ysabel Peikert
    I asked a similar question (heavy vs pouring cream) not too long ago. The only brand of double cream (which is closer to heavy cream than pure cream) which doesn't have any additives is Meander Valley double cream from Tassie. Depending where you are, … See more
    Reply
    33w
    Susan Dufton
    Ysabel Peikert I get that cream the tassie one, from Coles
    Reply
    33w
    Edited
    Janaina Cordeiro Morcombe
    Ysabel Peikert I got Meander Valley from Coles back in July when I was in Perth. SOme Coles, IGAs and FArmer Jacks sell the Bannister Downs double cream, it is even thicker than Meander Valley.
    Reply
    2w
    Greg Forknall
    I've used Meander Valley no thickeners but it's too thick to pour, I now use Woolies thickened cream use beef gelatine as thickening agent and you can pour it, I freeze into ice cube tray ½ tsp each. Doesn't have that oily film like other thickened cream has.
    Reply
    33w
    Edited
    Gina DiTrapani
    Author
    Greg Forknall how interesting! I must check the ingredients.
    Reply
    33w
    Linda Bebbington
    Greg Forknall 1/2 teaspoon? Does that even colour your coffee?
    Reply
    33w
    Greg Forknall
    Linda Bebbington tea for me, yes I like it dark 🙂 maybe ¾ tsp if I'm not careful
    Reply
    33w
    Kim Fitt
    I buy the Dairy Farmers brand from Coles or Woolies. It has only one (1) ingredient, pure cream. No fillers, no thickeners as some other heavy creams have.
    No photo description available.
    Reply
    33w
    Mark Miller
    Kim Fittwe use 1 litre glass bottles and pour the 600 ml cream and add 400 ml water.
    Reply
    33w
    Jaklin Hobbs
    Heavy cream overseas is equal to our Paul's pure pouring cream
    It's best to use one with no additives
    Reply
    33w
    Donna Sherrie
    I love this one
    No photo description available.
    Reply
    33w
    Gina DiTrapani
    Author
    Donna Sherrie I love it too but it leaves an oil slick. I prefer to have it other ways.
    Reply
    33w
    Donna Sherrie
    Gina I’m a fan of the oil slick 🤭😂
    Reply
    33w
    Juju Evo
    You can buy pure cream in Little cartons. I used that for a couple of months gradually reducing it and now take coffee black.
    Reply
    33w
    Gina DiTrapani
    Author
    Juju Evo I'm heading towards black coffee but taking it easy on some things.
    Reply
    33w
    Juju Evo
    Gina DiTrapani I never thought I would get there but I did!
    Reply
    33w
    JJ Dub
    U can also use kefir grains to turn the lactose into amazing probiotics, b vitamins and life force energy!
    Reply
    33w
    Deziree Mai
    JJ Dub oh! Interesting!
    Reply
    33w
    Anna Larsen
    JJ Dub yes milk kifir grains in pure cream is delicious. The grains love it. If anyone needs milk kifir grains in Perth I have some to share.
    Reply
    33w
    Su Tay
    Aldi has pure cream too!
    Reply
    33w
    Scott Hornby
    I have a long black with pouring cream with actual cream most cafe’s will sell a coffee with cream on the side or if I’m at home Bulla full cream is good too.
    Reply
    33w
    TheBraddie Tainton
    No photo description available.
    Reply
    33w
    Matt
    TheBraddie Tainton these budget "thick" creams normally have additives other than just cream like vegetable oil or thickening gums.
    Reply
    33w
    Donna Pisarek
    Matt some states are lucky that their thickened cream only contains gelatin. Unfortunately here in Qld they all contain carrageenan. It really psses me off!
    Reply
    33w
    Matt
    Donna Pisarek Pura and Dairy Farmers both sell a pure cream version that should be available in most supermarkets I've found.
    Reply
    33w
    Donna Pisarek
    Matt yes I know, I use those all of the time. They're getting very expensive now though and often times lately I'm unable to get it. I would like the option of being able to buy the thickened cream when the other shelf is empty, but not with carrageena… See more
    Reply
    33w
    Maria Iasky
    TheBraddie Tainton thicken with stuff. Look at ingredients
    Reply
    33w
    Bev Bradley
    I don’t see the need for bpc. Eat fatty meat.
    Reply
    33w
    Gina DiTrapani
    Author
    Bev Bradley it's not that I'm looking to have bulletproof coffee for the reasons it's usually promoted. I just meant to have my coffee with butter as butter is preferable to cream on Carnivore. 😊
    Reply
    33w
    Hayley Pauline
    Pure cream is what I use, thin enough to pour in my tea & can be whipped to use as thick cream too.
    Reply
    33w
    Edited
    Ian Chalmers
    Paul's pure cream, thickened creams has crap added. Just use it like milk
    Reply
    33w
    Christina James
    I use Paul’s cream for my coffee
    Reply
    33w
    Bev Bradley
    Oh and I hate to be a party pooper but strict carnivores won’t have coffee as it comes from a plant. Problem solved.
    Reply
    33w
    Gina DiTrapani
    Author
    Bev Bradley I know 😇. Same goes for pepper and my favourite Cholula hot sauce but I believe there's room for people to make choices that are appropriate for themselves.
    Reply
    33w
    Derek Craig
    For my bulletproof coffee I use mtc and ghee
    Reply
    33w
    Kate Kate
    Yes, pouring cream is the best! Can stand the oil slick from double. And be careful of thickened cream with Carrageenan in it - can cause issues. They removed gelatin from it cos of vegetarians. LOL. Do they not realise once the cow is done producing m… See more
    Reply
    33w
    Dionë Natasha Green
    I buy double cream from Aldi, it's cheaper than the Coles and Woolies brands
    Reply
    33w
    Greg Mack
    I still have coffee Nc have either Paul's cream, or Maleny cream. Sometimes double cream. Just make sure the cream has no other additives like carageenan.
    Reply
    33w
    Bev Bradley
    FYI. America has heavy whipping cream at 36 to 40 percent fat. They don’t have double cream. Down under we have double cream at 48 percent fat.
    Reply
    33w
    Helen Williams
    I have no idea what American double cream is but be careful with anything other than pure cream here in Australia because if it is thickened they use horrible things to thicken it with. There are a couple of brands that are OK but you need to read the … See more
    Reply
    33w
    Norbert Kiraly
    I use woollies thickened cream, always check ingredients, that's thickened with a little beef gelatin only - by thickened, that means will stiffen with cooking and cooling... it's otherwise runnier than pure cream and is 35% milk fat minimum, doesn't l… See more
    Reply
    33w
    Vanessa Garrard
    I personally use grass fed organic butter and grass fed jersey cream non homogenised or Cleopatras ‘body cream’ when I can get it
    Reply
    33w
    Misty Devine
    Vanessa Garrardoh yes.the cream so glorious
    Reply
    33w
    Jennie Grant
    Heavy cream refers to the fat content, and our Paul’s pure cream is the equivalent. I wondered the same for the longest time!
    Reply
    33w
    Matt
    If you get cream just make sure it's purely cream only in the ingredients because some manufacturers add vegetable oil and guar gum or other thickening agents.
    Reply
    33w
    Helen Williams
    This is really nice cream. I eat it for ‘dessert’ like yoghurt. However unlike yoghurt it’s so rich a few teaspoons of it is enough. It’s just cream, 56%.
    Reply
    33w
    Edited
    Helen Williams
    No photo description available.
    Reply
    33w
    Misty Devine
    Helen Williamsshe's lovely💕💜
    Reply
    33w
    Nicola Clinch
    Don't do it! I'm so fat I drink so much cream 🤣😅😭
    Reply
    33w
    Misty Devine
    I use melany grass fed.beautiful..Paul's backup..just pouring cream without anything added.oue bullet proof coffee is unsalted butter coffee and cream.blended..yum
    Reply
    33w
    Angela Oliver
    Heavy cream is cream, in the U.S. milk is called cream so they discribe regular cream as "heavy" cream, confusing.
    Reply
    33w
    Dianne Stevens
    I have used both salted and unsalted butter, both are good. Very yummy if blended (I use a stick blender)
    Reply
    33w
    Kirstzen Jane
    Just make sure it's pure cream with no thickening agents
    Reply
    33w
    Yvonne Gallagher
    I drink Paul’s pure cream like milk. It’s my treat.
    Reply
    33w
    Gina DiTrapani
    Author
    Yvonne Gallagher it's so rich to drink. How much can you drink at a time?
    Reply
    33w
    Yvonne Gallagher
    Gina DiTrapani
    Reply
    33w
    Lynda Johnston
    Gina DiTrapani I use about 50mils in my coffee ☕️
    Reply
    33w
    Yvonne Gallagher
    Maybe half a cup
    Reply
    33w
    Desiree Fielder
    I cut out ALL DAIRY, weight loss ensued, and gut microbiome changed. DAY 716.
    Reply
    33w
    Gina DiTrapani
    Author
    Desiree Fielder yeah I'm thinking that might be the case for me too. I've been gradually cutting out various dairy items but I'm encouraged to read that weight loss was the result for you.
    Reply
    33w
    Diane Mulcahy
    Desiree Fielder I’m the same as Gina. Dairy products are my final hill to climb. Just love ReMilk by Rokeby Farm. Plus jalna lactose free Greek yogurt. Weight loss stalled due to dairy I’m sure. Sad but true.
    Reply
    33w
    Gina DiTrapani
    Author
    Diane Mulcahy omg Jalna Full Cream Greek Yoghurt was my jam for months and months. Couldn't get enough! I would have it with (defrosted) frozen cherries and incredible Brookfarm Keto Granola. It was truly an addiction and I'm starting to see the light … See more
    Reply
    33w
    Desiree Fielder
    Gina DiTrapani you CAN do it!
    Reply
    33w
    Desiree Fielder
    Also no coffee, and did OMAD, but quite slim now so eat when necessary.
    Reply
    33w
    Desiree Fielder
    Gut took about 6 months, it's NOT easy cravings, but keep saturated fats up, and celtic sea salt too.
    Reply
    33w
    Gina DiTrapani
    Author
    Desiree Fielder why Celtic sea salt? I use iodised on GP's advice. (This GP is pro- Carnivore.)
    Reply
    33w
    Edited
    Desiree Fielder
    Gina DiTrapani I use iodised salt too.
    Reply
    33w
    Paige Szabadics
    I use "Whipping Cream". Works well, no oil slick - unless you get a blob of more solid cream, which does happen sometimes. I use the Harvey Fresh brand because I'm in WA.
    Reply
    33w
    Jen Sugar-Wilson Sydney
    Hey MCT oil isn't that good. I tested it on lion and got a bad side affect.
    Reply
    33w
    Daryl Gleeson
    Thickened. Cream doesn't have lactose
    Reply
    33w
    Kate Tuhoro
    I use Drake’s (ex IGA) ‘Value’ brand cream, which is a generic, therefore cheaper, brand. It only has gelatine as a thickener, which is basically a collagen from cows. So it’s a win: win for me. All other creams have crap in them as thickeners!
    Reply
    33w
    Gail Patricia
    Try to get pure cream...no additives.
    My husband puts it in the frother with milk 40 milk, 30 cream and 30 water.
    Reply
    33w
    Rae Rae
    Pauls pure cream is amazing in coffee...we shake it first to make it frothy
    Reply
    33w
    

    DATA
    
    comments = parse_data(data)
    puts JSON.pretty_generate(comments)
  
    tp comments
  end

  
  # it 'turn message into file name and title' do
  #   # sample_convo = File.read('spec/sample_files/carnivore/sample-convo1.txt')
  #   # sample_convo_short_summary_answer = 'Discussion on the necessity of electrolyte supplementation while following a carnivore diet.' #PART OF CONVO1

  #   sample_convo = File.read('spec/sample_files/carnivore/sample-convo-2.txt')
  #   sample_convo_short_summary_answer = "The thread discusses fiber's role in diet, oxalate dumping effects, and carnivore diet experiences"

  #   real_convo = File.read('spec/sample_files/carnivore/real-convo.txt')

  #   chatbot = CB
  #             .start(store: :save_last_file)
  #             .system_prompt('You are an expert in the Carnivore and Lion Diet, you will help with my research,  say "YAY" if you understand')
  #             .bot('YAY')
  #             .ask("Can you create a short summary from this conversation, 15 words or less.\n\n#{sample_convo}")
  #             .bot(sample_convo_short_summary_answer)
  #             .ask('Can you create a file name about this conversation in less then 80 characters, the format should be "some-file-in-lowercase"')
  #             .bot('electrolyte-supplementation-on-carnivore-diet-discussion.txt')
  #             .ask(
  #               <<~QUESTION
  #                 Can you create a short summary from this conversation and a filename
                  
  #                 Can you put it in a JSON structure in this format {"filename": "some-file-name.txt", title: "Useful title about convo"}
                    
  #                 Work from this convo: \n\n#{real_convo}
  #               QUESTION
  #             )
  #             .chat

  #   # chatbot.bot(chatbot.content) # I need to make this a part of the saved file
  #   data = JSON.parse(chatbot.content, symbolize_names: true)
  #   # L.debug_chatbot chatbot

  #   # L.block real_convo, title: 'Real Convo'
  #   puts JSON.pretty_generate(data)

  #   # chatbot.store.open_in_editor
  #   # CONVO-1
  #   # {:filename=>"carnivore-diet-meal-variety-discussion.txt", :title=>"Discussion on Meal Variety in Carnivore Diet"}
  #   # CONVO-2
  #   # {:filename=>"carnivore-diet-variety-discussion.txt", :title=>"Exploring Variety in Carnivore Diet"}

  #   # binding.pry
  # end

  # fit 'turn conversation into a well formed JSON structure' do
  #   sample_convo = File.read('spec/sample_files/carnivore/sample-convo-1.txt')
  #   sample_convo_answer_as_json =  File.read('spec/sample_files/carnivore/sample-convo-1.json')

  #   real_convo = File.read('spec/sample_files/carnivore/real-convo.txt')

  #   chatbot = CB
  #     .start(store: :save_last_file, max_tokens: 512)
  #     .system_prompt('You are an expert in the Carnivore and Lion Diet, you will help with my research,  say "YAY" if you understand')
  #     .bot('YAY')
  #     .ask("#{question_message_to_json}\n\n#{sample_convo}")
  #     .bot(sample_convo_answer_as_json)
  #     .ask("I am going to give you another conversation, can you convert it to a JSON structure like the one above?: \n\n#{real_convo}")
  #     .chat

  #   # chatbot.bot(chatbot.content) # I need to make this a part of the saved file
  #   L.debug_chatbot chatbot, include_json: true

  #   if chatbot.finish_reason == 'length'
  #     chatbot.ask('continue').chat
  #   end
  # end

  # def question_message_to_json
  #   <<~QUESTION

  #   I am going to give you data that is from a facebook group question.

  #   There will be a question by a person and then there will be one or more replies, each reply may also have child replies, I need the following information:
    
  #   Question and who asked it
  #   Replies and who said them
    
  #   Can you convert this data into a JSON, don't truncate?

  #   QUESTION
  # end
end
