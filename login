<!DOCTYPE html>
<html>
  <head>
    <meta content="text/html;charset=utf-8" http-equiv="content-type" />
    <meta content="d+fipo/M9f3FYM9O0jTT806qMI0V/l5qGfMxEPXyYLk=" name="csrf-token" />
    <meta content="authenticity_token" name="csrf-param" />
    <link type="image/vnd.microsoft.icon" rel="icon" href="/themes/trackster/favicon.ico" />
    <title>
      Trackster: New User Session
    </title>
    <link href="/stylesheets/base_packaged.css?1277384937" media="screen, print" rel="stylesheet" type="text/css" />
    <link href="/themes/trackster/theme.css?1277384913" media="screen" rel="stylesheet" type="text/css" />
    <script src="/javascripts/base_packaged.js?1277384937" type="text/javascript"></script>
  </head>
  <body>
    <div class="container_12 clearfix" id="wrapper">
            <div class="grid_12">
        <div id="branding">
          <h1>
            <a href="/">Trackster</a>
          </h1>
        </div>
      </div>

      <div class="grid_6">
  <div class="box login">
    <h2 class="heading">
      <a href="" class="panel-heading">Login to access your account</a>
    </h2>
        <div class="flash_alert">
      <p>
        <img alt="Flash_alert" src="/images/icons/flash_alert.png?1277384899" /> You must login to access that page.
      </p>
    </div>
    <div style="clear:both">
    </div>

    <div class="block">
      <div>
<form action="/user_sessions" class="new_user_session" id="new_user_session" method="post"><div style="margin:0;padding:0;display:inline"><input name="authenticity_token" type="hidden" value="d+fipo/M9f3FYM9O0jTT806qMI0V/l5qGfMxEPXyYLk=" /></div><div><fieldset><legend>Please enter your credentials</legend><div class="field"><label class="field_label" for="user_session_email">Email:</label><span class="field_message" id="user_session_email_message"></span><input id="user_session_email" name="user_session[email]" size="30" type="text" /></div>
<div class="field"><label class="field_label" for="user_session_password">Password:</label><span class="field_message" id="user_session_password_message"></span><input id="user_session_password" name="user_session[password]" prompt="false" size="30" type="password" /></div>
<div class="field"><label class="checkbox" for="user_session_remember_me">Remember me?</label><span class="field_message" id="user_session_remember_me_message"></span><input name="user_session[remember_me]" type="hidden" value="0" /><input id="user_session_remember_me" name="user_session[remember_me]" type="checkbox" value="1" /></div>
</fieldset></div>        <div class="submit_button">
          <input name="commit" type="submit" value="Login" />
        </div>
</form>        <div class="login_options">
Help:  <a href="/reset_password">Forgotten your password?</a>        </div>
      </div>
    </div>
  </div>
</div>

    </div>
  </body>
</html>
