module Analytics
  module Model
    module Filters
      def self.included(base)
        base.class_eval do
          named_scope :between, lambda {|*args|
            return {} unless args.last
            range = args.last
            this_scope = "started_at BETWEEN '#{range.first.to_s(:db)}' AND '#{range.last.to_s(:db)}'"
            parent_scope = self.scoped_methods.last[:find] unless self.scoped_methods.last.nil?
            if parent_scope == self.repeat_visitors.proxy_options ||
               parent_scope == self.repeat_visits.proxy_options
              this_scope += " AND previous_visit_at > '#{range.first.to_s(:db)}'"
            end
            if parent_scope == self.return_visitors.proxy_options ||
               parent_scope == self.return_visits.proxy_options
              this_scope += " AND previous_visit_at < '#{range.first.to_s(:db)}'"
            end
            {:conditions => this_scope}
          }

          named_scope :by, lambda {|*args|
            return {} unless args.last
            args = args.last.flatten if args.last.is_a?(Array)
  
            # Args are passed as SELECT and GROUP clauses
            # with special attention paid to :day, :month, :year, :hour
            # configurations because they manipulate the #tracked_at formation
            #
            # Note that this also controls the grouping since we add each
            # argument to both the SELECT and GROUP.  This simplifies reporting
            # on either aggregate events (ie. 43 page views this month) versus
            # more fine-grained reporting.
            select = []; group = []; joins = []; conditions = []
            args.each do |dim|
              dim = dim.to_sym
              if self.scopes[dim]
                # It's a named scope
                scope_options = self.send(dim).proxy_options
                select << scope_options[:select]  if scope_options[:select]
                group << scope_options[:group]    if scope_options[:group]
                conditions << scope_options[:conditions] if scope_options[:conditions]
                joins << scope_options[:joins]    if scope_options[:joins]
              else
                dimension = dim.to_s
                select << dimension
                group << dimension
                conditions << "#{dimension} IS NOT NULL" if non_null_dimensions.include?(dim)
                joins << :events if Event.columns_hash[dimension.to_s]
              end
            end
            {:select => select.join(', '), :conditions => conditions.uniq.join(' AND '), :group => group.uniq.join(', '), :joins => joins.uniq}
          }
          
          # Only when the campaign (or other resource) is active (ie. after effective date)
          named_scope :active, lambda {|resource|
            if resource && resource.respond_to?(:effective_at) && resource.effective_at
              {:conditions => ["started_at >= ?", resource.effective_at]}
            else
              {}
            end
          }
          
          named_scope :ip_filter, lambda {
            if Account.current_account.ip_filter_sql.blank?
              {}
            else
              {:conditions => Account.current_account.ip_filter_sql}
            end
          }
          
          # Composing three filters; a buit ugly but helps DRY a lot.
          # Assumes these names_scopes only apply conditions
          # See also http://stackoverflow.com/questions/1482940/combine-two-named-scopes-with-or-instead-of-and
          named_scope :filters, lambda {|params|
            conditions = []
            conditions << self.active(self).proxy_options[:conditions]
            conditions << self.ip_filter.proxy_options[:conditions]
            conditions << self.between(Period.from_params(params)).proxy_options[:conditions]
            {:conditions => self.merge_conditions(*conditions)}
          }
        end
      end
    end
  end
end
