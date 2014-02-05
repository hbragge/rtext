<% define 'Root' do %>
	<% file "fsm.c" do %>
#include "fsm.h"
void sm_trigger() {
<%iinc%>
  switch(state) {
		<% expand 'state::State', :foreach => states, :separator => '' %>
  default:
    break;
  }
<%idec%>
}
	<% end %>
<% end %>
