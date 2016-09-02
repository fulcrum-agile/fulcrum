class StorySearch
  SEARCH_RESULTS_LIMIT = 40
  attr_reader :relation, :query_params, :parsed_params, :conditions

  def self.query(relation, query_params)
    new(relation, query_params).search
  end

  def self.labels(relation, query_params)
    new(relation, query_params).labels
  end

  def initialize(relation, query_params)
    @relation      = relation
    @query_params  = query_params
    @parsed_params = []
    @conditions    = {}
    parse(query_params)
  end

  def search
    add_conditions_to :search
  end

  def search_labels
    add_conditions_to :search_labels
  end

  private

  def parse(query_params)
    query_params.split(' ').each do |token|
      if token =~ /^(.+?)\:(.+?)$/
        conditions.merge!($1 => $2)
      else
        parsed_params << token
      end
    end
  end

  def add_conditions_to(search_method)
    new_relation = relation.with_dependencies.send(search_method, parsed_params.join(' '))
    new_relation = relation.where(conditions) if conditions.size > 0
    new_relation.limit(SEARCH_RESULTS_LIMIT)
  end
end
