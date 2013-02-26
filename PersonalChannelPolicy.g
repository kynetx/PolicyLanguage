grammar PersonalChannelPolicy;
@header {
	import java.util.HashMap;
}
@members {
	/** Map variable name to Integer object holding value */
	HashMap memory = new HashMap();
}


/*------------------------------------------------------------------
 * PARSER RULES
 *------------------------------------------------------------------*/
 
policy 	:	policy_expr+;

policy_expr 
	:	 policy_stmt ';'  {System.out.println($policy_stmt.value);};
			
policy_stmt returns [String value]
	:	CLOUD cloud_id allow_or_block event_filter EVENTS  ON CHANNEL channel_id IF  condition  {
			memory.put("cloud_id" , $cloud_id.text); 
			memory.put("allow_or_block" , $allow_or_block.text);
			memory.put("channel_id" , $channel_id.text);
		  } 
		| CHANNEL channel_id BELONGS_TO CLOUD IDENTIFIER cloud_id   
		| CLOUD cloud_id allow_or_block event_filter EVENTS  ON CHANNEL channel_id 
		| CLOUD cloud_id allow_or_block event_filter EVENTS IF  condition; 
		

condition :	
		FROM  CLOUD IDENTIFIER IS cloud_id |
		FROM  CLOUD IDENTIFIER IS NOT cloud_id |
		FROM  CLOUD IDENTIFIER MATCHES cloud_id_regex |
		FROM  CLOUD IDENTIFIER  IS IN cloud_id_list |
		FROM  CLOUD IDENTIFIER  IS NOT IN cloud_id_list |
		CHANNEL RELATIONSHIP IS channel_relationship_id |
		CHANNEL RELATIONSHIP IS NOT channel_relationship_id |
		CHANNEL RELATIONSHIP  IS IN channel_relationship_id_list |
		CHANNEL RELATIONSHIP  IS NOT IN channel_relationship_id_list |
		EVENT ATTRIBUTE event_attr_name MATCHES event_attr_value_regex;

cloud_id : ALL | iname | inumber;

allow_or_block : (ALLOWS|BLOCKS);
//channel_relationship_id : (UPPERCASE_LETTERS|LOWERCASE_LETTERS|PLUS)+;
channel_relationship_id : PLUS ID (PLUS ID)* ;

channel_relationship_id_list : '[' channel_relationship_id ( ',' channel_relationship_id )* ']' ; 


cloud_id_list : '[' cloud_id (',' (iname|inumber))* ']' ; 


channel_id : ALL |  iname | inumber ;


event_domain : ID ; 
event_type : ID ;
event_type_list : '{' event_type (',' event_type)* '}';
 

event_filter : 	 ALL |	 event_domain ':'  (event_type | event_type_list) ; 
	
iname : (EQUAL|AT) inameseg ;
inameseg : ID ('*' ID)* ;
inumber : '=!' inumberseg ('!' inumberseg)* ;
inumberseg : (UPPERCASE_LETTERS|LOWERCASE_LETTERS|DIGIT)+;

cloud_id_regex 
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


CLOUD : 'cloud';
IDENTIFIER : 'identifier';
ALLOWS : 'allows';
BLOCKS : 'blocks';
EVENTS : 'events';
ON : 'on';
CHANNEL : 'channel';
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
SEPARATOR_I 	:	 '*';
WS: (' '|'\n'|'\r')+ {$channel=HIDDEN;} ; // ignore whitespace

MATCHES :	 'matches';
QUESTION_MARK 	:	 '?';
LEFT_PAREN : '(';
RIGHT_PAREN : ')';

ESCAPE_CHAR 	:	 '\\';
EVENT : 'event';
ATTRIBUTE : 'attribute';
ID	: ('a'..'z'|'A'..'Z'|'_') ('a'..'z'|'A'..'Z'|'_'|'0'..'9')*;
