module Tests exposing (..)

import Test exposing (..)
import Expect
import String
import App
import Html.Attributes
import Html
import Json.Decode exposing (decodeString)
import List


suite : Test
suite =
    describe "Synoptico"
        [ test "returns Ok ScreenPosition" <|
            \() ->
                App.init
                    |> Expect.equal
                        ( { synopticoSet = Nothing }
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
        , describe "synopticoSetDecoder"
            [ describe "when timer is given"
                [ test "decodes timer to Just <given value>" <|
                    \() ->
                        Expect.equal
                            (Json.Decode.decodeString
                                App.synopticoSetDecoder
                                """
                                    {
                                      "webviews": [{
                                          "urls": ["https://domain.com", "https://domain.com"],
                                          "position": {"top":"0%","left":"0%","height":"100%","width":"100%","zIndex":"1"},
                                          "timer": 5
                                      }],
                                      "name": "SynopticoSet"
                                    }
                                """
                            )
                            (Ok
                                (App.SynopticoSet
                                    [ App.WebView
                                        [ "https://domain.com", "https://domain.com" ]
                                        (App.ScreenPosition "0%" "0%" "100%" "100%" "1")
                                        (Just 5)
                                    ]
                                    "SynopticoSet"
                                )
                            )
                ]
            , describe "when timer is null"
                [ test "decodes timer to Nothing" <|
                    \() ->
                        Expect.equal
                            (Json.Decode.decodeString
                                App.synopticoSetDecoder
                                """
                                     {
                                         "webviews": [{
                                             "urls": ["https://domain.com"],
                                             "position": {"top":"0%","left":"0%","height":"100%","width":"100%","zIndex":"1"},
                                             "timer": null
                                         }],
                                         "name": "SynopticoSet"
                                     }
                                """
                            )
                            (Ok
                                (App.SynopticoSet
                                    [ App.WebView
                                        [ "https://domain.com" ]
                                        (App.ScreenPosition "0%" "0%" "100%" "100%" "1")
                                        Nothing
                                    ]
                                    "SynopticoSet"
                                )
                            )
                ]
            , describe "when timer is not given"
                [ test "decodes timer to Nothing" <|
                    \() ->
                        Expect.equal
                            (Json.Decode.decodeString
                                App.synopticoSetDecoder
                                """
                                     {
                                         "webviews": [{
                                             "urls": ["https://domain.com"],
                                             "position": {"top":"0%","left":"0%","height":"100%","width":"100%","zIndex":"1"}
                                         }],
                                         "name": "SynopticoSet"
                                     }
                                """
                            )
                            (Ok
                                (App.SynopticoSet
                                    [ App.WebView
                                        [ "https://domain.com" ]
                                        (App.ScreenPosition "0%" "0%" "100%" "100%" "1")
                                        Nothing
                                    ]
                                    "SynopticoSet"
                                )
                            )
                ]
            ]
        ]


dummyScreenPosition =
    App.ScreenPosition "" "" "" "" ""
