module Analytics
  module Model
    module Stream
      @@stream_columns = [
        'started_at as visit_started_at',
        'ended_at as visit_ended_at',
        'sessions.timezone as timezone',
        'sessions.duration as visit_duration',
        'a.name as account',
        'pr.name as property',
        'campaign_name',
        'co.name as campaign_content',
        'campaign_medium',
        'campaign_source',
        'sessions.contact_code as contact_code',
        'visitor',
        'visit',
        'page_views',
        'event_count',
        'os_name',
        'os_version',
        'device',
        'device_vendor',
        'mobile_device',
        'browser',
        'browser_version',
        'email_client',
        'language',
        'screen_size',
        'color_depth',
        'charset',
        'flash_version',
        'ip_address',
        'locality',
        'region',
        'country',
        'latitude',
        'longitude',
        'search_terms',
        'traffic_source',
        'referrer_category'
      ].join(', ')
      
      def stream(params = {})
        table = proxy_owner.class.table_name
        foreign_key = table.singularize
        proxy_id = proxy_owner['id']
        period = Period.from_params(params)
        ip_filter = Account.current_account.ip_filter_sql
        ip_filter_sql = "AND #{ip_filter}" if ip_filter
        find_by_sql <<-EOF
          SELECT 
            #{@@stream_columns}
          FROM sessions 
            inner join #{table} on sessions.#{foreign_key}_id = #{table}.id
            inner join accounts a         on sessions.account_id  = a.id
            left outer join campaigns cm  on sessions.campaign_id = cm.id
            left outer join contents co   on sessions.content_id  = co.id
            left outer join properties pr on sessions.property_id = pr.id
          WHERE
            #{table}.id = #{proxy_id}
            AND started_at > '#{period.first.to_s(:db)}' AND started_at < '#{period.last.to_s(:db)}'
            #{ip_filter_sql}
        EOF
      end
    end
  end
end