import { program } from 'commander'
import fs from 'fs'
import { parseBalanceMap } from '../merkle/parse-balance-map'

program
  .version('0.1.0')
  .requiredOption(
    '-i, --input <path>',
    'input JSON file location containing a map of account addresses to string balances',
  )
  .option('-o, --output <path>', 'output JSON file location for the generated merkle tree', 'merkle-tree.json')

program.parse(process.argv)

const json = JSON.parse(fs.readFileSync(program.input, { encoding: 'utf8' }))

if (typeof json !== 'object') throw new Error('Invalid JSON')

fs.writeFileSync(program.output, JSON.stringify(parseBalanceMap(json), null, 2))

console.log(`Merkle tree generated at ${program.output}`)
