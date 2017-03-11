var client = new Faye.Client(pubsub.server);
var subscription = client.subscribe(`/${pubsub.channel}`, function (message) {
  if (message.error) {
    alert(message.error);
    window.location.reload();
    return;
  }

  var buildTree = function (items) {
    var root = items[items.length - 1];
    root.path = root.name;
    for (var idx in items) {
      var item = items[idx];

      if (item != root) {
        item.path = [root.path, item.path].join('/');
        if (item.parent_path === '.') {
          item.parent_path = root.path;
        } else {
          item.parent_path = [root.path, item.parent_path].join('/');
        }
      }
    }
  };

  // batch statistics calculation
  var calculateStatistics = function (items) {
    var nodeMap = {};

    items.forEach(function (node) {
      nodeMap[node.path] = node;
    });

    var tree = {};

    var internalNodes = items.filter(function (item) { return item.type === 'tree'; });
    internalNodes.forEach(function (node) {
      tree[node.path] = [];
    });

    items.forEach(function (node) {
      if (tree[node.parent_path]) {
        tree[node.parent_path].push(node.path);
      }
    });

    var sumStatistics = function (stats) {
      var allStats = {};
      stats.forEach(function (stat) {
        for (var email in stat) {
          if (allStats[email]) {
            allStats[email] = allStats[email] + stat[email];
          } else {
            allStats[email] = stat[email];
          }
        }
      });
      return allStats;
    };

    var statistics = {};
    var setStatistics = function (node_path) {
      var node = nodeMap[node_path];
      if (node) {
        if (node.type === 'blob') {
          statistics[node.path] = node.stats;
        } else {
          statistics[node.path] = sumStatistics(
            tree[node.path].map(function (child_path) {
              return setStatistics(child_path);
            })
          );
        }
        return statistics[node.path];
      } else {
        return {};
      }
    };

    setStatistics(items[items.length - 1].path);

    for (var key in statistics) {
      var stats = statistics[key];

      var sortedStats = [];
      for (var email in stats) {
        sortedStats.push({ email: email, numLines: stats[email] })
      }
      sortedStats.sort(function(x, y) {
        // multiply -1 for descending order
        return -1 * (x.numLines - y.numLines);
      });

      statistics[key] = sortedStats;
    }

    return statistics;
  };

  var items = message.data;
  buildTree(items);
  var statistics = calculateStatistics(items);

  // prepare data for D3
  var treeData = d3.stratify()
                   .id(function (node) { return node.path; })
                   .parentId(function (node) { return node.parent_path; })(items);

  var i = 0,
      duration = 400,
      barHeight = 30,
      root = d3.hierarchy(treeData);;

  var svg = d3.select('.js-svg-container').append('svg')
              .classed("svg-content", true)
              .append('g');

  var tree = d3.tree().nodeSize([0, 30]);

  var createStatisticsTable = function (statistics) {
    var table = document.createElement('table');
    table.classList.add('pure-table');

    var thead = document.createElement('thead');
    table.appendChild(thead);

    var theadTr = document.createElement('tr');
    thead.appendChild(theadTr);

    (function (tr) {
      ['#', 'email', '#lines'].forEach(function (columnName) {
        var th = document.createElement('th');
        th.innerHTML = columnName;
        tr.appendChild(th);
      });
    })(theadTr);

    var tbody = document.createElement('tbody');
    table.appendChild(tbody);

    statistics.forEach(function(stat, index) {
      var tr = document.createElement('tr');

      var rank = document.createElement('td');
      tr.appendChild(rank);
      rank.innerHTML = index + 1;

      var email = document.createElement('td');
      tr.appendChild(email);
      email.innerHTML = stat.email;

      var numLines = document.createElement('td');
      tr.appendChild(numLines);
      numLines.innerHTML = stat.numLines;

      tbody.appendChild(tr);
    });

    return table;
  };

  var showStatistics = function (node) {
    var table = createStatisticsTable(statistics[node.data.data.path]);

    var container = document.querySelector('.js-stats');

    while (container.hasChildNodes()) {
      container.removeChild(container.lastChild);
    }
    container.appendChild(table);

    var pathElement = document.querySelector('.js-path');
    var path = node.data.data.path;
    if (node.data.data.type === 'tree') {
      path = path + '/';
    }
    pathElement.innerHTML = path;
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
      n.x = (i + 1) * barHeight;
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
             .text(function (d) { return d.data.data.name; })
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

  document.querySelector('.js-spinner').classList.add('hidden');

  updateLayout(root);
  showStatistics(root);
});
