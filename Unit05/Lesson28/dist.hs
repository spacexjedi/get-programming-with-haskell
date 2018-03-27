import qualified Data.Map as Map

type LatLong = (Double, Double)

-- The database
--
locationDB :: Map.Map String LatLong
locationDB =
  Map.fromList
    [ ("Arkham", (42.6054, -70.7829))
    , ("Innsmouth", (42.8250, -70.8150))
    , ("Carcosa", (29.9714, -90.7694))
    , ("New York", (40.7776, -73.9691))
    ]

--
-- Calculating the distance
--
toRadians :: Double -> Double
toRadians degrees = degrees * pi / 180

latLongToRads :: LatLong -> (Double, Double)
latLongToRads (lat, long) = (rlat, rlong)
  where
    rlat = toRadians lat
    rlong = toRadians long

-- Calculate the distance between two LatLongs
-- E.g. haversine (40.7776,-73.9691) (42.6054,-70.7829) == 207.3909006336738
haversine :: LatLong -> LatLong -> Double
haversine coords1 coords2 = earthRadius * c
  where
    (rlat1, rlong1) = latLongToRads coords1
    (rlat2, rlong2) = latLongToRads coords2
    dlat = rlat2 - rlat1
    dlong = rlong2 - rlong1
    a = sin (dlat / 2) ^ 2 + cos rlat1 * cos rlat2 * sin (dlong / 2) ^ 2
    c = 2 * atan2 (sqrt a) (sqrt (1 - a))
    earthRadius = 3961.0

--
-- Print the (potentially missing) distance
--
printDistance :: Maybe Double -> IO ()
printDistance Nothing         = putStrLn "City not found."
printDistance (Just distance) = putStrLn (show distance ++ " miles")

-- We don't want to have to do this:
haversineMaybe :: Maybe LatLong -> Maybe LatLong -> Maybe Double
haversineMaybe Nothing _               = Nothing
haversineMaybe _ Nothing               = Nothing
haversineMaybe (Just val1) (Just val2) = Just (haversine val1 val2)

-- QC2801
addMaybe :: Maybe Int -> Maybe Int -> Maybe Int
addMaybe (Just x) (Just y) = Just (x + y)
addMaybe _ _               = Nothing

-- QC2802
distanceFromNY :: LatLong -> Double
distanceFromNY = haversine (40.7776, -73.9691)

-- Using Functor’s <$> operator for partial application in a context
--   --> But this function can't be applied directly
maybeInc :: Maybe (Integer -> Integer)
maybeInc = (+) <$> Just 1

-- Applicative to the rescue
{-
  (<*>) :: Applicative f => f (a -> b) -> f a -> f b
-}
-- E.g.         maybeInc <*> Just 4 == Just 5
-- i.e.   (+) <$> Just 1 <*> Just 4 == Just 5
-- QC2803
val1 = Just 10

val2 = Just 5

e1 = (*) <$> val1 <*> val2 -- == Just 50

e2 = div <$> val1 <*> val2 -- == Just 2

e3 = mod <$> val1 <*> val2 -- == Just 0

--
-- Solution
--
start = Map.lookup "Carcosa" locationDB

dest = Map.lookup "Innsmouth" locationDB

--     partial application
--     vvvvvvvvvvvvvvvvvvv
dist = haversine <$> start <*> dest

--                   ^^^^^^^^^^^^^^
--             allows completion in context
--
--
main :: IO ()
main = do
  putStr "Starting city? "
  startCity <- getLine
  let startLatLong = Map.lookup startCity locationDB
  putStr "Destination city? "
  destCity <- getLine
  let destLatLong = Map.lookup destCity locationDB
  let distance = haversine <$> startLatLong <*> destLatLong
  printDistance distance

--
-- Q2801
haversineIO' :: IO LatLong -> IO LatLong -> IO Double
haversineIO' val1 val2 = do
  v1 <- val1
  v2 <- val2
  let result = haversine v1 v2
  return result

--
-- Q2802
haversineIO :: IO LatLong -> IO LatLong -> IO Double
haversineIO val1 val2 = haversine <$> val1 <*> val2