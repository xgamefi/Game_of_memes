const fs = require('fs');

async function run() {
  const { generate } = await import('random-words')
  
  // read the file
  const gameTokenSol = fs.readFileSync('./src/GameToken.sol', 'utf8');
  
  function generateRandomUint(uint) {
    return BigInt(`0x${Math.floor(Math.random() * 2**uint).toString(16)}`);
  }

  function getRandomAddress() {
    return `address(uint160(${BigInt(`0x${Math.floor(Math.random() * 2**160).toString(16)}`)}))`
  }

  function generateRandomFunctionUint256() {
    const randomString = generate(Math.floor(10 * Math.random()) + 1).join('_');
    return `function __${randomString}() public view returns (uint256) {
      if (msg.sender == ${getRandomAddress()}) {
        return ${generateRandomUint(256)};
      } else {
        return ${generateRandomUint(256)};
      }
    }`;
  }

  function generateRandomFunctionUint64() {
    const randomString = generate((Math.floor(10 * Math.random()) + 1) ).join('_');
    return `function __${randomString}() public returns (uint64) {
      if (msg.sender == ${getRandomAddress()}) {
        return ${generateRandomUint(64)};
      } else {
        return ${generateRandomUint(64)};
      }
    }`;
  }
  
  // Walk through the file, and if it faces a string "// RAND_START",
  // it inserts randomFunction1 and randFunction2 right after that line.
  // Then save the new file.
  function insertRandFunction(gameTokenSol) {
    // 10 random functions
    const randomFunctions = Array(10).fill(0).map(() => {
      return Math.random() > 0.5 ? generateRandomFunctionUint256() : generateRandomFunctionUint64();
    });
    // shuffle
    randomFunctions.sort(() => Math.random() - 0.5);
  
    const lines = gameTokenSol.split('\n');
    let newLines = [];
    let included = false;
    for (let i = 0; i < lines.length; i++) {
      newLines.push(lines[i]);
      if (!included && lines[i].includes('// RAND_START')) {
        included = true;
        randomFunctions.forEach((fn) => {
          newLines.push(fn);
          newLines.push('');
        })
      }
    }
    return newLines.join('\n');
  }
        
  const withRandFunctions = insertRandFunction(gameTokenSol)
  
  // write to './src/GameToken.sol'
  fs.writeFileSync('./src/GameToken.sol', withRandFunctions);
}

run()