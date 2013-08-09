

# Introduction #

Pixel is a policy expression language. While the concepts are modeled on those of other policy languages, including XACML, Pixel is designed to work specifically with the [Kynetx Rules Engine][kre]. Pixel can be used to specify access control policies that control which events are permitted on specific channels or channels with specific attributes. 

Pixel policies consist of declarations and rules. The declarations are optional and are used simply to make the rules more readable. Rules specify an effect (`allow` or `deny`) for actions (e.g. events) on resources (e.g. channels). 

This document describes policies and policy combination algorithms in Pixel.

[kre]: https://github.com/kre/Kinetic-Rules-Engine

# Policies #

The simplest policies allow or deny all events on all channels:

    policy 
      allow all events on any channel

    policy 
      deny all events on any channel

These are not necessarily very useful in most cases but represent two extreme cases of the permission spectrum. 

A more useful policy would limit the events that can be raised on a specific channel. 

    policy 
      allow cloudos:{subscribe, unsubscribe} events on channel =!1212

A policies can have more than one rule as show here:

    policy 
      allow cloudos:{subscribe, unsubscribe} events on channel =!1212
      allow cloudos:{subscribe, unsubscribe} events on channel =!2323
      allow notification:status events on channel =!2323


## Conditions and Attributes ##

The preceding example shows why attribute-based access control is useful. The policy allows `cloudos:{subscribe, unsubscribe}` events on two channels. Suppose the reason for that is that both of those channels have a common `relation` attribute of `+owner`; We could, rather write the same policy as 

    policy 
      allow cloudos:{subscribe, unsubscribe} events on any channel 
	     if channel attribute +relation is +owner

The preceding policy uses a condition to allow `cloudos:{subscribe, unsubscribe}` events on any channel with the right value for the `relation` attribute. 

## Declarations ##

Channel and cloud names tend to be long strings of hexadecimal characters. Declarations improve readability by allowing policy writers to give shorter, more meaningful names to things. For example, the following policy uses a declarations, `my_cloud`, to allow certain events on channel `A` if they are raised by cloud `B`. 

    decls
      A = =!234; 
	  B = =!345
    policy
      allow cloudos:unsubscribe events on channel A
	    if raised by cloud B;

# Rule Combining Algorithms #

Because a policy can have more than one rule, arriving at an `allow` or `deny` decision  requires combining rules. At present Pixel has a single, set rule combining algorithm (RCA), but future versions may allow the policy writer to choose the RCA. 


## Results ##

The job of the RCA is to determine whether to `allow` or `deny` a given action on a resource by a given subject. The result of the RCA can be one of four values:

1. `allow` (A) &mdash; allow the action on the resource
1. `deny` (D) &mdash; deny the action on the resource
1. `not applicable` (NA) &mdash; the policy doesn't say anything about the request
1. `indeterminate` (IN) &mdash; there was an error in evaluating the policy

## Permit-Overrides ##

The RCA in Pixel is *permit-overrides*. Permit-overrides prefers A to D to NA. That is, if any rule evaluates to P, the result is P; otherwise if no rule evaluates to P, and some rule evaluates to D, the result is D; finally if all rules evaluate to NA, the result is NA. Another way to think about this is that the RCA performs logical disjunction among the various applicable rules and if *any* return A, the result is A. 

When a policy is evaluated for a given subject and resource, each rule is examined for applicability. Any rules that are applicable are evaluated. If any of the applicable rules return A, the overall result is A. 

## Default to Deny ##

The RCA defaults to deny in the case of NA or IN results. 

