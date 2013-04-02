grammar PersonalChannelPolicy;

options {
  output=AST;
}

@header {
	package com.kynetx;
	import java.util.HashMap;
	import java.util.ArrayList;
}

@lexer::header {
	package com.kynetx;

}


@members {
	public HashMap policy = new HashMap();
	public ArrayList parse_errors = new ArrayList();

	public void emitErrorMessage(String msg) {
		parse_errors.add(msg);
	}
}



/*------------------------------------------------------------------
 * PARSER RULES
 *------------------------------------------------------------------*/
 
policy 	:	policy_expr+
	; 

policy_expr 
	:	policy_stmt ';'  
		{
			System.out.println($policy_stmt.result);
		}
	;
			
policy_stmt  returns[HashMap result]
	: 	cloud_id_expr? effect event_filter_expr channel_id_expr (IF  condition)?  
        	{
		 policy.put("cloud_id" , $cloud_id_expr.result);  
		 policy.put("effect" , $effect.text);
		 policy.put("channel_id" , $channel_id_expr.result);
		 policy.put("event_filter", $event_filter_expr.result);
		 if($condition.result != null) {
 		   policy.put("condition", $condition.result);
 		 }
                 $result = policy;
        	} 
	| 	channel_id_expr BELONGS_TO cloud_id_expr
	;  
		

condition returns[HashMap result]
	:	relationship_expr 
	{
		$result =$relationship_expr.result;
	}
	|	from_expr
	{
		$result =$from_expr.result;
	} 
	|	attribute_expr
	{
		$result =$attribute_expr.result;
	}
	;
	
from_expr returns[HashMap result]
	:	NOT? 'raised by' (cloud_id_expr | CLOUD IN cloud_id_list | CLOUD LIKE regex)
	{
		HashMap condition = new HashMap();
		if($NOT != null) {
		   condition.put("sense", false);
		} else {
		   condition.put("sense", true);
		}
		if($cloud_id_expr.result != null) {
		  condition.put("type", "raised_by_single");
		  condition.put("cloud_id", $cloud_id_expr.result);
		} else if ($cloud_id_list.result != null) {
		  condition.put("type", "raised_by_list");
  		  condition.put("cloud_list", $cloud_id_list.result);
		} else {
		  condition.put("type", "raised_by_match");
  		  condition.put("regex", $regex.text);
		}
		$result = condition;
	}
	;

	
relationship_expr  returns[HashMap result]
	:	CHANNEL RELATIONSHIP IS NOT? (channel_relationship_id | IN channel_relationship_id_list)
	{
		HashMap relationship = new HashMap();
		if($NOT != null) {
		   relationship.put("sense", false);
		} else {
		   relationship.put("sense", true);
		}		if($channel_relationship_id.result != null) {
		  relationship.put("type", "relationship_single");
		  relationship.put("relationship_id", $channel_relationship_id.result);
		} else {
		  relationship.put("type", "relationship_list");
  		  relationship.put("relationship_list", $channel_relationship_id_list.result);
		} 
		$result = relationship;
	} 
	;
		
attribute_expr returns[HashMap result]
	:	EVENTS ATTRIBUTE event_attr_name LIKE event_attr_value_regex
	{
		HashMap attribute = new HashMap();
		attribute.put("type", "attribute");
		attribute.put("name", $event_attr_name.text);
		attribute.put("regex", $event_attr_value_regex.text);
		$result = attribute;
	}
	;
		
cloud_id_expr returns[String result]
	:	ALL CLOUD
		{
		 	$result = $ALL.text; 
		}	
	|	CLOUD cloud_id
		{
		 	$result = $cloud_id.text;
		}
	;


cloud_id_list returns[ArrayList result]
	@init{
		ArrayList cloud_array = new ArrayList();
	}
	: '[' c0 = cloud_id { cloud_array.add($c0.text);} (',' c1 = cloud_id { cloud_array.add($c1.text);} )* ']' 
	{
		$result = cloud_array;
	}
	; 
	
cloud_id 
	:	iname 
	|	inumber;

effect  : 	ALLOWS
	|	BLOCKS;


channel_relationship_id returns[String result]
	:	PLUS ID (PLUS ID)* ;

