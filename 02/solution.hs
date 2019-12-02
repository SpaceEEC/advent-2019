import qualified Data.Map.Strict as Map
import Data.List

replaceComma :: Char -> Char
replaceComma c
    | c == ',' = ' '
    | otherwise = c

getMemoryMap :: String -> Map.Map Integer Integer
getMemoryMap input = do
    let values = map read $ words $ map replaceComma input

    let doFold (index, memory) element = (index + 1, Map.insert index element memory)

    snd $ foldl doFold (0, Map.empty) values

solve1 :: IO Integer
solve1 = do
    input <- readFile "./input.txt"
    let memory = getMemoryMap input
    pure $ doSolve memory (memory Map.! 0) 0

doSolve :: Map.Map Integer Integer -> Integer -> Integer -> Integer
doSolve memory 99 _ = memory Map.! 0

doSolve memory opcode index = do
    let op1 = memory Map.! (memory Map.! (index + 1))
    let op2 = memory Map.! (memory Map.! (index + 2))
    
    let result = case opcode of
            1 ->
                op1 + op2
            2 ->
                op1 * op2
            _ ->
                error $ "Index " ++ show index ++ " Opcode " ++ show opcode ++ " Memory " ++ show memory

    let memory2 = Map.insert (memory Map.! (index + 3)) result memory

    doSolve memory2 (memory2 Map.! (index + 4)) (index + 4)


solve2 :: IO (Maybe (Integer, Integer))
solve2 = do
    input <- readFile "./input.txt"
    let memory = getMemoryMap input
    let pairs = [(noun, verb) | noun <- [0..99], verb <- [0..99]]

    pure $ find ((19690720==) . (testPair memory)) pairs

testPair :: Map.Map Integer Integer -> (Integer, Integer) -> Integer
testPair memory (noun, verb) = do
    let memory2 = Map.insert 1 noun $ Map.insert 2 verb memory

    doSolve memory2 (memory2 Map.! 0) 0