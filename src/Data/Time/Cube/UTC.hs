{-# LANGUAGE DataKinds                  #-}
{-# LANGUAGE DeriveGeneric              #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE KindSignatures             #-}
{-# OPTIONS -Wall                       #-}

-- |
-- Module      : Data.Time.Cube.UTC
-- Copyright   : Copyright (c) 2015, Alpha Heavy Industries, Inc. All rights reserved.
-- License     : BSD3
-- Maintainer  : Enzo Haussecker <ehaussecker@alphaheavy.com>
-- Stability   : Experimental
-- Portability : Portable
--
-- UTC timestamps.
module Data.Time.Cube.UTC (

 -- ** UTC Timestamps
       UTCDate(..)
     , UTCDateTime(..)
     , UTCDateTimeNanos(..)

     ) where

import Control.DeepSeq     (NFData(..))
import Data.Int            (Int32, Int64)
import Data.Time.Cube.Base (Calendar)
import Data.Time.Cube.Unix (UnixDate)
import Foreign.Ptr         (plusPtr)
import Foreign.Storable    (Storable(..))
import GHC.Generics        (Generic)

-- |
-- Days since Unix epoch.
newtype UTCDate (cal :: Calendar) = UTCDate (UnixDate cal)
   deriving (Eq, Generic, NFData, Ord, Storable)

-- |
-- Seconds since Unix epoch (including leap seconds).
newtype UTCDateTime (cal :: Calendar) = UTCDateTime Int64
   deriving (Eq, Generic, NFData, Ord, Storable)

-- |
-- Nanoseconds since Unix epoch (including leap seconds).
data UTCDateTimeNanos (cal :: Calendar) =
     UTCDateTimeNanos {-# UNPACK #-} !Int64 {-# UNPACK #-} !Int32
     deriving (Eq, Generic, Ord)

instance NFData (UTCDateTimeNanos cal) where

   rnf (UTCDateTimeNanos base nsec) = rnf base `seq` rnf nsec `seq` ()

instance Storable (UTCDateTimeNanos cal) where
   sizeOf = const 12
   alignment = sizeOf
   peekElemOff ptr n = do
       let off = 12 * n
       base <- peek . plusPtr ptr $ off
       nsec <- peek . plusPtr ptr $ off + 8
       return $! UTCDateTimeNanos base nsec
   pokeElemOff ptr n (UTCDateTimeNanos base nsec) = do
       let off = 12 * n
       flip poke base . plusPtr ptr $ off
       flip poke nsec . plusPtr ptr $ off + 8