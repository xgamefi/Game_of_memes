import { ethers } from 'ethers'
import type { NextRequest } from 'next/server'

export const runtime = 'edge'

export interface MerkleDistributorInfo {
  merkleRoot: string
  tokenTotal: string
  claims: {
    [account: string]: {
      index: number
      amount: string
      proof: string[]
    }
  }
}

// This needs to be stored somewhere as a Cloudflare KV or something
const merkleTree: MerkleDistributorInfo = {
  "merkleRoot": "0x3f9aaec5ca2979e3145924a45f66e445869fc864018d3d1809178afce3b71d34",
  "tokenTotal": "0xc4000000000000000000",
  "claims": {
    "0x0187a11d91854F60124507c0bD8a4251243c0b60": {
      "index": 0,
      "amount": "0x52000000000000000000",
      "proof": [
        "0x744628cc03997f37d52ef51b472a2159105e8f35f869d6f151f37e5c3d448688",
        "0x74150d5b4bc14ca7e2594213c27c884cd224d54675f61629e6972aded845feb4"
      ]
    },
    "0x68b08287134f255ea8DEEfF409241f889C9f8Deb": {
      "index": 1,
      "amount": "0x26000000000000000000",
      "proof": [
        "0x46ae2c4cd3f2b8099e8536342607e38d38c2e4ddf6e2a6154c761d66fc97a447",
        "0x0134906f1fbdc2b8830f7a20c4d728258c80e9705c058c02dbfacd6594f5aa02"
      ]
    },
    "0x6c44EaAeF113Ba1fDfa6BC30Ef49E2342f2058a5": {
      "index": 2,
      "amount": "0x39000000000000000000",
      "proof": [
        "0x901b8ee7456186f717d9343c3bac2bb5401c104c0ba9e9eef7ef4a8ba98144d3",
        "0x74150d5b4bc14ca7e2594213c27c884cd224d54675f61629e6972aded845feb4"
      ]
    },
    "0x7684C7EF1BE259fE92E04E7F061B96B48d50fe80": {
      "index": 3,
      "amount": "0x13000000000000000000",
      "proof": [
        "0x6713ffcc9e6a08f76fdd7db3958a277673141967928a181a8807711253b8cb39",
        "0x0134906f1fbdc2b8830f7a20c4d728258c80e9705c058c02dbfacd6594f5aa02"
      ]
    }
  }
}

export async function GET(request: NextRequest) {
  const address = request.nextUrl.searchParams.get('address')

  if (!address) {
    return new Response(JSON.stringify({ error: 'Address is required' }), { status: 400 })
  }

  try {
    const checksumAddress = ethers.getAddress(address)
    
    if (!(checksumAddress in merkleTree.claims)) {
      return new Response(JSON.stringify({ error: 'Address has no claim' }), { status: 400 })
    }

    const claim = merkleTree.claims[checksumAddress]

    return new Response(JSON.stringify(claim), {
      headers: {
        'Content-Type': 'application/json'
      }
    })
  } catch (e) {
    return new Response(JSON.stringify({ error: 'Invalid address' }), { status: 400 })
  }
}
