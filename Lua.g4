/*
BSD License

Copyright (c) 2013, Kazunori Sakamoto
Copyright (c) 2016, Alexander Alexeev
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions
are met:

1. Redistributions of source code must retain the above copyright
   notice, this list of conditions and the following disclaimer.
2. Redistributions in binary form must reproduce the above copyright
   notice, this list of conditions and the following disclaimer in the
   documentation and/or other materials provided with the distribution.
3. Neither the NAME of Rainer Schuster nor the NAMEs of its contributors
   may be used to endorse or promote products derived from this software
   without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
"AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

This grammar file derived from:

    Lua 5.4 Reference Manual
    https://www.lua.org/manual/5.4/manual.html

    Lua 5.3 Reference Manual
    https://www.lua.org/manual/5.3/manual.html

    Lua 5.2 Reference Manual
    https://www.lua.org/manual/5.2/manual.html

    Lua 5.1 grammar written by Nicolai Mainiero
    https://www.antlr3.org/grammar/1178608849736/Lua.g

Tested by Kazunori Sakamoto with Test suite for Lua 5.2 (http://www.lua.org/tests/5.2/)

Tested by Alexander Alexeev with Test suite for Lua 5.3 http://www.lua.org/tests/lua-5.3.2-tests.tar.gz
*/

grammar Lua;

chunk
    : block EOF
    ;

block
    : stat* retstat?
    ;

stat
    : ';'                                                                           # StatEmptySemicolon
    | varlist '=' explist                                                           # StatAssignment
    | functioncall                                                                  # StatFunctionCall
    | label                                                                         # StatLabel
    | 'break'                                                                       # StatBreak
    | 'goto' NAME                                                                   # StatGoto
    | 'do' block 'end'                                                              # StatDo
    | 'while' exp 'do' block 'end'                                                  # StatWhile
    | 'repeat' block 'until' exp                                                    # StatRepeat
    | 'if' exp 'then' block ('elseif' exp 'then' block)* ('else' block)? 'end'      # StatIfThenElse
    | 'for' NAME '=' exp ',' exp (',' exp)? 'do' block 'end'                        # StatNumericFor
    | 'for' namelist 'in' explist 'do' block 'end'                                  # StatGenericFor
    | 'function' funcname funcbody                                                  # StatFunction
    | 'local' 'function' NAME funcbody                                              # StatLocalFunction
    | 'local' attnamelist ('=' explist)?                                            # StatLocalAttributeNameList
    ;

attnamelist
    : NAME attrib (',' NAME attrib)*
    ;

attrib
    : ('<' NAME '>')?
    ;

retstat
    : 'return' explist? ';'?                                                        # StatReturn
    ;

label
    : '::' NAME '::'
    ;

funcname
    : NAME ('.' NAME)* (':' NAME)?
    ;

varlist
    : var_ (',' var_)*
    ;

namelist
    : NAME (',' NAME)*
    ;

explist
    : exp (',' exp)*
    ;

exp
    : 'nil'                                                                         # ExpNil
    | 'false'                                                                       # ExpFalse
    | 'true'                                                                        # ExpTrue
    | number                                                                        # ExpNumber
    | string                                                                        # ExpString
    | '...'                                                                         # ExpVararg
    | functiondef                                                                   # ExpFunctionDef
    | prefixexp                                                                     # ExpPrefixExp
    | tableconstructor                                                              # ExpTableConstructor
    | <assoc=right> exp operatorPower exp                                           # ExpOperatorPower
    | operatorUnary exp                                                             # ExpOperatorUnary
    | exp operatorMulDivMod exp                                                     # ExpOperatorMulDivMod
    | exp operatorAddSub exp                                                        # ExpOperatorAddSub
    | <assoc=right> exp operatorStrcat exp                                          # ExpOperatorStrcat
    | exp operatorComparison exp                                                    # ExpOperatorComparison
    | exp operatorAnd exp                                                           # ExpOperatorAnd
    | exp operatorOr exp                                                            # ExpOperatorOr
    | exp operatorBitwise exp                                                       # ExpOperatorBitwise
    ;

