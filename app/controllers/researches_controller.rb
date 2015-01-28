class ResearchesController < ApplicationController

  # GET /researches
  # GET /researches.json
  def index
  end

  def create
    @neo = Neography::Rest.new
    node_check = @neo.execute_query("START a = node(*) RETURN ID(a), a.name;")["data"].collect{|n| {"id" => n[0], "name" => n[1]} }
    if node_check.empty?
      create_person
      add_aspect_map
    end
    #mapid = @neo.execute_query("START n = node(*) MATCH (n) WHERE n.name = 'Tenebrae' RETURN ID(n);")["data"]
    #map = @neo.get_node(mapid)
    # add_aspect_map
    aspect_from_object = Aspect.find(research_params[:aspect_from])
    aspect_to_object = Aspect.find(research_params[:aspect_to])
    aspect_from = get_node(aspect_from_object.aspect)
    aspect_to = get_node(aspect_to_object.aspect)
    min_distance = (research_params[:min_distance].to_i + 1)
    #route =degrees_of_separation(aspect_from.first, aspect_to.first, research_params[:min_distance].to_i)
    route = []
    degrees_of_separation(aspect_to.first, aspect_from.first, min_distance).each do |path|
      if path["names"].size > min_distance
        route << "Distance: #{(path["names"].size - 2 )} Path: #{path["names"].join(' => ')}"
      end
    end
    respond_to do |format|
      flash[:notice] = route.join("<br />").html_safe
      format.html { redirect_to root_url }
    end
  end
  def create_person
    aspects = Aspect.all
    aspects.each { |aspect|
      @neo.create_node("name" => aspect.aspect)
    }
  end

  def add_aspect_map
    aspects = Aspect.all
    aspects.each { |aspect|
      if !aspect.component2.empty?
        aspect_aspect = get_node(aspect.aspect)
        aspect_component1 = get_node(aspect.component1)
        aspect_component2 = get_node(aspect.component2)
        @neo.create_relationship("aspect", @neo.get_node(aspect_aspect.first), @neo.get_node(aspect_component1.first))
        @neo.create_relationship("aspect", @neo.get_node(aspect_component1.first), @neo.get_node(aspect_aspect.first))
        @neo.create_relationship("aspect", @neo.get_node(aspect_aspect.first), @neo.get_node(aspect_component2.first))
        @neo.create_relationship("aspect", @neo.get_node(aspect_component2.first), @neo.get_node(aspect_aspect.first))
      end
    }
  end

  def get_node(aspect)
    @neo.execute_query("START n = node(*) MATCH (n) WHERE n.name = '#{aspect}' RETURN ID(n);")["data"]
  end

  def degrees_of_separation(start_node, destination_node, depth)
    # paths =  @neo.get_paths(start_node,
    #                         destination_node,
    #                         {"type"=> "aspect", "direction" => "in"},
    #                         depth=7,
    #                         algorithm="allPaths")
    paths = @neo.get_paths(start_node,
      destination_node,
      {"type"=> "aspect", "direction" => "in"},
      depth=depth,
      algorithm="allPaths"
    )
    #paths = @neo.get_paths(start_node, destination_node, {"type" => "aspect"})
    #paths = @neo.get_node_relationships(start_node)
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
