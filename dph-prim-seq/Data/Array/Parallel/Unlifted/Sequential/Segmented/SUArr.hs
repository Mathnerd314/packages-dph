-----------------------------------------------------------------------------
-- |
-- Module      : Data.Array.Parallel.Unlifted.Sequential.Segmented.SUArr
-- Copyright   : (c) [2001..2002] Manuel M T Chakravarty & Gabriele Keller
--		 (c) 2006         Manuel M T Chakravarty & Roman Leshchinskiy
-- License     : see libraries/ndp/LICENSE
-- 
-- Maintainer  : Roman Leshchinskiy <rl@cse.unsw.edu.au>
-- Stability   : internal
-- Portability : portable
--
-- Description ---------------------------------------------------------------
--
-- This module defines segmented arrays in terms of unsegmented ones.
--
-- Todo ----------------------------------------------------------------------
--

{-# LANGUAGE CPP #-}

#include "fusion-phases.h"

module Data.Array.Parallel.Unlifted.Sequential.Segmented.SUArr (

  -- * Array types
  SUArr(..), MSUArr,

  -- * Basic operations on segmented parallel arrays
  lengthSU, lengthsSU,indicesSU, segdSU,
  concatSU, (>:),
  newMSU, unsafeFreezeMSU,

  -- * Segment descriptors
  module Data.Array.Parallel.Unlifted.Sequential.Segmented.USegd
) where

-- friends
import Data.Array.Parallel.Base (
  ST)
import Data.Array.Parallel.Unlifted.Sequential.Flat (
  UA, UArr, MUArr,
  (!:),
  newMU, unsafeFreezeMU)
import Data.Array.Parallel.Unlifted.Sequential.Segmented.USegd

import Control.Monad (
  liftM2)

infixr 9 >:


-- |Segmented arrays
-- -----------------

-- |Segmented arrays (only one level of segmentation)
-- 

-- NOTE: We do *not* make this strict in the arrays. This allows GHC to
--       eliminate construction/deconstruction of segmented arrays.

-- TODO: Is this ok?
data SUArr  e   = SUArr  USegd      (UArr  e)
data MSUArr e s = MSUArr (MUSegd s) (MUArr e s)

-- |Operations on segmented arrays
-- -------------------------------

-- |Yield the segment descriptor
--
segdSU :: UA e => SUArr e -> USegd
{-# INLINE_U segdSU #-}
segdSU (SUArr segd _) = segd

-- |Yield the flat data array
--
concatSU :: UA e => SUArr e -> UArr e
{-# INLINE_U concatSU #-}
concatSU (SUArr _ a) = a

-- |Yield the number of segments.
-- 
lengthSU :: UA e => SUArr e -> Int
{-# INLINE_U lengthSU #-}
lengthSU = lengthUSegd . segdSU

-- |Yield the lengths of the segments.
--
lengthsSU :: UA e => SUArr e -> UArr Int
{-# INLINE_U lengthsSU #-}
lengthsSU = lengthsUSegd . segdSU

-- |Yield the starting indices of the segments.
--
indicesSU :: UA e => SUArr e -> UArr Int
{-# INLINE_U indicesSU #-}
indicesSU = indicesUSegd . segdSU

-- |Compose a nested array.
--
(>:) :: UA a => USegd -> UArr a -> SUArr a
{-# INLINE_U (>:) #-}
(>:) = SUArr

-- |Operations on mutable segmented arrays
-- ---------------------------------------

-- |Allocate a segmented parallel array (providing the number of segments and
-- number of base elements).
--
newMSU :: UA e => Int -> Int -> ST s (MSUArr e s)
{-# INLINE_U newMSU #-}
newMSU nsegd n = liftM2 MSUArr (newMUSegd nsegd) (newMU n)

-- |Convert a mutable segmented array into an immutable one.
--
unsafeFreezeMSU :: UA e => MSUArr e s -> Int -> ST s (SUArr e)
{-# INLINE_U unsafeFreezeMSU #-}
unsafeFreezeMSU (MSUArr msegd ma) n = 
  do
    segd <- unsafeFreezeMUSegd msegd n
    let n' = if n == 0 then 0 else indicesUSegd segd !: (n - 1) + 
				   lengthsUSegd segd !: (n - 1)
    a <- unsafeFreezeMU ma n'
    return $ SUArr segd a


