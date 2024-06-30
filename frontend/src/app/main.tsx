import { ConnectButton } from "@rainbow-me/rainbowkit";
import { ethers } from "ethers";
import { MouseEventHandler, useCallback, useEffect, useState } from "react";
import { useAccount, useSimulateContract, useWriteContract } from "wagmi";
import { MerkleDistributorWithDeadlineAbi } from "@/app/MerkleDistributorWithDeadlineAbi"
import { ContractRunner } from "ethers";
import { readContract, simulateContract, waitForTransactionReceipt, writeContract } from "wagmi/actions";
import { config } from "./page";

enum Eligibility {
  UNKNOWN,
  ELIGIBLE,
  INELIGIBLE,
  CLAIMED
}

type Claim = {
  index: number
  amount: string
  proof: string[]
}

type GomeAllocationError = {
  error: string
}

const SEPOLIA_MERKLE_DISTRIBUTOR_ADDRESS = "0x11deeE7B0837F0030D58804eA50b590c686204Cd"

export default function Main() {
  // show more button when user is connected
  const account = useAccount()
  const address = account?.address
  const [claim, setClaim] = useState<Claim | null>(null)
  const [eligibility, setEligibility] = useState<Eligibility>(Eligibility.UNKNOWN)

  const addressInfo = address ? (
    <div>
      <h2>Your address</h2>
      <p>{address}</p>
    </div>
  ) : null

  const eligibleAmount = eligibility === Eligibility.ELIGIBLE && claim ? (
    <div>
      <h2>Eligible amount</h2>
      <p>{parseInt(claim.amount, 16) / 1e18} GOME</p>
    </div>
  ) : eligibility === Eligibility.CLAIMED && claim ? (
    <div>
      <p>Claimed {parseInt(claim.amount, 16) / 1e18} GOME already</p>
    </div>
  ) : eligibility === Eligibility.INELIGIBLE ? (
    <div>
      <p>This address is not eligible for claim</p>
    </div>
  ) : null

  const onClaim: MouseEventHandler<HTMLButtonElement> = useCallback(async () => {
    if (!address) {
      return
    }

    if (!claim) {
      return
    }

    if (eligibility !== Eligibility.ELIGIBLE) {
      return
    }

    if (!account.connector) {
      return
    }

    const { request } = await simulateContract(config, {
      address: SEPOLIA_MERKLE_DISTRIBUTOR_ADDRESS,
      abi: MerkleDistributorWithDeadlineAbi,
      functionName: 'claim',
      args: [BigInt(claim.index), address, BigInt(claim.amount), claim.proof as `0x${string}`[]],
    });
    const hash = await writeContract(config, request);
    // wait 
    await waitForTransactionReceipt(config, { hash });
    setEligibility(Eligibility.CLAIMED)
  }, [account.connector, address, claim, eligibility])

  const claimButton = eligibility === Eligibility.ELIGIBLE && claim ? (
    <button type="button" onClick={onClaim} style={{
      padding: `1rem`,
      borderRadius: `0.5rem`,
      backgroundColor: `#fff`,
      color: `#1f1f1f`,
      border: `none`,
      cursor: `pointer`,
    }}>
      Claim
    </button>) : null

  useEffect(() => {
    if (!address) {
      return
    }

    async function getAllocation() {
      const allocation: GomeAllocationError | Claim = await fetch('/api/allocation?address=' + address).then(async (res) => {
        const data = await res.json()
        return data
      }) as GomeAllocationError | Claim;

      if ('error' in allocation) {
        setEligibility(Eligibility.INELIGIBLE)
        return
      }

      const isClaimed = await getClaimed(allocation.index)

      setClaim(allocation)
      if (isClaimed) {
        setEligibility(Eligibility.CLAIMED)
        return
      }
      setEligibility(Eligibility.ELIGIBLE)
    }

    async function getClaimed(index: number) {
      // call sc
      const claimed: boolean = await readContract(
          config,
          {
            address: SEPOLIA_MERKLE_DISTRIBUTOR_ADDRESS,
            abi: MerkleDistributorWithDeadlineAbi,
            functionName: 'isClaimed',
            args: [BigInt(index)],
          }
        )

      return claimed
    }
    getAllocation()
  }, [address])

  useEffect(() => {
    setEligibility(Eligibility.UNKNOWN)
    setClaim(null)
  }, [address])

  return <div
    style={{
      height: `100%`,
      width: `100%`,
      display: `flex`,
      flexDirection: `column`,
      alignItems: `center`,
      justifyContent: `center`,
      textAlign: `center`,
    }}
  >
    <ConnectButton />
    {addressInfo}
    {eligibleAmount}
    {claimButton}
  </div>
}
