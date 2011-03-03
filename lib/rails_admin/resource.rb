module RailsAdmin
  class Resource
    attr_reader :fields
    def initialize(model)
      @abstract_model = RailsAdmin::AbstractModel.new(model)
      prepare_fields
    end

    def prepare_fields
      @fields = []
      @abstract_model.properties.each do |property|
        @fields << property[:name]
      end
      @abstract_model.associations.each do |association|
        @fields << association[:name]
      end  
    end
    private :prepare_fields
  end
end
