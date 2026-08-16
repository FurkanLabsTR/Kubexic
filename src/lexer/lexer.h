#pragma once

#include "token.h"

#include <string>
#include <vector>

namespace kx {

struct LexError {
  std::string message;
  int line = 0;
  int col = 0;
};

class Lexer {
 public:
  Lexer(std::string source, std::string file = "<input>");

  std::vector<Token> tokenize();

  bool ok() const { return errors_.empty(); }
  const std::vector<LexError>& errors() const { return errors_; }

 private:
  Token next();
  void skipTrivia();
  void report(const std::string& message, int line, int col);
  Token makeToken(TokenKind kind, int startCol);
  Token scanIdentifier();
  Token scanNumber();
  Token scanString(bool dollar);

  bool atEnd() const { return pos_ >= src_.size(); }
  char peek() const { return atEnd() ? '\0' : src_[pos_]; }
  char peekAt(size_t off) const {
    return pos_ + off >= src_.size() ? '\0' : src_[pos_ + off];
  }
  char advance();

  std::string src_;
  std::string file_;
  size_t pos_ = 0;
  int line_ = 1;
  int col_ = 1;
  std::vector<LexError> errors_;
};

}  // namespace kx