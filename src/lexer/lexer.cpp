#include "lexer.h"

#include <cctype>
#include <cstdlib>

namespace kx {

namespace {

struct KeywordEntry {
  const char* name;
  TokenKind kind;
};

constexpr KeywordEntry kKeywords[] = {
    {"component", TokenKind::KwComponent}, {"system", TokenKind::KwSystem},
    {"tag", TokenKind::KwTag},             {"struct", TokenKind::KwStruct},
    {"enum", TokenKind::KwEnum},           {"const", TokenKind::KwConst},
    {"var", TokenKind::KwVar},             {"void", TokenKind::KwVoid},
    {"int", TokenKind::KwInt},             {"long", TokenKind::KwLong},
    {"float", TokenKind::KwFloat},         {"double", TokenKind::KwDouble},
    {"bool", TokenKind::KwBool},           {"byte", TokenKind::KwByte},
    {"string", TokenKind::KwString},       {"if", TokenKind::KwIf},
    {"else", TokenKind::KwElse},           {"while", TokenKind::KwWhile},
    {"for", TokenKind::KwFor},             {"foreach", TokenKind::KwForeach},
    {"break", TokenKind::KwBreak},         {"continue", TokenKind::KwContinue},
    {"return", TokenKind::KwReturn},       {"spawn", TokenKind::KwSpawn},
    {"despawn", TokenKind::KwDespawn},     {"attach", TokenKind::KwAttach},
    {"detach", TokenKind::KwDetach},       {"self", TokenKind::KwSelf},
    {"with", TokenKind::KwWith},           {"without", TokenKind::KwWithout},
    {"new", TokenKind::KwNew},             {"tags", TokenKind::KwTags},
    {"using", TokenKind::KwUsing},         {"true", TokenKind::KwTrue},
    {"false", TokenKind::KwFalse},         {"is", TokenKind::KwIs},
    {"exact", TokenKind::KwExact},         {"panic", TokenKind::KwPanic},
    {"in", TokenKind::KwIn},
};

TokenKind lookupKeyword(const std::string& text) {
  for (const auto& e : kKeywords) {
    if (text == e.name) return e.kind;
  }
  return TokenKind::Identifier;
}

bool isDigit(char c) { return c >= '0' && c <= '9'; }
bool isIdentStart(char c) { return (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || c == '_'; }
bool isIdentPart(char c) { return isIdentStart(c) || isDigit(c); }

}  // namespace

Lexer::Lexer(std::string source, std::string file)
    : src_(std::move(source)), file_(std::move(file)) {}

const char* tokenKindName(TokenKind kind) {
  switch (kind) {
    case TokenKind::Eof: return "eof";
    case TokenKind::Identifier: return "identifier";
    case TokenKind::IntLiteral: return "int literal";
    case TokenKind::FloatLiteral: return "float literal";
    case TokenKind::StringLiteral: return "string literal";
    case TokenKind::DollarString: return "dollar string";
    case TokenKind::KwComponent: return "'component'";
    case TokenKind::KwSystem: return "'system'";
    case TokenKind::KwTag: return "'tag'";
    case TokenKind::KwStruct: return "'struct'";
    case TokenKind::KwEnum: return "'enum'";
    case TokenKind::KwConst: return "'const'";
    case TokenKind::KwVar: return "'var'";
    case TokenKind::KwVoid: return "'void'";
    case TokenKind::KwInt: return "'int'";
    case TokenKind::KwLong: return "'long'";
    case TokenKind::KwFloat: return "'float'";
    case TokenKind::KwDouble: return "'double'";
    case TokenKind::KwBool: return "'bool'";
    case TokenKind::KwByte: return "'byte'";
    case TokenKind::KwString: return "'string'";
    case TokenKind::KwIf: return "'if'";
    case TokenKind::KwElse: return "'else'";
    case TokenKind::KwWhile: return "'while'";
    case TokenKind::KwFor: return "'for'";
    case TokenKind::KwForeach: return "'foreach'";
    case TokenKind::KwBreak: return "'break'";
    case TokenKind::KwContinue: return "'continue'";
    case TokenKind::KwReturn: return "'return'";
    case TokenKind::KwSpawn: return "'spawn'";
    case TokenKind::KwDespawn: return "'despawn'";
    case TokenKind::KwAttach: return "'attach'";
    case TokenKind::KwDetach: return "'detach'";
    case TokenKind::KwSelf: return "'self'";
    case TokenKind::KwWith: return "'with'";
    case TokenKind::KwWithout: return "'without'";
    case TokenKind::KwNew: return "'new'";
    case TokenKind::KwTags: return "'tags'";
    case TokenKind::KwUsing: return "'using'";
    case TokenKind::KwTrue: return "'true'";
    case TokenKind::KwFalse: return "'false'";
    case TokenKind::KwIs: return "'is'";
    case TokenKind::KwExact: return "'exact'";
    case TokenKind::KwPanic: return "'panic'";
    case TokenKind::KwIn: return "'in'";
    case TokenKind::LBrace: return "'{'";
    case TokenKind::RBrace: return "'}'";
    case TokenKind::LParen: return "'('";
    case TokenKind::RParen: return "')'";
    case TokenKind::LBracket: return "'['";
    case TokenKind::RBracket: return "']'";
    case TokenKind::Semi: return "';'";
    case TokenKind::Comma: return "','";
    case TokenKind::Dot: return "'.'";
    case TokenKind::Colon: return "':'";
    case TokenKind::QMark: return "'?'";
    case TokenKind::Plus: return "'+'";
    case TokenKind::Minus: return "'-'";
    case TokenKind::Star: return "'*'";
    case TokenKind::Slash: return "'/'";
    case TokenKind::Percent: return "'%'";
    case TokenKind::EqEq: return "'=='";
    case TokenKind::BangEq: return "'!='";
    case TokenKind::Lt: return "'<'";
    case TokenKind::Gt: return "'>'";
    case TokenKind::LtEq: return "'<='";
    case TokenKind::GtEq: return "'>='";
    case TokenKind::AmpAmp: return "'&&'";
    case TokenKind::PipePipe: return "'||'";
    case TokenKind::Bang: return "'!'";
    case TokenKind::Assign: return "'='";
    case TokenKind::PlusEq: return "'+='";
    case TokenKind::MinusEq: return "'-='";
    case TokenKind::StarEq: return "'*='";
    case TokenKind::SlashEq: return "'/='";
    case TokenKind::PercentEq: return "'%='";
    case TokenKind::PlusPlus: return "'++'";
    case TokenKind::MinusMinus: return "'--'";
  }
  return "unknown";
}

void Lexer::report(const std::string& message, int line, int col) {
  errors_.push_back(LexError{file_ + ":" + std::to_string(line) + ":" + std::to_string(col) +
                                 ": " + message,
                             line, col});
}

char Lexer::advance() {
  char c = src_[pos_++];
  if (c == '\n') {
    line_++;
    col_ = 1;
  } else {
    col_++;
  }
  return c;
}

Token Lexer::makeToken(TokenKind kind, int startCol) {
  Token t;
  t.kind = kind;
  t.line = line_;
  t.col = startCol;
  return t;
}

void Lexer::skipTrivia() {
  for (;;) {
    while (!atEnd() && std::isspace(static_cast<unsigned char>(peek()))) advance();
    if (!atEnd() && peek() == '/' && peekAt(1) == '/') {
      while (!atEnd() && peek() != '\n') advance();
      continue;
    }
    if (!atEnd() && peek() == '/' && peekAt(1) == '*') {
      int startLine = line_, startCol = col_;
      advance();
      advance();
      bool closed = false;
      while (!atEnd()) {
        if (peek() == '*' && peekAt(1) == '/') {
          advance();
          advance();
          closed = true;
          break;
        }
        advance();
      }
      if (!closed) report("unterminated block comment", startLine, startCol);
      continue;
    }
    break;
  }
}

Token Lexer::scanIdentifier() {
  int startCol = col_;
  std::string text;
  while (!atEnd() && isIdentPart(peek())) text += advance();
  Token t = makeToken(lookupKeyword(text), startCol);
  t.text = text;
  return t;
}

Token Lexer::scanNumber() {
  int startCol = col_;
  std::string text;
  while (!atEnd() && isDigit(peek())) text += advance();

  bool isFloating = false;
  if (!atEnd() && peek() == '.' && isDigit(peekAt(1))) {
    isFloating = true;
    text += advance();
    while (!atEnd() && isDigit(peek())) text += advance();
  }

  if (!atEnd() && (peek() == 'e' || peek() == 'E')) {
    size_t save = pos_;
    int saveLine = line_, saveCol = col_;
    std::string exp;
    exp += advance();
    if (!atEnd() && (peek() == '+' || peek() == '-')) exp += advance();
    if (!atEnd() && isDigit(peek())) {
      isFloating = true;
      text += exp;
      while (!atEnd() && isDigit(peek())) text += advance();
    } else {
      pos_ = save;
      line_ = saveLine;
      col_ = saveCol;
    }
  }

  bool floatSuffix = false;
  bool longSuffix = false;
  if (!atEnd() && (peek() == 'f' || peek() == 'F')) {
    advance();
    floatSuffix = true;
    isFloating = true;
  } else if (!atEnd() && (peek() == 'L' || peek() == 'l')) {
    advance();
    longSuffix = true;
  }

  Token t = makeToken(isFloating ? TokenKind::FloatLiteral : TokenKind::IntLiteral, startCol);
  t.text = text;
  if (isFloating) {
    t.floatValue = std::strtod(text.c_str(), nullptr);
    t.isFloat = floatSuffix;
  } else {
    t.intValue = std::strtoll(text.c_str(), nullptr, 10);
  }
  (void)longSuffix;
  return t;
}

Token Lexer::scanString(bool dollar) {
  int startCol = col_;
  int startLine = line_;
  advance();
  std::string content;
  while (!atEnd() && peek() != '"') {
    char c = advance();
    if (c == '\\') {
      if (atEnd()) break;
      char e = advance();
      switch (e) {
        case 'n': content += '\n'; break;
        case 't': content += '\t'; break;
        case 'r': content += '\r'; break;
        case '0': content += '\0'; break;
        case '\\': content += '\\'; break;
        case '"': content += '"'; break;
        case '\'': content += '\''; break;
        default:
          report(std::string("unknown escape sequence '\\") + e + "'", line_, col_);
          content += e;
      }
    } else {
      content += c;
    }
  }
  if (atEnd()) {
    report("unterminated string literal", startLine, startCol);
    return makeToken(dollar ? TokenKind::DollarString : TokenKind::StringLiteral, startCol);
  }
  advance();
  Token t = makeToken(dollar ? TokenKind::DollarString : TokenKind::StringLiteral, startCol);
  t.text = content;
  return t;
}

Token Lexer::next() {
  char c = peek();
  switch (c) {
    case '{': advance(); return makeToken(TokenKind::LBrace, col_ - 1);
    case '}': advance(); return makeToken(TokenKind::RBrace, col_ - 1);
    case '(': advance(); return makeToken(TokenKind::LParen, col_ - 1);
    case ')': advance(); return makeToken(TokenKind::RParen, col_ - 1);
    case '[': advance(); return makeToken(TokenKind::LBracket, col_ - 1);
    case ']': advance(); return makeToken(TokenKind::RBracket, col_ - 1);
    case ';': advance(); return makeToken(TokenKind::Semi, col_ - 1);
    case ',': advance(); return makeToken(TokenKind::Comma, col_ - 1);
    case ':': advance(); return makeToken(TokenKind::Colon, col_ - 1);
    case '?': advance(); return makeToken(TokenKind::QMark, col_ - 1);
    case '.': advance(); return makeToken(TokenKind::Dot, col_ - 1);
    case '$': {
      if (peekAt(1) == '"') {
        advance();
        return scanString(true);
      }
      report("unexpected character '$'", line_, col_);
      advance();
      return makeToken(TokenKind::Eof, col_ - 1);
    }
    case '"': return scanString(false);
    case '+':
      advance();
      if (peek() == '+') { advance(); return makeToken(TokenKind::PlusPlus, col_ - 2); }
      if (peek() == '=') { advance(); return makeToken(TokenKind::PlusEq, col_ - 2); }
      return makeToken(TokenKind::Plus, col_ - 1);
    case '-':
      advance();
      if (peek() == '-') { advance(); return makeToken(TokenKind::MinusMinus, col_ - 2); }
      if (peek() == '=') { advance(); return makeToken(TokenKind::MinusEq, col_ - 2); }
      return makeToken(TokenKind::Minus, col_ - 1);
    case '*':
      advance();
      if (peek() == '=') { advance(); return makeToken(TokenKind::StarEq, col_ - 2); }
      return makeToken(TokenKind::Star, col_ - 1);
    case '/':
      advance();
      if (peek() == '=') { advance(); return makeToken(TokenKind::SlashEq, col_ - 2); }
      return makeToken(TokenKind::Slash, col_ - 1);
    case '%':
      advance();
      if (peek() == '=') { advance(); return makeToken(TokenKind::PercentEq, col_ - 2); }
      return makeToken(TokenKind::Percent, col_ - 1);
    case '=':
      advance();
      if (peek() == '=') { advance(); return makeToken(TokenKind::EqEq, col_ - 2); }
      return makeToken(TokenKind::Assign, col_ - 1);
    case '!':
      advance();
      if (peek() == '=') { advance(); return makeToken(TokenKind::BangEq, col_ - 2); }
      return makeToken(TokenKind::Bang, col_ - 1);
    case '<':
      advance();
      if (peek() == '=') { advance(); return makeToken(TokenKind::LtEq, col_ - 2); }
      return makeToken(TokenKind::Lt, col_ - 1);
    case '>':
      advance();
      if (peek() == '=') { advance(); return makeToken(TokenKind::GtEq, col_ - 2); }
      return makeToken(TokenKind::Gt, col_ - 1);
    case '&':
      advance();
      if (peek() == '&') { advance(); return makeToken(TokenKind::AmpAmp, col_ - 2); }
      report("unexpected character '&'", line_, col_);
      return makeToken(TokenKind::Eof, col_ - 1);
    case '|':
      advance();
      if (peek() == '|') { advance(); return makeToken(TokenKind::PipePipe, col_ - 2); }
      report("unexpected character '|'", line_, col_);
      return makeToken(TokenKind::Eof, col_ - 1);
    default:
      if (isDigit(c)) return scanNumber();
      if (isIdentStart(c)) return scanIdentifier();
      if (atEnd()) return makeToken(TokenKind::Eof, col_);
      report(std::string("unexpected character '") + c + "'", line_, col_);
      advance();
      return makeToken(TokenKind::Eof, col_ - 1);
  }
}

std::vector<Token> Lexer::tokenize() {
  std::vector<Token> tokens;
  for (;;) {
    skipTrivia();
    Token t = next();
    if (t.kind != TokenKind::Eof) {
      tokens.push_back(t);
    } else {
      tokens.push_back(t);
      break;
    }
  }
  return tokens;
}

}  // namespace kx