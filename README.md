# Simple Compiler with Optimization

A compiler implementation that demonstrates the complete compilation pipeline from source code to target assembly, including intermediate code generation and optimization passes.

## Features

- **Lexical Analysis**: Tokenizes source code using Flex
- **Syntax Analysis**: Parses tokens using Bison/Yacc
- **Three Address Code (TAC) Generation**: Generates intermediate representation
- **Optimization Passes**:
  - Constant Folding
  - Strength Reduction (multiplication/division by powers of 2 → bit shifts)
  - Algebraic Simplification (operations with 0)
- **Target Code Generation**: Generates assembly-like output

## Language Support

The compiler supports:
- **Arithmetic Operators**: `+`, `-`, `*`, `/`
- **Comparison Operators**: `<`, `>`, `<=`, `>=`, `==`, `!=`
- **Control Flow**: `if` statements with code blocks
- **Expressions**: Parenthesized expressions with proper precedence
- **Variables**: Identifier-based variable assignments

## Project Structure

```
.
├── prac_parser.y       # Bison/Yacc parser specification
├── prac_lexer.l        # Flex lexer specification
├── input.txt           # Sample input program
└── README.md           # This file
```

## Building the Compiler

### Prerequisites
- GCC compiler
- Flex (lexical analyzer generator)
- Bison/Yacc (parser generator)

### Build Steps

```bash
# Generate parser
bison -d prac_parser.y

# Generate lexer
flex prac_lexer.l

# Compile
gcc prac_parser.tab.c lex.yy.c -o compiler -lfl

# Run
./compiler input.txt
```

## Compiler Output Stages

1. **Tokenization**: Displays all tokens identified by the lexer
2. **Syntax Checking**: Validates grammar rules
3. **Three Address Code**: Shows unoptimized intermediate code
4. **Optimization**: Displays optimized TAC
5. **Target Code Generation**: Shows final assembly output

## Optimization Details

### Constant Folding
Evaluates constant expressions at compile time for all operators:
- Arithmetic: `5 + 3` → `8`, `10 * 2` → `20`
- Comparisons: `5 < 10` → `1`, `3 == 3` → `1`

### Strength Reduction
Replaces expensive operations with cheaper equivalents:
- `x * 2` → `x << 1`
- `x * 8` → `x << 3`
- `x / 4` → `x >> 2`
- Only applies to powers of 2

### Algebraic Simplification
Simplifies expressions using mathematical identities:
- `x + 0` → `x`, `0 + x` → `x`
- `x - 0` → `x`
- `x * 1` → `x`, `1 * x` → `x`
- `x / 1` → `x`
- `x * 0` → `0`, `0 * x` → `0`

## Assembly Instructions Generated

- **MOV**: Move data between registers/memory
- **ADD/SUB/MUL/DIV**: Arithmetic operations
- **SHL/SHR**: Bit shift operations (from strength reduction)
- **CMP**: Compare values
- **JMP/JNZ**: Unconditional/conditional jumps
- **SETL/SETG/SETLE/SETGE/SETE/SETNE**: Set flags for comparisons

## Build Artifacts

The compilation process generates:
- `prac_parser.tab.c` - Generated parser code
- `prac_parser.tab.h` - Parser header file
- `lex.yy.c` - Generated lexer code
- `compiler` - Final executable

Clean build artifacts with:
```bash
make clean
```
## Acknowledgments

Built as part of compiler design coursework demonstrating fundamental compilation techniques.

