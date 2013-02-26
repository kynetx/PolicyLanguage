# XDI Policy Language

A simple policy language to support XDI link contracts.

The goal of this project is to create a fully featured policy expression language that is human readable and compiles to XDI link contracts. 

We will start with a simpler language that creates link contracts for controlling messages on personal channels. 

## Plan

As Drummond went thru his example of a link contract as an event channel policy expression, it because more clear than ever that for this to work, we need a policy expression language that compiles to XDI. Programmers aren't going to write the XDI directly. I don't know how they could. More and more I think of XDI as the assembly language of data. 

Here is Drummond's example from https://wiki.oasis-open.org/xdi/XdiPolicyExpression/Discussion

```
...$do/$do$send/=!1111$(+channel)$(!23)$(+event)
...$do$if$($and)$(!1)/$do$send/(=!1111$(+channel)$(!23)$(+event)($1)$!(+domain)/!/(data:,cloudos))
...$do$if$($and)$(!2)/$do$send/(=!1111$(+channel)$(!23)$(+event)($1)$!(+type)/!/(data:,notification))
...$do$if$($and)$(!2)/$do$send/(=!1111$(+channel)$(!23)$(+event)($1)$!(+type)/!/(data:,subscription))
...$do$if$($and)$(!2)/$do$send/(=!1111$(+channel)$(!23)$(+event)($1)$!(+type)/!/(data:,deletion))
```

This says, to the extent I understand it:

```
User =!1111 can send events on channel !23
Channel !23 allows cloudos:{notification|subscription|deletion} events
```

We'd probably more likely need the following kinds of policy:

```
Cloud =!1111 is a +friend
Channel !23 belongs to user =!1111
Any channel that belong to a +friend allows cloudos:{notification|subscription|deletion} events
```

Or, more likely, 

```
Cloud =!1111 owns channel !23
Channel !23 has relationship type +friend
Any channel with relationship type +friend allows cloudos:{notification|subscription|deletion} events
```

Suppose this is our policy language (and it could be; I don't see any reason we could write a parser for statements like the three proceeding). We would want to compile it to the equivalent XDI statements for storage in the XDI graph of the cloud. 

We would want a system that allows us to query the XDI graph and produce a data structure like this for use in filtering events on channels:

```javascript
{...
 "!23" : {"cloudos" : {"notification" : true,
                       "subscription" : true,
                       "deletion" : true
                      }
          ...
         }
...
}
```

This would be cached and only flushed if the XDI server raised a system event saying that the policy graph had changed and allow the rules engine to make quick determinations whether or not the event was allowed on a specific channel. 

This all seems relatively straightforward.  We could have (maybe) an XDI pretty printer that turns the XDI statements that these policy statements compile to back into the policy statements. That means that the XDI graph for the cloud is the repository for the policy (if we can't get it back out in a human readable form, you would have to have another repository for the human readable statements and keep them in sync and that would be ugly). 

The biggest question in my mind is where does this policy come from in the first place? Who writes it? Using what tool? The first two statements are created when the channel is created, so that's OK:

```
Cloud =!1111 owns channel !23
Channel !23 has relationship type +friend
```

The last one is likely a global policy that the user might override or customize, but I don't know how that would work. 

```
Any channel with relationship type +friend allows cloudos:{notification|subscription|deletion} events
```

## Build Tools

The grammar is written in ANTLR. 

The compiler is written in Perl. 

