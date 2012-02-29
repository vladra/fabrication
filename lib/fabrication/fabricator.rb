class Fabrication::Fabricator

  class << self

    def define(name, options={}, &block)
      raise Fabrication::DuplicateFabricatorError, "'#{name}' is already defined" if schematics.include?(name)
      aliases = Array(options.delete(:aliases))
      schematic = schematics[name] = schematic_for(name, options, &block)
      Array(aliases).each do |as|
        schematics[as.to_sym] = schematic
      end
      schematic
    end

    def generate(name, options={}, overrides={}, &block)
      Fabrication::Support.find_definitions if schematics.empty?
      raise Fabrication::UnknownFabricatorError, "No Fabricator defined for '#{name}'" unless schematics.has_key?(name)
      schematics[name].generate(options, overrides, &block)
    end

    def schematics
      @schematics ||= {}
    end

    private

    def class_name_for(name, parent, options)
      options[:class_name] ||
        (parent && parent.klass.name) ||
        options[:from] ||
        name
    end

    def schematic_for(name, options, &block)
      parent = schematics[options[:from]]
      class_name = class_name_for(name, parent, options)
      klass = Fabrication::Support.class_for(class_name)
      raise Fabrication::UnfabricatableError, "No class found for '#{name}'" unless klass
      if parent
        parent.merge(&block).tap { |s| s.klass = klass }
      else
        Fabrication::Schematic.new(klass, &block)
      end
    end

  end

end
