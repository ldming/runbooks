local removeBlankLines(str) =
  std.strReplace(str, '\n\n', '\n');

local chomp(str) =
  if std.isString(str) then
    std.rstripChars(str, '\n')
  else
    std.assertEqual(str, { __assert__: 'str should be a string value' });

local indent(str, spaces) =
  std.strReplace(removeBlankLines(chomp(str)), '\n', '\n' + std.repeat(' ', spaces));

local unwrapText(str) =
  local lines = std.split(str, '\n');
  local linesTrimmed = std.map(function(l) std.rstripChars(l, ' \t'), lines);
  local linesJoined = std.foldl(
    function(memo, line)
      local memoLast = std.length(memo) - 1;
      local prevItem = memo[memoLast];
      if line == '' || prevItem == '' then
        memo + [line]
      else
        // Join onto previous line
        memo[:memoLast] + [prevItem + ' ' + line],
    linesTrimmed[1:],
    linesTrimmed[:1]
  );
  std.join('\n', linesJoined);

local capitalizeFirstLetter(str) =
  local chars = std.stringChars(str);
  if std.length(chars) == 0 then
    ''
  else
    std.asciiUpper(chars[0]) + std.join('', chars[1:]);

local splitOnChars(str, chars) =
  if std.length(chars) < 2 then
    std.split(str, chars)
  else
    local charArray = std.stringChars(chars);
    local first = charArray[0];
    local stringIntermediate =
      std.foldl(
        function(str, char) std.strReplace(str, char, first),
        charArray[1:],
        str
      );

    std.filter(
      function(f) f != '',
      std.split(stringIntermediate, first)
    );

{
  removeBlankLines(str):: removeBlankLines(str),
  chomp(str):: chomp(str),
  indent(str, spaces):: indent(str, spaces),
  unwrapText(str):: unwrapText(str),

  /* Like split, but allows for multiple chars to split on */
  splitOnChars:: splitOnChars,

  /* Make the first letter of a string capital */
  capitalizeFirstLetter: capitalizeFirstLetter,
}
