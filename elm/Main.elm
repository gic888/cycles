import Html exposing (Html, button, div, text)
import Html.Events exposing (onClick)
import Set
import Dict
import Time exposing (Time, now)
import Maybe exposing (..)
import Task


main =
  Html.program { 
      init = init, 
      view = view, 
      update = update,
      subscriptions = always Sub.none }


-- DATA

smallGraph = """
0 4 10 19
1 0 6 9
2
3 4 11 19
4 1
5 1 4 12
6 14
7 3 8 13 19
8 1
9
10 14 18
11 12
12 5 16
13
14 16
15 10 11
16 0 17
17 3
18 3 8 12
19 1 2 5 8 9 17 18
"""

largeGraph = """
0 33
1 2 18 25
2 3 4 17 27
3 12 20 25
4 28 30
5 1 11 31
6 9 17 26 30 34
7 5 19
8 2 4 9 17
9 5 14 15 24 27 33 34
10 12 14 18 30 34
11 1 2 13 16 32
12 3 26 27 28 32
13 8 25 28
14 22
15 8 14 24 31
16 17 18 29
17 9 16 22 33 34
18 3 9 14 16 22 26
19 3 7 16
20 5 14 16 33
21 11
22
23 0 5 31
24 26 34
25 7 20
26 6 10 13 15 28
27 15 16 21
28 11 27 33
29 2 3
30 6 18 23
31 10 11 12 33
32 3 4 5 14 30
33 32
34 13 17 22
"""


-- COMPUTATION
type alias Vid = String
type alias Graph = Dict.Dict Vid (List String)
type alias Path = {
    start: String,
    stop: String,
    path: Set.Set Vid,
    graph: Graph
}

readGraph : String -> Graph
readGraph s = Dict.empty


countCycles : Graph -> Int
countCycles g = Dict.size g

-- MODEL

type alias Model = {
    startTime: Maybe Time,
    data: String,
    cycles: Maybe Int,
    report: String
}

init : (Model, Cmd Msg)
init = ({
    startTime = Nothing,
    data = "",
    cycles = Nothing,
    report = "No computation active"
    },
    Cmd.none)


timeDelay : Maybe Time -> Time -> String
timeDelay ms me = case ms of
    Nothing -> "[not started]"
    Just s -> toString (me - s)    

finalReport : Model -> Time -> String
finalReport {startTime, data, cycles, report } stopTime = 
    "Counted " ++ (toString cycles) ++ " cycles in " ++ (timeDelay startTime stopTime)  ++ "ms"


-- UPDATE

type Msg = SetData String | Start Time | Compute String | Finish Time

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    SetData s ->
        ({model | data = s, report = "starting job"}, Task.perform Start Time.now)
    Start t ->  
        ({model | startTime = Just t, report = "Job started at " ++ (toString t)}, Task.perform  Compute (Task.succeed model.data))
    Compute s -> 
        ({model | cycles = Just (countCycles (readGraph s))}, Task.perform Finish Time.now)
    Finish t ->
        ({model | data = "", report = (finalReport model t)}, Cmd.none)



-- VIEW

view : Model -> Html Msg
view model =
  div []
    [ 
    div [] [ text model.report ]
    , button [ onClick (SetData smallGraph) ] [ text "20" ]
    , button [ onClick (SetData largeGraph) ] [ text "35" ]
    ]