channel_relationship_id_list returns[ArrayList result]
	@init{
		ArrayList rship_array = new ArrayList();
	}
	: '[' r0 =  channel_relationship_id { rship_array.add($r0.text);} ( ',' r1 = channel_relationship_id { rship_array.add($r1.text);} )* ']' 
	{
		$result = rship_array;
	}
	; 


channel_id_expr returns[String result]
	:	ON? a=(ANY|AUTH) CHANNEL
	{
	 	$result = $a.text; 
	}	
	|	ON? CHANNEL channel_id
	{
	 	$result = $channel_id.text;
	}
	;
	
channel_id : iname | inumber ;


event_domain : ID ; 
event_type : ID ;
event_type_list returns[ArrayList result]
	: '{' types += event_type (',' types += event_type)* '}'
	{
		ArrayList type_array = new ArrayList();
		if($types != null) {
			for(int i = 0;i< $types.size();i++) {
				type_array.add($types.get(i));
			}
		}
		$result = type_array;
	}
	;
 

event_filter_expr returns[HashMap result]
	:	event_filter EVENTS
	{
		$result =$event_filter.result;
	}
	;
	
event_filter returns[HashMap result]
	: 	 ALL 
	{
	 	HashMap event = new HashMap();
	 	event.put("domain", "all");
		$result = event; 
	}
	|	 event_domain (':'  (event_type | event_type_list))? 
	{
	 	HashMap event = new HashMap();
	 	event.put("domain", $event_domain.text);
	 	if($event_type.text != null) {
	 	  ArrayList type_array = new ArrayList();
	 	  type_array.add($event_type.text);
	 	  event.put("types", type_array);
	 	} else if ($event_type_list.result != null) {
	 	  event.put("types", $event_type_list.result);
	 	} else {
	 	  event.put("types", new ArrayList());
	 	}
		$result = event;
	}
	; 
	
iname : (EQUAL|AT) ID ('*' ID)* ;

// TODO: match XDI syntax here: https://wiki.oasis-open.org/xdi/XdiAbnf (immutable)
inumber : '=!' inumseq ('!' inumseq)* ;
inumseq :HEX;

regex
	:	 '/' cloud_id '/';

event_attr_value_regex 
	:	 '/' ID '/';

event_attr_name : ID ;	

/*------------------------------------------------------------------
 * LEXER RULES
 *------------------------------------------------------------------*/
 
UPPERCASE_LETTERS 
	:	 'A'..'Z';
LOWERCASE_LETTERS 
	:	'a'..'z';
DIGIT	:	
		'0'..'9';
PLUS 	:	 '+';

BANG 	:	 '!';
EQUAL   :	 '=';
AT	: '@';
UNDERSCORE 
	:	 '_';
HYPHEN 	:	 '-';


CLOUD 	: 'cloud' 
	| 'clouds';
IDENTIFIER 	
	: 'identifier';
ALLOWS : 'allows' | 'allow';
BLOCKS : 'blocks' | 'block' | 'deny' | 'denies';
EVENTS : 'events' | 'event';
ON : 'on';
CHANNEL : 'channel' 
	| 'channels';
OWNS : 'owns';
NOT : 'not';
AND : 'and';
OR : 'or';
RELATIONSHIP : 'relationship';
IS : 'is';
IN : 'in';
NEWLINE : '\n';
IF : 'if'; 
FROM 	:	 'from';
BELONGS_TO :	 'belongs to';
ALL 	:	 'all';
ANY	:	'any';
AUTH	: 'authenticated' 
	| 'authd'
	| 'unauthenticated'
	| 'unauthd'
	;
SEPARATOR_I 	:	 '*';
WS: (' '|'\n'|'\r')+ {$channel=HIDDEN;} ; // ignore whitespace

LIKE :	 'like';
QUESTION_MARK 	:	 '?';
LEFT_PAREN : '(';
RIGHT_PAREN : ')';

ESCAPE_CHAR 	:	 '\\';

ATTRIBUTE : 'attribute';

HEX	: ('abcdef' | '0'..'9')+;

ID	: ('a'..'z'|'A'..'Z'|'_') ('a'..'z'|'A'..'Z'|'_'|'0'..'9')*;


INT :	' -'? '0'..'9'+
    ;

FLOAT
    :   ' -'? ('0'..'9')+ '.' ('0'..'9')*
    |   ' -'? '.' ('0'..'9')*

    ;

