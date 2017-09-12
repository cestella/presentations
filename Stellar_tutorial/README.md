# Introduction

[Stellar](https://github.com/apache/metron/tree/master/metron-stellar/stellar-common)
is an expression language used by [Metron](http://metron.apache.org).
The purpose of this document is to give a brief overview of its
capabilities through use of the REPL.

## Prerequisites

There are a few prerequisites, of course, before we get started.  It
goes without saying, a working Metron instance would be necessary.
Once that is acquired:
* Log in to the access node (i.e. the one that contains the metron binaries and shell scripts).
* Create the following environment variables:
  * `METRON_HOME` - The base directory for the Metron installation (e.g.
    in apache this is `/usr/metron/$VERSION/`
  * `ZK_QUORUM` - A zookeeper host (with port specified).

# The Basics

## Start the REPL

Start the REPL by running the stellar shell command via:
```
$METRON_HOME/bin/stellar
```

You should see something similar to the following:
```
[root@node2 zookeeper]# /usr/metron/0.4.1/bin/stellar
Stellar, Go!
Please note that functions are loading lazily in the background and will
be unavailable until loaded fully.
2017-09-11 23:49:50,245 WARN  [Thread-1] resolver.BaseFunctionResolver:
Using System classloader
[Stellar]>>> Functions loaded, you may refer to functions now...
```

# Explore the REPL

The REPL that has a few interesting attributes:
* Variables and functions are tab completed (go ahead and type `TO` and then tab)
* Every stellar function has documentation that can be interrogated via the REPL.  The syntax is ?FUNCTION_NAME (e.g. ?TO_UPPER)
  * Try it out yourself by typing `?` and then tab to get a list of possible functions and variables to use
  * Try it out further by typing `?TO_UPPER` and then enter to get the documentation for `TO_UPPER`


# Literals

We can now investigate the various literals available in Stellar:
* String
* Numeric
* Map
* List

Paste the following into the REPL

```
# Create a string field called string_field
string_field := 'hello world'
string_field
# Create a int field called int_field
int_field := 1
int_field
# Create a long field called long_field
long_field := 10000000000000L + int_field
long_field
# Create a double field called double_field
double_field := 2.2 + int_field + long_field
double_field
# Create a map field called map_field, note that the keys can be other fields here
map_field := { 'key1' : string_field, string_field : int_field }
map_field
# Create a list field called list_field
list_field := [ 'apple', 'orange', string_field]
list_field
# show the vars, note that the expression
%vars
``` 

# String Manipulation

We can manipulate strings too.  Paste the following into the REPL.

```
# Manipulate a string.  Weird caps and spaces..sounds about par for the course.
user := 'cStElLa '
user := TO_LOWER(TRIM(user))
user
# Create a user like we might get from an authentication record
user := 'LOCAL\\cstella'
user
# We can use regexps to pick apart the last bit of the name.
# We will treat it as a string that has some stuff followed by punctuation followed by some other stuff.
# We want the last bit of stuff
user := REGEXP_GROUP_VAL( user, '(.*)\\p{Punct}(.*)', 2)
user
# Now consider a list of usernames and you want just the first one
user := 'cstella,sball,jsirota'
user
# We can split the string up by comma
user_list := SPLIT(user, ',')
user_list
user := GET_FIRST(user_list)
user
# Maybe instead we want the second one, though
user := GET(user_list,1)
user
# or the last one
user := GET_LAST(user_list)
user
# There is also some special syntactical sugar for string contains
'i' in 'team'
'tea' in 'team'
# Indeed, there does not seem to be an i in team, but there is some tea.
```

# Data Structures

You can also manipulate many common data structures, such as
* Maps
* Lists
* Sets
* Multisets

Paste the following into the REPL to explore this
```
# Lists are easy
list := [ 'casey', 'stella' ]
list
# Lists can be added to
LIST_ADD(list, 'blah')
# And can have their length taken
if LENGTH(list) > 2 then 'bigger' else 'smaller'
# if they are strings, they can be joined
cat := JOIN(list, ' ')
cat
# Maps can also be used
map := { 'foo' : 1, 'bar' : 2 }
map
# Get the 'foo' key and add 1 to it
MAP_GET('foo', map) + 1
# Also have sets
set := SET_INIT(['casey', 'casey', 'stella'])
set
# Sets can be added to as well
set := SET_ADD(set, 'stella')
set
# or removed from
set := SET_REMOVE(set, 'casey')
set
# And also have their length taken
LENGTH(set)
# And multisets, which can help keep track of sparse sets
multiset := MULTISET_INIT([ 'casey', 'casey', 'stella'])
multiset
# Some syntactic sugar was added for data structures such as maps, sets, multisets and lists to determine contains
# stella is in all of the collections
'stella' in set && 'stella' in list && 'stella' in multiset
# metron is in none of them
'metron' in set || 'metron' in list || 'metron' in multiset
# foo is the only key in the map
'foo' in map
```

# Stats

A common task is to inquire about statistical baselines.  To accumulate windowed distribution of a variable
(e.g. the # of times a user logs in every day) and to determine outlier status based on how far off a value is
from this statistical baseline.  An integral component to that is creation, manipulation, merging and scalable
storage of distributional sketches (i.e. approximate distributions of data).

Let's play around with that here by pasting these into the REPL:
```
# You can initiate a stats object and interact with it
stats := STATS_INIT()
stats := STATS_ADD(stats, 1.0)
stats := STATS_ADD(stats, 2.0)
stats := STATS_ADD(stats, 3.0)
stats := STATS_ADD(stats, 5.0)
# Now we can interrogate stats objects to get some idea about how the data is distributed
# This will become important for use-cases involving statistical baselining
# How about the median
STATS_PERCENTILE(stats, 50.0)
# Or the standard deviation
STATS_SD(stats)
# Find out more functions that you can do by typing ?STATS and then tab
# I can also split the distribution up and merge it back together
# We can create one distribution of 1,2, and another one for 3 and 5
stats1 := STATS_INIT()
stats1 := STATS_ADD(stats1, 1.0)
stats1 := STATS_ADD(stats1, 2.0)
STATS_PERCENTILE(stats1, 50.0)
STATS_SD(stats1)
stats2 := STATS_INIT()
stats2 := STATS_ADD(stats2, 3.0)
stats2 := STATS_ADD(stats2, 5.0)
STATS_PERCENTILE(stats2, 50.0)
STATS_SD(stats2)
# Now we have 2 distributions stats1 and stats2 that, if I could merge them, should equal stats
stats_merge := STATS_MERGE([stats1, stats2])
STATS_PERCENTILE(stats_merge, 50.0)
STATS_SD(stats_merge)
# Note this is equivalent to the median and standard deviation of the stats distribution.                                     
# Also it is different than either of the two component distributions.
```
