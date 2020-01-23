class DemeterCop
  GLOBAL_REPORTER = {}

  def self.clear!(watched_class = nil)
    if watched_class.nil?
      GLOBAL_REPORTER.clear
    else
      GLOBAL_REPORTER.delete(watched_class)
    end
  end

  def self.report(watched_class = nil)
    if watched_class.nil?
      GLOBAL_REPORTER
    else
      GLOBAL_REPORTER[watched_class]
    end
  end

  def self.watch(object, reporter: reporter_for_object(object))
    Wire.attach(object, reporter: reporter )
  end

  def self.reporter_for_object(object)
    GLOBAL_REPORTER[object.class] ||= {}
    GLOBAL_REPORTER[object.class]
  end

  module Wire
    # These can be considered "non-worrying" as they're pretty much core types,
    # meaning they have stable interface and calling their methods is less of a
    # Law of Demeter violation
    EXCLUDED_CLASSES = [Object, String, Hash, Time, ]
    EXCLUDED_CLASSES << 'ActiveSupport::TimeWithZone'.constantize if defined?(ActiveSupport::TimeWithZone)

    # These classes ruby passes by value and don't have singleton classes for us to prepend
    EXCLUDED_BASE_CLASSES = [Symbol, Integer, Float, NilClass, TrueClass, FalseClass]
    EXCLUDED_CLASSES << 'BigDecimal'.constantize if defined?(BigDecimal)

    def self.attach(target, trace: [], reporter: {}, limit_left: 5)
      return target if limit_left == 0 || EXCLUDED_CLASSES.include?(target.class) || EXCLUDED_BASE_CLASSES.any? { |c| target.class <= c }

      middleman = Module.new
      methods_to_watch(target).each do |name|
        middleman.define_method(name) do |*args, &block|
          result = super(*args, &block)
          new_trace = [*target._demeter_cop_previous_trace, name]
          _demeter_cop_reporter[new_trace] = {location: caller.first}
          Wire.attach(result, trace: new_trace, reporter: _demeter_cop_reporter, limit_left: limit_left - 1)
          result
        end
      end

      middleman.define_method(:_demeter_cop_previous_trace) { trace }
      middleman.define_method(:_demeter_cop_reporter) { reporter }

      target.singleton_class.prepend(middleman)
      target
    end

    def self.methods_to_watch(target)
      (target.public_methods(false) - [:_demeter_cop_previous_trace, :_demeter_cop_reporter])
        .select { |name| name.to_s.length > 3 }
    end
  end
end
