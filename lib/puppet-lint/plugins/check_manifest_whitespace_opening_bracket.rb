# frozen_string_literal: true

PuppetLint.new_check(:manifest_whitespace_opening_bracket_before) do
  def check
    tokens.select { |token| token.type == :LBRACK }.each do |bracket_token|
      prev_token = bracket_token.prev_token
      prev_code_token = prev_non_space_token(bracket_token)

      next unless prev_token && prev_code_token
      if %i[LBRACK LBRACE COMMA SEMIC COMMENT].include?(prev_code_token.type)
        next
      end
      next unless %i[WHITESPACE NEWLINE INDENT].include?(prev_token.type)

      if %i[INDENT NEWLINE].include?(prev_token.type) && %i[RBRACK RBRACE].include?(prev_code_token.type)
        next
      end
      next unless tokens.index(prev_code_token) != tokens.index(bracket_token) - 2 ||
                  !is_single_space(prev_token)

      notify(
        :error,
        message: 'there should be a single space before an opening bracket',
        line: bracket_token.line,
        column: bracket_token.column,
        token: bracket_token,
      )
    end
  end

  def fix(problem)
    token = problem[:token]
    prev_token = token.prev_token
    prev_code_token = prev_non_space_token(token)

    while prev_code_token != prev_token
      unless %i[WHITESPACE INDENT NEWLINE].include?(prev_token.type)
        raise PuppetLint::NoFix
      end

      remove_token(prev_token)
      prev_token = prev_token.prev_token
    end

    add_token(tokens.index(token), new_single_space)
  end
end

PuppetLint.new_check(:manifest_whitespace_opening_bracket_after) do
  def check
    tokens.select { |token| token.type == :LBRACK }.each do |bracket_token|
      next_token = bracket_token.next_token

      next unless next_token
      next unless %i[WHITESPACE NEWLINE INDENT].include?(next_token.type)

      if next_token.type == :NEWLINE
        next_token = next_token.next_token
        next if next_token.type != :NEWLINE
      end

      notify(
        :error,
        message: 'there should be no whitespace or a single newline after an opening bracket',
        line: next_token.line,
        column: next_token.column,
        token: next_token,
      )
    end
  end

  def fix(problem)
    token = problem[:token]

    if token.type == :WHITESPACE
      remove_token(token)
      return
    end

    while token.next_token.type == :NEWLINE || (token.next_token.type == :INDENT && token.next_token.next_token.type != :NEWLINE)
      remove_token(token)
      token = token.next_token
    end
  end
end
