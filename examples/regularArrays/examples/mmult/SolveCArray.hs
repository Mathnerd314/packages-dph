
module SolveCArray
	( wrapCArraySolver
	, mmMult_replicate)
where
import CArray				as CA
import Array				as A


{-# INLINE wrapCArraySolver #-}
wrapCArraySolver solver mat1 mat2
	= fromCArray (solver (toCArray mat1) (toCArray mat2))


-- | Matrix-Matrix multiplication using replicateSlice.
mmMult_replicate	
	:: CArray DIM2  Double 
	-> CArray DIM2  Double 
	-> CArray DIM2  Double  

mmMult_replicate	
	arr1@(CArray (sh  :. m1 :. n1) fn1) 
	arr2@(CArray (sh' :. m2 :. n2) fn2) 

	| not $ (m1 == n2) && (sh == sh')
	= error "mmMult: invalid matrix sizes"
	
	| otherwise
	= fold (+) 0 (arr1Ext * arr2Ext)
	where
		arr2T   = forceCArray $ transpose arr2
		arr1Ext = replicateSlice arr1  (() :. A.All :. m2 :. A.All)
		arr2Ext = replicateSlice arr2T (() :. n1 :. A.All :. A.All)

