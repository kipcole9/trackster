<% form_for current_account, :url => calendar_path, :html => {:id => "account_calendar"} do |a| %>
  <h2>Edit your calendar settings:</h2>
  <p>My fiscal year uses <%= select_calendar_type(a.object) %>.</p>
  <div id="container">
    <!-- Gregorian -->
    <span id="gregorian">
      <p>It starts in <%= select_month(a.object) %>.</p>
      <p>The week starts on <%= select_day(a.object) %> of the <%= select_week_starts_in(a.object) %> of the year.</p>
    </span>
    <!-- 13-week -->
    <span id="thirteen">
      <p>The year <%= select_begins_ends(a.object) %> on the <%= select_first_last(a.object) %> <%= select_day(a.object) %> of <%= select_month(a.object) %>.</p>
      <p>The months of a quarter are in a <%= select_quarter_type(a.object) %> week format.</p>
    </span>
  </div>
  <div class="submit_button"><%= submit_tag I18n.t('accounts.settings.update_calendar'), :id => "commit_calendar" %></div>
<% end %>
<h2>The current quarter in your calendar:</h2>
<div id="calendar">
  <%= render "calendars/this_quarter" %>
</div>


