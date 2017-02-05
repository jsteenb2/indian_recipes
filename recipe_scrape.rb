require 'mechanize'
require 'open-uri'
require 'pry-byebug'

class RecipeScraper
    attr_reader :pages
    def initialize
        @agent = Mechanize.new
        @pages = {}
        @page = @agent.get('http://www.rachnas-kitchen.com')
    end

    def grab_categories
        find_links(@page, "#menu-secondary-menu li", @pages)
    end

    def grab_recipes
        @pages.each do |title, node_obj|
            category_page = node_obj[:node].click
            recipe_links = find_links(category_page, "#genesis-content h2 a")
            node_obj[:recipes] = recipe_links
        end
    end

    def build_recipes
        @pages.each do |title, node_obj|
            node_obj[:recipes].each do |recipe_node|
                write_recipe(recipe_node, node_obj)
                binding.pry
            end
        end
    end

    private 

        def format_page_info(link_node, category_node)
            title = link_node[:node].text.split("|")[0].strip
            file_name = title.to_s.downcase.split(" ").join("_") + ".txt"
            recipe_header = "#{ title } courtesy #{ url }"
            {
                page_url: link_node[:node].href,
                page_title: title,
                file_name: file_name,
                recipe_header: recipe_header
            }
        end

        def write_recipe(link_node, category_node)
            file_info = format_page_info(link_node, category_node)
            # url = link_node[:node].href
            # title = link_node[:node].text.split("|")[0].strip
            # file_name = title.to_s.downcase.split(" ").join("_") + ".txt"
            # next if File.exists? file_name

            doc = Nokogiri::HTML(open(file_info[:url])) 

            ingredients = doc.css '.ingredient'
            instructions = doc.css '.instruction'
            

            # recipe_title = "#{ title } courtesy #{ url }" 

            File.open(file_name, 'w+') do |file|
                file.puts file_info[:recipe_header]
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

        def find_links(page, selector, container = {})
            link_texts = find_link_text(page, selector)
            link_texts.map do |link_text|
                container[link_text] = {
                    node: page.links.find { |link| link_text == link.text }
                }
            end
        end

        def find_link_text(page, selector)
            page.css(selector)
                .map { |link| link.text }
                .reject { |link_text| (link_text == "\n") || 
                                    (link_text.downcase.include? "video") 
                        }
        end
end

go_get_em = RecipeScraper.new
go_get_em.grab_categories
go_get_em.grab_recipes
go_get_em.build_recipes
pp go_get_em.pages


# recipes.each do |key, value|
    # file_name = key.to_s.downcase.split(" ").join("_") + ".txt"
    # next if File.exists? file_name

    # doc = Nokogiri::HTML(open(value)) 

    # ingredients = doc.css('.ingredient')
    # instructions = doc.css '.instruction'
    

    # recipe_title = "#{ key.to_s } courtesy #{ value }" 

    # File.open(file_name, 'w+') do |file|
    #     file.puts recipe_title
    #     file.puts

    #     file.puts "INGREDIENTS"
    #     file.puts "------------"
    #     ingredients.each do |ingredient|
    #         file.puts ingredient.text
    #     end
        
    #     file.puts
    #     file.puts "INSTRUCTIONS"
    #     file.puts "------------"

    #     instructions.each_with_index do |instruction, index|
    #         instr_line = "#{index + 1}) #{instruction.text}"
    #         file.puts instr_line
    #     end
    # end
# end