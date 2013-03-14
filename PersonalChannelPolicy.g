grammar PersonalChannelPolicy;

options {
  output=AST;
//  backtrack=true;
//  memoize=true;
//  language=C;
//  ASTLabelType=pANTLR3_BASE_TREE;
}

@header {
	package test;
	import java.util.HashMap;
	import java.util.ArrayList;
}

@lexer::header {
	package test;

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
			System.out.println($policy_stmt.value);
		}
	;
			
policy_stmt returns [String value] 
	: 	cloud_id_expr? effect event_filter_expr channel_id_expr (IF  condition)?  
        	{
		 policy.put("cloud_id" , $cloud_id_expr.result);  
		 policy.put("effect" , $effect.text);
// 		 policy.put("channel_id" , $channel_id_expr.result);
// 		 policy.put("condition", $condition.result);
        	} 
	| 	channel_id_expr BELONGS_TO cloud_id_expr
	; 
		

condition returns[HashMap result]
	:	relationship_expr 
	|	from_expr
	|	attribute_expr
	;
	
from_expr returns[HashMap result]
	:	NOT? 'raised by' (cloud_id_expr | CLOUD IN cloud_id_list | CLOUD LIKE regexp)
		{
		 HashMap from = new HashMap();
		 $result = from;
		}
	;

	
relationship_expr
	:	CHANNEL RELATIONSHIP IS NOT? (channel_relationship_id | IN channel_relationship_id_list)
	;
		
attribute_expr
	:	EVENTS ATTRIBUTE event_attr_name LIKE event_attr_value_regex
	;
		
cloud_id_expr returns[HashMap result]
	:	ALL CLOUD
		{
			HashMap cid = new HashMap();
			cid.put('id', 'all');
		 	$result = cid; 
		}	
	|	CLOUD cloud_id
		{
			HashMap cid = new HashMap();
			cid.put('id', $cloud_id.text);
		 	$result = cid;
		}
	;


cloud_id:	iname 
	|	inumber;

effect  : 	ALLOWS
	|	BLOCKS;


channel_relationship_id : PLUS ID (PLUS ID)* ;

channel_relationship_id_list : '[' channel_relationship_id ( ',' channel_relationship_id )* ']' ; 


cloud_id_list : '[' cloud_id (',' (iname|inumber))* ']' ; 


channel_id_expr returns[HashMap result]
	:	ON? ANY CHANNEL
	|	ON? CHANNEL channel_id
	;
	
channel_id : iname | inumber ;


event_domain : ID ; 
event_type : ID ;
event_type_list : '{' event_type (',' event_type)* '}';
 

event_filter_expr
	:	event_filter EVENTS;
	
event_filter : 	 ALL |	 event_domain (':'  (event_type | event_type_list))? ; 
	
iname : (EQUAL|AT) ID ('*' ID)* ;

// TODO: match XDI syntax here: https://wiki.oasis-open.org/xdi/XdiAbnf (immutable)
inumber : '=!' inumseq ('!' inumseq)* ;
inumseq :HEX;

regexp
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
ANY	:	'any';
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

