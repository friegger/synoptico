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
        , describe "rotateUrlOf"
            [ test "rotates the url of the webview with the given index within the given set" <|
                \() ->
                    let
                        createSet urlsOfWebViewWithIndex1 =
                            Just <|
                                App.SynopticoSet
                                    [ App.WebView [ "url1", "url2", "url3" ] dummyScreenPosition (Just 60)
                                    , App.WebView urlsOfWebViewWithIndex1 dummyScreenPosition (Just 60)
                                    ]
                                    "test-set"

                        set =
                            createSet [ "url4", "url5", "url6" ]

                        expectedSet =
                            createSet [ "url5", "url6", "url4" ]
                    in
                        App.rotateUrlOf set 1 |> Expect.equal expectedSet
            ]
        ]


dummyScreenPosition =
    App.ScreenPosition "" "" "" "" ""
