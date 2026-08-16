#pragma once

#include "ast.h"
#include "token.h"

#include <memory>
#include <string>
#include <vector>

namespace kx {

struct ParseError {
  std::string message;
  int line = 0;
  int col = 0;
};

class Parser {
 public:
  Parser(std::vector<Token> tokens, std::string file);

  std::unique_ptr<Program> parse();

  bool ok() const { return errors_.empty(); }
  const std::vector<ParseError>& errors() const { return errors_; }

 private:
  const Token& peek() const;
  const Token& peekAt(size_t n) const;
  bool check(TokenKind k) const;
  bool checkName() const;
  const Token& advance();
  bool match(TokenKind k);
  bool expect(TokenKind k, const char* what);
  void errorHere(const std::string& msg);
  void errorAt(const std::string& msg, int line, int col);

  Decl parseComponent();
  Decl parseSystem();
  Decl parseTag();
  Decl parseStruct();
  Decl parseEnum();
  Decl parseConst();
  Decl parseFunction();
  Decl parseTopLevel();

  StmtPtr parseStatement();
  StmtPtr parseBlock();
  StmtPtr parseVarDecl();
  StmtPtr parseIf();
  StmtPtr parseWhile();
  StmtPtr parseFor();
  StmtPtr parseForeach();
  StmtPtr parseReturn();
  StmtPtr parseSwitch();
  StmtPtr parseAttach();
  StmtPtr parseDetach();
  StmtPtr parseDespawn();

  ExprPtr parseExpression();
  ExprPtr parseAssignment();
  ExprPtr parseTernary();
  ExprPtr parseLogicalOr();
  ExprPtr parseLogicalAnd();
  ExprPtr parseEquality();
  ExprPtr parseRelational();
  ExprPtr parseAdditive();
  ExprPtr parseMultiplicative();
  ExprPtr parseUnary();
  ExprPtr parsePostfix();
  ExprPtr parsePrimary();
  ExprPtr parseInterpolated(const Token& dollar);
  ComponentInit parseComponentInit();

  bool isNameToken(const Token& t) const;
  bool tryParseTypeArgs(std::vector<std::string>& out);
  ExprPtr parseCall(ExprPtr base, std::vector<std::string> typeArgs);

  std::vector<Token> tokens_;
  size_t cur_ = 0;
  std::string file_;
  std::vector<ParseError> errors_;
};

std::unique_ptr<Program> parseSource(const std::string& source,
                                     const std::string& file = "<input>",
                                     std::vector<ParseError>* errors = nullptr);

}  // namespace kx