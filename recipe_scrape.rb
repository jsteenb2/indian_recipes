require 'mechanize'
require 'open-uri'
require 'fileutils'
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
                # binding.pry
            end
        end
    end

    private 

        def format_page_info(link_node, category_node)
            url = link_node[:node].href
            title = link_node[:node].text.split("|")[0].strip
            file_name = title.to_s.downcase.split(" ").join("_") + ".txt"
            recipe_header = "#{ title } courtesy #{ url }"
            category_name = category_node[:node].text.split(" ").join("_")
            file_loc = "rachnas-kitchen/#{category_name}/#{file_name}"
            {
                page_url: url,
                page_title: title,
                file_name: file_name,
                file_loc: file_loc,
                recipe_header: recipe_header,
                category_name: category_name
            }
        end

        def create_dir(file_obj)
            home_dir_name = 'rachnas-kitchen'
            FileUtils.makedirs(home_dir_name) unless Dir.exists? home_dir_name
            
            cat_dir_name = "#{home_dir_name}/#{file_obj[:category_name]}"
            FileUtils.makedirs(cat_dir_name) unless Dir.exists? cat_dir_name
        end

        def get_doc_info(file, doc, section)
            doc_info = doc.css ".#{section}"
            file.puts
            file.puts "#{section}"
            file.puts "------------"
            doc_info.each_with_index do |node, index|
                file.puts section == 'ingredient' ? node.text : "#{index + 1}) #{node.text}"
            end
        end

        def write_recipe(link_node, category_node)
            file_info = format_page_info(link_node, category_node)
            return if File.exists? file_info[:file_loc]
            doc = Nokogiri::HTML(open(file_info[:page_url])) 
            create_dir(file_info)
            File.open(file_info[:file_loc], 'w+') do |file|
                file.puts file_info[:recipe_header]
                get_doc_info(file, doc, "ingredient")
                get_doc_info(file, doc, "instruction")
            end
            puts "Successfully created file: #{file_info[:file_name]}"
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