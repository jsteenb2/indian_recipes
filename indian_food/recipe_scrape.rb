require 'nokogiri'
require 'open-uri'

recipes = {
    "Chicken Vindaloo": 'http://www.rachnas-kitchen.com/chicken-vindaloo/',
    "Tamarind Chutney": 'http://www.rachnas-kitchen.com/sweet-tamarind-chutney-saunth-chutney-tamarind-sauce/',
    "Mint Chutney": 'http://www.rachnas-kitchen.com/green-chutney-recipe/',
    "Hyderabadi Chicken Biryani": 'http://www.rachnas-kitchen.com/hyderabadi-chicken-biryani-recipe/',
    "Chicken Korma": 'http://www.rachnas-kitchen.com/chicken-korma-recipe/',
    "Kadai Chicken": "http://www.rachnas-kitchen.com/kadai-chicken-recipe-chicken-karahi/",
    "Butter Chicken": 'http://www.rachnas-kitchen.com/indian-butter-chicken-curry/',
    "Instant Whole Wheat Naan": 'http://www.rachnas-kitchen.com/whole-wheat-naan-naan-recipe-without-yeast/',
    "Butter Naan": "http://www.rachnas-kitchen.com/naan-bread-recipe/",
    "Makki Ki Roti": 'http://www.rachnas-kitchen.com/makki-ki-roti-how-to-make-makki-di-roti/',
    "Mango Lassi": 'http://www.rachnas-kitchen.com/mango-lassi-recipe/',
    "Masoor Dal": 'http://www.rachnas-kitchen.com/masoor-dal-recipe/',
    "Dal Fry": 'http://www.rachnas-kitchen.com/dal-fry-recipe/',
    "Dal Makhani": 'http://www.rachnas-kitchen.com/traditional-dal-makhani-recipe/',
    "Kadia Palak": 'http://www.rachnas-kitchen.com/kadai-paneer-recipe-restaurant-style/',
    "Palak Paneer": 'http://www.rachnas-kitchen.com/palak-paneer-recipe/',
    "Homemade Ghee": 'http://www.rachnas-kitchen.com/how-to-make-ghee/'
}

recipes.each do |key, value|
    file_name = key.to_s.downcase.split(" ").join("_") + ".txt"
    next if File.exists? file_name

    doc = Nokogiri::HTML(open(value)) 

    ingredients = doc.css('.ingredient')
    instructions = doc.css '.instruction'
    

    recipe_title = "#{ key.to_s } courtesy #{ value }" 

    File.open(file_name, 'w+') do |file|
        file.puts recipe_title
        file.puts

        file.puts "INGREDIENTS"
        file.puts "------------"
        ingredients.each do |ingredient|
            file.puts ingredient.text
        end
        
        file.puts
        file.puts "INSTRUCTIONS"
        file.puts "------------"

        instructions.each_with_index do |instruction, index|
            instr_line = "#{index + 1}) #{instruction.text}"
            file.puts instr_line
        end
    end
end