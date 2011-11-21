{-# OPTIONS_HADDOCK hide #-}
#include "fusion-phases.h"

-- | PR instance for Doubles.
module Data.Array.Parallel.PArray.PData.Double 
        ( PData (..)
        , PDatas(..))
where
import Data.Array.Parallel.Pretty
import Data.Array.Parallel.PArray.PData.Base
import Data.Array.Parallel.PArray.PData.Nested
import qualified Data.Array.Parallel.Unlifted   as U
import qualified Data.Vector                    as V
import qualified Data.Vector.Unboxed            as VU

-------------------------------------------------------------------------------
data instance PData Double
        = PDouble !(U.Array Double)

data instance PDatas Double
        = PDoubles !(V.Vector (U.Array Double))


-- PR -------------------------------------------------------------------------
instance PR Double where

  {-# NOINLINE validPR #-}
  validPR _
        = True

  {-# NOINLINE nfPR #-}
  nfPR (PDouble xx)
        = xx `seq` ()

  {-# NOINLINE similarPR #-}
  similarPR  = (==)

  {-# NOINLINE coversPR #-}
  coversPR weak (PDouble uarr) ix
   | weak       = ix <= U.length uarr
   | otherwise  = ix <  U.length uarr

  {-# NOINLINE pprpPR #-}
  pprpPR d
   =    double d

  {-# NOINLINE pprpDataPR #-}
  pprpDataPR (PDouble vec)
   =   text "PDouble"
   <+> text (show $ U.toList vec)


  -- Constructors -------------------------------
  {-# INLINE_PDATA emptyPR #-}
  emptyPR
        = PDouble U.empty

  {-# INLINE_PDATA replicatePR #-}
  replicatePR len x
        = PDouble (U.replicate len x)

  {-# INLINE_PDATA replicatesPR #-}
  replicatesPR segd (PDouble arr)
        = PDouble (U.replicate_s segd arr)

  {-# INLINE_PDATA appendPR #-}
  appendPR (PDouble arr1) (PDouble arr2)
        = PDouble (arr1 U.+:+ arr2)

  {-# INLINE_PDATA appendsPR #-}
  appendsPR segdResult segd1 (PDouble arr1) segd2 (PDouble arr2)
        = PDouble $ U.append_s segdResult segd1 arr1 segd2 arr2


  -- Projections --------------------------------                
  {-# INLINE_PDATA lengthPR #-}
  lengthPR (PDouble uarr)
        = U.length uarr

  {-# INLINE_PDATA indexPR #-}
  indexPR (PDouble arr) ix
        = arr VU.! ix

  {-# INLINE_PDATA indexsPR #-}
  indexsPR (PDoubles pvecs) (PInt srcs) (PInt ixs)
   = PDouble $ U.zipWith get srcs ixs
   where get !src !ix
                = (pvecs V.! src) VU.! ix

  {-# NOINLINE extractPR #-}
  extractPR (PDouble arr) start len 
        = PDouble (U.extract arr start len)

  {-# NOINLINE extractsPR #-}
  extractsPR (PDoubles vecpdatas) ussegd
   = let segsrcs        = U.sourcesOfSSegd ussegd
         segstarts      = U.startsOfSSegd  ussegd
         seglens        = U.lengthsOfSSegd ussegd
     in  PDouble (U.extract_ss vecpdatas segsrcs segstarts seglens)
                

  -- Pack and Combine ---------------------------
  {-# NOINLINE packByTagPR #-}
  packByTagPR (PDouble arr1) arrTags tag
        = PDouble $ U.packByTag arr1 arrTags tag

  {-# NOINLINE combine2PR #-}
  combine2PR sel (PDouble arr1) (PDouble arr2)
        = PDouble (U.combine2 (U.tagsSel2 sel)
                           (U.repSel2  sel)
                           arr1 arr2)


  -- Conversions --------------------------------
  {-# NOINLINE fromVectorPR #-}
  fromVectorPR xx
        = PDouble (U.fromList $ V.toList xx)

  {-# NOINLINE toVectorPR #-}
  toVectorPR (PDouble arr)
        = V.fromList $ U.toList arr


  -- PDatas -------------------------------------
  {-# INLINE_PDATA emptydPR #-}
  emptydPR 
        = PDoubles $ V.empty
        
  {-# INLINE_PDATA singletondPR #-}
  singletondPR (PDouble pdata)
        = PDoubles $ V.singleton pdata
        
  {-# INLINE_PDATA lengthdPR #-}
  lengthdPR (PDoubles vec)
        = V.length vec
        
  {-# INLINE_PDATA indexdPR #-}
  indexdPR (PDoubles vec) ix
        = PDouble $ vec V.! ix

  {-# INLINE_PDATA appenddPR #-}
  appenddPR (PDoubles xs) (PDoubles ys)
        = PDoubles $ xs V.++ ys
        
  {-# NOINLINE fromVectordPR #-}
  fromVectordPR vec
        = PDoubles $ V.map (\(PDouble xs) -> xs) vec
        
  {-# NOINLINE toVectordPR #-}
  toVectordPR (PDoubles vec)
        = V.map PDouble vec


-- Show -----------------------------------------------------------------------
deriving instance Show (PData  Double)
deriving instance Show (PDatas Double)

instance PprVirtual (PData Double) where
  pprv (PDouble vec)
   = text (show $ U.toList vec)

