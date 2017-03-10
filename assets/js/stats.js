var client = new Faye.Client(pubsub.server);
var subscription = client.subscribe(`/${pubsub.channel}`, function (message) {
  if (message.error) {
    // TODO: show error
    return;
  }
  // batch statistics calculation
  var calculateStatistics = function (items) {
    var statistics = {};
    for (var idx in items) {
      var item = items[idx];
      statistics[item.path] = item.stats || {};
    }
    for (var idx in items) {
      var item = items[idx];
      if (item.stats) {
        for (var key in item.stats) {
          if(statistics[item.parent_path][key]) {
            statistics[item.parent_path][key] = statistics[item.parent_path][key] + item.stats[key];
          } else {
            statistics[item.parent_path][key] = item.stats[key];
          }
        }
      }
    }
    return statistics;
  };

  var statistics = calculateStatistics(message.data);

  // prepare data for D3
  var treeData = d3.stratify()
                   .id(function (node) { return node.path; })
                   .parentId(function (node) { return node.parent_path; })(message.data);

  var i = 0,
      duration = 400,
      barHeight = 30,
      root = d3.hierarchy(treeData);;

  var svg = d3.select('.js-svg-container').append('svg')
              .classed("svg-content", true)
              .append('g');

  var tree = d3.tree().nodeSize([0, 30]);

  var showStatistics = function (node) {
    // TODO: show in other element
    // alert(statistics[node.data.data.path]);
  };

  var toggleChildren = function (node) {
    if (node.children) {
      node._children = node.children;
      node.children = null;
    } else {
      node.children = node._children;
      node._children = null;
    }
    updateLayout(node);
  };

  var updateLayout = function(source) {
    nodes = tree(root);
    nodesSort = [];

    d3.select('svg')
     .transition()
     .duration(duration)
     .on('end', function () {
       var nodes = document.querySelectorAll('.node');
       var lastNode = nodes[nodes.length - 1];
       var rect = lastNode.getBoundingClientRect();
       var height = window.scrollY + rect.top + rect.height;
       d3.select('.svg-content')
         .attr('viewBox', `0 0 600 ${height}`)
         .attr('height', height);
     });


    nodes.eachBefore(function (n) {
       nodesSort.push(n);
    });

    nodesSort.forEach(function (n, i) {
      n.x = i * barHeight;
    });


    var node = svg.selectAll('g.node')
                  .data(nodesSort, function(d) { return d.id || (d.id = ++i); });

    var nodeEnter = node.enter()
                        .append('g')
                        .attr('class', 'node')
                        .attr('transform', function(d) {  return `translate(${source.y}, ${source.x})`; })
                        .style('opacity', 1e-6);

    nodeEnter.append('text')
             .attr('dy', 3.5)
             .attr('dx', 5.5)
             .classed('filename', true)
             .text(function (d) { return d.data.id; })
             .on('click', toggleChildren)
             .on('mouseover', showStatistics);

    nodeEnter.transition()
             .duration(duration)
             .attr('transform', function (d) { return `translate(${d.y}, ${d.x})`; })
             .style('opacity', 1);

    node.transition()
        .duration(duration)
        .attr('transform', function (d) { return `translate(${d.y}, ${d.x})`; })
        .style('opacity', 1);

    node.exit()
        .transition()
        .duration(duration)
        .attr('transform', function (d) { return `translate(${source.y}, ${source.x})`; })
        .style('opacity', 1e-6)
        .remove();

    nodes.eachBefore(function (d) {
      d.x0 = d.x;
      d.y0 = d.y;
    });
  };

  updateLayout(root);
});
