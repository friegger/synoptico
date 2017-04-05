module Tests exposing (..)

import Test exposing (..)
import Expect
import String
import App
import Material
import Html.Attributes
import Html
import Json.Decode exposing (decodeString)
import List


all : Test
all =
    describe "Synoptico"
        [ test "returns Ok ScreenPosition" <|
            \() ->
                App.init
                    |> Expect.equal
                        ( { synopticoSet = Nothing
                          , mdl = Material.model
                          }
                        , Cmd.none
                        )
        , describe "shift"
            [ describe "given an empty list"
                [ test "returns an empty list" <|
                    \() -> App.shift [] |> Expect.equal []
                ]
            , describe "given a list with a single item"
                [ test "returns the list" <|
                    \() -> App.shift [ 1 ] |> Expect.equal [ 1 ]
                ]
            , describe "given a list with 3 elements"
                [ test "returns a list where the first element has been appended" <|
                    \() -> App.shift [ 1, 2, 3 ] |> Expect.equal [ 2, 3, 1 ]
                ]
            ]
        ]
