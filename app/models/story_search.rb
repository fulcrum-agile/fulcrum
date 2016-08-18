class StorySearch
  SEARCH_RESULTS_LIMIT = 30
  attr_reader :project, :query_params, :parsed_params, :conditions

  def initialize(project, query_params)
    @project       = project
    @query_params  = query_params
    @parsed_params = []
    @conditions    = {}
    parse(query_params)
  end

  def search
    relation = @project.stories
    relation = relation.search(@parsed_params.join(' '))
    relation = relation.where(@conditions) if @conditions.size > 0
    relation.limit(SEARCH_RESULTS_LIMIT)
  end

  private

  def parse(query_params)
    query_params.split(' ').each do |token|
      if token =~ /^(.+?)\:(.+?)$/
        @conditions.merge!($1 => $2)
      else
        @parsed_params << token
      end
    end
  end
end
