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
        ]
