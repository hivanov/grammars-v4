/**
 * A Protocol Buffers 3 grammar for ANTLR v4.
 *
 * Derived and adapted from:
 * https://developers.google.com/protocol-buffers/docs/reference/proto3-spec
 *
 * @author Hristo Ivanov
 */
grammar ProtocolBuffers3;

options { tokenVocab = Search; }

// comments
SINGLE_LINE_COMMENT: '//' .*? [\n\r] -> skip;
MULTI_LINE_COMMENT: '/*' .*? '*/' -> skip;

// syntax
EXTEND: 'extend';
SYNTAX: 'syntax';
MESSAGE: 'message';
REPEATED: 'repeated';
REQUIRED: 'required';
OPTIONAL: 'optional';
RESERVED: 'reserved';
TO: 'to';
ENUM: 'enum';
OPTION: 'option';
IMPORT: 'import';
MAP: 'map';
PUBLIC: 'public';
PACKAGE: 'package';
DOUBLE: 'double';
FLOAT: 'float';
INT32: 'int32';
INT64: 'int64';
UINT32: 'uint32';
UINT64: 'uint64';
SINT32: 'sint32';
SINT64: 'sint64';
FIXED32: 'fixed32';
FIXED64: 'fixed64';
SFIXED32: 'sfixed32';
SFIXED64: 'sfixed64';
BOOL: 'bool';
STRING: 'string';
BYTES: 'bytes';
TRUE: 'true';
FALSE: 'false';
EQUALS: '=';
COLON: ':';
SEMICOLON: ';';
RCURLY_BRACKET: '}';
LCURLY_BRACKET: '{';
LSQUARE_BRACKET: '[';
RSQUARE_BRACKET: ']';
OPEN_PAREN: '(';
CLOSE_PAREN: ')';
COMMA: ',';
LT: '<';
RT: '>';
DOT: '.';
SERVICE: 'service';
RPC: 'rpc';
RETURNS: 'returns';
ONEOF: 'oneof';

proto3File:
    syntaxDeclaration
    declarations
    ;

syntaxDeclaration:
    SYNTAX EQUALS String SEMICOLON
    ;

importDeclarations:
    importDeclaration+
;
importDeclaration
    : importFileDeclaration
    | importPublicFileDeclaration
    ;
importFileDeclaration: IMPORT String SEMICOLON;
importPublicFileDeclaration: IMPORT PUBLIC String SEMICOLON;

declarations: declaration*;
declaration
    : messageDeclaration
    | enumDeclaration
    | optionDeclaration
    | packageDeclaration
    | extensionDeclaration
    | importDeclarations
    | serviceDeclaration
    | oneOfDeclaration
    ;
serviceDeclaration
    : SERVICE name serviceMethods;
serviceMethods
    : LCURLY_BRACKET serviceMethodDeclarationOrOption* RCURLY_BRACKET;
serviceMethodDeclarationOrOption
    : optionDeclaration
    | serviceMethodDeclaration
    ;
serviceMethodDeclaration
    : RPC name type RETURNS type serviceMethodOptions
    ;
serviceMethodOptions
    : LCURLY_BRACKET optionDeclaration* RCURLY_BRACKET
    ;

extensionDeclaration
    : EXTEND name fields
    ;
packageDeclaration
    : PACKAGE name SEMICOLON
    ;
messageDeclaration
    : MESSAGE name fields
    ;
oneOfDeclaration
    : ONEOF name fields
    ;
fields
    : LCURLY_BRACKET field* RCURLY_BRACKET
    ;

field
    : fieldDeclaration
    | reservednumbersDeclaration
    | reservedNamesDeclaration
    | messageDeclaration
    | enumDeclaration
    | optionDeclaration
    | extensionDeclaration
    | oneOfDeclaration
    ;
fieldDeclaration: fieldQualifier type name EQUALS tag fieldOptions SEMICOLON;
reservednumbersDeclaration: RESERVED reservednumbers SEMICOLON;
reservedNamesDeclaration: RESERVED reservedNames SEMICOLON;

fieldQualifier
    : REPEATED
    | REQUIRED
    | OPTIONAL
    |
    ;
tag
    : number;

enumDeclaration
    : ENUM name enums
    ;
enums
    : LCURLY_BRACKET enumList RCURLY_BRACKET
    | LCURLY_BRACKET RCURLY_BRACKET
    ;
enumList
    : singleEnum*;

singleEnum
    : enumMemberDeclaration
    | optionDeclaration
    ;
enumMemberDeclaration: name EQUALS number fieldOptions SEMICOLON;
fieldOptions
    : LSQUARE_BRACKET fieldOptionList RSQUARE_BRACKET
    |;
fieldOptionList
    : fieldOption (COMMA fieldOption)*
    ;
fieldOption
    : optionName EQUALS optionValue;

optionName
    : name
    ;

optionDeclaration
    : OPTION optionName EQUALS optionValue SEMICOLON
    ;
optionValue
    : scalarOptionValue
    | stringOptionValue
    | identifierOptionValue
    | structuredOptionValues
    ;
scalarOptionValue
    : number 
    | (TRUE | FALSE)
    ;
structuredOptionValues
    : LCURLY_BRACKET structuredOptionValue+ RCURLY_BRACKET;
structuredOptionValue
    : name COLON optionValue
    | name structuredOptionValues;
stringOptionValue: String;
identifierOptionValue: Identifier;
reservednumbers
    : reservednumber (COMMA reservednumber)*
    ;
reservednumber
    : reservedSinglenumber
    | reservedRangeOfnumbers
    ;
reservedSinglenumber: tag;
reservedRangeOfnumbers: tag TO tag;
reservedNames
    : String (COMMA String)*
    ;

nameWithoutParens
    : Identifier (DOT Identifier)*
    ;
name
    : DOT? nameWithoutParens
    | OPEN_PAREN DOT? nameWithoutParens CLOSE_PAREN (DOT nameWithoutParens)?
    ;
type
    : scalarType
    | name
    | MAP LT keyType COMMA type RT
    ;
scalarType
    : DOUBLE
    | FLOAT
    | INT32
    | INT64
    | UINT32
    | UINT64
    | SINT32
    | SINT64
    | FIXED32
    | FIXED64
    | SFIXED32
    | SFIXED64
    | BOOL
    | STRING
    | BYTES
    ;
keyType
    : INT32
    | INT64
    | UINT32
    | UINT64
    | SINT32
    | SINT64
    | FIXED32
    | FIXED64
    | SFIXED32
    | SFIXED64
    | BOOL
    | STRING
    ;

Identifier
    : ID
    ;
number
    : SignedInteger
    | HexNumber
    | Decimal
    ;

String: QUOTE ('\\"' | ~'"')* QUOTE;

// 74743.432

// atoms
HexNumber: HexPrefix (HexChar|Digit)+;
fragment Integer: NonZero Digit* | Digit;
fragment OptionalPlusMinus: [+-]?;
SignedInteger: OptionalPlusMinus Integer;
fragment DecimalPoint: '.';
fragment DecimalReal: '-'? Integer DecimalPoint Integer ('e' SignedInteger)?;
Decimal: (DecimalReal | Nan | (OptionalPlusMinus Inf));
fragment Nan: [nN][aA][nN];
fragment Inf: 'inf';
fragment ID: [a-zA-Z][a-zA-Z_0-9]*;
fragment NonZero: [1-9];
fragment Digit: [0-9]+;
fragment HexChar: [a-fA-F];
fragment HexPrefix: [+-]?'0'[Xx];
WHITESPACE: [ \t\n\r]+ -> skip;
fragment QUOTE: '"';
