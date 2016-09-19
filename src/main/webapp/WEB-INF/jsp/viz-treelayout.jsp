<!DOCTYPE html>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" 	prefix="fmt" 	%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" 	prefix="c" 		%>

<!-- setup the locale for the messages based on the language in the session -->
<fmt:setLocale value="${sessionScope['fr.sparna.rdf.skosplay.SessionData'].userLocale.language}"/>
<fmt:setBundle basename="fr.sparna.rdf.skosplay.i18n.Bundle"/>

<html>
  <head>
    <title>SKOS Play! - Visualize the Caribbean Disaster Management Knowledge Broker</title>
    <meta http-equiv="Content-Type" content="text/html;charset=utf-8"/>
    <script src="js/d3.v3.min.js" charset="utf-8"></script>
    <script src="js/jquery-1.9.1.min.js" charset="utf-8"></script>
    <link href="bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link rel="stylesheet" href="css/skos-play.css" />
    <script src="bootstrap/js/bootstrap.min.js"></script>
    
    <style type="text/css">

.node circle {
  cursor: pointer;
  fill: #fff;
  stroke: #FDDFAD;;
  stroke-width: 1.5px;
}

.node text {
  font-size: 12px;
}

path.link {
  fill: none;
  stroke: #FDDFAD;
  stroke-width: 3px;
  opacity: 1;
}

.ext-link {
  font-weight: bold;
}

    </style>
  </head>
  <body>
    <div id="header" style="text-align:center; font-size: 0.9em;">
  		<span id="help-popover"><i class="icon-info-sign"></i><fmt:message key="viz.help.label" /></span>
  	</div>
    <div class="container-fluid">
      <div id="body"></div>
    </div>
    <script type="text/javascript">

var m = [20, 320, 20, 320],
    w = 5000 - m[1] - m[3],
    h = 800 - m[0] - m[2],
    i = 0,
    root;

var tree = d3.layout.tree()
    .size([h, w]);

var diagonal = d3.svg.diagonal()
    .projection(function(d) { return [d.y, d.x]; });

var vis = d3.select("#body").append("svg:svg")
    .attr("width", w + m[1] + m[3])
    .attr("height", h + m[0] + m[2])
  	.append("svg:g")
    .attr("transform", "translate(" + m[3] + "," + m[0] + ")");


  var dataset = '${dataset}';
  var json = JSON.parse( dataset );
// d3.json("json?language=${language}&root=${root}", function(json) {
  root = json;
  root.x0 = h / 2;
  root.y0 = 0;

  function toggleAll(d) {
    if (d.children) {
      d.children.forEach(toggleAll);
      toggle(d);
    }
  }

  // Initialize the display to show a few nodes.
  root.children.forEach(toggleAll);
  update(root);
// });

function update(source) {
  var duration = d3.event && d3.event.altKey ? 5000 : 500;

  // Compute the new tree layout.
  var nodes = tree.nodes(root).reverse();

  // Normalize for fixed-depth.
  nodes.forEach(function(d) { d.y = d.depth * 180; });

  // Update the nodes…
  var node = vis.selectAll("g.node")
      .data(nodes, function(d) { return d.id || (d.id = ++i); });

  // Enter any new nodes at the parent's previous position.
  var nodeEnter = node.enter().append("svg:g")
      .attr("class", "node")
      .attr("transform", function(d) { return "translate(" + source.y0 + "," + source.x0 + ")"; })
      .on("click", function(d) { toggle(d); update(d); });

  nodeEnter.append("svg:circle")
      .attr("r", 1e-6)
      .style("fill", function(d) { return d._children ? "#a8e9ff" : "#fff"; });

  // add a link to the concept
  var a = nodeEnter.append("a")
	  .attr("xlink:href", function(d){ return d.uri; })
	  .attr("target", "_blank");
  
  a.append("svg:text")
      .attr("x", function(d) { return d.children || d._children ? -15 : 15; })
      .attr("dy", "-.6em")
      .attr("text-anchor", function(d) { return d.children || d._children ? "end" : "start"; })
      .text(function(d) { return (d.name != null)?d.name:d.uri ; })
      .style("fill-opacity", 1e-6);

  // Transition nodes to their new position.
  var nodeUpdate = node.transition()
      .duration(duration)
      .attr("transform", function(d) { return "translate(" + d.y + "," + d.x + ")"; });

  nodeUpdate.select("circle")
      .attr("r", 9)
      .style("fill", function(d) { return d._children ? "#a8e9ff" : "#fff"; });

  nodeUpdate.select("text")
      .style("fill-opacity", 1);

  // Transition exiting nodes to the parent's new position.
  var nodeExit = node.exit().transition()
      .duration(duration)
      .attr("transform", function(d) { return "translate(" + source.y + "," + source.x + ")"; })
      .remove();

  nodeExit.select("circle")
      .attr("r", 1e-6);

  nodeExit.select("text")
      .style("fill-opacity", 1e-6);

  // Update the links…
  var link = vis.selectAll("path.link")
      .data(tree.links(nodes), function(d) { return d.target.id; });

  // Enter any new links at the parent's previous position.
  link.enter().insert("svg:path", "g")
      .attr("class", "link")
      .attr("d", function(d) {
        var o = {x: source.x0, y: source.y0};
        return diagonal({source: o, target: o});
      })
    .transition()
      .duration(duration)
      .attr("d", diagonal);

  // Transition links to their new position.
  link.transition()
      .duration(duration)
      .attr("d", diagonal);

  // Transition exiting nodes to the parent's new position.
  link.exit().transition()
      .duration(duration)
      .attr("d", function(d) {
        var o = {x: source.x, y: source.y};
        return diagonal({source: o, target: o});
      })
      .remove();

  // Stash the old positions for transition.
  nodes.forEach(function(d) {
    d.x0 = d.x;
    d.y0 = d.y;
  });
}

// Toggle children.
function toggle(d) {
  if (d.children) {
    d._children = d.children;
    d.children = null;
  } else {
    d.children = d._children;
    d._children = null;
  }
}

    </script>
    
    <script>
        $(document).ready(function () {
          // add external link behavior to every external link
          $('text').mouseover(function() {
            $(this).attr("class", "ext-link");
          });
          $('text').mouseout(function() {
            $(this).attr("class", "");
          });
          
          $('#help-popover').popover({
        	  html: true,
              trigger : "click",
              delay: { show: 0, hide: 400 },
              content: '<fmt:message key="viz.treelayout.help.content" />',
              placement: "bottom"
          });
          $('#help-popover').css("text-decoration", "underline").css("cursor", "pointer");
        });         
    </script>

    <div class="container"> 

      <h3>Use the comment box below to provide feedback on the concept hierarchy.</h3>     

      <form method="POST" action="comments" class="form-horizontal" role="form">

        <div class="form-group">   
          <textarea rows="3" class="form-control" name="content" id="content" required>Comment...</textarea>
        </div>

        <div class="form-group">
          <div class="col-xs-6">
            <label for="name" class="control-label">Name:</label>
            <input type="text" class="form-control" id="username" name="username" required/>
          </div>
        </div>

        <div class="form-group">
            <button type="submit" class="btn btn-default">Submit</button>
        </div>

      </form>

      <div class="row comments">

        <c:forEach items="${comments}" var="comment">
          <div class="comment">
            <p><b><c:out value="${comment['username']}"/>:</b></p>
            <p><c:out value="${comment['content']}"/></p>
          </div>
        </c:forEach> 
      </div>
    </div>
    </div>
</div>
  </body>
</html>