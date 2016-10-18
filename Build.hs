{-# LANGUAGE DeriveAnyClass             #-}
{-# LANGUAGE DeriveGeneric              #-}
{-# LANGUAGE FlexibleInstances          #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
import FSL
import           PNLPipeline

outdir = "_data"

---------------------------------------------------------------
-- main
main :: IO ()
main = shakeArgs shakeOptions{shakeFiles=outdir, shakeVerbosity=Chatty} $ do

  want [outdir </> "data-1.nrrd",
        outdir </> "data-2.nrrd"
       ]

  "_data/data-*.nrrd" %> \out -> do
    need [tonii out]
    dwiToNrrd ["--allowLossyConversion"] (tonii out)
    return ()

  [outdir </> "data-1.nii.gz",
   outdir </> "data-2.nii.gz",
   outdir </> "data-1.bval",
   outdir </> "data-1.bvec",
   outdir </> "data-2.bval",
   outdir </> "data-2.bvec"]
    &%> \(out1:out2:_) -> do
    let dwi = "src/data.nii.gz"
    need [dwi, tobval dwi, tobvec dwi]
    (out1', out2') <- snipDwi dwi 100
    moveDwi out1' out1
    moveDwi out2' out2