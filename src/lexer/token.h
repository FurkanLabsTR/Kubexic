#pragma once

#include <cstdint>
#include <string>

namespace kx {

enum class TokenKind {
  Eof,

  Identifier,
  IntLiteral,
  FloatLiteral,
  StringLiteral,
  DollarString,

  KwComponent,
  KwSystem,
  KwTag,
  KwStruct,
  KwEnum,
  KwConst,
  KwVar,
  KwVoid,
  KwInt,
  KwLong,
  KwFloat,
  KwDouble,
  KwBool,
  KwByte,
  KwString,
  KwIf,
  KwElse,
  KwWhile,
  KwFor,
  KwForeach,
  KwBreak,
  KwContinue,
  KwReturn,
  KwSpawn,
  KwDespawn,
  KwAttach,
  KwDetach,
  KwSelf,
  KwWith,
  KwWithout,
  KwNew,
  KwTags,
  KwUsing,
  KwTrue,
  KwFalse,
  KwIs,
  KwExact,
  KwPanic,
  KwIn,
  KwSwitch,
  KwCase,
  KwDefault,

  LBrace,
  RBrace,
  LParen,
  RParen,
  LBracket,
  RBracket,
  Semi,
  Comma,
  Dot,
  Colon,
  QMark,

  Plus,
  Minus,
  Star,
  Slash,
  Percent,
  EqEq,
  BangEq,
  Lt,
  Gt,
  LtEq,
  GtEq,
  AmpAmp,
  PipePipe,
  Bang,
  Assign,
  PlusEq,
  MinusEq,
  StarEq,
  SlashEq,
  PercentEq,
  PlusPlus,
  MinusMinus,
};

struct Token {
  TokenKind kind = TokenKind::Eof;
  std::string text;
  std::int64_t intValue = 0;
  double floatValue = 0.0;
  bool isFloat = false;
  bool isLong = false;
  int line = 0;
  int col = 0;
};

const char* tokenKindName(TokenKind kind);

}  // namespace kx