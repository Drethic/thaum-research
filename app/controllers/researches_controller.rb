class ResearchesController < ApplicationController

  # GET /researches
  # GET /researches.json
  def index
  end

  def create
    @neo = Neography::Rest.new
    @neo.inspect
    respond_to do |format|
      format.html { redirect_to root_url, notice: "From: #{@neo.create_relationship("test", "a", "b")}" }
    end
    # aspect_from = Aspect.find(research_params[:aspect_from])
    # aspect_to = Aspect.find(research_params[:aspect_to])
    # create_person
    # degrees_of_separation(aspect_to.aspect, aspect_from.aspect).each do |path|
    #   puts "#{(path["names"].size - 1 )} Path: " + path["names"].join(' => ')
    # end
  end
  def create_person
    aspects = Aspect.all
    aspects.each { |aspect|
      @neo.create_node("name" => aspect.aspect)
      make_mutual_friends(aspect.component1, aspect.component2)
    }
  end
  
  def make_mutual_friends(node1, node2)
    @neo.create_relationship("aspect", node1, node2)
    @neo.create_relationship("aspect", node2, node1)
  end
  
  def degrees_of_separation(start_node, destination_node)
    paths =  @neo.get_paths(start_node, 
                            destination_node, 
                            {"type"=> "aspect", "direction" => "in"},
                            depth=4, 
                            algorithm="shortestPath")
    paths.each do |p|
     p["names"] = p["nodes"].collect { |node| 
       @neo.get_node_properties(node, "name")["name"] }
    end
  end
  private
    # Never trust parameters from the scary internet, only allow the white list through.
    def research_params
      params.require(:index).permit(:aspect_from, :aspect_to, :min_distance)
    end
  # def create
  #   @aspect_from = Aspect.find(research_params[:aspect_from])
  #   @aspect_to = Aspect.find(research_params[:aspect_to])
  #   @min_distance = research_params[:min_distance].to_i
  #   @current_step = 1
  #   @steps = []
  #   @alternate_route = []
  #   respond_to do |format|
  #     format.html { redirect_to root_url, notice: "From: #{@aspect_from.inspect}, To: #{@aspect_to.inspect}, Min Distance: #{@min_distance}, Current Step: #{@current_step}, Possible steps: #{compare_step_chance}" }
  #   end
  # end
  # private
  #   # Never trust parameters from the scary internet, only allow the white list through.
  #   def research_params
  #     params.require(:index).permit(:aspect_from, :aspect_to, :min_distance)
  #   end
    
  #   def is_primal(aspect)
  #     aspect.component1 == "Primal" ? true : false
  #   end
    
  #   def possible_steps(aspect)
  #     Aspect.select(:id, :aspect).where("component1 = ? or component2 = ?", aspect.aspect, aspect.aspect)
  #   end
    
  #   def compare_step_chance
  #     possible_steps_local = []
  #     aspect_from = @current_step == 1 ? possible_steps(@aspect_from) : @steps[@current_step - 2]
  #     aspect_to = possible_steps(@aspect_to)
  #     steps = aspect_from & aspect_to
  #     if @current_step <= @min_distance && steps.any?
  #       steps.each { |step|
  #         possible_steps_local << step.aspect
  #       }
  #       @current_step += 1
  #       @steps.push(possible_steps_local)
  #       compare_step_chance
  #     elsif @current_step <= @min_distance
  #       # @steps.push(aspect_from)
  #       @steps.push(["from"])
  #       @current_step += 1
  #       compare_step_chance
  #     else
  #       @steps
  #     end
  #   end
    
  #   def find_alternate_route(aspect_from, aspect_to)
      
  #   end
end
