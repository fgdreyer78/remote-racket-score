import sys

path = r'c:\src\Remote Racket Score - CODING\lib\features\score\landscape_score_layout.dart'
with open(path, 'r', encoding='utf-8') as f:
    lines = f.readlines()

# Fix line 112 (index 111): winner text interpolation
lines[111] = "            child: Text('${score.winnerIsA! ? config.playerAName : config.playerBName} VENCEU!',\n"

# Fix line 142 (index 141): clockRemaining
old142 = lines[141]
lines[141] = old142.replace("Text('',", "Text('$clockRemaining',")

# Fix line 182 (index 181): games score
old182 = lines[181]
lines[181] = old182.replace("Text('',", "Text('$g',")

# Fix line 193 (index 192): prev set games value
old193 = lines[192]
lines[192] = old193.replace("Text('',", "Text('$gv',")

# Fix line 195 (index 194): prev set tiebreak pts
old195 = lines[194]
lines[194] = old195.replace("Text('',", "Text('$tb',")

# Fix line 198 (index 197): prev set games value (no tiebreak)
old198 = lines[197]
lines[197] = old198.replace("Text('',", "Text('$gv',")

with open(path, 'w', encoding='utf-8') as f:
    f.writelines(lines)

print('Fixed 6 lines')
with open(path, 'r', encoding='utf-8') as f:
    lines = f.readlines()
print('L112:', repr(lines[111].rstrip()))
print('L142:', repr(lines[141].rstrip()))
print('L182:', repr(lines[181].rstrip()))
print('L193:', repr(lines[192].rstrip()))
print('L195:', repr(lines[194].rstrip()))
print('L198:', repr(lines[197].rstrip()))
