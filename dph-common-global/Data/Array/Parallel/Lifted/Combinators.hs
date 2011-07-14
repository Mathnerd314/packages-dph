{-# LANGUAGE
	TypeFamilies, MultiParamTypeClasses, 
	FlexibleInstances, FlexibleContexts,
        RankNTypes, ExistentialQuantification,
        StandaloneDeriving, TypeOperators #-}

-- | Define closures for each of the combinators the vectoriser uses.
--
--   For each combinator:
--    The *PA_v version is the "vectorised" version that has had its parameters
--    closure converted. For first-order functions, the *PA_v version is
--    identical to the standard *PA version from D.A.P.PArray, so we can 
--    just use that directly.
--
--    The *PA_l version is the "lifted" version that works on arrays of arrays.
--    Each of these functions also takes an integer as its first argument. 
--    This is the "lifting context" that says now many element to expect in 
--    each of the argument arrays. 
--
--    The *PP version contains both the vectorised and lifted versions wrapped
--    up in a closure. The code produced by the vectoriser uses the *PP
--    versions directly.
--
module Data.Array.Parallel.Lifted.Combinators where
import Data.Array.Parallel.Lifted.Closure
import Data.Array.Parallel.PArray

import qualified Data.Array.Parallel.Unlifted     as U

-- length ---------------------------------------------------------------------
-- | Take the number of elements in an array.
lengthPP   :: PA a => PArray a :-> Int
lengthPP = closure1 lengthPA lengthPA_l


lengthPA_l :: PJ m (PArray a)
	   => Int -> PData m (PArray a) -> PData Sized Int

lengthPA_l c da
 = let	PNestedS segd _	= restrictPJ c da
   in   fromUArrayPS (U.lengthsSegd segd)


-- replicate ------------------------------------------------------------------
-- | Produce a new array by replicating a single element the given number of times.
replicatePP     :: PA a => Int :-> a :-> PArray a
replicatePP     = closure2 replicatePA replicatePA_l


replicatePA_l   :: PA a 
                => Int -> PData m1 Int -> PData m2 a -> PData Sized (PArray a)
replicatePA_l = error "replciatePA_l"


-- map ------------------------------------------------------------------------
mapPP   :: (PA a, PA b) 
        => (a :-> b) :-> PArray a :-> PArray b
mapPP 	= closure2 mapPA_v mapPA_l


mapPA_v :: (PR a, PR b)
	=> (a :-> b) -> PArray a -> PArray b

mapPA_v (Clo fv fl env) (PArray n as) 
	= PArray n (fl n (repeatPE env) as)


mapPA_l :: (PJ m1 (a :-> b), PJ m2 (PArray a), PJ Sized a)
	=> Int 	-> PData m1 (a :-> b) 
		-> PData m2 (PArray a) -> PData Sized (PArray b)

mapPA_l n arrClo arr2
 = case restrictPJ n arr2 of
    PNestedS segd xs -> 
     PNestedS segd  
        (liftedApply    (U.elementsSegd segd) 
                        (replicatelPJ segd arrClo)
                        xs )

     
-- not sure how to represent the result of a nested repeat.
-- maybe we want to stash extra information in the mode.
-- so the mode type says what sort of segment descriptor to use

--  result of repeatlPE has form:
--     a a a  b b  c c c c c
--  Want to represent this without physically copying the data.
--  Roman says maybe only need to slice, replicate, slice.. but not replicate again.
--
--  Really want:
--     .  .  .
--     .  .  c
--     a  .  c 
--     a  .  c
--     a  b  c
--  Don't need to actually store run lengths. 
--  lifted apply just applies whole elem arrays
--

{-
repeatlPE :: PJ m1 a
          => U.Segd -> PData m1 a -> PData m2 a
repeatlPE = error "repeatlPE: undefined"
-}

-- index ----------------------------------------------------------------------
indexPP :: PA a => PArray a :-> Int :-> a
indexPP	= closure2 indexPA indexPA_l

indexPA_l :: (PJ m1 (PArray a), PJ m2 Int)
	=> Int -> PData m1 (PArray a) -> PData m2 Int -> PData Sized a

indexPA_l n src ixs
 = case indexlPJ n src (restrictPJ n ixs) of
        PArray _ d -> d

-- Tuple ======================================================================

-- unzip ----------------------------------------------------------------------
unzipPP :: PArray (a, b) :-> (PArray a, PArray b)
unzipPP         = closure1 unzipPA unzipPA_l




-- Scalar =====================================================================

-- sum ------------------------------------------------------------------------
sumPP_double :: PArray Double :-> Double
sumPP_double    = closure1 sumPA sumPA_l

sumPA   :: PArray Double -> Double
sumPA (PArray _ (PDoubleS xs))
        = U.sum xs

sumPA_l :: forall m1. PJ m1 (PArray Double)
        => Int -> PData m1 (PArray Double) -> PData Sized Double
sumPA_l c xss
 = let  PNestedS segd (PDoubleS xs)   = restrictPJ c xss
   in   PDoubleS (U.sum_s segd xs)


-- plus -----------------------------------------------------------------------
plusPP_int	 :: Int :-> Int :-> Int
plusPP_int	 = closure2 (+) plusPA_int_l

plusPA_int_l :: (PJ m1 Int, PJ m2 Int)
         => Int -> PData m1 Int -> PData m2 Int -> PData Sized Int
plusPA_int_l n d1 d2
 = let PIntS vec1 = restrictPJ n d1
       PIntS vec2 = restrictPJ n d2
   in  PIntS (U.zipWith (+) vec1 vec2)


-- mult -----------------------------------------------------------------------
multPP_double   :: Double :-> Double :-> Double
multPP_double = closure2 (*) multPA_double_l


multPA_double_l :: (PJ m1 Double, PJ m2 Double)
         => Int -> PData m1 Double -> PData m2 Double -> PData Sized Double
multPA_double_l n d1 d2
 = let PDoubleS vec1 = restrictPJ n d1
       PDoubleS vec2 = restrictPJ n d2
   in  PDoubleS (U.zipWith (*) vec1 vec2)

