CREATE TABLE `account_users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `role_mask` int(11) DEFAULT NULL,
  `tags` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_account_users_on_account_id_and_user_id` (`account_id`,`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=47 DEFAULT CHARSET=utf8;

CREATE TABLE `accounts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(20) DEFAULT NULL,
  `description` text,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `logo_file_name` varchar(255) DEFAULT NULL,
  `logo_content_type` varchar(255) DEFAULT NULL,
  `logo_file_size` int(11) DEFAULT NULL,
  `theme` varchar(255) DEFAULT NULL,
  `tracker` varchar(15) DEFAULT NULL,
  `agent_id` int(11) DEFAULT NULL,
  `email_from` varchar(50) DEFAULT NULL,
  `email_from_name` varchar(50) DEFAULT NULL,
  `email_reply_to` varchar(50) DEFAULT NULL,
  `email_reply_to_name` varchar(50) DEFAULT NULL,
  `unsubscribe_url` varchar(255) DEFAULT NULL,
  `kind` varchar(10) DEFAULT NULL,
  `custom_domain` varchar(100) DEFAULT NULL,
  `timezone` varchar(20) DEFAULT NULL,
  `salutation` varchar(100) DEFAULT NULL,
  `currency_code` varchar(3) DEFAULT NULL,
  `default_locale` varchar(10) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_accounts_on_tracker` (`tracker`),
  UNIQUE KEY `index_accounts_on_name` (`name`),
  UNIQUE KEY `index_accounts_on_custom_domain` (`custom_domain`),
  KEY `index_accounts_on_agent_id` (`agent_id`)
) ENGINE=InnoDB AUTO_INCREMENT=20 DEFAULT CHARSET=utf8;

CREATE TABLE `addresses` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `contact_id` int(11) DEFAULT NULL,
  `street` varchar(255) DEFAULT NULL,
  `locality` varchar(255) DEFAULT NULL,
  `country` varchar(255) DEFAULT NULL,
  `postalcode` varchar(10) DEFAULT NULL,
  `kind` varchar(10) DEFAULT NULL,
  `region` varchar(255) DEFAULT NULL,
  `preferred` tinyint(1) DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_addresses_on_contact_id` (`contact_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `affiliations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `contact_id` int(11) DEFAULT NULL,
  `type` varchar(10) DEFAULT NULL,
  `affiliate_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_affiliations_on_affiliate_id` (`affiliate_id`),
  KEY `index_affiliations_on_contact_id` (`contact_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `backgrounds` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `contact_id` int(11) DEFAULT NULL,
  `description` text,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `campaigns` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `description` text,
  `cost` int(11) DEFAULT NULL,
  `distribution` int(11) DEFAULT NULL,
  `bounces` int(11) DEFAULT NULL,
  `unsubscribes` int(11) DEFAULT NULL,
  `code` varchar(10) DEFAULT NULL,
  `created_by` int(11) DEFAULT NULL,
  `updated_by` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `effective_at` datetime DEFAULT NULL,
  `source` varchar(255) DEFAULT NULL,
  `content` varchar(255) DEFAULT NULL,
  `contact_code` varchar(255) DEFAULT NULL,
  `medium` varchar(255) DEFAULT NULL,
  `email_from` varchar(50) DEFAULT NULL,
  `email_from_name` varchar(50) DEFAULT NULL,
  `email_reply_to` varchar(50) DEFAULT NULL,
  `email_reply_to_name` varchar(50) DEFAULT NULL,
  `unsubscribe_url` varchar(255) DEFAULT NULL,
  `content_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_campaigns_on_account_id` (`account_id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8;

CREATE TABLE `cities` (
  `city` int(11) NOT NULL AUTO_INCREMENT,
  `country` int(11) NOT NULL DEFAULT '0',
  `name` varchar(200) NOT NULL DEFAULT '',
  `lat` float DEFAULT NULL,
  `lng` float DEFAULT NULL,
  `state` varchar(64) NOT NULL DEFAULT '',
  PRIMARY KEY (`city`),
  KEY `kCountry` (`country`),
  KEY `kName` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `cityByCountry` (
  `city` int(11) NOT NULL AUTO_INCREMENT,
  `country` int(11) NOT NULL DEFAULT '0',
  `name` varchar(200) NOT NULL DEFAULT '',
  `lat` float DEFAULT NULL,
  `lng` float DEFAULT NULL,
  `state` varchar(64) NOT NULL DEFAULT '',
  PRIMARY KEY (`city`),
  KEY `kCountry` (`country`),
  KEY `kName` (`name`)
) ENGINE=MyISAM AUTO_INCREMENT=37419 DEFAULT CHARSET=latin1;

CREATE TABLE `comments` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `title` varchar(255) DEFAULT '',
  `comment` text,
  `commentable_id` int(11) DEFAULT NULL,
  `commentable_type` varchar(255) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_comments_on_commentable_id` (`commentable_id`),
  KEY `index_comments_on_commentable_type` (`commentable_type`),
  KEY `index_comments_on_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `contacts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `given_name` varchar(255) DEFAULT NULL,
  `family_name` varchar(255) DEFAULT NULL,
  `salutation_template` varchar(255) DEFAULT NULL,
  `nickname` varchar(20) DEFAULT NULL,
  `name` varchar(100) DEFAULT NULL,
  `locale` varchar(50) DEFAULT NULL,
  `timezone` varchar(50) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `account_id` int(11) DEFAULT NULL,
  `role` varchar(255) DEFAULT NULL,
  `profile` varchar(255) DEFAULT NULL,
  `photo_file_name` varchar(255) DEFAULT NULL,
  `photo_content_type` varchar(255) DEFAULT NULL,
  `photo_file_size` int(11) DEFAULT NULL,
  `created_by` int(11) DEFAULT NULL,
  `updated_by` int(11) DEFAULT NULL,
  `organization_id` int(11) DEFAULT NULL,
  `gender` varchar(10) DEFAULT 'unknown',
  `role_function` varchar(50) DEFAULT NULL,
  `role_level` varchar(50) DEFAULT NULL,
  `name_order` varchar(2) DEFAULT NULL,
  `honorific_prefix` varchar(50) DEFAULT NULL,
  `honorific_suffix` varchar(50) DEFAULT NULL,
  `type` varchar(20) DEFAULT NULL,
  `employees` int(11) DEFAULT NULL,
  `revenue` int(11) DEFAULT NULL,
  `contact_code` varchar(50) DEFAULT NULL,
  `currency_code` varchar(3) DEFAULT NULL,
  `industry` varchar(100) DEFAULT NULL,
  `industry_code` varchar(5) DEFAULT NULL,
  `birthday` date DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_contacts_on_family_name` (`family_name`),
  KEY `index_contacts_on_given_name` (`given_name`),
  KEY `index_contacts_on_name` (`name`),
  KEY `index_contacts_on_account_id_and_contact_code` (`account_id`,`contact_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `content_variants` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `content_id` int(11) DEFAULT NULL,
  `name` varchar(100) DEFAULT NULL,
  `description` text,
  `created_by` int(11) DEFAULT NULL,
  `updated_by` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8;

CREATE TABLE `contents` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) DEFAULT NULL,
  `name` varchar(100) DEFAULT NULL,
  `description` text,
  `purpose` varchar(50) DEFAULT NULL,
  `created_by` int(11) DEFAULT NULL,
  `updated_by` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_contents_on_account_id` (`account_id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8;

CREATE TABLE `countries` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` char(48) NOT NULL DEFAULT '',
  `code` char(2) NOT NULL DEFAULT '',
  PRIMARY KEY (`id`),
  KEY `kCountry` (`name`)
) ENGINE=MyISAM AUTO_INCREMENT=250 DEFAULT CHARSET=latin1;

CREATE TABLE `delayed_jobs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `priority` int(11) DEFAULT '0',
  `attempts` int(11) DEFAULT '0',
  `handler` text,
  `last_error` text,
  `run_at` datetime DEFAULT NULL,
  `locked_at` datetime DEFAULT NULL,
  `failed_at` datetime DEFAULT NULL,
  `locked_by` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `emails` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `contact_id` int(11) DEFAULT NULL,
  `address` varchar(255) DEFAULT NULL,
  `kind` varchar(10) DEFAULT NULL,
  `preferred` tinyint(1) DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_emails_on_contact_id` (`contact_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `events` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `session_id` int(11) DEFAULT NULL,
  `sequence` int(11) DEFAULT NULL,
  `url` varchar(255) DEFAULT NULL,
  `page_title` varchar(255) DEFAULT NULL,
  `tracked_at` datetime DEFAULT NULL,
  `entry_page` tinyint(1) DEFAULT '1',
  `exit_page` tinyint(1) DEFAULT '1',
  `created_at` datetime DEFAULT NULL,
  `category` varchar(20) DEFAULT NULL,
  `action` varchar(20) DEFAULT NULL,
  `label` varchar(255) DEFAULT NULL,
  `value` float DEFAULT NULL,
  `internal_search_terms` varchar(100) DEFAULT NULL,
  `redirect_id` int(11) DEFAULT NULL,
  `duration` int(11) DEFAULT NULL,
  `contact_code` varchar(50) DEFAULT NULL,
  `page_view` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_events_on_session_id` (`session_id`),
  KEY `index_events_on_tracked_at` (`tracked_at`),
  KEY `index_events_on_url` (`url`),
  KEY `index_events_on_label` (`label`),
  KEY `index_events_on_page_view` (`page_view`)
) ENGINE=InnoDB AUTO_INCREMENT=57981 DEFAULT CHARSET=utf8;

CREATE TABLE `files` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `group_members` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `group_id` int(11) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `groups` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `description` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `account_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `histories` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `updates` text,
  `created_by` int(11) DEFAULT NULL,
  `historical_type` varchar(255) DEFAULT NULL,
  `historical_id` int(11) DEFAULT NULL,
  `transaction` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `actionable_type` varchar(20) DEFAULT NULL,
  `actionable_id` int(11) DEFAULT NULL,
  `account_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=16061 DEFAULT CHARSET=utf8;

CREATE TABLE `imports` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `messages` text,
  `started_at` datetime DEFAULT NULL,
  `ended_at` datetime DEFAULT NULL,
  `records` int(11) DEFAULT NULL,
  `created` int(11) DEFAULT NULL,
  `updated` int(11) DEFAULT NULL,
  `description` varchar(255) DEFAULT NULL,
  `created_by` int(11) DEFAULT NULL,
  `original_file` varchar(255) DEFAULT NULL,
  `account_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8;

CREATE TABLE `instant_messengers` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `contact_id` int(11) DEFAULT NULL,
  `type` varchar(10) DEFAULT NULL,
  `address` varchar(255) DEFAULT NULL,
  `preferred` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `index_instant_messengers_on_contact_id` (`contact_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `ip4` (
  `ip` int(10) unsigned NOT NULL DEFAULT '0',
  `country` smallint(5) unsigned NOT NULL DEFAULT '0',
  `city` smallint(5) unsigned NOT NULL DEFAULT '0',
  `cron` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  KEY `kCountry` (`country`),
  KEY `kCity` (`city`),
  KEY `kIP` (`ip`),
  KEY `kcron` (`cron`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

CREATE TABLE `language_versions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `content_variant_id` int(11) DEFAULT NULL,
  `language` varchar(50) DEFAULT NULL,
  `url` varchar(255) DEFAULT NULL,
  `content` text,
  `original_file_name` varchar(255) DEFAULT NULL,
  `mime_type` varchar(50) DEFAULT NULL,
  `created_by` int(11) DEFAULT NULL,
  `updated_by` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `base_url` varchar(255) DEFAULT NULL,
  `refreshed_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8;

CREATE TABLE `lists` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `logged_exceptions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `exception_class` varchar(255) DEFAULT NULL,
  `controller_name` varchar(255) DEFAULT NULL,
  `action_name` varchar(255) DEFAULT NULL,
  `message` text,
  `backtrace` text,
  `environment` text,
  `request` text,
  `created_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=390 DEFAULT CHARSET=utf8;

CREATE TABLE `notes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `note` text,
  `notable_type` varchar(20) DEFAULT NULL,
  `notable_id` int(11) DEFAULT NULL,
  `updated_by` int(11) DEFAULT NULL,
  `created_by` int(11) DEFAULT NULL,
  `related_date` date DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `phones` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `contact_id` int(11) DEFAULT NULL,
  `kind` varchar(10) DEFAULT NULL,
  `number` varchar(50) DEFAULT NULL,
  `preferred` tinyint(1) DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_phones_on_contact_id` (`contact_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `properties` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `description` text,
  `tracker` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `search_parameter` varchar(255) DEFAULT NULL,
  `thumb_file_name` varchar(100) DEFAULT NULL,
  `thumb_content_type` varchar(50) DEFAULT NULL,
  `thumb_file_size` int(11) DEFAULT NULL,
  `host` varchar(70) DEFAULT NULL,
  `index_page` varchar(50) DEFAULT 'index.*',
  `title_prefix` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_properties_on_account_id_and_name` (`account_id`,`name`),
  KEY `index_properties_on_host` (`host`),
  KEY `index_properties_on_account_id` (`account_id`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8;

CREATE TABLE `recipients` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `salutation` varchar(255) DEFAULT NULL,
  `first_name` varchar(255) DEFAULT NULL,
  `last_name` varchar(255) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `redirects` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `url` varchar(255) DEFAULT NULL,
  `category` varchar(255) DEFAULT 'page',
  `action` varchar(255) DEFAULT 'view',
  `label` varchar(255) DEFAULT NULL,
  `value` varchar(255) DEFAULT '0',
  `redirect_url` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_redirects_on_redirect_url` (`redirect_url`),
  KEY `index_redirects_on_account_id` (`account_id`),
  KEY `index_redirects_on_name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=31 DEFAULT CHARSET=utf8;

CREATE TABLE `schema_migrations` (
  `version` varchar(255) NOT NULL,
  UNIQUE KEY `unique_schema_migrations` (`version`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `search_engines` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `host` varchar(255) DEFAULT NULL,
  `query_param` varchar(50) DEFAULT NULL,
  `country` varchar(10) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_search_engines_on_host` (`host`)
) ENGINE=InnoDB AUTO_INCREMENT=2516 DEFAULT CHARSET=utf8;

CREATE TABLE `sessions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `property_id` int(11) DEFAULT NULL,
  `campaign_id` int(11) DEFAULT NULL,
  `visitor` varchar(20) DEFAULT NULL,
  `visit` int(11) DEFAULT '0',
  `session` varchar(20) DEFAULT NULL,
  `event_count` int(11) DEFAULT NULL,
  `browser` varchar(20) DEFAULT NULL,
  `browser_version` varchar(10) DEFAULT NULL,
  `language` varchar(10) DEFAULT NULL,
  `screen_size` varchar(10) DEFAULT NULL,
  `color_depth` smallint(6) DEFAULT NULL,
  `charset` varchar(10) DEFAULT NULL,
  `os_name` varchar(20) DEFAULT NULL,
  `os_version` varchar(10) DEFAULT NULL,
  `flash_version` varchar(10) DEFAULT NULL,
  `campaign_name` varchar(50) DEFAULT NULL,
  `campaign_source` varchar(50) DEFAULT NULL,
  `campaign_medium` varchar(50) DEFAULT NULL,
  `campaign_content` varchar(50) DEFAULT NULL,
  `ip_address` varchar(20) DEFAULT NULL,
  `locality` varchar(50) DEFAULT NULL,
  `region` varchar(30) DEFAULT NULL,
  `country` varchar(2) DEFAULT NULL,
  `latitude` float DEFAULT NULL,
  `longitude` float DEFAULT NULL,
  `duration` int(11) DEFAULT '0',
  `started_at` datetime DEFAULT NULL,
  `ended_at` datetime DEFAULT NULL,
  `geocoded_at` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `page_views` int(11) DEFAULT NULL,
  `previous_visit_at` datetime DEFAULT NULL,
  `count` int(11) DEFAULT NULL,
  `account_id` int(11) DEFAULT NULL,
  `mobile_device` tinyint(1) DEFAULT NULL,
  `referrer` varchar(255) DEFAULT NULL,
  `referrer_host` varchar(100) DEFAULT NULL,
  `search_terms` varchar(100) DEFAULT NULL,
  `traffic_source` varchar(50) DEFAULT NULL,
  `date` date DEFAULT NULL,
  `day_of_month` int(11) DEFAULT NULL,
  `year` int(11) DEFAULT NULL,
  `month` int(11) DEFAULT NULL,
  `hour` int(11) DEFAULT NULL,
  `week` int(11) DEFAULT NULL,
  `day_of_week` tinyint(4) DEFAULT NULL,
  `timezone` mediumint(9) DEFAULT NULL,
  `user_agent` varchar(255) DEFAULT NULL,
  `lon_local_time` tinyint(1) DEFAULT '0',
  `device` varchar(50) DEFAULT NULL,
  `device_vendor` varchar(50) DEFAULT NULL,
  `referrer_category` varchar(50) DEFAULT NULL,
  `impressions` int(11) DEFAULT NULL,
  `contact_code` varchar(50) DEFAULT NULL,
  `email_client` varchar(20) DEFAULT NULL,
  `dialect` varchar(5) DEFAULT NULL,
  `forwarded_for` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_sessions_on_campaign_id` (`campaign_id`),
  KEY `index_sessions_on_property_id` (`property_id`),
  KEY `index_sessions_on_started_at` (`started_at`),
  KEY `index_sessions_on_date` (`date`),
  KEY `index_sessions_on_day` (`day_of_month`),
  KEY `index_sessions_on_month` (`month`),
  KEY `index_sessions_on_day_of_week` (`day_of_week`),
  KEY `index_sessions_on_year` (`year`),
  KEY `index_sessions_on_hour` (`hour`),
  KEY `index_sessions_on_country` (`country`),
  KEY `index_sessions_on_language` (`language`),
  KEY `index_sessions_on_browser` (`browser`),
  KEY `index_sessions_on_device` (`device`),
  KEY `index_sessions_on_os_name` (`os_name`),
  KEY `index_sessions_on_os_version` (`os_version`),
  KEY `index_sessions_on_search_terms` (`search_terms`),
  KEY `index_sessions_on_referrer_host` (`referrer_host`),
  KEY `index_sessions_on_account_id` (`account_id`)
) ENGINE=InnoDB AUTO_INCREMENT=27280 DEFAULT CHARSET=utf8;

CREATE TABLE `taggings` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `tag_id` int(11) DEFAULT NULL,
  `taggable_id` int(11) DEFAULT NULL,
  `tagger_id` int(11) DEFAULT NULL,
  `tagger_type` varchar(255) DEFAULT NULL,
  `taggable_type` varchar(255) DEFAULT NULL,
  `context` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_taggings_on_tag_id` (`tag_id`),
  KEY `index_taggings_on_taggable_id_and_taggable_type_and_context` (`taggable_id`,`taggable_type`,`context`)
) ENGINE=InnoDB AUTO_INCREMENT=1792 DEFAULT CHARSET=utf8;

CREATE TABLE `tags` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=18 DEFAULT CHARSET=utf8;

CREATE TABLE `team_members` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `team_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `teams` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `description` text,
  `lft` int(11) DEFAULT NULL,
  `rgt` int(11) DEFAULT NULL,
  `parent_id` int(11) DEFAULT NULL,
  `created_by` int(11) DEFAULT NULL,
  `updated_by` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `tracks` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `property_id` int(11) DEFAULT NULL,
  `campaign_id` int(11) DEFAULT NULL,
  `visitor` varchar(20) DEFAULT NULL,
  `visit` int(11) DEFAULT '0',
  `session` varchar(20) DEFAULT NULL,
  `event_count` int(11) DEFAULT NULL,
  `browser` varchar(20) DEFAULT NULL,
  `browser_version` varchar(10) DEFAULT NULL,
  `language` varchar(10) DEFAULT NULL,
  `screen_size` varchar(10) DEFAULT NULL,
  `color_depth` smallint(6) DEFAULT NULL,
  `charset` varchar(10) DEFAULT NULL,
  `os_name` varchar(20) DEFAULT NULL,
  `os_version` varchar(10) DEFAULT NULL,
  `flash_version` varchar(10) DEFAULT NULL,
  `campaign_name` varchar(50) DEFAULT NULL,
  `campaign_source` varchar(255) DEFAULT NULL,
  `campaign_medium` varchar(255) DEFAULT NULL,
  `campaign_content` varchar(255) DEFAULT NULL,
  `ip_address` varchar(20) DEFAULT NULL,
  `locality` varchar(255) DEFAULT NULL,
  `region` varchar(255) DEFAULT NULL,
  `country` varchar(255) DEFAULT NULL,
  `latitude` float DEFAULT NULL,
  `longitude` float DEFAULT NULL,
  `duration` int(11) DEFAULT '0',
  `started_at` datetime DEFAULT NULL,
  `ended_at` datetime DEFAULT NULL,
  `geocoded_at` datetime DEFAULT NULL,
  `page_views` int(11) DEFAULT NULL,
  `previous_visit_at` datetime DEFAULT NULL,
  `count` int(11) DEFAULT NULL,
  `account_id` int(11) DEFAULT NULL,
  `mobile_device` tinyint(1) DEFAULT NULL,
  `referrer` varchar(255) DEFAULT NULL,
  `referrer_host` varchar(100) DEFAULT NULL,
  `search_terms` varchar(255) DEFAULT NULL,
  `traffic_source` varchar(50) DEFAULT NULL,
  `session_id` int(11) DEFAULT NULL,
  `sequence` int(11) DEFAULT NULL,
  `url` varchar(255) DEFAULT NULL,
  `page_title` varchar(255) DEFAULT NULL,
  `tracked_at` datetime DEFAULT NULL,
  `entry_page` tinyint(1) DEFAULT '1',
  `exit_page` tinyint(1) DEFAULT '1',
  `category` varchar(255) DEFAULT NULL,
  `action` varchar(255) DEFAULT NULL,
  `label` varchar(255) DEFAULT NULL,
  `value` float DEFAULT NULL,
  `internal_search_terms` varchar(255) DEFAULT NULL,
  `redirect_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `traffic_sources` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) DEFAULT NULL,
  `host` varchar(255) DEFAULT NULL,
  `source_type` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3611 DEFAULT CHARSET=utf8;

CREATE TABLE `users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `given_name` varchar(100) DEFAULT '',
  `email` varchar(100) DEFAULT NULL,
  `crypted_password` varchar(255) DEFAULT NULL,
  `password_salt` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `activated_at` datetime DEFAULT NULL,
  `state` varchar(255) DEFAULT 'passive',
  `deleted_at` datetime DEFAULT NULL,
  `locale` varchar(255) DEFAULT NULL,
  `timezone` varchar(255) DEFAULT NULL,
  `account_id` int(11) DEFAULT NULL,
  `photo_file_name` varchar(255) DEFAULT NULL,
  `photo_content_type` varchar(255) DEFAULT NULL,
  `photo_file_size` int(11) DEFAULT NULL,
  `photo_updated_at` datetime DEFAULT NULL,
  `family_name` varchar(100) DEFAULT NULL,
  `phone_number` varchar(50) DEFAULT NULL,
  `administrator` tinyint(1) DEFAULT NULL,
  `persistence_token` varchar(255) NOT NULL,
  `single_access_token` varchar(255) NOT NULL,
  `perishable_token` varchar(255) NOT NULL,
  `login_count` int(11) NOT NULL DEFAULT '0',
  `failed_login_count` int(11) NOT NULL DEFAULT '0',
  `last_request_at` datetime DEFAULT NULL,
  `current_login_at` datetime DEFAULT NULL,
  `last_login_at` datetime DEFAULT NULL,
  `current_login_ip` varchar(255) DEFAULT NULL,
  `last_login_ip` varchar(255) DEFAULT NULL,
  `openid_identifier` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_users_on_email` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8;

CREATE TABLE `views` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `session_id` int(11) DEFAULT NULL,
  `track_id` int(11) DEFAULT NULL,
  `view_sequence` int(11) DEFAULT NULL,
  `url` varchar(255) DEFAULT NULL,
  `page_title` varchar(255) DEFAULT NULL,
  `referrer` varchar(255) DEFAULT NULL,
  `tracked_at` datetime DEFAULT NULL,
  `duration` int(11) DEFAULT '0',
  `entry_page` tinyint(1) DEFAULT '1',
  `exit_page` tinyint(1) DEFAULT '1',
  `created_at` datetime DEFAULT NULL,
  `event_category` varchar(255) DEFAULT NULL,
  `event_action` varchar(255) DEFAULT NULL,
  `event_label` varchar(255) DEFAULT NULL,
  `event_value` float DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `websites` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `contact_id` int(11) DEFAULT NULL,
  `kind` varchar(10) DEFAULT NULL,
  `url` varchar(255) DEFAULT NULL,
  `preferred` tinyint(1) DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_websites_on_contact_id` (`contact_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO schema_migrations (version) VALUES ('20090424232357');

INSERT INTO schema_migrations (version) VALUES ('20090424232411');

INSERT INTO schema_migrations (version) VALUES ('20090424233042');

INSERT INTO schema_migrations (version) VALUES ('20090425001145');

INSERT INTO schema_migrations (version) VALUES ('20090425001153');

INSERT INTO schema_migrations (version) VALUES ('20090427001140');

INSERT INTO schema_migrations (version) VALUES ('20090427005501');

INSERT INTO schema_migrations (version) VALUES ('20090427011909');

INSERT INTO schema_migrations (version) VALUES ('20090427032152');

INSERT INTO schema_migrations (version) VALUES ('20090427045957');

INSERT INTO schema_migrations (version) VALUES ('20090427223333');

INSERT INTO schema_migrations (version) VALUES ('20090427223722');

INSERT INTO schema_migrations (version) VALUES ('20090428000056');

INSERT INTO schema_migrations (version) VALUES ('20090428013718');

INSERT INTO schema_migrations (version) VALUES ('20090428050437');

INSERT INTO schema_migrations (version) VALUES ('20090428053635');

INSERT INTO schema_migrations (version) VALUES ('20090428072825');

INSERT INTO schema_migrations (version) VALUES ('20090428075403');

INSERT INTO schema_migrations (version) VALUES ('20090430215611');

INSERT INTO schema_migrations (version) VALUES ('20090501025109');

INSERT INTO schema_migrations (version) VALUES ('20090501035135');

INSERT INTO schema_migrations (version) VALUES ('20090501060822');

INSERT INTO schema_migrations (version) VALUES ('20090501061027');

INSERT INTO schema_migrations (version) VALUES ('20090501061414');

INSERT INTO schema_migrations (version) VALUES ('20090503063252');

INSERT INTO schema_migrations (version) VALUES ('20090506070802');

INSERT INTO schema_migrations (version) VALUES ('20090506222403');

INSERT INTO schema_migrations (version) VALUES ('20090507202731');

INSERT INTO schema_migrations (version) VALUES ('20090510232123');

INSERT INTO schema_migrations (version) VALUES ('20090511010125');

INSERT INTO schema_migrations (version) VALUES ('20090511043426');

INSERT INTO schema_migrations (version) VALUES ('20090511045121');

INSERT INTO schema_migrations (version) VALUES ('20090511224450');

INSERT INTO schema_migrations (version) VALUES ('20090511224826');

INSERT INTO schema_migrations (version) VALUES ('20090513035739');

INSERT INTO schema_migrations (version) VALUES ('20090513060133');

INSERT INTO schema_migrations (version) VALUES ('20090513072118');

INSERT INTO schema_migrations (version) VALUES ('20090513074355');

INSERT INTO schema_migrations (version) VALUES ('20090514070940');

INSERT INTO schema_migrations (version) VALUES ('20090516221908');

INSERT INTO schema_migrations (version) VALUES ('20090516223427');

INSERT INTO schema_migrations (version) VALUES ('20090516224845');

INSERT INTO schema_migrations (version) VALUES ('20090517220859');

INSERT INTO schema_migrations (version) VALUES ('20090517221048');

INSERT INTO schema_migrations (version) VALUES ('20090518041720');

INSERT INTO schema_migrations (version) VALUES ('20090518043803');

INSERT INTO schema_migrations (version) VALUES ('20090519074409');

INSERT INTO schema_migrations (version) VALUES ('20090520062105');

INSERT INTO schema_migrations (version) VALUES ('20090525053401');

INSERT INTO schema_migrations (version) VALUES ('20090526010543');

INSERT INTO schema_migrations (version) VALUES ('20090526014111');

INSERT INTO schema_migrations (version) VALUES ('20090528034243');

INSERT INTO schema_migrations (version) VALUES ('20090529065956');

INSERT INTO schema_migrations (version) VALUES ('20090529075341');

INSERT INTO schema_migrations (version) VALUES ('20090531035145');

INSERT INTO schema_migrations (version) VALUES ('20090601231204');

INSERT INTO schema_migrations (version) VALUES ('20090602220657');

INSERT INTO schema_migrations (version) VALUES ('20090603102921');

INSERT INTO schema_migrations (version) VALUES ('20090603214651');

INSERT INTO schema_migrations (version) VALUES ('20090603232022');

INSERT INTO schema_migrations (version) VALUES ('20090605073223');

INSERT INTO schema_migrations (version) VALUES ('20090608012027');

INSERT INTO schema_migrations (version) VALUES ('20090608013415');

INSERT INTO schema_migrations (version) VALUES ('20090608030238');

INSERT INTO schema_migrations (version) VALUES ('20090613045037');

INSERT INTO schema_migrations (version) VALUES ('20090613051548');

INSERT INTO schema_migrations (version) VALUES ('20090613223058');

INSERT INTO schema_migrations (version) VALUES ('20090614050646');

INSERT INTO schema_migrations (version) VALUES ('20090616034812');

INSERT INTO schema_migrations (version) VALUES ('20090616035331');

INSERT INTO schema_migrations (version) VALUES ('20090616080754');

INSERT INTO schema_migrations (version) VALUES ('20090618034839');

INSERT INTO schema_migrations (version) VALUES ('20090804120547');

INSERT INTO schema_migrations (version) VALUES ('20090804121520');

INSERT INTO schema_migrations (version) VALUES ('20091101081221');

INSERT INTO schema_migrations (version) VALUES ('20091101081556');

INSERT INTO schema_migrations (version) VALUES ('20091101082223');

INSERT INTO schema_migrations (version) VALUES ('20091114132709');

INSERT INTO schema_migrations (version) VALUES ('20091121013420');

INSERT INTO schema_migrations (version) VALUES ('20091121020325');

INSERT INTO schema_migrations (version) VALUES ('20091121041531');

INSERT INTO schema_migrations (version) VALUES ('20091122021321');

INSERT INTO schema_migrations (version) VALUES ('20091128041915');

INSERT INTO schema_migrations (version) VALUES ('20091129035302');

INSERT INTO schema_migrations (version) VALUES ('20091129084613');

INSERT INTO schema_migrations (version) VALUES ('20091129120801');

INSERT INTO schema_migrations (version) VALUES ('20091219015353');

INSERT INTO schema_migrations (version) VALUES ('20091219052337');

INSERT INTO schema_migrations (version) VALUES ('20100102044602');

INSERT INTO schema_migrations (version) VALUES ('20100205143521');

INSERT INTO schema_migrations (version) VALUES ('20100215065108');

INSERT INTO schema_migrations (version) VALUES ('20100218064559');

INSERT INTO schema_migrations (version) VALUES ('20100221084025');

INSERT INTO schema_migrations (version) VALUES ('20100227043437');

INSERT INTO schema_migrations (version) VALUES ('20100227084558');

INSERT INTO schema_migrations (version) VALUES ('20100227122315');

INSERT INTO schema_migrations (version) VALUES ('20100227155603');

INSERT INTO schema_migrations (version) VALUES ('20100304035905');

INSERT INTO schema_migrations (version) VALUES ('20100305232235');

INSERT INTO schema_migrations (version) VALUES ('20100305233734');

INSERT INTO schema_migrations (version) VALUES ('20100308024457');

INSERT INTO schema_migrations (version) VALUES ('20100308030537');

INSERT INTO schema_migrations (version) VALUES ('20100308031813');

INSERT INTO schema_migrations (version) VALUES ('20100308070456');

INSERT INTO schema_migrations (version) VALUES ('20100308160044');

INSERT INTO schema_migrations (version) VALUES ('20100309133237');

INSERT INTO schema_migrations (version) VALUES ('20100310162031');

INSERT INTO schema_migrations (version) VALUES ('20100312143246');

INSERT INTO schema_migrations (version) VALUES ('20100318104157');

INSERT INTO schema_migrations (version) VALUES ('20100320074853');

INSERT INTO schema_migrations (version) VALUES ('20100320131317');

INSERT INTO schema_migrations (version) VALUES ('20100320135927');

INSERT INTO schema_migrations (version) VALUES ('20100326001646');

INSERT INTO schema_migrations (version) VALUES ('20100330045914');

INSERT INTO schema_migrations (version) VALUES ('20100330085239');

INSERT INTO schema_migrations (version) VALUES ('20100330190108');

INSERT INTO schema_migrations (version) VALUES ('20100330190223');

INSERT INTO schema_migrations (version) VALUES ('20100331071436');

INSERT INTO schema_migrations (version) VALUES ('20100407020035');

INSERT INTO schema_migrations (version) VALUES ('20100410095116');

INSERT INTO schema_migrations (version) VALUES ('20100411121918');

INSERT INTO schema_migrations (version) VALUES ('20100411123810');

INSERT INTO schema_migrations (version) VALUES ('20100417020648');

INSERT INTO schema_migrations (version) VALUES ('20100418031057');

INSERT INTO schema_migrations (version) VALUES ('20100418031129');

INSERT INTO schema_migrations (version) VALUES ('20100418033829');

INSERT INTO schema_migrations (version) VALUES ('20100418082051');

INSERT INTO schema_migrations (version) VALUES ('20100419055038');

INSERT INTO schema_migrations (version) VALUES ('20100419073755');

INSERT INTO schema_migrations (version) VALUES ('20100421033647');

INSERT INTO schema_migrations (version) VALUES ('20100423074543');

INSERT INTO schema_migrations (version) VALUES ('20100424020238');

INSERT INTO schema_migrations (version) VALUES ('20100630052109');

INSERT INTO schema_migrations (version) VALUES ('20100704060831');