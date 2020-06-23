<% # License: LGPL-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/master/LICENSE 
# from: https://github.com/reactjs/react-rails/blob/master/lib/generators/templates/component.js.jsx.tsx
%>
// License: LGPL-3.0-or-later
<%= file_header %>
<% unions = attributes.select{ |a| a[:union] } -%>
<% if unions.size > 0 -%>
<% unions.each do |e| -%>
type <%= e[:name].titleize %> = <%= e[:type]%>
<% end -%>
<% end -%>

interface I<%= component_name %>Props {
<% if attributes.size > 0 -%>
<% attributes.each do | attribute | -%>
<% if attribute[:union] -%>
  <%= attribute[:name].camelize(:lower) %>: <%= attribute[:name].titleize %>;
<% else -%>
  <%= attribute[:name].camelize(:lower) %>: <%= attribute[:type] %>;
<% end -%>
<% end -%>
<% end -%>
}


function <%= component_name %>(props:I<%= component_name %>Props) {
    return (
      <React.Fragment>
  <% attributes.each do |attribute| -%>
      <%= attribute[:name].titleize %>: {props.<%= attribute[:name].camelize(:lower) %>}
  <% end -%>
    </React.Fragment>
    );
}

<%= file_footer %>