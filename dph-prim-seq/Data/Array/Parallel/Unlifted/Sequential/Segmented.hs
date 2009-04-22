-----------------------------------------------------------------------------
-- |
-- Module      : Data.Array.Parallel.Unlifted.Sequential.Segmented
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
-- Interface to operations on segmented unlifted arrays.
--
-- Todo ----------------------------------------------------------------------
--

module Data.Array.Parallel.Unlifted.Sequential.Segmented (

  replicateSU, appendSU,

  foldlSU, foldSU, fold1SU,

  -- * Basic operations
  lengthSU, singletonSU, singletonsSU, replicateSU,
  sliceIndexSU, extractIndexSU,
  replicateCU, repeatCU, (!:^),
  indexedSU, appendSU,

  -- * Basic operations lifted
  lengthsSU, indicesSU,

  -- * Subarrays
  sliceSU, extractSU, takeCU, dropCU,

  -- * Zipping
  fstSU, sndSU, zipSU,

  -- * Permutations
  bpermuteSU, bpermuteSU',

  -- * Higher-order operations
  mapSU, zipWithSU,
  {-concatMapU,-}
  foldlSU, foldlSU', foldSU, foldSU',
  fold1SU, fold1SU',
  {-scanSU, scan1SU,-}

  -- filter and combines
  filterSU, packCU, 

  combineSU, combineCU,
  -- * Logical operations
  andSU, orSU,

  -- * Arithmetic operations
  sumSU, productSU, maximumSU, minimumSU,
  sumRU,
  USegd,

  -- * Operations on segment descriptors
  lengthUSegd, lengthsUSegd, indicesUSegd, elementsUSegd,
  lengthsToUSegd, mkUSegd
) where

import Data.Array.Parallel.Unlifted.Sequential.Segmented.USegd
import Data.Array.Parallel.Unlifted.Sequential.Segmented.Basics
import Data.Array.Parallel.Unlifted.Sequential.Segmented.Combinators
import Data.Array.Parallel.Unlifted.Sequential.Segmented.Sums
import Data.Array.Parallel.Unlifted.Sequential.Segmented.Text ()

