# run with:  god -c /path/to/this_file.god
# 
APP_DIR     = '/u/apps/trackster'
MAIL_CONFIG = "#{APP_DIR}/config/mailer.yml"

# Load daemon specific configurations
God.load "#{File.dirname(__FILE__)}/god/*.god"

God::Contacts::Email.message_settings = {
  :from => 'god@vietools.com'
}

God::Contacts::Email.server_settings = YAML.load(File.read(MAIL_CONFIG))['mailer']

God.contact(:email) do |c|
  c.name  = 'kip'
  c.email = 'kip@noexpectations.com.au'
  c.group = 'developers'
end

God.contact(:email) do |c|
  c.name  = 'bongo'
  c.email = 'bongo@xroads.com.au'
  c.group = 'developers'
end
