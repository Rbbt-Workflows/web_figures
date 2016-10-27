require 'rbbt/workflow'
url = "https://github.com/novus/nvd3/tarball/master"

module WebFigures
  extend Workflow

  def self.values2d3(data)
    data = data.to_single if data.respond_to? :to_single and not data.type == :single

    values = []
    data.each do |key, value|
      name = key.respond_to?(:name) ? key.name || key : key
      values << {:label => name, :value => value}
    end

    values
  end
end
