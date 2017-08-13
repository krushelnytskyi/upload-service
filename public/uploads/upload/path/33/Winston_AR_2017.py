#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""Ontology validation."""

# Standard library
import os
import json


###############################################################################
def print_tree(report, field):
    """Print the category tree."""
    inverse = dict((k['id'], k) for k in report[field])
    functions = dict((k['id'], []) for k in report[field] if
                     k['parents'] == [])

    for fun in report[field]:
        for parent in fun['parents']:
            if parent != '':
                functions[parent].append(fun['id'])

    sorted_keys = [i for i in sorted(functions.keys()) if
                   inverse[i]['label'] != '']

    for num, key in enumerate(sorted_keys):
        fun1 = inverse[key]
        pro = [i['label'] for i in report['products'] if key in i[field]]
        if field != 'industries' or not pro:
            print '\n%d) %s' % (num + 1, fun1['label'])
        else:
            print '\n%d) %s (%s)' % (num + 1, fun1['label'], ', '.join(pro))
        for num2, sec_fun in enumerate(functions[key]):
            fun2 = inverse[sec_fun]
            pro = [i['label'] for i in report['products'] if sec_fun in
                   i[field]]
            index = '%d.%d' % (num + 1, num2 + 1)
            print ' |--- %s) %s (%s)' % (index, fun2['label'], ', '.join(pro))

    print


###############################################################################
def generate_network(report):
    """Generate a JSON file for the network."""

    # "obj" is the object that contains the network
    obj = {'nodes': [],
           'edges': []}

    # "keys" is the array of node types. We don't add companies to the network,
    # it would be too crowded.
    keys = ['functions', 'industries', 'products']

    # Let's start with the nodes, we'll add edges later.

    # loop over node types
    for key in keys:
        # loop over nodes with a specific node type
        for item in report[key]:
            # if the node is a function or an industry, and it does not have
            # a parent, then it's a parent, so don't add it to the network
            if key in ['functions', 'industries'] and not item['parents']:
                # "continue" in a python loop means "skip the iteration"
                continue
            # build the node object
            node = {'id': item['id'],
                    'label': item['label'],
                    'type': key,
                    'uri': item['uri']}
            # sometimes I added an empty node at the end of each json file,
            # so only if the node id is not an empty string, add it to the
            # network.
            if node['id'] != '':
                obj['nodes'].append(node)

    # build a set with all the ids of all the nodes added to the network. A
    # set is a collection of unique elements in python.
    node_ids = set([i['id'] for i in obj['nodes']])

    # Now let's add edges.

    # this variable helps with giving a name to the edges, it's just a counter
    # that increases by 1 every time an edge is created.
    counter = 0

    # loop over node types
    for key in keys:
        # loop over nodes with a specific node type
        for item in report[key]:
            # if the node is an empty node, continue and skip the rest of the
            # loop
            if item['id'] == '':
                continue
            # if the node is a function or an industry, and it does not have
            # a parent, then it's a parent.
            if key in ['functions', 'industries'] and not item['parents']:
                # build a list of all the children of the given parent
                sons = [i for i in report[key] if item['id'] in i['parents']]
                # loop over the children (excluding the last element)
                for num1, son1 in enumerate(sons[:-1]):
                    # loop over the children that come after the child in the
                    # previous loop, son1
                    for son2 in sons[num1+1:]:
                        # increase the counter by 1
                        counter += 1
                        # build the edge object, edge is between son1 and son2
                        edge = {'id': 'e%d' % counter,
                                'source': son1['id'],
                                'target': son2['id']}
                        # add the edge to the network
                        obj['edges'].append(edge)
            # loop over just industries and functions
            for field in ['industries', 'functions']:
                # if the node is a product
                if field in item:
                    # loop over the ids in the field
                    for _id in item[field]:
                        # increase the counter by 1
                        counter += 1
                        # build the edge object, edge is between the product
                        # and the industry or the function
                        edge = {'id': 'e%d' % counter,
                                'source': item['id'],
                                'target': _id}
                        # add the edge to the network
                        obj['edges'].append(edge)
            # add the edge between the product and the company. This step is
            # not necessary and you can skip it, as we don't add companies to
            # the network.
            if 'company' in item and item['company'] in node_ids:
                counter += 1
                edge = {'id': 'e%d' % counter,
                        'source': item['id'],
                        'target': item['company']}
                obj['edges'].append(edge)

    # Let's check if we've added all the edges we wanted.

    # build a set of all the nodes with an edge
    edge_ids = set([i['source'] for i in obj['edges']] +
                   [i['target'] for i in obj['edges']])

    # the difference between the union and the intersection of the set of
    # all the nodes with an edge and the set of all nodes should be 0. If it's
    # not, stop the program and add the edges that are missing in the files.
    diff = (node_ids | edge_ids) - (node_ids & edge_ids)
    if diff:
        print 'Add %s' % diff
        return

    # upload the network to a gist on github. this step in not necessary for
    # you, the network can be on techemergence server.
    # gist = 'e89c169e3469584a79097577cb00631e'
    # path = '%s/network.json' % gist
    # git_dir = '%s/.git/' % gist
    # work_tree = '%s/' % gist
    # json.dump(obj, open(path, 'w'), indent=4, sort_keys=True)
    # os.system(('git --git-dir=%s --work-tree=%s commit -a -m '
    #            '"Improve: JSON file."') % (git_dir, work_tree))
    # os.system('git --git-dir=%s --work-tree=%s push' % (git_dir, work_tree))


###############################################################################
def main(print_trees=True):
    """Print report."""
    report = {}

    report['products'] = json.load(open('products.json'))
    report['functions'] = json.load(open('functions.json'))
    report['industries'] = json.load(open('industries.json'))
    report['companies'] = json.load(open('companies.json'))

    if print_trees:
        print_tree(report, 'functions')
        print '\n' + '-' * 80 + '\n'
        print_tree(report, 'industries')

    generate_network(report)


###############################################################################
if __name__ == '__main__':
    main()
