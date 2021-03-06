{
module Parser.Parser where
import Parser.Lexer
import Lang.Ast
import JetErrorM
}

%name stlc
%tokentype { Token }
%monad { JetError } { (>>=) } { return }
%error { parseError }
--%lexer { stlcLex } { TokEOF _ }

%token
    true            { TokTrue $$ }
    false           { TokFalse $$ }
    Bool            { TokTBool _ }
    Int             { TokTInt _ }
    int_literal	    { TokInt pos $$ }
    var		        { TokVar pos $$ }
    if              { TokIf _}
    then            { TokThen _}
    else            { TokElse _}
    let             { TokLet _}
    in              { TokIn _}
    fix             { TokFix _ }
    pred            { TokPred _ }
    succ            { TokSucc _ }
    iszero          { TokIszero _ }
    "\\"            { TokLambda _ }
    "->"            { TokArrow _ }
    "."             { TokDot _ }
    "("             { TokLBrace _ }
    ")"             { TokRBrace _ }
    ":"             { TokColon _ }
    "="             { TokEq _ }

%right "->"
%%

Expr    : "\\" var ":" Type "." Expr    { Lam (Id $2) $4 $6 }
        | AppExpr                       { $1 }

AppExpr : AppExpr AppRhs                { App $1 $2 }
        | AppRhs                        { $1 }

AppRhs  : if Expr then Expr else Expr   { If $2 $4 $6 }
        | let var "=" Expr in Expr      { Let (Id $2) $4 $6 }
        | fix Expr                      { Fix $2 }
        | pred Expr                     { Pred $2 }
        | succ Expr                     { ESucc $2 }
        | iszero Expr                   { Iszero $2 }
        | var                           { Var pos (Id $1) }
        | int_literal                   { Lit pos (LitInt $1) }
        | true                          { Lit $1 (LitBool True) }
        | false                         { Lit $1 (LitBool False) }
        | "(" ")"                       { Lit (AlexPn 0 0 0) LitUnit }
        | "(" Expr ")"                  { $2 }

Type    : Int               { TInt }
        | Bool              { TBool }
        | Type "->" Type    { TFun $1 $3 }
        | "(" ")"           { TUnit }
        | "(" Type ")"      { $2 }


{
parseError :: [Token] -> JetError a
parseError [tok] = let loc = getLoc tok in
    Fail ("Parse Error " ++ show (fst loc) ++ ":" ++ show (snd loc) ++ " found unexpected \"" ++ show tok ++ "\"")
parseError toks = Fail ("Unexpected end of input")
}