prefixexp
    : varOrExp nameAndArgs*
    ;

functioncall
    : varOrExp nameAndArgs+
    ;

varOrExp
    : var_ | '(' exp ')'
    ;

var_
    : (NAME | '(' exp ')' varSuffix) varSuffix*
    ;

varSuffix
    : nameAndArgs* ('[' exp ']' | '.' NAME)
    ;

nameAndArgs
    : (':' NAME)? args
    ;

args
    : '(' explist? ')' | tableconstructor | string
    ;

functiondef
    : 'function' funcbody
    ;

funcbody
    : '(' parlist? ')' block 'end'
    ;

parlist
    : namelist (',' '...')? | '...'
    ;

tableconstructor
    : '{' fieldlist? '}'
    ;

fieldlist
    : field (fieldsep field)* fieldsep?
    ;

field
    : '[' exp ']' '=' exp | NAME '=' exp | exp
    ;

fieldsep
    : ',' | ';'
    ;

operatorOr
	: 'or';

operatorAnd
	: 'and';

operatorComparison
	: '<' | '>' | '<=' | '>=' | '~=' | '==';

operatorStrcat
	: '..';

operatorAddSub
	: '+' | '-';

operatorMulDivMod
	: '*' | '/' | '%' | '//';

operatorBitwise
	: '&' | '|' | '~' | '<<' | '>>';

operatorUnary
    : 'not' | '#' | '-' | '~';

operatorPower
    : '^';

number
    : INT | HEX | FLOAT | HEX_FLOAT
    ;

string
    : NORMALSTRING | CHARSTRING | LONGSTRING
    ;

// LEXER

NAME
    : [a-zA-Z_][a-zA-Z_0-9]*
    ;

NORMALSTRING
    : '"' ( EscapeSequence | ~('\\'|'"') )* '"'
    ;

CHARSTRING
    : '\'' ( EscapeSequence | ~('\''|'\\') )* '\''
    ;

LONGSTRING
    : '[' NESTED_STR ']'
    ;

fragment
NESTED_STR
    : '=' NESTED_STR '='
    | '[' .*? ']'
    ;

INT
    : Digit+
    ;

HEX
    : '0' [xX] HexDigit+
    ;

FLOAT
    : Digit+ '.' Digit* ExponentPart?
    | '.' Digit+ ExponentPart?
    | Digit+ ExponentPart
    ;

HEX_FLOAT
    : '0' [xX] HexDigit+ '.' HexDigit* HexExponentPart?
    | '0' [xX] '.' HexDigit+ HexExponentPart?
    | '0' [xX] HexDigit+ HexExponentPart
    ;

fragment
ExponentPart
    : [eE] [+-]? Digit+
    ;

fragment
HexExponentPart
    : [pP] [+-]? Digit+
    ;

fragment
EscapeSequence
    : '\\' [abfnrtvz"'\\]
    | '\\' '\r'? '\n'
    | DecimalEscape
    | HexEscape
    | UtfEscape
    ;

fragment
DecimalEscape
    : '\\' Digit
    | '\\' Digit Digit
    | '\\' [0-2] Digit Digit
    ;

fragment
HexEscape
    : '\\' 'x' HexDigit HexDigit
    ;

fragment
UtfEscape
    : '\\' 'u{' HexDigit+ '}'
    ;

fragment
Digit
    : [0-9]
    ;

fragment
HexDigit
    : [0-9a-fA-F]
    ;

COMMENT
    : '--[' NESTED_STR ']' -> channel(HIDDEN)
    ;

LINE_COMMENT
    : '--'
    (                                               // --
    | '[' '='*                                      // --[==
    | '[' '='* ~('='|'['|'\r'|'\n') ~('\r'|'\n')*   // --[==AA
    | ~('['|'\r'|'\n') ~('\r'|'\n')*                // --AAA
    ) ('\r\n'|'\r'|'\n'|EOF)
    -> channel(HIDDEN)
    ;

WS
    : [ \t\u000C\r\n]+ -> skip
    ;

SHEBANG
    : '#' '!' ~('\n'|'\r')* -> channel(HIDDEN)
    ;
