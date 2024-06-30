const fs = require('fs');

// const GameTokenSol = require('./src/GameToken.sol');

// read the file
const gameTokenSol = fs.readFileSync('./src/GameToken.sol', 'utf8');

// Walk through the file, and delete any lines in between '// RAND_START' and '// RAND_END'
function deleteRandFunctions(gameTokenSol) {
  const lines = gameTokenSol.split('\n');
  let newLines = [];
  let deleting = false;
  for (let i = 0; i < lines.length; i++) {
    if (lines[i].includes('// RAND_END')) {
      deleting = false;
    }
    if (!deleting) {
      newLines.push(lines[i]);
    }
    if (lines[i].includes('// RAND_START')) {
      deleting = true;
    } 
  }
  return newLines.join('\n');
}
      
const withoutRandFunctions = deleteRandFunctions(gameTokenSol)

// write to './src/GameToken.sol'
fs.writeFileSync('./src/GameToken.sol', withoutRandFunctions);
