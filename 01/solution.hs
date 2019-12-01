neededFuel :: Integer -> Integer
neededFuel = (subtract 2) . (`div` 3)

solve1 :: IO Integer
solve1 = do
    text <- readFile "./input.txt"
    pure $ sum $ map (neededFuel . read) (lines text)


neededFuel' :: Integer -> Integer
neededFuel' mass
    | requiredFuel > 0 = requiredFuel + neededFuel' requiredFuel
    | otherwise = 0
    where requiredFuel = max 0 $ neededFuel mass

solve2 :: IO Integer
solve2 = do
    text <- readFile "./input.txt"
    pure $ sum $ map (neededFuel' . read) (lines text)
