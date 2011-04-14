{-# LANGUAGE ParallelArrays #-}
{-# OPTIONS -fvectorise #-}
module ReverseVectorised        
        (treeReversePA)
where
import Data.Array.Parallel.Prelude
import Data.Array.Parallel.Prelude.Int
import qualified Prelude as P


treeReversePA :: PArray Int -> PArray Int
{-# NOINLINE treeReversePA #-}
treeReversePA ps
        = toPArrayP (treeReverse (fromPArrayP ps))


-- | Reverse the elements in an array using a tree.
treeReverse :: [:Int:] -> [:Int:]
{-# NOINLINE treeReverse #-}
treeReverse xx
        | lengthP xx == 1
        = xx
        
        | otherwise
        = let   len     = lengthP xx
                half    = len `div` 2
                s1      = sliceP 0    half xx
                s2      = sliceP half len  xx           
          in    treeReverse s2 +:+ treeReverse s1